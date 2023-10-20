#ifndef __POSTFX_COMMON__
#define __POSTFX_COMMON__

#include "../ToolsGfx/globals.hlsl"
#include "../ToolsGfx/vertex_pos_col_tex.hlsl"
#include "../ToolsGfx/vertex_pos_tex.hlsl"
#include "../ToolsGfx/floatz.hlsl"
#include "../ToolsGfx/pixeloutput_color.hlsl"
#include "../gfxcore/hlslcoreminmax.h"
#include "postfx_t6_visionset.h"

#if !TOOLSGFX

cbuffer GenericsCBuffer : register(b3)
{
	float4 scriptVector0 : packoffset(c0);
	float4 scriptVector1 : packoffset(c1);
	float4 scriptVector2 : packoffset(c2);
	float4 scriptVector3 : packoffset(c3);
	float4 scriptVector4 : packoffset(c4);
	float4 scriptVector5 : packoffset(c5);
	float4 scriptVector6 : packoffset(c6);
	float4 scriptVector7 : packoffset(c7);
	float4 weaponParam0 : packoffset(c8);
	float4 weaponParam1 : packoffset(c9);
	float4 weaponParam2 : packoffset(c10);
	float4 weaponParam3 : packoffset(c11);
	float4 weaponParam4 : packoffset(c12);
	float4 weaponParam5 : packoffset(c13);
	float4 weaponParam6 : packoffset(c14);
	float4 weaponParam7 : packoffset(c15);
}

#endif

static const float int16ToFloat = 1.0 / 32768;
static const float floatToInt16 = 32768;

float postfx_get_time()
{
#if TOOLSGFX
	return gScene.time;
#else
	return gameTime.w;
#endif
}

float4 postfx_get_viewport_size()
{
#if TOOLSGFX
	return float4(gScene.renderTargetSize, gScene.renderTargetInvSize);
#else
	return renderTargetSize;
#endif
}

float4 postfx_get_camera_look()
{
#if TOOLSGFX
	return float4(-0.13, 0.234, -0.432, 0);
#else
	return cameraLook;
#endif
}

void postfx_generate_fullscreen_quad(const float3 vertexPosition, const float2 texCoords, const uint instance, out float4 outPosition, out float2 outTexCoords)
{
	#if TOOLSGFX
	outPosition = float4(texCoords * float2(2, -2) + float2(-1, 1), 0, 1);
	#else
	outPosition = transform_offset_to_clip(transform_position_to_world(vertexPosition, instance));
	#endif

	outTexCoords = texCoords;
}

float3 postfx_tone_map_color(const float3 color)
{
	return linear_to_srgb(color);
}

float3 postfx_inverse_tone_map_color(const float3 color)
{
	return srgb_to_linear(color);
}

float3 postfx_tone_map_framebuffer(const float3 color)
{
#if TOOLSGFX
	return color;
#else
	return linear_to_srgb(color * int16ToFloat);
#endif
}

float3 postfx_inverse_tone_map_framebuffer(const float3 color)
{
#if TOOLSGFX
	return color;
#else
	return srgb_to_linear(color) * floatToInt16;
#endif
}

float3 postfx_float_to_int16_framebuffer(const float3 color)
{
#if TOOLSGFX
	return color;
#else
	return color * floatToInt16;
#endif
}

float3 postfx_int16_to_float_framebuffer(const float3 color)
{
#if TOOLSGFX
	return color;
#else
	return color * int16ToFloat;
#endif
}
#if USE_T6_VISIONSET
float4 postfx_apply_t6_visionset_to_lut(const float4 color)
{
	return postfx_t6_visionset_apply_vision(
		color * visionSetBrightness,
		visColorRangeS,
		visColorRangeE,
		visColorShadowMatrixR,
		visColorShadowMatrixG,
		visColorShadowMatrixB,
		visColorHilightMatrixR,
		visColorHilightMatrixG,
		visColorHilightMatrixB,
		visColorMidtoneMatrixR,
		visColorMidtoneMatrixG,
		visColorMidtoneMatrixB,
		visColorFinalGamma,
		visColorFinalSaturation,
		visColorFinalBlend).xyzw;
}

float3 postfx_apply_t6_visionset_to_framebuffer(const float3 color)
{
	return postfx_inverse_tone_map_framebuffer(postfx_t6_visionset_apply_vision(
		float4(postfx_tone_map_framebuffer(color * visionSetBrightness), 1),
		visColorRangeS,
		visColorRangeE,
		visColorShadowMatrixR,
		visColorShadowMatrixG,
		visColorShadowMatrixB,
		visColorHilightMatrixR,
		visColorHilightMatrixG,
		visColorHilightMatrixB,
		visColorMidtoneMatrixR,
		visColorMidtoneMatrixG,
		visColorMidtoneMatrixB,
		visColorFinalGamma,
		visColorFinalSaturation,
		visColorFinalBlend).xyz);
}

