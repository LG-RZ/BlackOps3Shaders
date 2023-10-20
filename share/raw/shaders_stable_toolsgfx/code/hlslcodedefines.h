#ifndef __CODE_DEFINES__
#define __CODE_DEFINES__

#include "../gfxcore/hlslcoredefines.h"
#include "../ToolsGfx/hlsl_to_pssl.h"
#include "../gfxcore/hlslcorepssl_to_hlsl.h"

struct CodeSceneTransforms
{
	row_major float4x4 wldToCamMatrix;
	row_major float4x4 camToOffMatrix;
	row_major float4x4 offToCamMatrix;
	row_major float4x4 camToClpMatrix;
	row_major float4x4 camToWldMatrix;
	row_major float4x4 wldToClpMatrix;
	row_major float4x4 offToClpMatrix;
	row_major float4x4 clpToCamMatrix;
};

struct TriDensitySettings
{
	uint4 flags;
	float4 params;
};

struct ShaderDebugConstants
{
	float4 debugTunable0;
	float4 debugTunable1;
	float4 debugTunable2;
	float4 debugTunable3;
	float debugSlider0;
	float debugSlider1;
	float debugSlider2;
	float debugSlider3;
	uint debugToggle0;
	uint debugToggle1;
	uint debugToggle2;
	uint debugToggle3;
};

struct CodeSceneConsts
{
	CodeSceneTransforms transforms;
	CoreFogConstants fog;
	CoreSunConstants sun;
	CoreGlobalProbePack globalProbe;
	CoreWeatherConsts weather;
	TriDensitySettings triDensity;
	SSTLightingConstants outdoorOcclusionTreeConstants;
	float4 outdoorPinToWorldZ;
	ShaderDebugConstants shaderDebugConstants;
	float3 wldCameraPosition;
	float padding1;
	float4 viewSpaceScaleBias;
	uint2 renderTargetSize;
	float2 renderTargetInvSize;
	float nearClip;
	float farClipScale;
	float time;
	float siegeTime;
	float exposure;
	float invExposure;
	float exposureClamped;
	float padding2;
	uint numLights;
	uint numProbes;
	uint numShadowedLights;
	uint numOverrideProbes;
	uint lightingMode;
	uint numLitFogVolumes;
	uint numComputeSprites;
	uint padding3;
	float2 gSpotShadowResolutionAndRcp;
	uint computeSpritesDebug;
	uint numComputeLmaps;
	float2 skyRotation;
	float skySize;
	float skyTransition;
	uint forceViewToNormal;
	uint numForwardDecals;
	uint numAttenuationVolumes;
	uint fullHDR;
	float4 extraClipPlane0;
	float4 extraClipPlane1;
};

struct CodeObjectBonesConst 
{
	row_major float3x4 objMatrixT;
	float4 extra;
};

#endif