#ifndef __CODE_INSTANCING__
#define __CODE_INSTANCING__

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

StructuredBuffer<ModelInstanceData> modelInstanceBuffer : register(t4);
StructuredBuffer<GpuBoneData> boneMatrixBuffer : register(t5);

#endif