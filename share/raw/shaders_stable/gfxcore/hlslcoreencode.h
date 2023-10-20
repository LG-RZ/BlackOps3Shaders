#ifndef __CORE_ENCODE__
#define __CORE_ENCODE__

#include "hlslcorepssl_to_hlsl.h"
#include "hlslcoretypes.h"

float normal_encode(float normal)
{
	return normal * 0.5 + 0.5;
}

float2 normal_encode(float2 normal)
{
	return normal * 0.5 + 0.5;
}

float3 normal_encode(float3 normal)
{
	return normal * 0.5 + 0.5;
}

float4 normal_encode(float4 normal)
{
	return normal * 0.5 + 0.5;
}

float normal_decode(float normal)
{
	return normal * 2.0 - 1.0;
}

float2 normal_decode(float2 normal)
{
	return normal * 2.0 - 1.0;
}

float3 normal_decode(float3 normal)
{
	return normal * 2.0 - 1.0;
}

float4 normal_decode(float4 normal)
{
	return normal * 2.0 - 1.0;
}

#endif