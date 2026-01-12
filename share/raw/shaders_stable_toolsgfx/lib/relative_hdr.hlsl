#ifndef __LIB_RELATIVE_HDR__
#define __LIB_RELATIVE_HDR__

#include "gfxcore/hlslcoredefines.h"
#include "gfxcore/hlslcoremath.h"
#include "gfxcore/hlslcoreminmax.h"
#include "code/hlslcodeconstantbuffers.h"

float HDR_CalculateBrightness(float3 color)
{
    return dot(color, float3(0.299, 0.587, 0.114));
}

float HDR_GetExposureClamped()
{
    #if TOOLSGFX
    return gScene.exposureClamped;
    #else
    return relHDRExposure.x;
    #endif
}

float HDR_ApplyExposure(inout float3 color, bool relativeHDR)
{
    float brightnessClamped = max(max(HDR_CalculateBrightness(color), 0.0001), HDR_GetExposureClamped());

    if(relativeHDR)
        color *= brightnessClamped;

    return brightnessClamped;
}

void HDR_ApplyExposure(inout float4 color, bool relativeHDR)
{
    float brightnessClamped = max(max(HDR_CalculateBrightness(color.rgb), 0.0001), HDR_GetExposureClamped());

    if(relativeHDR)
        color *= brightnessClamped;
}

#endif