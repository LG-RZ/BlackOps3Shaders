#ifndef __LIB_TRANSFORM__
#define __LIB_TRANSFORM__

#include "globals.hlsl"
#include "gfxcore/hlslcoretransform.h"
#include "gfxcore/hlslcoremath.h"
#include "code/motion_vector_globals.h"

float4x4 Transform_GetViewMatrix()
{
	#if TOOLSGFX
	return gScene.transforms.offToCamMatrix;
	#else
	return viewMatrix;
	#endif
}

float4x4 Transform_GetProjectionMatrix()
{
	#if TOOLSGFX
	return gScene.transforms.camToClpMatrix;
	#else
	return projectionMatrix;
	#endif
}

float4x4 Transform_GetViewProjectionMatrix()
{
	#if TOOLSGFX
	return gScene.transforms.offToClpMatrix;
	#else
	return viewProjectionMatrix;
	#endif
}

float3 Transform_GetCameraWorldPosition()
{
	#if TOOLSGFX
	return gScene.wldCameraPosition;
	#else
	return eyeOffset.xyz;
	#endif
}

float3x4 Transform_GetBoneMatrix(uint index, uint instance)
{
	#if TOOLSGFX
	return gObjectBones[index].objMatrixT;
	#else
	if(modelInstanceBuffer[instance].boneArrayIndex != 0)
		return boneMatrixBuffer[modelInstanceBuffer[instance].boneArrayIndex + index].objMatrixT;
	else
		return FLOAT3X4_IDENTITY;
	#endif
}

float3x4 Transform_GetPrevFrameBoneMatrix(uint index, uint instance)
{
	#if TOOLSGFX
	return gObjectBones[index].objMatrixT; // basically a placeholder since this would probably never happen in toolsgfx
	#else
	uint prevFrameIndex = modelInstanceBuffer[instance].flagsAndPrevFrameIndex & 0x0FFFFFFF;
	if(prevFrameIndex != 0)
		return boneMatrixBufferPrevFrame[prevFrameIndex + index].objMatrixT;
	else
		return FLOAT3X4_IDENTITY;
	#endif
}

row_major float4x4 Transform_GetWorldMatrix(uint instance)
{
	#if TOOLSGFX

	row_major float4x4 worldMatrix;

	if(instance)
		worldMatrix = gObjectInstanceData[instance].worldMatrix;
	else
		worldMatrix = gObject.worldMatrix;

	return worldMatrix;
	#else
	row_major float4x4 worldMatrix;

	if (modelInstanceBuffer[instance].worldMatrix)
		worldMatrix = float4x4(boneMatrixBuffer[modelInstanceBuffer[instance].boneArrayIndex + modelInstanceBuffer[instance].worldMatrix].objMatrixT, 0, 0, 0, 1);
	else
		worldMatrix = FLOAT4X4_IDENTITY;

	return worldMatrix;
	#endif
}

float3 Transform_GetWorldPosition(uint instance)
{
	#if TOOLSGFX
	row_major float4x4 worldMatrix;

	if(instance)
		worldMatrix = gObjectInstanceData[instance].worldMatrix;
	else
		worldMatrix = gObject.worldMatrix;

	return worldMatrix[3].xyz;
	#else
	row_major float4x4 worldMatrix;

	if (modelInstanceBuffer[instance].worldMatrix)
		worldMatrix = float4x4(boneMatrixBuffer[modelInstanceBuffer[instance].boneArrayIndex + modelInstanceBuffer[instance].worldMatrix].objMatrixT, 0, 0, 0, 1);
	else
		worldMatrix = FLOAT4X4_IDENTITY;

	return float3(worldMatrix[0].w, worldMatrix[1].w, worldMatrix[2].w);
	#endif
}

float3 Transform_NormalToWorld(float3 normal, uint instance)
{
	#if TOOLSGFX
	return mul(normal, (float3x3)Transform_GetWorldMatrix(instance));
	#else
	return mul((float3x3)Transform_GetWorldMatrix(instance), normal);
	#endif
}

