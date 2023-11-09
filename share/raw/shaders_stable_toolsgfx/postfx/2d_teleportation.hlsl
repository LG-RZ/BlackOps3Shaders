#include "postfx_common.h"

// Globals
float4 flagParams;
float4 colorObjMin;
float4 colorObjMax;
float colorObjMinBaseBlend;
float colorObjMaxBaseBlend;
float2 uvScroll;
float4 detailScale;
float4 detailScale1;
float4 detailScale2;
float4 detailScale3;
float4 alphaRevealParms;
float4 colorDetailScale;
float alphaRevealSoftEdge;
float alphaRevealRamp;
float lightningGlow;
float2 lightningReveal;
float anusSpin;
float anusGlow;
float anusOpacity;
float vagSpin;
float vagGlow;
float vagOpacity;
float wipeGlow;
float warpPixels;
float faceOpacity;
float faceGlow;
float faceAngle;
float faceSpeed;
float sparkleSpeed;
float sparkleGlow;

// Script Controls
float4 scriptControl0;
float4 scriptControl1;
float4 scriptControl2;

// Textures

#if TOOLSGFX

SamplerState trilinearSampler : register(s0);
SamplerState bilinearClampSampler : register(s1);
Texture2D<float4> frameBuffer : register(t0);
Texture2D<float4> lightningTexture : register(t1);
Texture2D<float4> spaceAnusTexture : register(t2);
Texture2D<float4> pantherVagTexture : register(t3);
Texture2D<float4> lookupTexture : register(t4);
Texture2D<float4> faceTexture1 : register(t5);
Texture2D<float4> faceTexture2 : register(t6);
Texture2D<float4> sparkleTexture : register(t7);
Texture2D<float4> spaceTexture : register(t8);

#else

SamplerState trilinearSampler : register(s1);
SamplerState bilinearClampSampler : register(s2);
Texture2D<float4> frameBuffer : register(t0);
Texture2D<float4> lightningTexture : register(t6);
Texture2D<float4> spaceAnusTexture : register(t7);
Texture2D<float4> pantherVagTexture : register(t9);
Texture2D<float4> lookupTexture : register(t10);
Texture2D<float4> faceTexture1 : register(t11);
Texture2D<float4> faceTexture2 : register(t12);
Texture2D<float4> sparkleTexture : register(t14);
Texture2D<float4> spaceTexture : register(t15);

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
	
	postfx_generate_fullscreen_quad(vertex.position, vertex.texCoords, instance, pixel.position, pixel.texCoords);
	
#if TOOLSGFX
	// We need to have the vertex inputs used in this shader otherwise it won't compile
	pixel.fakeInput.x = vertex.position.x;
#endif
	
	return pixel;
}

