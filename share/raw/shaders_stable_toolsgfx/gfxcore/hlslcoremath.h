#ifndef __GFX_CORE_MATH__
#define __GFX_CORE_MATH__

#include "hlslcoredefines.h"
#include "hlslcoreminmax.h"

// Unit conversions

float InchToCentimeter(float inch)
{
	return inch * 2.54;
}

float CentimeterToInch(float centimeter)
{
	return centimeter / 2.54;
}

float2 InchToCentimeter(float2 inch)
{
	return inch * 2.54;
}

float2 CentimeterToInch(float2 centimeter)
{
	return centimeter / 2.54;
}

float3 InchToCentimeter(float3 inch)
{
	return inch * 2.54;
}

float3 CentimeterToInch(float3 centimeter)
{
	return centimeter / 2.54;
}

// Color

#define R11G11B10_MAX float3(65024, 65024, 64512)

// Fix for some intrinsic functions

bool IsFinite(float value)
{
    return (asuint(value) & 0x7F800000) != 0x7F800000;
}

bool IsNaN(float x)
{
    return (asuint(x) & 0x7FFFFFFF) > 0x7F800000;
}

bool IsInf(float x)
{
    return (asuint(x) & 0x7FFFFFFF) == 0x7F800000;
}

bool2 IsFinite(float2 value)
{
    return (asuint(value) & 0x7F800000) != 0x7F800000;
}

bool2 IsNaN(float2 x)
{
    return (asuint(x) & 0x7FFFFFFF) > 0x7F800000;
}

bool2 IsInf(float2 x)
{
    return (asuint(x) & 0x7FFFFFFF) == 0x7F800000;
}

bool3 IsFinite(float3 value)
{
    return (asuint(value) & 0x7F800000) != 0x7F800000;
}

bool3 IsNaN(float3 x)
{
    return (asuint(x) & 0x7FFFFFFF) > 0x7F800000;
}

bool3 IsInf(float3 x)
{
    return (asuint(x) & 0x7FFFFFFF) == 0x7F800000;
}

// Float3x4

#define FLOAT3X4_IDENTITY float3x4( 1, 0, 0, 0, \
                                    0, 1, 0, 0, \
                                    0, 0, 1, 0)

// Float4x4

#define FLOAT4X4_IDENTITY float4x4( 1, 0, 0, 0, \
                                    0, 1, 0, 0, \
                                    0, 0, 1, 0, \
                                    0, 0, 0, 1 )

float4x4 Float4x4_CreateScale(float3 scale)
{
	return float4x4(
		scale.x, 0, 0, 0,
		0, scale.y, 0, 0,
		0, 0, scale.z, 0,
		0, 0, 0, 1);
}

float4x4 Float4x4_CreateRotationX(float angle)
{
	float cosValue = cos(angle);
	float sinValue = sin(angle);

	return float4x4(
		1, 0, 0, 0,
		0, cosValue, -sinValue, 0,
		0, sinValue, cosValue, 0,
		0, 0, 0, 1);
}

float4x4 Float4x4_CreateRotationY(float angle)
{
	float cosValue = cos(angle);
	float sinValue = sin(angle);
	
	return float4x4(
		cosValue, 0, -sinValue, 0,
		0, 1, 0, 0,
		sinValue, 0, cosValue, 0,
		0, 0, 0, 1);
}

float4x4 Float4x4_CreateRotationZ(float angle)
{
	float cosValue = cos(angle);
	float sinValue = sin(angle);

	return float4x4(
		cosValue, -sinValue, 0, 0,
		sinValue, cosValue, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1);
}

// Float3x3

#define FLOAT3X3_IDENTITY float3x3( 1, 0, 0, \
                                    0, 1, 0, \
                                    0, 0, 1 )

float3x3 Float3x3_CreateScale(float3 scale)
{
	return float3x3(
		scale.x, 0, 0,
		0, scale.y, 0,
		0, 0, scale.z);
}

float3x3 Float3x3_CreateRotationX(float angle)
{
	float cosValue = cos(angle);
	float sinValue = sin(angle);

	return float3x3(
		1, 0, 0,
		0, cosValue, -sinValue,
		0, sinValue, cosValue);

}

float3x3 Float3x3_CreateRotationY(float angle)
{
	float cosValue = cos(angle);
	float sinValue = sin(angle);
	
	return float3x3(
		cosValue, 0, -sinValue,
		0, 1, 0,
		sinValue, 0, cosValue);
}

float3x3 Float3x3_CreateRotationZ(float angle)
{
	float cosValue = cos(angle);
	float sinValue = sin(angle);

	return float3x3(
		cosValue, -sinValue, 0,
		sinValue, cosValue, 0,
		0, 0, 1);
}

#endif