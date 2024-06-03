#ifndef __GFX_CORE_FOG__
#define __GFX_CORE_FOG__

#include "gfxcore/hlslcoredefines.h"
#include "code/hlslcodeconstantbuffers.h"

// TO-DO: Implement atmospheric fog and add the in-game counter parts

float Fog_GetHeightFalloff()
{
    #if TOOLSGFX
    return gScene.fog.heightFalloff;
    #else
    return fogConstants.heightFalloff;
    #endif
}

float Fog_GetSkyHeightFalloff()
{
    #if TOOLSGFX
    return gScene.fog.skyHeightFalloff;
    #else
    return fogConstants.skyHeightFalloff;
    #endif
}

float Fog_GetK0()
{
    #if TOOLSGFX
    return gScene.fog.K0;
    #else
    return fogConstants.K0;
    #endif
}

float Fog_GetSkyK0()
{
    #if TOOLSGFX
    return gScene.fog.skyK0;
    #else
    return fogConstants.skyK0;
    #endif
}

float Fog_GetK0b()
{
    #if TOOLSGFX
    return gScene.fog.K0b;
    #else
    return fogConstants.K0b;
    #endif
}

float Fog_GetSkyK0b()
{
    #if TOOLSGFX
    return gScene.fog.skyK0b;
    #else
    return fogConstants.skyK0b;
    #endif
}

float Fog_GetExpMul()
{
    #if TOOLSGFX
    return gScene.fog.expMul;
    #else
    return fogConstants.expMul;
    #endif
}

float Fog_GetExpAdd()
{
    #if TOOLSGFX
    return gScene.fog.expAdd;
    #else
    return fogConstants.expAdd;
    #endif
}

float3 Fog_GetWorldSunFogDirection()
{
    #if TOOLSGFX
    return gScene.fog.wldSunFogDir;
    #else
    return fogConstants.wldSunFogDir;
    #endif
}

float2 Fog_GetSunForAngles()
{
    #if TOOLSGFX
    return gScene.fog.sunFogAngles;
    #else
    return fogConstants.sunFogAngles;
    #endif
}

float4 Fog_GetFogColor()
{
    #if TOOLSGFX
    return gScene.fog.fogColor;
    #else
    return fogConstants.fogColor;
    #endif
}

float4 Fog_GetSunFogColor()
{
    #if TOOLSGFX
    return gScene.fog.sunFogColor;
    #else
    return fogConstants.sunFogColor;
    #endif
}

float Fog_GetBlendAmount()
{
    #if TOOLSGFX
    return gScene.fog.blendAmount;
    #else
    return fogConstants.blendAmount;
    #endif
}

float2 Fog_GetAtmosphereFogDistanceDensityScale()
{
    #if TOOLSGFX
    return gScene.fog.atmospherefogdistancedensityscale;
    #else
    return fogConstants.atmospherefogdistancedensityscale;
    #endif
}

float2 Fog_GetAtmosphereFogDistanceOffset()
{
    #if TOOLSGFX
    return gScene.fog.atmospherefogdistanceoffset;
    #else
    return fogConstants.atmospherefogdistanceoffset;
    #endif
}

float2 Fog_GetAtmosphereFogDensityAtCamera()
{
    #if TOOLSGFX
    return gScene.fog.atmospherefogdensityatcamera;
    #else
    return fogConstants.atmospherefogdensityatcamera;
    #endif
}

float2 Fog_GetAtmosphereSkyFogDensityAtCamera()
{
    #if TOOLSGFX
    return gScene.fog.atmosphereskyfogdensityatcamera;
    #else
    return fogConstants.atmosphereskyfogdensityatcamera;
    #endif
}

float2 Fog_GetAtmosphereFogHeightDensityScale()
{
    #if TOOLSGFX
    return gScene.fog.atmospherefogheightdensityscale;
    #else
    return fogConstants.atmospherefogheightdensityscale;
    #endif
}