float4 postfx_apply_t6_lut_visionset(Texture2D lutTexture, SamplerState lutSampler, float4 color)
{
	float4 r0, r1, r2;

	r0.xyzw = color.xyzw;
	r0.xyz = r0.xyz * r0.xyz;
	r1.xyzw = 0; // Bloom
	r0.xyz = r0.xyz * float3(4, 4, 4) + r1.xyz;
	r0.xyz = sqrt(r0.xyz);
	r1.xyz = r0.xyz * float3(-5.77078009, -5.77078009, -5.77078009) + float3(4.32808495, 4.32808495, 4.32808495);
	r1.xyz = exp2(r1.xyz);
	r1.xyz = float3(1, 1, 1) + -r1.xyz;
	r1.xyz = r1.xyz * float3(0.25, 0.25, 0.25) + float3(0.75, 0.75, 0.75);
	r2.xyz = -(float3(0.75, 0.75, 0.75) < r0.xyz);
	r0.xyz = r2.xyz ? r1.xyz : r0.xyz;
	r1.xyz = r0.xzy * float3(31, 31, 0.96875) + float3(0.5, 0, 0.015625);
	r0.x = 31 * r0.z;
	r0.x = frac(r0.x);
	r0.y = floor(r1.y);
	r1.w = 0;
	r0.yz = r0.yy * float2(32, 32) + r1.wx;
	r2.x = r1.x;
	r2.y = 32;
	r0.yz = r2.xy + r0.yz;
	r1.xy = float2(0.0009765625, 0.0009765625) * r0.yz;
	r2.xyzw = lutTexture.Sample(lutSampler, r1.yz).xyzw;
	r1.xyzw = lutTexture.Sample(lutSampler, r1.xz).xyzw;
	r1.xyzw = postfx_apply_t6_visionset_to_lut(r1.xyzw);
	r2.xyzw = postfx_apply_t6_visionset_to_lut(r2.xyzw);
	r0.yzw = r2.xyz + -r1.xyz;
	r0.xyz = r0.xxx * r0.yzw + r1.xyz;
	return float4(r0.xyz, dot(r0.xyz, float3(0.298999995, 0.587000012, 0.114)));
}

#endif

float4 postfx_apply_t6_lut(Texture2D lutTexture, SamplerState lutSampler, float4 color)
{
	float4 r0, r1, r2;

	r0.xyzw = color.xyzw;
	r0.xyz = r0.xyz * r0.xyz;
	r1.xyzw = 0; // Bloom
	r0.xyz = r0.xyz * float3(4, 4, 4) + r1.xyz;
	r0.xyz = sqrt(r0.xyz);
	r1.xyz = r0.xyz * float3(-5.77078009, -5.77078009, -5.77078009) + float3(4.32808495, 4.32808495, 4.32808495);
	r1.xyz = exp2(r1.xyz);
	r1.xyz = float3(1, 1, 1) + -r1.xyz;
	r1.xyz = r1.xyz * float3(0.25, 0.25, 0.25) + float3(0.75, 0.75, 0.75);
	r2.xyz = -(float3(0.75, 0.75, 0.75) < r0.xyz);
	r0.xyz = r2.xyz ? r1.xyz : r0.xyz;
	r1.xyz = r0.xzy * float3(31, 31, 0.96875) + float3(0.5, 0, 0.015625);
	r0.x = 31 * r0.z;
	r0.x = frac(r0.x);
	r0.y = floor(r1.y);
	r1.w = 0;
	r0.yz = r0.yy * float2(32, 32) + r1.wx;
	r2.x = r1.x;
	r2.y = 32;
	r0.yz = r2.xy + r0.yz;
	r1.xy = float2(0.0009765625, 0.0009765625) * r0.yz;
	r2.xyzw = lutTexture.Sample(lutSampler, r1.yz).xyzw;
	r1.xyzw = lutTexture.Sample(lutSampler, r1.xz).xyzw;
	r0.yzw = r2.xyz + -r1.xyz;
	r0.xyz = r0.xxx * r0.yzw + r1.xyz;
	return float4(r0.xyz, dot(r0.xyz, float3(0.298999995, 0.587000012, 0.114)));
}

#endif