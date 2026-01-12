#ifndef __LIB_HDR_OLD__
#define __LIB_HDR_OLD__

#include "lib/relative_hdr.hlsl"
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

void HDR_ApplyFalloff(inout float3 color, float falloffPower, float3 normal, float3 viewDirection, bool inverted)
{
    if(falloffPower == 0)
        return;

    float fresnel = saturate(dot(-normalize(viewDirection), normalize(normal)));

    if(inverted)
        fresnel = 1.0 - fresnel;

    color *= pow(fresnel, falloffPower);
}

void HDR_ApplyDepth(inout float2 texCoords, float depth, float3 viewDirection, float3 normal, float3 tangent, float3 binormal)
{
    float nDotV = dot(-normalize(viewDirection), normalize(normal));
    float tDotV = dot(-normalize(viewDirection), normalize(tangent));
    float bDotV = dot(-normalize(viewDirection), normalize(binormal));

    if(nDotV <= 0)
        return;

    texCoords += (-float2(tDotV, bDotV) / nDotV) * (depth + 0.00001);
}

void HDR_ApplyFlicker(inout float3 color, Texture2D<float> flickerMap, SamplerState flickerSampler, float3 uvOffsets, float time, float2 flickerRange, float2 flickerSeed, float flickerSpeed, float flickerPower)
{
    float2 flickerMapUVs = float2(flickerSeed.x, flickerSpeed * time + frac(uvOffsets.x + uvOffsets.y + uvOffsets.z + flickerSeed.y));
    float flickerBlend = pow(abs(flickerMap.SampleLevel(flickerSampler, flickerMapUVs, 0).r), flickerPower);
    color.rgb *= lerp(flickerRange.x, flickerRange.y, flickerBlend);
}

#endif