float2 Fog_GetAtmosphereSkyFogHeightDensityScale()
{
    #if TOOLSGFX
    return gScene.fog.atmosphereskyfogheightdensityscale;
    #else
    return fogConstants.atmosphereskyfogheightdensityscale;
    #endif
}

float3 Fog_GetAtmosphereTotalDensity()
{
    #if TOOLSGFX
    return gScene.fog.atmosphereTotalDensity;
    #else
    return fogConstants.atmosphereTotalDensity;
    #endif
}

float Fog_GetAtmosphereExtinctionIntensity()
{
    #if TOOLSGFX
    return gScene.fog.atmosphereExtinctionIntensity;
    #else
    return fogConstants.atmosphereExtinctionIntensity;
    #endif
}

float Fog_GetAtmosphereMieSchlickK()
{
    #if TOOLSGFX
    return gScene.fog.atmosphereMieSchlickK;
    #else
    return fogConstants.atmosphereMieSchlickK;
    #endif
}

float3 Fog_GetAtmosphereMieDensity()
{
    #if TOOLSGFX
    return gScene.fog.atmosphereMieDensity;
    #else
    return fogConstants.atmosphereMieDensity;
    #endif
}

float3 Fog_GetAtmosphereRayleighDensity()
{
    #if TOOLSGFX
    return gScene.fog.atmosphereRayleighDensity;
    #else
    return fogConstants.atmosphereRayleighDensity;
    #endif
}

float Fog_GetAtmosphereHazeBaseDistance()
{
    #if TOOLSGFX
    return gScene.fog.atmospherehazebasedist;
    #else
    return fogConstants.atmospherehazebasedist;
    #endif
}

float Fog_GetAtmosphereHazeFadeDistance()
{
    #if TOOLSGFX
    return gScene.fog.atmospherehazefadedist;
    #else
    return fogConstants.atmospherehazefadedist;
    #endif
}

float Fog_GetAtmosphereSunStrength()
{
    #if TOOLSGFX
    return gScene.fog.atmospheresunstrength;
    #else
    return fogConstants.atmospheresunstrength;
    #endif
}

float Fog_GetAtmosphereInScatterIntensity()
{
    #if TOOLSGFX
    return gScene.fog.atmosphereInScatterIntensity;
    #else
    return fogConstants.atmosphereInScatterIntensity;
    #endif
}

float Fog_GetWorldFogSkySize()
{
    #if TOOLSGFX
    return gScene.fog.worldfogskysize;
    #else
    return fogConstants.worldfogskysize;
    #endif
}

float3 Fog_GetAtmosphericFogDensity(
    in float rayLength,
    in float height,
    in float blend,
    in float2 distanceDensityScale,
    in float2 distanceOffset,
    in float2 densityAtCamera,
    in float2 heightDensityScale,
    in float3 totalDensity)
{
    [branch]
    if(blend > 0.0)
    {
        float2 distanceDensity = densityAtCamera * (distanceOffset + (rayLength * distanceDensityScale));

        float2 heightFalloff = abs(height) > 0.01 ? ((1.0 - exp2(height * heightDensityScale * -1.44269502)) / (height * heightDensityScale)) * distanceDensity : distanceDensity;

        float3 densityX = exp2(heightFalloff.x * totalDensity);
        float3 densityY = exp2(heightFalloff.y * totalDensity);

        return lerp(densityX, densityY, blend);
    }
    else
    {
        float distanceDensity = densityAtCamera.x * (distanceOffset.x + (rayLength * distanceDensityScale.x));

        float heightFalloff = abs(height) > 0.01 ? ((1.0 - exp2(height * heightDensityScale.x * -1.44269502)) / (height * heightDensityScale.x)) * distanceDensity : distanceDensity;

        return exp2(heightFalloff.x * totalDensity);
    }
}

