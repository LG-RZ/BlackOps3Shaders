#include "postfx_common.h"

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

#if TOOLSGFX
SamplerState bilinearClampler : register(s0);
#else
SamplerState bilinearClampler : register(s1);
#endif

Texture2D<float3> sceneTexture : register(t0);

float redSteps = 1.0;
float greenSteps = 1.0;
float blueSteps = 1.0;

float brightnessSteps = 2.0;

float4 ps_main(const PixelInput pixel) : SV_TARGET
{
	float2 texCoords = pixel.texCoords;

	PostFx_FixPreviewResolution(pixel.position.xy, texCoords);

    float3 color = PostFx_NormalizeColor(sceneTexture.Sample(bilinearClampler, texCoords));

	color = LinearToSRGB(color);

	if(redSteps > 1.0)
		color.r = floor(color.r * (redSteps - 1.0) + 0.5) / (redSteps - 1.0);
	if(greenSteps > 1.0)
		color.g = floor(color.g * (greenSteps - 1.0) + 0.5) / (greenSteps - 1.0);
	if(blueSteps > 1.0)
		color.b = floor(color.b * (blueSteps - 1.0) + 0.5) / (blueSteps - 1.0);

	float3 hsv = RGB2HSV(color);

	if(brightnessSteps > 1.0)
		hsv.z = floor(hsv.z * (brightnessSteps - 1.0) + 0.5) / (brightnessSteps - 1.0);

	color = HSV2RGB(hsv);
	color = SRGBToLinear(color);

	#if TOOLSGFX
	color = LinearToSRGB(color);
	#endif

    return float4(PostFx_DenormalizeColor(color), 1.0);
}