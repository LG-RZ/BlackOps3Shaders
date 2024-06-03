#ifndef __LIB_HDR_OLD__
#define __LIB_HDR_OLD__

#include "gfxcore/hlslcoremath.h"
#include "code/hlslcodeconstantbuffers.h"

void HDR_ClampExposure(inout float3 color)
{
    #if TOOLSGFX

    float3 colorClamped = color * gScene.invExposure;

    float3 fullHdrColor = all(IsFinite(color)) ? colorClamped : 0.0;

    color = colorClamped >= 0.0001 ? colorClamped : 0.0;

    color = gScene.fullHDR ? fullHdrColor : min(color, R11G11B10_MAX);

    #else

    color = color * relHDRExposure.y;
    color = color >= 0.0001 ? color : 0.0;

    color = min(color, R11G11B10_MAX);

    #endif
}

#endif