// This is all a messs but it should work (Not tested)
void Fog_ApplyAtmosphericFog(inout float3 color, float3 position, bool skyFog = false)
{
    float3 nPos = normalize(position);
    float rayLength = length(position);

    float2 fogDensityAtCamera = Fog_GetAtmosphereFogDensityAtCamera();
    float2 fogHeightDensityScale = Fog_GetAtmosphereFogHeightDensityScale();

    if(skyFog)
    {
        fogDensityAtCamera = Fog_GetAtmosphereSkyFogDensityAtCamera();
        fogHeightDensityScale = Fog_GetAtmosphereSkyFogHeightDensityScale();
    }

    float3 fogDensity = Fog_GetAtmosphericFogDensity(
        rayLength,
        position.z,
        Fog_GetBlendAmount(),
        Fog_GetAtmosphereFogDistanceDensityScale(),
        Fog_GetAtmosphereFogDistanceOffset(),
        fogDensityAtCamera,
        fogHeightDensityScale,
        Fog_GetAtmosphereTotalDensity());

    fogDensity = fogDensity * Fog_GetAtmosphereExtinctionIntensity() + 1.0;
    fogDensity = saturate(fogDensity - Fog_GetAtmosphereExtinctionIntensity());

    float unknown1 = dot(Fog_GetWorldSunFogDirection(), -nPos);
    float unknown2 = -Fog_GetAtmosphereMieSchlickK() * Fog_GetAtmosphereMieSchlickK() + 1.0;
    float unknown3 = pow(Fog_GetAtmosphereMieSchlickK() * -unknown1 + 1.0, 2) * 12.566371;

    unknown2 = unknown2 / unknown3;

    float rayHazeDistance = saturate((rayLength - Fog_GetAtmosphereHazeBaseDistance()) * Fog_GetAtmosphereHazeFadeDistance()) * unknown2;

    unknown1 = (pow(saturate(unknown1), 2) + 1.0) * 0.0596831031 - 1.0;
    unknown1 = unknown1 * Fog_GetAtmosphereSunStrength() + 1.0;

    float3 density = (rayHazeDistance * Fog_GetAtmosphereMieDensity()) + (unknown1 * Fog_GetAtmosphereRayleighDensity());

    density *= Fog_GetAtmosphereInScatterIntensity();

    color = color * fogDensity + (density * (1.0 - fogDensity));
}

void Fog_ApplyWorldFog(inout float3 color, float3 position, bool skyFog = false)
{
    float heightFalloff = Fog_GetHeightFalloff();
    float k0 = Fog_GetK0();
    float k0b = Fog_GetK0b();

    if(skyFog)
    {
        heightFalloff = Fog_GetSkyHeightFalloff();
        k0 = Fog_GetSkyK0();
        k0b = Fog_GetSkyK0b();
    }

    float heightMax = position.z * heightFalloff;
    float heightMin = position.z * heightFalloff + k0;

    heightMin = (heightMin < 0 ? exp2(heightMin * 1.44269502) : heightMin + 1.0) - k0b;

    float heightPercentange = abs(heightMax) < 0.0001 ? saturate(k0b) : heightMin / (abs(heightMax) < 0.0001 ? 1 : heightMax);

    heightPercentange = exp2((heightPercentange * Fog_GetExpMul()) * length(position) + Fog_GetExpAdd());

    float colorBlendFactor = 1.0 - min(heightPercentange, 1.0);

    float fogColorBlendFactor = saturate(dot(Fog_GetWorldSunFogDirection(), normalize(position)) * Fog_GetSunForAngles().y + Fog_GetSunForAngles().x);
    float4 fogColor = lerp(Fog_GetSunFogColor(), Fog_GetFogColor(), fogColorBlendFactor);

    color = lerp(color, fogColor.rgb, colorBlendFactor * fogColor.a);
}

void Fog_ApplyFog(inout float3 color, float3 position, bool skyFog = false)
{
    if(Fog_GetAtmosphereExtinctionIntensity() > 0.0)
    {
        Fog_ApplyAtmosphericFog(color, position, skyFog);
    }
    else
    {
        Fog_ApplyWorldFog(color, position, skyFog);
    }
}

#endif