#ifndef __GFX_CORE_MIN_MAX__
#define __GFX_CORE_MIN_MAX__

float min3(float x, float y, float z)
{
	return min(min(z, y), x);
}

float min3(float3 xyz)
{
	return min3(xyz.x, xyz.y, xyz.z);
}

float max3(float x, float y, float z)
{
	return max(max(z, y), x);
}

float max3(float3 xyz)
{
	return max3(xyz.x, xyz.y, xyz.z);
}

float min4(float x, float y, float z, float w)
{
	return min(min(min(w, z), y), x);
}

float min4(float4 xyzw)
{
	return min4(xyzw.x, xyzw.y, xyzw.z, xyzw.w);
}

float max4(float x, float y, float z, float w)
{
	return max(max(max(w, z), y), x);
}

float max4(float4 xyzw)
{
	return max4(xyzw.x, xyzw.y, xyzw.z, xyzw.w);
}

float max4(float x, float3 yzw)
{
	return max4(x, yzw.x, yzw.y, yzw.z);
}

#endif