float4 ps_main(const PixelInput pixel) : SV_TARGET
{
	float4 o0;
	float4 r0, r1, r2, r3, r4, r5, r6, r7, r8, r9;
	bool4 r0_b, r2_b;
	
	r0.xy = float2(-0.5, -0.5) + pixel.texCoords.xy;
	r1.xyzw = lightningTexture.Sample(trilinearSampler, pixel.texCoords.xy).xyzw;
	r0.z = saturate(scriptControl1.y * 0.998000026 + 0.00100000005);
	r0.w = 1 + -r0.z;
	r2.x = saturate(lightningReveal.y);
	r0.z = log2(r0.z);
	r0.z = r2.x * r0.z;
	r0.z = exp2(r0.z);
	r3.x = -r0.z;
	r0.z = log2(r0.w);
	r0.z = r2.x * r0.z;
	r3.y = exp2(r0.z);
	r0.zw = saturate(lightningReveal.xx * r3.xy + r0.ww);
	r1.w = r1.w + -r0.z;
	r0.z = r0.w + -r0.z;
	r0.z = saturate(r1.w / r0.z);
	r2_b.xy = 0 < scriptControl2.zy;
	if (r2_b.x)
	{
		r3.y = postfx_get_time() * sparkleSpeed;
		r3.x = 0;
		r2.xz = pixel.texCoords.xy + r3.xy;
		r3.xyzw = sparkleTexture.Sample(trilinearSampler, r2.xz).xyzw;
	}
	else
	{
		r3.xyzw = 0;
	}
	r2.xz = scriptControl1.zw * anusOpacity;
	r2_b.xz = 0 < r2.xz;
	if (r2_b.x)
	{
		r0.w = postfx_get_time() * anusSpin;
		r1.w = anusSpin * postfx_get_time() + 1;
		r1.w = 0.226892799 * r1.w;
		sincos(r1.w, r2.x, r4.x);
		r4.y = r4.x;
		r4.z = r2.x;
		r5.x = dot(r4.yz, r0.xy);
		r4.x = -r2.x;
		r5.y = dot(r4.xy, r0.xy);
		r2.xw = scriptControl0.x * r0.xy + r5.xy;
		r2.xw = float2(0.5, 0.5) + r2.xw;
		r4.xyzw = spaceAnusTexture.Sample(trilinearSampler, r2.xw).xyzw;
		r0.w = -r0.w * 0.970000029 + 1;
		r0.w = 0.506145477 * r0.w;
		sincos(r0.w, r2.x, r5.x);
		r5.y = r5.x;
		r5.z = r2.x;
		r6.x = dot(r5.yz, r0.xy);
		r5.x = -r2.x;
		r6.y = dot(r5.xy, r0.xy);
		r2.xw = scriptControl0.xx * r0.xy + r6.xy;
		r2.xw = float2(0.5, 0.5) + r2.xw;
		r5.xyzw = spaceAnusTexture.Sample(trilinearSampler, r2.xw).xyzw;
		r4.xyzw = r5.xyzw + r4.xyzw;
	}
	else
	{
		r4.xyzw = 0;
	}
	if (r2_b.z)
	{
		r0.w = vagSpin * postfx_get_time() + 1;
		r0.w = 0.0174532924 * r0.w;
		sincos(r0.w, r2.x, r5.x);
		r5.y = r5.x;
		r5.z = r2.x;
		r6.x = dot(r5.yz, r0.xy);
		r5.x = -r2.x;
		r6.y = dot(r5.xy, r0.xy);
		r2.xz = scriptControl0.y * r0.xy + r6.xy;
		r2.xz = saturate(float2(0.5, 0.5) + r2.xz);
		r5.xyzw = pantherVagTexture.Sample(trilinearSampler, r2.xz).xyzw;
	}
	else
	{
		r5.xyzw = float4(0, 0, 0, 0);
	}
	r0.w = scriptControl2.x * faceOpacity;
	r0_b.w = 0 < r0.w;
	if (r0_b.w)
	{
		r6.xyzw = saturate(pixel.texCoords.xyxy * float4(-2, 1, 2, 1) + float4(1, -0.5, -1, -0.5));
		r2.xz = r6.xz * r6.xz;
		r7.yw = -r6.xz * faceAngle + r6.yw;
		r6.yw = log2(r6.xz);
		r6.yw = float2(0.00999999978, 0.00999999978) * r6.yw;
		r6.yw = exp2(r6.yw);
		r8.yw = r6.yw * float2(-598, -598) + float2(600, 600);
		r7.xz = -postfx_get_time() * faceSpeed + r6.xz;
		r8.xz = float2(5, 5);
		r6.xyzw = r8.xyzw * r7.xyzw;
		r7.xyzw = faceTexture1.Sample(bilinearClampSampler, r6.xy).xyzw;
		r8.w = r7.w * r2.x;
		r8.xyz = r8.www * r7.xyz;
		r6.xyzw = faceTexture2.Sample(bilinearClampSampler, r6.zw).xyzw;
		r7.w = r6.w * r2.z;
		r7.xyz = r6.xyz;
		r9.xyzw = r7.xyzw + -r8.xyzw;
		r7.xyzw = r7.wwww * r9.xyzw + r8.xyzw;
		r0.w = r6.w * r2.z + r7.w;
	}
	else
	{
		r7.xyz = 0;
		r0.w = 0;
	}
	r6.xyzw = float4(0.129999995, 0.0900000036, -0.170000002, 0.0500000007) * postfx_get_time();
	r8.x = 0.930000007;
	r8.y = 0.129999995 * postfx_get_time();
	r1.w = lookupTexture.Sample(trilinearSampler, r8.xy).x;
	r2.x = dot(r6.xyzw, float4(81.2394867, 17.3480244, 37.3498383, 59.3948402));
	r6.x = frac(r2.x);
	r6.yzw = float3(0.0900000036, -0.170000002, 0.0500000007) * postfx_get_time();
	r2.x = dot(r6.xyzw, float4(81.2394867, 17.3480244, 37.3498383, 59.3948402));
	r6.y = frac(r2.x);
	r2.x = dot(r6.xyzw, float4(81.2394867, 17.3480244, 37.3498383, 59.3948402));
	r6.z = frac(r2.x);
	r2.x = dot(r6.xyzw, float4(81.2394867, 17.3480244, 37.3498383, 59.3948402));
	r6.w = frac(r2.x);
	r2.x = dot(r6.xyzw, float4(81.2394867, 17.3480244, 37.3498383, 59.3948402));
	r6.x = frac(r2.x);
	r2.x = dot(r6.xyzw, float4(81.2394867, 17.3480244, 37.3498383, 59.3948402));
	r6.y = frac(r2.x);
	r2.x = dot(r6.xyzw, float4(81.2394867, 17.3480244, 37.3498383, 59.3948402));
	r6.z = frac(r2.x);
	r2.x = dot(r6.xyzw, float4(81.2394867, 17.3480244, 37.3498383, 59.3948402));
	r2.x = frac(r2.x);
	r2.z = r6.x * r6.y;
	r2.z = r2.z * r6.z;
	r2.x = r2.z * r2.x;
	r2.z = dot(r0.xy, r0.xy);
	r2.z = sqrt(r2.z);
	r1.w = r2.x * r1.w + r2.z;
	r2.x = 9.99999975e-005 + scriptControl0.z;
	r2.w = r2.x * r2.x;
	r2.x = r2.x * r2.w;
	r1.w = 1 / r1.w;
	r1.w = saturate(r2.x * r1.w);
	r2.x = r1.w * -2 + 3;
	r1.w = r1.w * r1.w;
	r1.w = r2.x * r1.w;
	if (r2_b.y)
	{
		r6.xyzw = spaceTexture.Sample(trilinearSampler, pixel.texCoords.xy).xyzw;
		r6.xyzw = anusGlow * r6.xyzw;
		o0.w = r6.w;
	}
	else
	{
		r2.x = 1 / r2.z;
		r2.x = saturate(0.216000006 * r2.x);
		r2.y = r2.x * -2 + 3;
		r2.x = r2.x * r2.x;
		r2.x = r2.y * r2.x;
		r2.yz = postfx_get_viewport_size().zw * warpPixels;
		r2.yz = scriptControl0.ww * r2.yz;
		r2_b.w = 0 < scriptControl1.x;
		r8.xy = r2.xx * r2.yz + float2(1, 1);
		r8.xy = r0.xy * r8.xy + float2(0.5, 0.5);
		r2.xy = -r2.xx * r2.yz + float2(1, 1);
		r0.xy = r0.xy * r2.xy + float2(0.5, 0.5);
		r0.xy = saturate(r2.ww ? r8.xy : r0.xy);
		r2.xyzw = frameBuffer.Sample(trilinearSampler, r0.xy).xyzw;
		#if TOOLSGFX
		r2.xyz = srgb_to_linear(r2.xyz);
		#endif
		r6.xyzw = postfx_int16_to_float_framebuffer(r2.xyzw);
		o0.w = r6.w;
	}
	r1.xyz = r1.xyz * lightningGlow + -r6.xyz;
	r0.xyz = r0.zzz * r1.xyz + r6.xyz;
	r1.x = scriptControl2.z * r3.w;
	r2.xyz = r3.xyz * sparkleGlow + -r0.xyz;
	r0.xyz = r1.xxx * r2.xyz + r0.xyz;
	r1.x = anusOpacity * r4.w;
	r1.x = scriptControl1.z * r1.x;
	r2.xyz = r4.xyz * anusGlow + -r0.xyz;
	r0.xyz = r1.xxx * r2.xyz + r0.xyz;
	r1.x = vagOpacity * r5.w;
	r1.x = scriptControl1.w * r1.x;
	r2.xyz = r5.xyz * vagGlow + -r0.xyz;
	r0.xyz = r1.xxx * r2.xyz + r0.xyz;
	r0.w = scriptControl2.x * r0.w;
	r1.xyz = r7.xyz * faceGlow + -r0.xyz;
	r0.xyz = r0.www * r1.xyz + r0.xyz;
	r1.xyz = wipeGlow + -r0.xyz;
	r0.xyz = r1.www * r1.xyz + r0.xyz;
	o0.xyz = postfx_float_to_int16_framebuffer(r0.xyz);
	return o0;
}