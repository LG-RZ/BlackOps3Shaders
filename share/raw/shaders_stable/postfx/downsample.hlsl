#include "postfx_common.h"

Texture2D<float4> frameBuffer : register(t0);
SamplerState bilinearClampler : register(s1);

float downSamples;

struct VertexInput
{
	float3 position : POSITION;
	float2 texCoords : TEXCOORD0;
};

struct PixelInput
{
	float4 position : SV_POSITION;
	float2 texCoords : TEXCOORD0;
};

PixelInput vs_main(const VertexInput vertex, const uint instance : INSTANCE_SEMANTIC)
{
	PixelInput pixel;
	
	PostFx_GenerateFullscreenQuad(vertex.position, vertex.texCoords, instance, pixel.position, pixel.texCoords);
	
	return pixel;
}

float4 ps_main(const PixelInput pixel) : SV_TARGET
{
    #if UPSAMPLING
    return frameBuffer.Load(int3(pixel.position.xy / (downSamples + 1), 0));
    #else
    return frameBuffer.Load(int3(pixel.position.xy * (downSamples + 1), 0));
    #endif
}