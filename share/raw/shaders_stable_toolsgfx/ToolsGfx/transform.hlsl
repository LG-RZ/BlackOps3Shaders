#ifndef __LIB_TRANSFORM__
#define __LIB_TRANSFORM__

#include "globals.hlsl"
#include "../gfxcore/hlslcoretransform.h"
#include "../code/motion_vector_globals.h"

// Change the functions so they have their in-game counterparts
float3x4 get_bone_matrix(uint index, uint instance)
{
	#if TOOLSGFX
	return gObjectBones[index].objMatrixT;
	#else
	return boneMatrixBuffer[modelInstanceBuffer[instance].boneArrayIndex + index].objMatrixT;
	#endif
}

float4x4 get_world_matrix(uint instance)
{
	if (instance)
		return gObjectInstanceData[instance].worldMatrix;
	else
		return gObject.worldMatrix;
}

float3 transform_normal(float3 nor, float3x3 mat)
{
	return mul(nor, mat);
}

float3 transform_normal_to_world(float3 nor, uint instance)
{
	return mul(nor, (float3x3) get_world_matrix(instance));
}

float3 transform_normal(float3 nor, float weight, uint index, uint instance)
{
	return mul(nor, (float3x3)(get_bone_matrix(index, instance) * weight));
}

float3 transform_position(float3 pos, float3x4 mat)
{
	return mul(mat, float4(pos, 1));
}

float4 transform_position(float4 pos, float4x4 mat)
{
	return mul(pos, mat);
}

float3 transform_position(float3 pos, float4x4 mat)
{
	return mul(float4(pos, 1), mat).xyz;
}

float3 transform_position(float3 pos, float weight, uint index, uint instance)
{
	return transform_position(pos, get_bone_matrix(index, instance) * weight);
}

float3 transform_position_to_world(float3 pos, uint instance)
{
	return mul(float4(pos, 1), get_world_matrix(instance)).xyz;
}

float3 transform_offset_to_camera(float3 offset)
{
	return mul(float4(offset - gScene.wldCameraPosition, 1), gScene.transforms.offToCamMatrix).xyz;
}

float4 transform_camera_to_clip(float3 pos)
{
	return mul(float4(pos, 1), gScene.transforms.camToClpMatrix);
}

float4 transform_offset_to_clip(float3 pos)
{
	return mul(float4(pos - gScene.wldCameraPosition, 1), gScene.transforms.offToClpMatrix);
}

#endif