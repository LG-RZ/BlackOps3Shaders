#ifndef __POSTFX_COMMON__
#define __POSTFX_COMMON__

#include "lib/globals.hlsl"
#include "lib/vertex_pos_col_tex.hlsl"
#include "lib/vertex_pos_tex.hlsl"
#include "lib/floatz.hlsl"
#include "lib/pixeloutput_color.hlsl"
#include "gfxcore/hlslcoreminmax.h"
#include "postfx_t6_visionset.h"

void PostFx_GenerateFullscreenQuad(const float3 vertexPosition, const float2 texCoords, const uint instance, out float4 outPosition, out float2 outTexCoords)
{
	#if TOOLSGFX
	outPosition = float4(texCoords * float2(2, -2) + float2(-1, 1), 0, 1);
	#else
	outPosition = Transform_OffsetToClip(Transform_PositionToWorld(vertexPosition, instance));
	#endif

	outTexCoords = texCoords;
}

void PostFx_FixPreviewResolution(in float2 position, inout float2 texCoords)
{
	#if TOOLSGFX

	float2 resolution = GetRenderTargetSize().xy / float2(16.0, 9.0);

	resolution = floor(resolution);

	if(resolution.x < 1.0)
		resolution.x = 1.0;
	
	if(resolution.y < 1.0)
		resolution.y = 1.0;
	
	float factor = min(resolution.x, resolution.y);

	float2 newResolution = factor * float2(16.0, 9.0);

	if(any(position > newResolution))
		discard;

	texCoords = position / newResolution;

	#endif
}

float PostFx_GetAspectRatio(bool fixResolution = true)
{
    #if TOOLSGFX

    if(!fixResolution)
        return GetAspectRatio();

    float2 resolution = GetRenderTargetSize().xy / float2(16.0, 9.0);

	resolution = floor(resolution);

	if(resolution.x < 1.0)
		resolution.x = 1.0;
	
	if(resolution.y < 1.0)
		resolution.y = 1.0;
	
	float factor = min(resolution.x, resolution.y);

	float2 newResolution = factor * float2(16.0, 9.0);

    return newResolution.x / newResolution.y;

    #else

    return GetAspectRatio();

    #endif
}

float3 PostFx_NormalizeColor(const float3 color)
{
	#if TOOLSGFX
	return color;
	#else
	return color / 32768.0;
	#endif
}

float3 PostFx_DenormalizeColor(const float3 color)
{
	#if TOOLSGFX
	return color;
	#else
	return color * 32768.0;
	#endif
}

#if USE_T6_VISIONSET

float4 PostFx_ApplyVisionToScene(const float4 color)
{
	float3 nColor = color.rgb;

	#if TOOLSGFX
	nColor = nColor * 2.0;
	#else
	nColor = nColor * 0.5;
	#endif

	nColor = LinearToSRGB(nColor);
	nColor = PostFx_T6_VisionSetApply(float4(nColor, color.a)).rgb;
	nColor = SRGBToLinear(nColor);

	return float4(nColor.rgb, color.a);
}

float4 PostFx_ApplyVision(const float4 color)
{
	float3 nColor = color.rgb;

	nColor = PostFx_T6_VisionSetApply(float4(nColor, color.a)).rgb;

	return float4(nColor.rgb, color.a);
}

#endif

#endif