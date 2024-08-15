#ifndef __GFX_CORE_DEFINES__
#define __GFX_CORE_DEFINES__

#include "hlslcoreplatform.h"

// Having these here might not be correct possibly moving it to hlslcoretypes

#define M_PI 3.141592653589793

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
	uint4 data[8];
};

struct CoreReflectionProbeAttenuationPack
{
	uint4 data[6];
};

struct CoreReflectionProbePack
{
	float3 offOrigin; // 0x0 -> 0xC
	float3x3 invOrient; // 0xC -> 0x30
	float3 size; // 0x30 -> 0x3C
	float3 probeCenter; // 0x3C -> 0x48
	float weightMul; // 0x48 -> 0x4C
	float3 volumeCoordMul; // 0x4C -> 0x58
	float3 volumeCoordAdd; // 0x58 -> 0x64
	float exposure; // 0x64 -> 0x68
	float3 avgCubeColor; // 0x68 -> 0x74
	uint firstBlend_fade; // 0x74 -> 0x78 // packed as: (ushort and half)
	uint arraySlot_numBlends; // 0x78 -> 0x7C
	float4 prbClipPlanes[6]; // 0x80 -> 0xE0
};

struct CoreLightConstantsPack
{
	float3 offOrigin;
	float3 color;
	uint flags;
	float nearMul;
	float nearAdd;
	float farMul;
	float farAdd;
	float dAttenuation;
	float mShadowPenumbraRadius;
	float3 offProjOrigin;
	uint4 data[11];
};

struct CoreCullConstantsPack
{
	float3 origin;
	half3 bbExtents;
	half data1;
	uint3 data2;
	uint4 data3[3];
};

#endif