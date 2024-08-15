#include "lib/globals.hlsl"
#include "lib/vertdecl_vertex.hlsl"
#include "lib/vertdecl_vertex_tangentspace.hlsl"
#include "lib/gpu_skin.hlsl"
#include "lib/gbuffer.hlsl"

SamplerState colorSampler;
SamplerState normalSampler;
SamplerState specColorSampler;
SamplerState aoSampler;

Texture2D<float4> colorMap;
Texture2D<float3> normalMap;
Texture2D<float3> specColorMap;
Texture2D<float> glossMap;
Texture2D<float> aoMap;

Texture2D<float> heightMap;

float3 colorTint;
float baseNormalHeight;
float2 glossRange;

float heightScale = 1.0f;
float minLayers;
float maxLayers;
bool clampUVs;

struct GBufferPOMPixelInput
{
	float4 position		: SV_POSITION;
	float  color		: COLOR1;
	float2 texCoords	: TEXCOORD0;
	float3 normal		: TEXCOORD1;
	float3 tangent		: TEXCOORD2;
	float3 biTangent	: TEXCOORD3;
	float3 viewDirWorld	: TEXCOORD4;
	float3 viewDirTan	: TEXCOORD5;
	uint instance 		: TEXCOORD6;

	#if GENERATE_MOTION_VECTOR
	float4 motionVector : TEXCOORD7;
	#endif
};

GBufferPOMPixelInput vs_main(const GBufferVertexInput vertex, const uint instance : INSTANCE_SEMANTIC)
{
	GBufferPOMPixelInput pixel;
	
	float3 position = vertex.position;
	float3 normal = Vertex_DecodeNormal(vertex.normal);
	float3 tangent = Vertex_DecodeNormal(vertex.tangent.xyz);

	#if GENERATE_MOTION_VECTOR

	pixel.motionVector = Transform_GenerateMotionVector(position, vertex.weights, vertex.indices, instance);

	#endif

	GPUSkin_SkinVertex(position, normal, tangent, vertex.weights, vertex.indices, instance);
	
	position = Transform_PositionToWorld(position, instance);
	normal = Transform_NormalToWorld(normal, instance);
	tangent = Transform_NormalToWorld(tangent, instance);
	
	pixel.position = Transform_OffsetToClip(position);
	pixel.texCoords = vertex.texCoords;
	pixel.color = vertex.color.a;
	pixel.normal = normalize(normal);
	pixel.tangent = normalize(tangent);
	pixel.biTangent = Vertex_CalculateBiNormal(pixel.normal, pixel.tangent, Vertex_DecodeBiNormalSign(vertex.tangent.w));
	pixel.instance = instance;

    float3x3 mWorldToTangent = float3x3( pixel.tangent, pixel.biTangent, pixel.normal );

    pixel.viewDirWorld = Transform_GetViewDirection(position);
    pixel.viewDirTan = mul(mWorldToTangent, pixel.viewDirWorld);

	return pixel;
}

// https://www.gamedev.net/tutorials/programming/graphics/a-closer-look-at-parallax-occlusion-mapping-r3262/

float2 ParallaxMapping(float2 texCoords, float3 normal, float3 wsViewDirection, float3 tsViewDirection)
{ 
	float fParallaxLimit = -length( tsViewDirection.xy ) / tsViewDirection.z;

	fParallaxLimit *= heightScale;

	float2 vOffsetDir = normalize( tsViewDirection.xy );
	float2 vMaxOffset = vOffsetDir * fParallaxLimit;

	int nNumSamples = (int)lerp( maxLayers, minLayers, abs(dot( wsViewDirection, normal )) );
	float fStepSize = 1.0 / (float)nNumSamples;

	float2 dx = ddx( texCoords );
	float2 dy = ddy( texCoords );
	float fCurrRayHeight = 1.0;
	float2 vCurrOffset = float2( 0, 0 );
	float2 vLastOffset = float2( 0, 0 );
	float fLastSampledHeight = 1;
	float fCurrSampledHeight = 1;
	int nCurrSample = 0; 

	while ( nCurrSample < nNumSamples )
	{
		fCurrSampledHeight = heightMap.SampleGrad( colorSampler, texCoords + vCurrOffset, dx, dy );
		if ( fCurrSampledHeight > fCurrRayHeight )
		{
			float delta1 = fCurrSampledHeight - fCurrRayHeight;
			float delta2 = ( fCurrRayHeight + fStepSize ) - fLastSampledHeight;
			float ratio = delta1/(delta1+delta2);
			vCurrOffset = (ratio) * vLastOffset + (1.0-ratio) * vCurrOffset;
			nCurrSample = nNumSamples + 1;
		} 
		else 
		{
			nCurrSample++;
			fCurrRayHeight -= fStepSize;
			vLastOffset = vCurrOffset;
			vCurrOffset += fStepSize * vMaxOffset;
			fLastSampledHeight = fCurrSampledHeight; 
		} 
	}

	return texCoords + vCurrOffset;
}

// The output of the pixel shader will be used in a compute shader that handles lighting, reflections etc.
GBufferPixelOutput ps_main(const GBufferPOMPixelInput pixel, const uint isFrontFace : SV_IsFrontFace)
{
	GBufferPixelOutput output;

    float2 texCoords = ParallaxMapping(pixel.texCoords, normalize(pixel.normal), normalize(pixel.viewDirWorld), normalize(pixel.viewDirTan));

    if(clampUVs && (texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0))
        discard;

	float4 diffuse = colorMap.Sample(colorSampler, texCoords);
	diffuse.rgb *= lerp(1.0, colorTint, diffuse.a);
	diffuse.a = 1.0;

	float4 normal = GBuffer_DecodeNormal(normalMap.Sample(normalSampler, texCoords), baseNormalHeight);
	float gloss = glossMap.Sample(specColorSampler, texCoords);

	float3 specular = specColorMap.Sample(specColorSampler, texCoords);
	float occlusion = aoMap.Sample(aoSampler, texCoords);
	
	float4 albedo = diffuse;
	float4 normalGloss = GBuffer_CalculateNormalGloss(pixel.normal, pixel.tangent, pixel.biTangent, isFrontFace, normal, gloss, glossRange);
	float4 reflectanceOcclusion = GBuffer_CalculateReflectanceOcclusion(pixel.position.xy, isFrontFace, albedo, specular, 1.0, occlusion, true, true);
	
	output.Albedo = albedo;
	output.NormalGloss = normalGloss;
	output.ReflectanceOcclusion = reflectanceOcclusion;

	#if GENERATE_MOTION_VECTOR

	output.Velocity = MotionVector_CalculateVelocity(pixel.position.xy, pixel.motionVector);

	#endif
	
	return output;
}