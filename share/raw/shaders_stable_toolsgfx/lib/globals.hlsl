#ifndef __LIB_GLOBALS__
#define __LIB_GLOBALS__

// Maybe actually do this sometime
// TO-DO:
// Move most normal operations to vertdecl_vertex_tangentspace.hlsl
// Put all operations related to bi-tangents/bi-normals in vertdecl_vertex_binormal.hlsl

// Credits to Scobulala for this
#if TOOLSGFX
#define INSTANCE_SEMANTIC INSTANCEID
#else
#define INSTANCE_SEMANTIC TEXCOORD15
#endif

#include "code/hlslcodeinstancing.h"
#include "code/hlslregreserve.h"
#include "code/hlslcodeconstantbuffers.h"

float GetTime()
{
    #if TOOLSGFX
    return gScene.time;
    #else
    return gameTime.w;
    #endif
}

float4 GetRenderTargetSize()
{
	#if TOOLSGFX
	return float4(gScene.renderTargetSize, gScene.renderTargetInvSize);
	#else
	return renderTargetSize;
	#endif
}

float GetAspectRatio()
{
    return GetRenderTargetSize().x / GetRenderTargetSize().y;
}

float SRGBToLinear(const float color)
{
	return color <= 0.04045 ? color / 12.92 : pow((color + 0.055) / 1.055, 2.4);
}

float3 SRGBToLinear(const float3 color)
{
	return float3(SRGBToLinear(color.r), SRGBToLinear(color.g), SRGBToLinear(color.b));
}

float4 SRGBToLinear(const float4 color)
{
	return float4(SRGBToLinear(color.r), SRGBToLinear(color.g), SRGBToLinear(color.b), color.a);
}

float LinearToSRGB(const float color)
{
	return color <= 0.0031308 ? color * 12.92 : pow(color, 1.0 / 2.4) * 1.055 - 0.055;
}

float3 LinearToSRGB(const float3 color)
{
	return float3(LinearToSRGB(color.r), LinearToSRGB(color.g), LinearToSRGB(color.b));
}

float4 LinearToSRGB(const float4 color)
{
	return float4(LinearToSRGB(color.r), LinearToSRGB(color.g), LinearToSRGB(color.b), color.a);
}

float GetIntensity(float3 color)
{
    return dot(color, float3(0.299, 0.587, 0.114));
}

float Luminance(const float3 rgb)
{
	return dot(rgb, float3(0.212585, 0.715195, 0.072220));
}

float2 GetSkyRotation()
{
    #if TOOLSGFX
    return gScene.skyRotation;
    #else
    return skyRotationTransition.xy;
    #endif
}

float GetSkySize()
{
    #if TOOLSGFX
    return gScene.skySize;
    #else
    return skyRotationTransition.z;
    #endif
}

float GetSkyTransition()
{
    #if TOOLSGFX
    return gScene.skyTransition;
    #else
    return skyRotationTransition.w;
    #endif
}

#endif