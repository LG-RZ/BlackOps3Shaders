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

// Credits: https://gist.github.com/ompuco/3209f1b32213cec5b7bccf0e67caf3e9

static const float4x4 psx_dither_table = float4x4
(
    0,    8,    2,    10,
    12,    4,    14,    6, 
    3,    11,    1,    9, 
    15,    7,    13,    5
);

bool usePSXColorPrecision;

float4 ps_main(const PixelInput pixel) : SV_TARGET
{
	float2 texCoords = pixel.texCoords;

	PostFx_FixPreviewResolution(pixel.position.xy, texCoords);

    float3 color = PostFx_NormalizeColor(sceneTexture.Sample(bilinearClampler, texCoords));

	int dither = psx_dither_table[((int)pixel.position.x) % 4][((int)pixel.position.y) % 4];

	color *= 255.0;
  	color += (dither / 2.0 - 4.0);

	if(usePSXColorPrecision)
  		color = lerp((uint3(color) & 0xf8), 0xf8, step(0xf8,color)); 
		
	color /= 255;

	#if TOOLSGFX

	color = LinearToSRGB(color);

	#endif

    return float4(PostFx_DenormalizeColor(color), 1.0);
}