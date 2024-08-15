#ifndef __LIB_GPU_SKIN__
#define __LIB_GPU_SKIN__

#include "transform.hlsl"
#include "quaternion.hlsl"
#include "gfxcore/hlslcorerept.h"

#if USE_SIEGE_SKINNING

#if TOOLSGFX
Texture2D<float4> gpuSkinBase : register(t18);
Texture2D<float4> gpuSkinQuat : register(t19);
Texture2D<float4> gpuSkinPos : register(t20);
#else
Texture2D<float4> gpuSkinBase : register(t1);
Texture2D<float4> gpuSkinQuat : register(t2);
Texture2D<float4> gpuSkinPos : register(t3);
#endif

void GPUSkin_SiegeBlend(
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

	float3 transformedPosition = Quaternion_TransformVector(quat, offset);
	float3 transformedNormal = Quaternion_TransformVector(quat, normal);
	float3 transformedTangent = Quaternion_TransformVector(quat, tangent);
	
	blendedPosition += (pos + (transformedPosition + base)) * boneWeight;
	blendedNormal += transformedNormal * boneWeight;
	blendedTangent += transformedTangent * boneWeight;
}

void GPUSkin_SkinVertexSiege(inout float3 position, inout float3 normal, inout float3 tangent, float4 inWeights, uint4 inBoneIndices, uint instance)
{
	#if TOOLSGFX

	uint width, totalFrames;
	gpuSkinQuat.GetDimensions(width, totalFrames);
	
	float offset = (instance ? gObjectInstanceData[instance].siegeAnimOffset : gObject.siegeAnimOffset) + gScene.siegeTime * 30;
	float currentFrame = fmod(offset, totalFrames);
	float nextFrame = (currentFrame + 1) % totalFrames;
	float interpolationFactor = frac(currentFrame);

	#else

	float4 frameData = modelInstanceBuffer[instance].siegeAnimStateOffset ? boneMatrixBuffer[modelInstanceBuffer[instance].siegeAnimStateOffset].extra : 0.0;

	uint currentFrame = (uint)frameData.x;
	uint nextFrame = (uint)frameData.y;
	float interpolationFactor = frameData.z;

	#endif
	
	float3 blendedPosition = 0, blendedNormal = 0, blendedTangent = 0;
	
	GPUSkin_SiegeBlend(position, normal, tangent, inWeights.x, inBoneIndices.x, currentFrame, nextFrame, interpolationFactor, blendedPosition, blendedNormal, blendedTangent);
	GPUSkin_SiegeBlend(position, normal, tangent, inWeights.y, inBoneIndices.y, currentFrame, nextFrame, interpolationFactor, blendedPosition, blendedNormal, blendedTangent);
	GPUSkin_SiegeBlend(position, normal, tangent, inWeights.z, inBoneIndices.z, currentFrame, nextFrame, interpolationFactor, blendedPosition, blendedNormal, blendedTangent);
	GPUSkin_SiegeBlend(position, normal, tangent, inWeights.w, inBoneIndices.w, currentFrame, nextFrame, interpolationFactor, blendedPosition, blendedNormal, blendedTangent);
	
	position = blendedPosition;
	normal = normalize(blendedNormal);
	tangent = normalize(blendedTangent);
}

#endif

#if USE_GPU_SKIN

float3 GPUSkin_TransformNormal(float3 normal, float weight, uint index, uint instance)
{
	return mul((float3x3)(Transform_GetBoneMatrix(index, instance) * weight), normal);
}

float3 GPUSkin_TransformPosition(float3 position, float weight, uint index, uint instance)
{
	return mul(Transform_GetBoneMatrix(index, instance) * weight, float4(position, 1));
}

void GPUSkin_SkinVertexLinear(inout float3 position, inout float3 normal, inout float3 tangent, const float4 inWeights, const uint4 inBoneIndices, const uint instance)
{
	float3 outPosition = 0.0;
	float3 outNormal = 0.0;
	float3 outTangent = 0.0;

	if (inWeights.x > 0)
	{
		outPosition += GPUSkin_TransformPosition(position, inWeights.x, inBoneIndices.x, instance);
		outNormal += GPUSkin_TransformNormal(normal, inWeights.x, inBoneIndices.x, instance);
		outTangent += GPUSkin_TransformNormal(tangent, inWeights.x, inBoneIndices.x, instance);
	}
		
	if (inWeights.y > 0)
	{
		outPosition += GPUSkin_TransformPosition(position, inWeights.y, inBoneIndices.y, instance);
		outNormal += GPUSkin_TransformNormal(normal, inWeights.y, inBoneIndices.y, instance);
		outTangent += GPUSkin_TransformNormal(tangent, inWeights.y, inBoneIndices.y, instance);
	}
		
	if (inWeights.z > 0)
	{
		outPosition += GPUSkin_TransformPosition(position, inWeights.z, inBoneIndices.z, instance);
		outNormal += GPUSkin_TransformNormal(normal, inWeights.z, inBoneIndices.z, instance);
		outTangent += GPUSkin_TransformNormal(tangent, inWeights.z, inBoneIndices.z, instance);
	}
		
	if (inWeights.w > 0)
	{
		outPosition += GPUSkin_TransformPosition(position, inWeights.w, inBoneIndices.w, instance);
		outNormal += GPUSkin_TransformNormal(normal, inWeights.w, inBoneIndices.w, instance);
		outTangent += GPUSkin_TransformNormal(tangent, inWeights.w, inBoneIndices.w, instance);
	}

	position = outPosition;
	normal = normalize(outNormal);
	tangent = normalize(outTangent);
}

#endif

bool GPUSkin_HasBones(const uint instance)
{
	#if TOOLSGFX
	if (instance)
		return gObjectInstanceData[instance].hasBones;
	else
		return gObject.hasBones;
	#else
	return modelInstanceBuffer[instance].boneArrayIndex;
	#endif
}

bool GPUSkin_HasSiegeAnim(const uint instance)
{
	#if TOOLSGFX
	if (instance)
		return gObjectInstanceData[instance].hasSiegeAnim;
	else
		return gObject.hasSiegeAnim;
	#else
	return modelInstanceBuffer[instance].siegeAnimStateOffset ? boneMatrixBuffer[modelInstanceBuffer[instance].siegeAnimStateOffset].extra.w == 0.0 : false;
	#endif
}

void GPUSkin_SkinVertex(inout float3 position, inout float3 normal, inout float3 tangent, const float4 inWeights, const uint4 inBoneIndices, const uint instance)
{
	#if USE_GPU_SKIN && USE_SIEGE_SKINNING

	if (!GPUSkin_HasSiegeAnim(instance) && GPUSkin_HasBones(instance))
	{
		GPUSkin_SkinVertexLinear(position, normal, tangent, inWeights, inBoneIndices, instance);
	}
	else if(GPUSkin_HasSiegeAnim(instance))
	{
		GPUSkin_SkinVertexSiege(position, normal, tangent, inWeights, inBoneIndices, instance);
	}

	#elif USE_GPU_SKIN

	if (GPUSkin_HasBones(instance))
	{
		GPUSkin_SkinVertexLinear(position, normal, tangent, inWeights, inBoneIndices, instance);
	}

	#elif USE_SIEGE_SKINNING

	if(GPUSkin_HasSiegeAnim(instance))
	{
		GPUSkin_SkinVertexSiege(position, normal, tangent, inWeights, inBoneIndices, instance);
	}

	#endif
}

#endif