float3 Transform_PositionToWorld(float3 position, uint instance)
{
	#if TOOLSGFX
	return mul(float4(position, 1), Transform_GetWorldMatrix(instance)).xyz;
	#else
	return mul(Transform_GetWorldMatrix(instance), float4(position, 1)).xyz;
	#endif
}

float3 Transform_GetViewDirection(float3 position)
{
	return position - Transform_GetCameraWorldPosition();
}

float3 Transform_OffsetToCamera(float3 position)
{
	return mul(float4(position - Transform_GetCameraWorldPosition(), 1), Transform_GetViewMatrix()).xyz;
}

float4 Transform_CameraToClip(float3 offset)
{
	return mul(float4(offset, 1), Transform_GetViewProjectionMatrix());
}

float4 Transform_OffsetToClip(float3 offset)
{
	return mul(float4(offset.xyz - Transform_GetCameraWorldPosition(), 1.0), Transform_GetViewProjectionMatrix());
}

// TO-DO: Move this to a better place and add siege animation support and make it look a bit better

#if GENERATE_MOTION_VECTOR

float4 Transform_GenerateMotionVector(in float3 position, in float4 weights, in uint4 boneIndices, in uint instance)
{
	uint prevFrameIndex = modelInstanceBuffer[instance].flagsAndPrevFrameIndex & 0x0FFFFFFF;

	if(prevFrameIndex != 0)
	{
		float3 outPosition = 0.0;
		if (weights.x > 0)
			outPosition += mul(Transform_GetPrevFrameBoneMatrix(boneIndices.x, instance) * weights.x, float4(position, 1));
		if (weights.y > 0)
			outPosition += mul(Transform_GetPrevFrameBoneMatrix(boneIndices.y, instance) * weights.y, float4(position, 1));
		if (weights.z > 0)
			outPosition += mul(Transform_GetPrevFrameBoneMatrix(boneIndices.z, instance) * weights.z, float4(position, 1));
		if (weights.w > 0)
			outPosition += mul(Transform_GetPrevFrameBoneMatrix(boneIndices.w, instance) * weights.w, float4(position, 1));
		position = outPosition;
	}
	else
	{
		if(modelInstanceBuffer[instance].boneArrayIndex != 0)
		{
			float3 outPosition = 0.0;
			if (weights.x > 0)
				outPosition += mul(Transform_GetBoneMatrix(boneIndices.x, instance) * weights.x, float4(position, 1));
			if (weights.y > 0)
				outPosition += mul(Transform_GetBoneMatrix(boneIndices.y, instance) * weights.y, float4(position, 1));
			if (weights.z > 0)
				outPosition += mul(Transform_GetBoneMatrix(boneIndices.z, instance) * weights.z, float4(position, 1));
			if (weights.w > 0)
				outPosition += mul(Transform_GetBoneMatrix(boneIndices.w, instance) * weights.w, float4(position, 1));
			position = outPosition;
		}
	}

	bool hasMatrix = modelInstanceBuffer[instance].worldMatrix != 0;

	hasMatrix = hasMatrix && modelInstanceBuffer[instance].boneArrayIndex == 0;
	hasMatrix = hasMatrix && prevFrameIndex != 0;

	uint matrixIndex = hasMatrix ? prevFrameIndex : modelInstanceBuffer[instance].worldMatrix;

	row_major float3x4 prevMatrix = FLOAT3X4_IDENTITY;

	if(matrixIndex != 0)
		prevMatrix = boneMatrixBufferPrevFrame[matrixIndex].objMatrixT;
	
	position = position - motionVectorConstants.prevFrameEyeOffset;
	position = mul(prevMatrix, float4(position, 1));

	return mul(float4(position, 1), motionVectorConstants.prevFrameOffToClpMatrixFull);
}

#endif

#endif