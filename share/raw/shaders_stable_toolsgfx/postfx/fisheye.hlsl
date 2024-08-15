#include "postfx/postfx_common.h"

float radius;
float density;
float intensity;

bool invertGradient;
bool invertDensity;
bool displayGradient;

#if TOOLSGFX

SamplerState bilinearClampler : register(s0);
Texture2D<float3> sceneTexture : register(t0);

#else

SamplerState bilinearClampler : register(s1);
Texture2D<float3> sceneTexture : register(t0);

#endif

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

float Checkerboard(float2 uv, float2 total)
{
    uv = floor(total * uv);
	return fmod(uv.x + uv.y, 2.);
}

float4 ps_main(const PixelInput pixel) : SV_TARGET
{
	float2 texCoords = pixel.texCoords;

	PostFx_FixPreviewResolution(pixel.position.xy, texCoords);

    float gradient = RadialGradientExponential(texCoords, 0.5, radius, density, invertDensity);

	if(invertGradient)
		gradient = 1.0 - gradient;

    float2 distortedUVs = texCoords - ((texCoords - 0.5) * gradient * intensity);

	#if TOOLSGFX
    if(displayGradient)
    {
		float checker = Checkerboard(distortedUVs, 32);
        return float4(lerp(0.1, 1.0, checker).xxx, 1);
    }
    #endif

	float3 color = sceneTexture.Sample(bilinearClampler, distortedUVs);

	#if TOOLSGFX
	color = LinearToSRGB(color);
	#endif

	return float4(color, 1);
}