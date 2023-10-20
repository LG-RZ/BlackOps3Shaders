#ifndef __CODE_CONSTANT_BUFFERS__
#define __CODE_CONSTANT_BUFFERS__

#include "hlslcodedefines.h"
#include "gfxcore/hlslcoretypes.h"

cbuffer PerSceneConsts : register(b1)
{
	row_major float4x4 projectionMatrix : packoffset(c0);
	row_major float4x4 viewMatrix : packoffset(c4);
	row_major float4x4 viewProjectionMatrix : packoffset(c8);
	row_major float4x4 inverseProjectionMatrix : packoffset(c12);
	row_major float4x4 inverseViewMatrix : packoffset(c16);
	row_major float4x4 inverseViewProjectionMatrix : packoffset(c20);
	float4 eyeOffset : packoffset(c24);
	float4 adsZScale : packoffset(c25);
	float4 hdrControl0 : packoffset(c26);
	float4 hdrControl1 : packoffset(c27);
	float4 fogColor : packoffset(c28);
	float4 fogConsts : packoffset(c29);
	float4 fogConsts2 : packoffset(c30);
	float4 fogConsts3 : packoffset(c31);
	float4 fogConsts4 : packoffset(c32);
	float4 fogConsts5 : packoffset(c33);
	float4 fogConsts6 : packoffset(c34);
	float4 fogConsts7 : packoffset(c35);
	float4 fogConsts8 : packoffset(c36);
	float4 fogConsts9 : packoffset(c37);
	float3 sunFogDir : packoffset(c38);
	float4 sunFogColor : packoffset(c39);
	float2 sunFog : packoffset(c40);
	float4 zNear : packoffset(c41);
	float3 clothPrimaryTint : packoffset(c42);
	float3 clothSecondaryTint : packoffset(c43);
	float4 renderTargetSize : packoffset(c44);
	float4 upscaledTargetSize : packoffset(c45);
	float4 materialColor : packoffset(c46);
	float4 cameraUp : packoffset(c47);
	float4 cameraLook : packoffset(c48);
	float4 cameraSide : packoffset(c49);
	float4 cameraVelocity : packoffset(c50);
	float4 skyMxR : packoffset(c51);
	float4 skyMxG : packoffset(c52);
	float4 skyMxB : packoffset(c53);
	float4 sunMxR : packoffset(c54);
	float4 sunMxG : packoffset(c55);
	float4 sunMxB : packoffset(c56);
	float4 skyRotationTransition : packoffset(c57);
	float4 debugColorOverride : packoffset(c58);
	float4 debugAlphaOverride : packoffset(c59);
	float4 debugNormalOverride : packoffset(c60);
	float4 debugSpecularOverride : packoffset(c61);
	float4 debugGlossOverride : packoffset(c62);
	float4 debugOcclusionOverride : packoffset(c63);
	float4 debugStreamerControl : packoffset(c64);
	float4 emblemLUTSelector : packoffset(c65);
	float4 colorMatrixR : packoffset(c66);
	float4 colorMatrixG : packoffset(c67);
	float4 colorMatrixB : packoffset(c68);
	float4 gameTime : packoffset(c69);
	float4 gameTick : packoffset(c70);
	float4 subpixelOffset : packoffset(c71);
	float4 viewportDimensions : packoffset(c72);
	float4 viewSpaceScaleBias : packoffset(c73);
	float4 ui3dUVSetup0 : packoffset(c74);
	float4 ui3dUVSetup1 : packoffset(c75);
	float4 ui3dUVSetup2 : packoffset(c76);
	float4 ui3dUVSetup3 : packoffset(c77);
	float4 ui3dUVSetup4 : packoffset(c78);
	float4 ui3dUVSetup5 : packoffset(c79);
	float4 clipSpaceLookupScale : packoffset(c80);
	float4 clipSpaceLookupOffset : packoffset(c81);
	uint4 computeSpriteControl : packoffset(c82);
	float4 invBcTexSizes : packoffset(c83);
	float4 invMaskTexSizes : packoffset(c84);
	float4 relHDRExposure : packoffset(c85);
	uint4 triDensityFlags : packoffset(c86);
	float4 triDensityParams : packoffset(c87);
	float4 voldecalRevealTextureInfo : packoffset(c88);
	float4 extraClipPlane0 : packoffset(c89);
	float4 extraClipPlane1 : packoffset(c90);
	float4 shaderDebug : packoffset(c91);
	uint isDepthHack : packoffset(c92);
}

cbuffer LightingGlobals : register(b2)
{
	uint numLights : packoffset(c0);
	uint numRefProbes : packoffset(c0.y);
	uint numRefProbeBlends : packoffset(c0.z);
	uint numDedicatedLights : packoffset(c0.w);
	float4 clearColor : packoffset(c1);
	float4 sssParams : packoffset(c2);
	CoreFogConstants fogConstants : packoffset(c3);
	CoreSunConstants sunConstants : packoffset(c17);
	SSTMinMaxConstants minMaxConstants : packoffset(c33);
	CoreGlobalProbePack globalProbeConstants : packoffset(c35);
	CoreWeatherConsts weather : packoffset(c38);
	SSTLightingConstants outdoorSSTConstants : packoffset(c43);
	float4 pinToWorldZ : packoffset(c49);
	CoreVolumetricConstants volumetric : packoffset(c50);
	uint viewID : packoffset(c52);
	uint enableCountDebug : packoffset(c52.y);
	uint centerGroupIDx : packoffset(c52.z);
	uint centerGroupIDy : packoffset(c52.w);
	uint viewmodelSunShadowRaw : packoffset(c53);
	uint debugDrawOverlayType : packoffset(c53.y);
	float drawNumLighstScale : packoffset(c53.z);
	float drawNumLightsAlpha : packoffset(c53.w);
	uint probeDebug : packoffset(c54);
	float probeDebugRadius : packoffset(c54.y);
	uint showSunVis : packoffset(c54.z);
	uint enableAO : packoffset(c54.w);
	uint showAO : packoffset(c55);
	uint numGpuCullTilesWidth : packoffset(c55.y);
	uint numGpuCullTilesHeight : packoffset(c55.z);
	int permuteHighlight : packoffset(c55.w);
	uint overdrawOverlayMaxValue : packoffset(c56);
	float overdrawOverlayAlpha : packoffset(c56.y);
	uint overdrawDecals : packoffset(c56.z);
	uint overdrawDecalsLayers : packoffset(c56.w);
	uint permuteStride : packoffset(c57);
	uint numDecals : packoffset(c57.y);
	uint numStaticDecals : packoffset(c57.z);
	uint numDynamicDecals : packoffset(c57.w);
	uint numOverrideProbes : packoffset(c58);
	uint enableDitheredShadow : packoffset(c58.y);
	uint oitMaxEntries : packoffset(c58.z);
	uint numAttenuationVolumes : packoffset(c58.w);
}

#endif