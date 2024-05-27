#include "postfx_common.h"

#if TOOLSGFX

SamplerState bilinearClampler : register(s0);
Texture2D<float4> sceneTexture : register(t0);

#else

SamplerState bilinearClampler : register(s1);
Texture2D<float4> sceneTexture : register(t0);

#endif

float2 focalOffset;
float2 radius;
float3 colorOffsets;

struct VertexInput
{
	float3 position : POSITION;
	float2 texCoords : TEXCOORD0;
};

struct PixelInput
{
	float4 position : SV_POSITION;
	float2 texCoords : TEXCOORD0;
#if TOOLSGFX
	float1 fakeInput : TEXCOORD1;
#endif
};

PixelInput vs_main(const VertexInput vertex, const uint instance : INSTANCE_SEMANTIC)
{
	PixelInput pixel;
	
	PostFx_GenerateFullscreenQuad(vertex.position, vertex.texCoords, instance, pixel.position, pixel.texCoords);
	
#if TOOLSGFX
	// We need to have the vertex inputs used in this shader otherwise it won't compile
	pixel.fakeInput.x = vertex.position.x;
#endif
	
	return pixel;
}

float4 ps_main(const PixelInput pixel) : SV_TARGET
{
	float2 texCoords = pixel.texCoords;

	PostFx_FixPreviewResolution(pixel.position.xy, texCoords);

	float2 pos = pixel.texCoords - 0.5;
	pos -= focalOffset;
	pos *= radius;
	pos += 0.5f;
	
	float2 direction = pos - 0.5;
	
	float r = sceneTexture.Sample(bilinearClampler, texCoords.xy + (direction * colorOffsets.r)).r;
	float g = sceneTexture.Sample(bilinearClampler, texCoords.xy + (direction * colorOffsets.g)).g;
	float b = sceneTexture.Sample(bilinearClampler, texCoords.xy + (direction * colorOffsets.b)).b;
	float a = 1;
	
	#if TOOLSGFX
	return float4(LinearToSRGB(float3(r, g, b)), a);
	#else
	return float4(r, g, b, a);
	#endif
}