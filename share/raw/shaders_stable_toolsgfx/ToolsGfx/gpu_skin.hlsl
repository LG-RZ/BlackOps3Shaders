#ifndef __LIB_GPU_SKIN__
#define __LIB_GPU_SKIN__

#include "transform.hlsl"
#include "quaternion.hlsl"
#include "../gfxcore/hlslcorerept.h"


#if USE_SIEGE_SKINNING

Texture2D<float4> gpuSkinBase : register(t18);
Texture2D<float4> gpuSkinQuat : register(t19);
Texture2D<float4> gpuSkinPos : register(t20);

void siege_blend(
	in float3 position,
	in float3 normal,
	in float3 tangent,
	in float boneWeight,
	in uint boneIndex,
	in uint currentFrame,
	in uint nextFrame,
	in float interpolationFactor,
	inout float3 blendedPosition,
	inout float3 blendedNormal,
	inout float3 blendedTangent)
{
	float4 q1 = gpuSkinQuat.Load(int3(boneIndex, currentFrame, 0));
	float4 q2 = gpuSkinQuat.Load(int3(boneIndex, nextFrame, 0));
	float3 p1 = gpuSkinPos.Load(int3(boneIndex, currentFrame, 0)).xyz;
	float3 p2 = gpuSkinPos.Load(int3(boneIndex, nextFrame, 0)).xyz;
	float3 base = gpuSkinBase.Load(int3(boneIndex, 0, 0)).xyz;
	
	float4 quat = normalize(lerp(q1, q2, interpolationFactor));
	float3 pos = lerp(p1, p2, interpolationFactor);
	
	float3 offset = position - base;

	float3 transformedPosition = transform_vector(quat, offset);
	float3 transformedNormal = transform_vector(quat, normal);
	float3 transformedTangent = transform_vector(quat, tangent);
	
	blendedPosition += (pos + (transformedPosition + base)) * boneWeight;
	blendedNormal += transformedNormal * boneWeight;
	blendedTangent += transformedTangent * boneWeight;
}

void siege_skin(inout float3 position, inout float3 normal, inout float3 tangent, float4 inWeights, uint4 inBoneIndices, uint instance)
{
	uint width, totalFrames;
	gpuSkinQuat.GetDimensions(width, totalFrames);
	
	float offset = (instance ? gObjectInstanceData[instance].siegeAnimOffset : gObject.siegeAnimOffset) + gScene.siegeTime * 30;
	float currentFrame = fmod(offset, totalFrames);
	float nextFrame = (currentFrame + 1) % totalFrames;
	float interpolationFactor = frac(currentFrame);
	
	float3 blendedPosition = 0, blendedNormal = 0, blendedTangent = 0;
	
	siege_blend(position, normal, tangent, inWeights.x, inBoneIndices.x, currentFrame, nextFrame, interpolationFactor, blendedPosition, blendedNormal, blendedTangent);
	siege_blend(position, normal, tangent, inWeights.y, inBoneIndices.y, currentFrame, nextFrame, interpolationFactor, blendedPosition, blendedNormal, blendedTangent);
	siege_blend(position, normal, tangent, inWeights.z, inBoneIndices.z, currentFrame, nextFrame, interpolationFactor, blendedPosition, blendedNormal, blendedTangent);
	siege_blend(position, normal, tangent, inWeights.w, inBoneIndices.w, currentFrame, nextFrame, interpolationFactor, blendedPosition, blendedNormal, blendedTangent);
	
	position = blendedPosition;
	normal = normalize(blendedNormal);
	tangent = normalize(blendedTangent);
}

#endif

#if USE_GPU_SKIN

void linear_skin(inout float3 position, inout float3 normal, inout float3 tangent, const float4 inWeights, const uint4 inBoneIndices, const uint instance)
{
	if (inWeights.x != 0)
	{
		position = transform_position(position, inWeights.x, inBoneIndices.x, instance);
		normal = transform_normal(normal, inWeights.x, inBoneIndices.x, instance);
		tangent = transform_normal(tangent, inWeights.x, inBoneIndices.x, instance);
	}
		
	if (inWeights.y != 0)
	{
		position = transform_position(position, inWeights.y, inBoneIndices.y, instance);
		normal = transform_normal(normal, inWeights.y, inBoneIndices.y, instance);
		tangent = transform_normal(tangent, inWeights.y, inBoneIndices.y, instance);
	}
		
	if (inWeights.z != 0)
	{
		position = transform_position(position, inWeights.z, inBoneIndices.z, instance);
		normal = transform_normal(normal, inWeights.z, inBoneIndices.z, instance);
		tangent = transform_normal(tangent, inWeights.z, inBoneIndices.z, instance);
	}
		
	if (inWeights.w != 0)
	{
		position = transform_position(position, inWeights.w, inBoneIndices.w, instance);
		normal = transform_normal(normal, inWeights.w, inBoneIndices.w, instance);
		tangent = transform_normal(tangent, inWeights.w, inBoneIndices.w, instance);
	}
}

#endif

bool has_bones(const uint instance)
{
	if (instance)
		return gObjectInstanceData[instance].hasBones;
	else
		return gObject.hasBones;
}

bool has_siege_anim(const uint instance)
{
	if (instance)
		return gObjectInstanceData[instance].hasSiegeAnim;
	else
		return gObject.hasSiegeAnim;
}

void skin(inout float3 position, inout float3 normal, inout float3 tangent, const float4 inWeights, const uint4 inBoneIndices, const uint instance)
{
#if USE_GPU_SKIN
	if (has_bones(instance))
	{
		linear_skin(position, normal, tangent, inWeights, inBoneIndices, instance);
	}
#endif
#if USE_SIEGE_SKINNING
	if(has_siege_anim(instance))
	{
		siege_skin(position, normal, tangent, inWeights, inBoneIndices, instance);
	}
#endif
}

#endif