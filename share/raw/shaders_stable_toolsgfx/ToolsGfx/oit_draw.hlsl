#ifndef __LIB_OIT_DRAW__
#define __LIB_OIT_DRAW__

#include "globals.hlsl"
#include "../code/oit.h"
#include "../gfxcore/hlslcoreminmax.h"
#include "../gfxcore/hlslcoreencode.h"

#ifndef bitFieldInsert
#define bitFieldInsert(width, offset, src2, src3) \
	((src2 << offset) & ((((1 << width) - 1) << offset) & 0xffffffff)) | (src3 & ~((((1 << width) - 1) << offset) & 0xffffffff))
#endif

#ifndef bitFieldExtract
#define bitFieldExtract(width, offset, src2) \
	width == 0 ? 0 : (width + offset < 32) ? (src2 << (32 - (width + offset))) >> (32 - width) : src2 >> offset;
#endif

#if USE_OIT

RWTexture2D<uint> gOITFragmentCount : register(u6);
RWTexture2DArray<uint2> gOITFragmentData : register(u7);

float4 oit_draw(const float3 position, const float4 inColor, const float3 inGreyscaleColor, const uint maxEntries = 9, const uint computeSprites = 0)
{
	float greyscale = saturate(dot(inGreyscaleColor, float3(0.2990, 0.5870, 0.1140)));
	float alpha = inColor.a + greyscale;
	float3 color = inColor.rgb * alpha;
	
	if (!all(float4(color, alpha) == 0))
	{
		uint count;
		
		InterlockedAdd(gOITFragmentCount[position.xy], 1, count);
		
		if (count < maxEntries)
		{
			uint2 data;
			uint1 unk1 = (asuint(abs(max3(color))) & 0x7F800000) + 0x00800000;
			float3 unk2 = color + asfloat(unk1);
			uint1 unk3 = bitFieldExtract(8, 15, asuint(unk2.x));
			uint2 unk4 = bitFieldInsert(8, uint2(8, 16), (asuint(unk2.yz) >> 15), 0);
			uint1 unk5 = unk3 + unk4.x + unk4.y;
			float unk6 = saturate(alpha) * 2046;
			uint1 unk7 = asuint(position.z) << 2;
			uint1 unk8 = unk6;
			unk8 = unk8 & 2046;
			
			data.x = (unk1 << 1) + unk5;
			data.y = bitFieldInsert(11, 0, unk8, unk7);
			if (computeSprites != 0)
				data.y = bitFieldInsert(1, 0, computeSprites, data.y);
			
			gOITFragmentData[uint3(position.xy, count)] = data;
			
			return 0;
		}
		
		return float4(inColor.rgb, alpha);
	}
	
	return 0;
}

#endif

#endif