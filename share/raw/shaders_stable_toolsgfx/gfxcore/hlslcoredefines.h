#ifndef __GFX_CORE_DEFINES__
#define __GFX_CORE_DEFINES__

#include "hlslcoreplatform.h"

// Having these here might not be correct possibly moving it to hlslcoretypes

struct CoreFogConstants
{
	float4 fogColor;
	float4 sunFogColor;
	float K0;
	float skyK0;
	float expMul;
	float expAdd;
	float heightFalloff;
	float skyHeightFalloff;
	float K0b;
	float padding0;
	float skyK0b;
	float3 wldSunFogDir;
	float2 sunFogAngles;
	float atmospheresunstrength;
	float atmosphereMieSchlickK;
	float2 atmosphereskyfogdensityatcamera;
	float atmosphereExtinctionIntensity;
	float atmosphereInScatterIntensity;
	float3 atmosphereRayleighDensity;
	float atmospherehazebasedist;
	float3 atmosphereMieDensity;
	float atmospherehazefadedist;
	float3 atmosphereTotalDensity;
	float worldfogskysize;
	float3 atmosphereInScatterIntensityOverTotalDensity;
	float blendAmount;
	float2 atmosphereskyfogheightdensityscale;
	float2 atmospherefogdistanceoffset;
	float2 atmospherefogdistancedensityscale;
	float2 atmospherefogheightdensityscale;
	float2 atmospherefogdensityatcamera;
	float2 padding1;
};

struct SSTConstants
{
	float2 dimensionInTiles;
	float inchesPerTexel;
	float spanInInches;
};

struct SSTLightingConstants
{
	SSTConstants constants;
	row_major float4x4 offToPinTransform;
	float coordScale;
	uint rootOffset;
	uint2 pad0;
};

struct SSTMinMaxConstants
{
	float2 sstToMinMaxScale;
	float2 pad0;
	float2 halfMinTexelSize;
	float rcpInchesDimLevel0;
	float shadowBiasInches;
};

struct CoreSunConstants
{
	float3 wldDir;
	float splitDepthOffset;
	float3 color;
	float specScale;
	float globalProbeExposure;
	float3 avgGlobalProbeColor;
	float4 splitPinTransform[3];
	uint sunCookieIndex;
	float sunCookieIntensity;
	float sunVolumetricCookieIntensity;
	uint toolsGfxDisableSunShadow;
	float4 sunCookieTransform[2];
	float intensity;
	int splitArrayOffset;
	float2 pad0;
	SSTLightingConstants sstLightingConstants;
};

struct CoreGlobalProbePack
{
	uint4 data[3];
};

struct CoreWeatherConsts
{
	float rain;
	float windSpeed;
	float windDirSin;
	float windDirCos;
	float weatherTile;
	float3 weatherVector;
	float3 weatherVector2;
	float padding0;
	float3 weatherTint;
	float padding1;
	float3 weatherTint2;
	float padding2;
};

struct CoreVolumetricConstants
{
	uint firstSpotLight;
	uint lastSpotLight;
	uint firstOmniLight;
	uint lastOmniLight;
	uint firstProbe;
	uint lastProbe;
	uint padding0;
	uint padding1;
};

struct CoreDecalConstantsPack
{
	float4 data[8];
};

struct CoreReflectionProbeAttenuationPack
{
	float4 data[6];
};

struct CoreReflectionProbePack
{
	float4 data[14];
};

struct CoreLightConstantsPack
{
	float4 data[15];
};

struct CoreCullConstantsPack
{
	float4 data[5];
};

#endif