#include "lib/globals.hlsl"
#include "lib/vertdecl_vertex.hlsl"
#include "lib/vertdecl_vertex_tangentspace.hlsl"
#include "lib/gpu_skin.hlsl"
#include "lib/gbuffer.hlsl"

SamplerState colorSampler;
SamplerState normalSampler;

Texture2D<float4> colorMap;
Texture2D<float3> normalMap;

float3 colorTint;
float baseNormalHeight;
float2 glossRange;

float warpingStrength = 1.0;

#if USE_VERTEX_SNAP

float snappingPrecision = 1.0;

#endif

struct GBufferPSXPixelInput
{
	float4 position		            		: SV_POSITION;
	float  color		            		: COLOR1;
	float2 texCoords						: TEXCOORD0;
	noperspective float2 warpedTexCoords	: TEXCOORD1;
	float3 normal		            		: TEXCOORD2;
	float3 tangent		            		: TEXCOORD3;
	float3 biTangent	            		: TEXCOORD4;
};

GBufferPSXPixelInput vs_main(const GBufferVertexInput vertex, const uint instance : INSTANCE_SEMANTIC)
{
	GBufferPSXPixelInput pixel;
	
	float3 position = vertex.position;
	float3 normal = Vertex_DecodeNormal(vertex.normal);
	float3 tangent = Vertex_DecodeNormal(vertex.tangent.xyz);

	GPUSkin_SkinVertex(position, normal, tangent, vertex.weights, vertex.indices, instance);
	
	position = Transform_PositionToWorld(position, instance);
	normal = Transform_NormalToWorld(normal, instance);
	tangent = Transform_NormalToWorld(tangent, instance);
	
	pixel.position = Transform_OffsetToClip(position);
	pixel.texCoords = vertex.texCoords;
	pixel.warpedTexCoords = vertex.texCoords;
	pixel.color = vertex.color.a;
	pixel.normal = normalize(normal);
	pixel.tangent = normalize(tangent);
	pixel.biTangent = Vertex_CalculateBiNormal(pixel.normal, pixel.tangent, Vertex_DecodeBiNormalSign(vertex.tangent.w));

    #if USE_VERTEX_SNAP

    float2 snapping = float2(160, 120) * snappingPrecision;

    pixel.position.xyz /= pixel.position.w;
	pixel.position.x = floor(snapping.x * pixel.position.x) / snapping.x;
	pixel.position.y = floor(snapping.y * pixel.position.y) / snapping.y;
	pixel.position.xyz *= pixel.position.w;

    #endif

	return pixel;
}

// The output of the pixel shader will be used in a compute shader that handles lighting, reflections etc.
GBufferPixelOutput ps_main(const GBufferPSXPixelInput pixel, const uint isFrontFace : SV_IsFrontFace)
{
	GBufferPixelOutput output;
	
	float2 texCoords = lerp(pixel.texCoords, pixel.warpedTexCoords, warpingStrength);

	float4 diffuse = colorMap.Sample(colorSampler, texCoords);

    #if USE_ALPHA_TEST

    if(diffuse.a < 0.5)
        discard;

    #endif

	diffuse.rgb *= lerp(1.0, colorTint, diffuse.a);
	diffuse.a = 1.0;

	float4 normal = GBuffer_DecodeNormal(normalMap.Sample(normalSampler, texCoords), baseNormalHeight);

	float4 albedo = diffuse;
	float4 normalGloss = GBuffer_CalculateNormalGloss(pixel.normal, pixel.tangent, pixel.biTangent, isFrontFace, normal, 1.0, glossRange);
	float4 reflectanceOcclusion = GBuffer_CalculateReflectanceOcclusion(pixel.position.xy, isFrontFace, albedo, 0.0, 1.0, 1.0, false, false);
	
	output.Albedo = albedo;
	output.NormalGloss = normalGloss;
	output.ReflectanceOcclusion = reflectanceOcclusion;

	return output;
}