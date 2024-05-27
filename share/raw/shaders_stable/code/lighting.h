#ifndef __CODE_LIGHTING__
#define __CODE_LIGHTING__

#include "gfxcore/hlslcoretypes.h"
#include "hlslregreserve.h"
#include "lighting_pack.h"

// Bad idea?
/*
#if BASE_SPEC || (!BASE_SPEC && !BASE_TEXTURES)

SamplerState specColorSampler;
SamplerState aoSampler;

Texture2D<float4> glossMap;
Texture2D<float4> aoMap;

#endif

#if !USE_COLOR_SPEC && !BASE_SPEC && !BASE_TEXTURES

float3 specColorTint;

#endif

#if !BASE_SPEC && !BASE_TEXTURES

Texture2D<float4> specColorMap;

#endif
*/

#endif