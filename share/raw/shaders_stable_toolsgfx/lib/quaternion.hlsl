#ifndef __LIB_QUATERNION__
#define __LIB_QUATERNION__

float3 Quaternion_TransformVector(float4 quat, float3 vec)
{
	float3 t = 2 * cross(quat.xyz, vec);
	return vec + quat.w * t + cross(quat.xyz, t);
}

#endif