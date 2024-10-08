#include "postfx_common.h"

float waveWarpScale;
float boost;
float falloff;
float sceneBlurAmount;

#if TOOLSGFX

SamplerState bilinearClampler : register(s0);
SamplerState bilinearSampler : register(s1);
Texture2D<float4> sceneTexture : register(t0);
Texture2D<float4> distortionMap : register(t1);
Texture2D<float4> warpMap : register(t2);

#else

SamplerState bilinearClampler : register(s1);
SamplerState bilinearSampler : register(s2);
Texture2D<float4> sceneTexture : register(t0);
Texture2D<float4> distortionMap : register(t1);
Texture2D<float4> warpMap : register(t2);

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

float4 ps_main(const PixelInput pixel) : SV_TARGET
{
	float2 texCoords = pixel.texCoords;

	PostFx_FixPreviewResolution(pixel.position.xy, texCoords);

	float4 r0, r1, r2, r3, r4;
	r0.x = GetTime() * 0.175000;
	r0.y = frac(r0.x);
	r0.x = floor(r0.x);
	r0.x = r0.x * 146.978592;
	sincos(r0.x, r0.x, r1.x);
	r0.z = r0.y * -2.680593 + 2.520593;
	r0.y = r0.y * 2 + -1;
	r0.y = abs(r0.y) + abs(r0.y);
	r2.z = r0.x;
	r2.y = r1.x;
	r2.x = -r0.x;
	r0.xw = texCoords.xy - 0.5;
	r1.x = dot(r2.yz, r0.xw);
	r1.y = dot(r2.xy, r0.xw);
	r1.xy = r1.xy * r0.z + 0.5;
	r1.zw = texCoords;
	r2.xyzw = distortionMap.Sample(bilinearSampler, r1.zw);
	r1.zw = r2.xy * 4.015748 - 2.015748;
	r1.xy = waveWarpScale.x * r1.zw + r1.xy;
	r2.xyzw = warpMap.Sample(bilinearSampler, r1.xy);
	r0.z = GetTime() * 0.175 + 0.5;
	r1.x = frac(r0.z);
	r0.z = floor(r0.z);
	r0.z = r0.z * 293.957184;
	sincos(r0.z, r3.x, r4.x);
	r0.z = r1.x * 2.000000 + -1.000000;
	r1.x = r1.x * -2.680593 + 2.520593;
	r0.z = abs(r0.z) + abs(r0.z);
	r0.yz = min(r0.yz, 1);
	r1.y = r0.z * -2.000000 + 3.000000;
	r0.z = r0.z * r0.z;
	r0.z = r0.z * r1.y;
	r0.z = r0.z * r2.x;
	r0.z = max(r0.z, 0.000000);
	r2.z = r3.x;
	r2.y = r4.x;
	r2.x = -r3.x;
	r3.y = dot(r2.xy, r0.xw);
	r3.x = dot(r2.yz, r0.xw);
	r0.xw = r3.xy * r1.x + 0.5;
	r0.xw = waveWarpScale.x * r1.zw + r0.xw;
	r1.xyzw = warpMap.Sample(bilinearSampler, r0.xw);
	r0.x = r0.y * -2.000000 + 3.000000;
	r0.y = r0.y * r0.y;
	r0.x = r0.y * r0.x;
	r0.x = r0.x * r1.x;
	r0.x = max(r0.z, r0.x);
	r1.xyzw = sceneTexture.Sample(bilinearClampler, texCoords).xyzw;
	r1.xyz = PostFx_NormalizeColor(r1.xyz);
	#if USE_T6_VISIONSET
	r1.xyzw = PostFx_ApplyVisionToScene(r1.xyzw);
	#endif
	r1.xyzw = LinearToSRGB(r1.xyzw);
	r0.y = dot(r1.xyz, float3(0.300000, 0.590000, 0.110000));
	r0.y = log2(r0.y);
	r0.xy = r0.xy * float2(sceneBlurAmount, falloff);
	r0.y = exp2(r0.y);
	r0.y = r0.y * boost.x;
	r0.x = r0.x * r0.y;
	r0.x = r0.x * 0.01;
	r1.xyzw = -texCoords.xyxy + 0.5;
	r0.y = dot(r1.zw, r1.zw);
	r0.y = rsqrt(r0.y);
	r2.xyzw = r1.zwzw * r0.y + float4(0.156234, 0.300659, -0.673996, -0.141340);
	r1.xyzw = r1.xyzw * r0.y + float4(0.333068, -0.542503, 0.977288, 0.211027);
	r1.xyzw = r1.xyzw * r0.x + texCoords.xyxy;
	r0.xyzw = r2.xyzw * r0.x + texCoords.xyxy;
	r2.xyzw = sceneTexture.Sample(bilinearClampler, r0.xy);
	r0.xyzw = sceneTexture.Sample(bilinearClampler, r0.zw);
	r0.xyzw = r0.xyzw + r2.xyzw;
	r2.xyzw = sceneTexture.Sample(bilinearClampler, r1.xy);
	r1.xyzw = sceneTexture.Sample(bilinearClampler, r1.zw);
	r0.xyzw = r0.xyzw + r2.xyzw;
	r0.xyzw = r1.xyzw + r0.xyzw;
	r0.xyz = r0.xyz * 0.250000;
	r0.xyz = PostFx_NormalizeColor(r0.xyz);

	#if USE_T6_VISIONSET
	r0.xyz = PostFx_ApplyVisionToScene(r0.xyzw).rgb;
	#endif

	#if TOOLSGFX
	r0.xyz = LinearToSRGB(r0.xyz);
	#endif

	r0.xyz = PostFx_DenormalizeColor(r0.xyz);

	return float4(r0.xyz, 1);
}