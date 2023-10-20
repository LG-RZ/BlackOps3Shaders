#include "globals.hlsl"
#include "transform.hlsl"
#include "gpu_skin.hlsl"

Texture2D<float4> colorMap : register(t0);
SamplerState colorSampler : register(s0);

struct VertexInput
{
	float3 position		: POSITION;
	float4 color		: COLOR;
	float2 texCoords	: TEXCOORD;
	float3 normal		: NORMAL;
	float4 weights		: BLENDWEIGHT;
	uint4 indices		: BLENDINDICES;
};

struct PixelInput
{
	float4 position		: SV_POSITION;
	float4 color		: COLOR;
	float2 texCoords	: TEXCOORD;
};

PixelInput vs_main(in VertexInput vertex, in uint instance : INSTANCE_SEMANTIC)
{
	PixelInput pixel;
	
	float3 pos = vertex.position;
	float3 normal = vertex.normal;
	float3 tan = 0;
	float3 color = vertex.color.xyz;
	
	skin(pos, normal, tan, vertex.weights, vertex.indices, instance);
	
	pos = transform_offset_to_camera(transform_position_to_world(pos, instance));
	normal = transform_normal_to_world(normal, instance);
	tan = transform_normal_to_world(tan, instance);

	switch (gScene.lightingMode)
	{
		case 1:
			color = (dot(abs(normal), float3(0.6, 0.8, 1.0)) / dot(abs(normal), float3(1.0, 1.0, 1.0))) * vertex.color.xyz;
			break;
		case 2:
			color = min(abs(dot(normalize(transform_offset_to_camera(normal)), normalize(pos))) + 0.1, 1) * vertex.color.xyz;
			break;
	}
	
	pixel.position = transform_camera_to_clip(pos);
	pixel.color = float4(color, vertex.color.w);
	pixel.texCoords = vertex.texCoords;
	
	return pixel;
}

float4 ps_main(in PixelInput pixel) : SV_TARGET
{
	float4 color = colorMap.Sample(colorSampler, pixel.texCoords);
	
	color = float4(pow(color.xyz, 0.454545), color.w) * pixel.color;
	
	#if USE_COLOR_TINT

	color.xyz *= lerp(1, colorTint.xyz, color.w);
	
	#endif
	
	return color;
}