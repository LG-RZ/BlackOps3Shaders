#ifndef __CODE_OIT__
#define __CODE_OIT__

#include "gfxcore/hlslcoreminmax.h"

#ifndef bitFieldInsert
#define bitFieldInsert(width, offset, src2, src3) \
	((src2 << offset) & ((((1 << width) - 1) << offset) & 0xffffffff)) | (src3 & ~((((1 << width) - 1) << offset) & 0xffffffff))
#endif

#ifndef bitFieldExtract
#define bitFieldExtract(width, offset, src2) \
	width == 0 ? 0 : (width + offset < 32) ? (src2 << (32 - (width + offset))) >> (32 - width) : src2 >> offset;
#endif

#define OIT_LAYER_COUNT 9

uint OIT_PackColor(float3 color)
{
	uint Result;

	float base = abs(max3(color));

	uint exponent = (asuint(base) & 0x7F800000) + 0x00800000;

	color += asfloat(exponent);

	uint red = bitFieldExtract(8, 15, asuint(color.r));
	uint green = bitFieldInsert(8, 8, asuint(color.g) >> 15, 0);
	uint blue = bitFieldInsert(8, 16, asuint(color.b) >> 15, 0);

	Result = (exponent << 1) + (red + green + blue);

	return Result;
}

uint OIT_PackComputeSprites(bool computeSprites)
{
	return computeSprites ? 1 : 0;
}

uint OIT_PackAlpha(float alpha)
{
	return (uint)(saturate(alpha) * 2046) & 2046;
}

uint OIT_PackDepth(float depth)
{
	return asuint(depth) << 2;
}

bool OIT_UnpackComputeSprites(uint Data)
{
	return (Data & 0x1) != 0x0;
}

float OIT_UnpackAlpha(uint Data)
{
	return ((float)(Data & 2046)) / 2046.0f;
}

float OIT_UnpackDepth(uint Data)
{
	return asfloat(((Data & 0xFFFFF800) >> 2) & 0x3FFFFFFF);
}

float3 OIT_UnpackColor(uint Data)
{
	return 0;
}

#endif