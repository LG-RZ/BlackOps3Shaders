#include "lib\globals.hlsl"
#include "lib\transform.hlsl"
#include "lib\gpu_skin.hlsl"
#include "lib\vertdecl_vertex_tangentspace.hlsl"

struct VertexInput
{
	float3 position : POSITION;
	float4 color : COLOR;
	float2 texCoords : TEXCOORD;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float4 weights : BLENDWEIGHT;
	uint4 indices : BLENDINDICES;
};

struct PixelInput
{
	float4 position : SV_Position;
	float color : COLOR1;
};

#if TOOLSGFX

SamplerState bilinearClampler : register(s0);
Texture2D<float4> iResolveScene : register(t49);

#else

SamplerState bilinearClampler : register(s1);
Texture2D<float4> iResolveScene : register(t0);

#endif

PixelInput vs_main(const VertexInput vertex, const uint instance : INSTANCE_SEMANTIC)
{
	PixelInput pixel;
	
	float3 position = vertex.position;
	float3 normal = 0;
	float3 tangent = 0;
	
	skin(position, normal, tangent, vertex.weights, vertex.indices, instance);
	
	position = transform_position_to_world(position, instance);

	pixel.position = transform_offset_to_clip(position);
	pixel.color = vertex.color.a;

	return pixel;
}

float2 focalOffset;
float2 radius;
float3 colorOffsets;

float4 ps_main(const PixelInput pixel) : SV_TARGET
{
	#if !UNLIT_PASS
	
	#if TOOLSGFX
	float2 texCoords = pixel.position.xy * gScene.renderTargetInvSize;
	#else
	float2 texCoords = pixel.position.xy * renderTargetSize.zw;
	#endif
	
	float2 pos = texCoords - 0.5;
	pos -= focalOffset;
	pos *= radius;
	pos += 0.5f;
	
	float2 direction = pos - 0.5;
	
	float r = iResolveScene.Sample(bilinearClampler, texCoords.xy + (direction * colorOffsets.r) * pixel.color).r;
	float g = iResolveScene.Sample(bilinearClampler, texCoords.xy + (direction * colorOffsets.g) * pixel.color).g;
	float b = iResolveScene.Sample(bilinearClampler, texCoords.xy + (direction * colorOffsets.b) * pixel.color).b;
	float a = 1;
	
	float4 rgba = float4(r,g,b,a);
	
	#else
	
	float4 rgba = 1;
	
	#endif
	
	return rgba;
}