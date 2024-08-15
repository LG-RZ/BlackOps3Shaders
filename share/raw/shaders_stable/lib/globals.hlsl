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

uint GetOITMaxEntries()
{
    #if TOOLSGFX
    return 9;
    #else
    return oitMaxEntries;
    #endif
}

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

float RadialGradientExponential(float2 uvs, float2 centerPosition, float radius, float density, bool invertDensity = false)
{
    float result;
    
    centerPosition.y = 1 - centerPosition.y;
    
    float2 centeredUVs = uvs * 2 - 1;
    float distanceFromCenter = length(centeredUVs + (1 - (centerPosition * 2)));
    float radialGradient = 1 - saturate(distanceFromCenter / (radius * 2));
    
    if(invertDensity)
        density = 1.0 / density;
    
    result = pow(radialGradient, 1.0 / abs(density));
    
    return saturate(result);
}

// Credits: https://web.archive.org/web/20200207113336/http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl

float3 RGB2HSV(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 HSV2RGB(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

// Credits: https://www.youtube.com/watch?v=nM320eVlLvQ
float Random2D(float2 coord) 
{
	return frac(sin(dot(coord.xy, float2(12.9898, 78.233))) * 43758.5453);
}

#endif