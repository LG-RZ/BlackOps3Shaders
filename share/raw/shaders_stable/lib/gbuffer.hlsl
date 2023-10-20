#ifndef __LIB_GBUFFER__
#define __LIB_GBUFFER__

#include "gfxcore/hlslcoregbufferinput.h"
#include "gfxcore/hlslcoregbufferoutput.h"

Texture2D<float4> colorMap;
SamplerState colorSampler;

#if USE_COLOR_TINT
float3 colorTint;
#endif

#endif