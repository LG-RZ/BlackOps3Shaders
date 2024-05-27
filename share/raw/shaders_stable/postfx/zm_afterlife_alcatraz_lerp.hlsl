#include "postfx_common.h"

float waveWarpScale;
float scrollSpeed;
float2 maskRadius;
float2 vignetteRadius;
float maskSoftness;
float vignetteSoftness;
float3 vignetteColor;
float boost;

#if TOOLSGFX

SamplerState bilinearClampler : register(s0);
SamplerState bilinearSampler : register(s1);
Texture2D<float4> sceneTexture : register(t0);
Texture2D<float4> maskMap : register(t1);
Texture2D<float4> noiseMap : register(t2);

#else

SamplerState bilinearClampler : register(s1);
SamplerState bilinearSampler : register(s2);
Texture2D<float4> sceneTexture : register(t0);
Texture2D<float4> maskMap : register(t1);
Texture2D<float4> noiseMap : register(t2);

#endif

struct VertexInput
{
	float3 position : POSITION;
	float2 texCoords : TEXCOORD0;
};

struct PixelInput
{
	float4 position : SV_Position;
	float2 texCoords : TEXCOORD0;
#if TOOLSGFX
	float1 fakeInput : TEXCOORD3;
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

void Afterlife_CalculateTexCoords(in float2 texCoords, out float3 texCoords1, out float3 texCoords2)
{
	float4 r0, r1, r2, r3;
	r0.x = GetTime() * scrollSpeed;
	r0.yz = r0.x * float2(0.5, 0.2274);
	r0.x = r0.x * 0.5 + 0.5;
	r0.y = frac(r0.y);
	sincos(r0.z, r1.x, r2.x);
	r0.z = r0.y * -0.3 + 0.5;
	r0.y = r0.y * 2 - 1;
	r0.y = abs(r0.y) + abs(r0.y);
	r3.z = r1.x;
	r3.y = r2.x;
	r3.x = -r1.x;
	r1.xy = texCoords.xy - 0.5;
	r2.x = dot(r3.yz, r1.xy);
	r2.y = dot(r3.xy, r1.xy);
	texCoords1.xy = r2.xy * r0.z + 0.5;
	r0.z = frac(r0.x);
	r0.x = r0.x * -0.4547;
	sincos(r0.x, r0.x, r2.x);
	r0.w = r0.z * 2 - 1;
	r0.z = r0.z * -0.3 + 0.5;
	r0.w = abs(r0.w) + abs(r0.w);
	r0.yw = min(r0.yw, 1.0);
	r1.z = r0.w * -2 + 3;
	r0.w = r0.w * r0.w;
	texCoords1.z = r0.w * r1.z;
	r3.z = r0.x;
	r3.y = r2.x;
	r3.x = -r0.x;
	r2.y = dot(r3.xy, r1.xy);
	r2.x = dot(r3.yz, r1.xy);
	texCoords2.xy = r2.xy * r0.z + 0.5;
	r0.x = r0.y * -2 + 3;
	r0.y = r0.y * r0.y;
	texCoords2.z = r0.y * r0.x;
}

float4 ps_main(in PixelInput pixel) : SV_TARGET
{
	float2 texCoords = pixel.texCoords;

	PostFx_FixPreviewResolution(pixel.position.xy, texCoords);

	float3 maskTexCoords1;
	float3 maskTexCoords2;

	Afterlife_CalculateTexCoords(texCoords, maskTexCoords1, maskTexCoords2);

	float4 r0, r1;
	r0.xyzw = maskMap.Sample(bilinearSampler, maskTexCoords1.xy);
	r0.x = r0.x * maskTexCoords1.z;
	r0.x = max(r0.x, 0);
	r1.xyzw = maskMap.Sample(bilinearSampler, maskTexCoords2.xy);
	r0.y = r1.x * maskTexCoords2.z;
	r0.x = max(r0.x, r0.y);
	r0.x = r0.x * boost;
	r0.yz = pixel.texCoords.xy * 8;
	r1.xyzw = noiseMap.Sample(bilinearSampler, r0.yz);
	r0.x = r0.x * r1.x;
	r0.yz = texCoords.xy;
	r0.yz = r0.yz * 2 - 1;
	r0.y = dot(r0.yz, r0.yz);
	r0.y = sqrt(r0.y);
	r0.z = r0.y * 0.7072 - vignetteRadius.x;
	r0.y = r0.y * 0.7072 - maskRadius.x;
	r0.w = vignetteRadius.y - vignetteRadius.x;
	r0.w = 1 / r0.w;
	r0.z = saturate(r0.w * r0.z);
	r0.w = r0.z * -2 + 3;
	r0.z = r0.z * r0.z;
	r0.z = r0.z * r0.w;
	r0.z = log2(r0.z);
	r0.z = r0.z * vignetteSoftness;
	r0.z = exp2(r0.z);
	r0.x = r0.x * r0.z;

	float blendFactor = r0.x;

	#if TOOLSGFX
	r1.xyz = r0.x * LinearToSRGB(vignetteColor.xyz);
	#else
	r1.xyz = r0.x * vignetteColor.xyz;
	#endif
	r0.x = maskRadius.y - maskRadius.x;
	r0.x = 1 / r0.x;
	r0.x = saturate(r0.x * r0.y);
	r0.y = r0.x * -2 + 3;
	r0.x = r0.x * r0.x;
	r0.x = r0.x * r0.y;
	r0.x = log2(r0.x);
	r0.x = r0.x * maskSoftness;
	r0.x = exp2(r0.x);
	r0.x = 1 - r0.x;
	r0.x = r0.x * waveWarpScale + 1;
	r0.yz = texCoords.xy - 0.5;
	r0.xy = r0.yz / r0.x;
	r0.xy = r0.xy + 0.5;
	r0.xyzw = sceneTexture.Sample(bilinearClampler, r0.xy);
	r1.w = 0;
	
	r0.xyz = PostFx_NormalizeColor(r0.xyz);

	#if USE_T6_VISIONSET
	r0.xyzw = PostFx_ApplyVisionToScene(r0.xyzw);
	#endif

	#if TOOLSGFX
	r0.xyz = LinearToSRGB(r0.xyz);
	#endif

	r0.xyz = PostFx_DenormalizeColor(r0.xyz);
	r1.xyz = PostFx_DenormalizeColor(r1.xyz);
	
	return float4(lerp(r0.xyz, r1.xyz, saturate(blendFactor)), 1);
}