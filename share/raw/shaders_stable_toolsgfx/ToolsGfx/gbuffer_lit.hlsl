#include "gbuffer_common.hlsl"

GBufferPixelInput vs_main(const GBufferVertexInput vertex, const uint instance : INSTANCE_SEMANTIC)
{
	GBufferPixelInput pixel;
	
	float3 position = vertex.position;
	float3 normal = decode_normal(vertex.normal);
	float3 tangent = decode_normal(vertex.tangent.xyz);
	
	skin(position, normal, tangent, vertex.weights, vertex.indices, instance);
	
	position = transform_position_to_world(position, instance);
	normal = transform_normal_to_world(normal, instance);
	tangent = transform_normal_to_world(normal, instance);
	
	pixel.position = transform_offset_to_clip(position);
	pixel.texCoords = vertex.texCoords;
	pixel.color = vertex.color.a;
	pixel.normal = normalize(normal);
	pixel.tangent = normalize(tangent);
	pixel.biTangent = get_vertex_binormal(pixel.normal, pixel.tangent, decode_binormal_sign(vertex.tangent.w));

	return pixel;
}

// The output of the pixel shader will be used in a compute shader that handles lighting, reflections etc.
GBufferPixelOutput ps_main(const GBufferPixelInput pixel, const uint isFrontFace : SV_IsFrontFace)
{
	GBufferPixelOutput output;
	
	float4 albedo = gbuffer_calculate_albedo(pixel, isFrontFace);
	float4 normalGloss = gbuffer_calculate_normal_gloss(pixel, isFrontFace);
	float4 reflectanceOcclusion = gbuffer_calculate_reflectance_occlusion(pixel, isFrontFace, output.albedo);
	
	output.albedo = albedo;
	output.normalGloss = normalGloss;
	output.reflectanceOcclusion = reflectanceOcclusion;
	
	return output;
}