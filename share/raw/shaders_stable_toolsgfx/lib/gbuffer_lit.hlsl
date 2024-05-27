#include "gbuffer_common.hlsl"

GBufferPixelInput vs_main(const GBufferVertexInput vertex, const uint instance : INSTANCE_SEMANTIC)
{
	GBufferPixelInput pixel;
	
	float3 position = vertex.position;
	float3 normal = Vertex_DecodeNormal(vertex.normal);
	float3 tangent = Vertex_DecodeNormal(vertex.tangent.xyz);
	
	GPUSkin_SkinVertex(position, normal, tangent, vertex.weights, vertex.indices, instance);
	
	position = Transform_PositionToWorld(position, instance);
	normal = Transform_NormalToWorld(normal, instance);
	tangent = Transform_NormalToWorld(normal, instance);
	
	pixel.position = Transform_OffsetToClip(position);
	pixel.texCoords = vertex.texCoords;
	pixel.color = vertex.color.a;
	pixel.normal = normalize(normal);
	pixel.tangent = normalize(tangent);
	pixel.biTangent = Vertex_CalculateBiNormal(pixel.normal, pixel.tangent, Vertex_DecodeBiNormalSign(vertex.tangent.w));

	return pixel;
}

// The output of the pixel shader will be used in a compute shader that handles lighting, reflections etc.
GBufferPixelOutput ps_main(const GBufferPixelInput pixel, const uint isFrontFace : SV_IsFrontFace)
{
	GBufferPixelOutput output;
	
	float4 albedo = GBuffer_CalculateAlbedo(pixel, isFrontFace);
	float4 normalGloss = GBuffer_CalculateNormalGloss(pixel, isFrontFace);
	float4 reflectanceOcclusion = GBuffer_CalculateReflectanceOcclusion(pixel, isFrontFace, output.Albedo);
	
	output.Albedo = albedo;
	output.NormalGloss = normalGloss;
	output.ReflectanceOcclusion = reflectanceOcclusion;
	
	return output;
}