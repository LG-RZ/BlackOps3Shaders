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

float Fog_GetK0()
{
    #if TOOLSGFX
    return gScene.fog.K0;
    #else
    return fogConstants.K0;
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

float2 Fog_GetAtmosphereFogHeightDensityScale()
{
    #if TOOLSGFX
    return gScene.fog.atmospherefogheightdensityscale;
    #else
    return fogConstants.atmospherefogheightdensityscale;
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

// This is all a messs but it should work (Not tested)
void Fog_ApplyAtmosphericFog(inout float3 color, float3 position)
{
    float3 normalizedPosition = normalize(position);
    float posLength = length(position);

    float3 fogDensity;

    if(Fog_GetBlendAmount() > 0.0)
    {
        float2 distanceDensity = (posLength * Fog_GetAtmosphereFogDistanceDensityScale() + Fog_GetAtmosphereFogDistanceOffset()) * Fog_GetAtmosphereFogDensityAtCamera();

        float2 heightMax = position.z * Fog_GetAtmosphereFogHeightDensityScale();
        float2 heightMin = 1.0 - exp2(heightMax * -1.44269502);

        float2 heightFalloff = abs(position.z) > 0.01 ? (heightMin / heightMax) * distanceDensity : distanceDensity;

        float3 densityX = exp2(heightFalloff.x * Fog_GetAtmosphereTotalDensity());
        float3 densityY = exp2(heightFalloff.y * Fog_GetAtmosphereTotalDensity());

        fogDensity = lerp(densityX, densityY, Fog_GetBlendAmount());
    }
    else
    {
        float distanceDensity = (posLength * Fog_GetAtmosphereFogDistanceDensityScale().x + Fog_GetAtmosphereFogDistanceOffset().x) * Fog_GetAtmosphereFogDensityAtCamera().x;

        float heightMax = position.z * Fog_GetAtmosphereFogHeightDensityScale().x;
        float heightMin = 1.0 - exp2(heightMax * -1.44269502);

        float heightFalloff = abs(position.z) > 0.01 ? (heightMin / heightMax) * distanceDensity : distanceDensity;

        fogDensity = exp2(heightFalloff.x * Fog_GetAtmosphereTotalDensity());
    }

    fogDensity = fogDensity * Fog_GetAtmosphereExtinctionIntensity() + 1.0;
    fogDensity = saturate(fogDensity - Fog_GetAtmosphereExtinctionIntensity());

    float unknown1 = dot(Fog_GetWorldSunFogDirection(), -normalizedPosition);
    float unknown2 = -Fog_GetAtmosphereMieSchlickK() * Fog_GetAtmosphereMieSchlickK() + 1.0;
    float unknown3 = pow(Fog_GetAtmosphereMieSchlickK() * -unknown1 + 1.0, 2) * 12.566371;

    unknown2 = unknown2 / unknown3;

    posLength = saturate((posLength - Fog_GetAtmosphereHazeBaseDistance()) * Fog_GetAtmosphereHazeBaseDistance());

    posLength = posLength * unknown2;

    unknown1 = (pow(saturate(unknown1), 2) + 1.0) * 0.0596831031 - 1.0;
    unknown1 = unknown1 * Fog_GetAtmosphereSunStrength() + 1.0;

    float3 density = (posLength * Fog_GetAtmosphereMieDensity()) + (unknown1 * Fog_GetAtmosphereRayleighDensity());

    density *= Fog_GetAtmosphereInScatterIntensity();

    color = color * fogDensity + (density * (1.0 - fogDensity));
}

void Fog_ApplyWorldFog(inout float3 color, float3 position)
{
    float heightMax = position.z * Fog_GetHeightFalloff();
    float heightMin = position.z * Fog_GetHeightFalloff() + Fog_GetK0();

    heightMin = (heightMin < 0 ? exp2(heightMin * 1.44269502) : heightMin + 1.0) - Fog_GetK0b();

    float heightPercentange = abs(heightMax) < 0.0001 ? saturate(Fog_GetK0b()) : heightMin / heightMax;

    heightPercentange = exp2((heightPercentange * Fog_GetExpMul()) * length(position) + Fog_GetExpAdd());

    float colorBlendFactor = 1.0 - min(heightPercentange, 1.0);

    float fogColorBlendFactor = saturate(dot(Fog_GetWorldSunFogDirection(), normalize(position)) * Fog_GetSunForAngles().y + Fog_GetSunForAngles().x);
    float4 fogColor = lerp(Fog_GetSunFogColor(), Fog_GetFogColor(), fogColorBlendFactor);

    color = lerp(color, fogColor.rgb, colorBlendFactor * fogColor.a);
}

void Fog_ApplyFog(inout float3 color, float3 position)
{
    if(Fog_GetAtmosphereExtinctionIntensity() > 0.0)
    {
        Fog_ApplyAtmosphericFog(color, position);
    }
    else
    {
        Fog_ApplyWorldFog(color, position);
    }
}

#endif