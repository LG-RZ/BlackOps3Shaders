#ifndef __CODE_INSTANCING__
#define __CODE_INSTANCING__

#if TOOLSGFX

struct CodeObjectConsts 
{
	row_major float4x4 worldMatrix;
	float4 customFloat4s[7];
	int4 customInt4s;
	uint hasBones;
	uint hasSiegeAnim;
	float siegeAnimOffset;
	float sortDepth;
};

StructuredBuffer<CodeObjectConsts> gObjectInstanceData : register(t30);

#else

struct GpuBoneData
{
	row_major float3x4 objMatrixT;
	float4 extra;
};

struct ModelInstanceData
{
	uint boneArrayIndex;
	uint shaderConstantSet;
	uint flagsAndPrevFrameIndex;
	uint worldMatrix;
	uint siegeAnimStateOffset;
	uint prevFrameSiegeAnimStateOffset;
};

struct GpuShaderConstantSet
{
	float4 scriptVector0;
	float4 scriptVector1;
	float4 scriptVector2;
	float4 scriptVector3;
	float4 scriptVector4;
	float4 scriptVector5;
	float4 scriptVector6;
	float4 scriptVector7;
	float4 weaponParam0;
	float4 weaponParam1;
	float4 weaponParam2;
	float4 weaponParam3;
	float4 weaponParam4;
	float4 weaponParam5;
	float4 weaponParam6;
	float4 weaponParam7;
	float4 characterParam0;
	float4 characterParam1;
	float4 characterParam2;
	float4 characterParam3;
	float4 characterParam4;
	float4 characterParam5;
	float4 characterParam6;
	float4 characterParam7;
};

StructuredBuffer<ModelInstanceData> modelInstanceBuffer : register(t4);
StructuredBuffer<GpuBoneData> boneMatrixBuffer : register(t5);
StructuredBuffer<GpuBoneData> boneMatrixBufferPrevFrame : register(t8);

#endif

#endif