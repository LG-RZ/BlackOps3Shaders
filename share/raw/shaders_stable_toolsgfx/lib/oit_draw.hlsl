#ifndef __LIB_OIT_DRAW__
#define __LIB_OIT_DRAW__

#include "globals.hlsl"
#include "code/oit.h"
#include "gfxcore/hlslcoreminmax.h"
#include "gfxcore/hlslcoreencode.h"

#if USE_OIT

RWTexture2D<uint> gOITFragmentCount : register(u6);
RWTexture2DArray<uint2> gOITFragmentData : register(u7);

float4 OIT_Draw(int2 position, float depth, float3 inColor, float alpha, uint maxEntries = OIT_LAYER_COUNT, bool computeSprites = false)
{
	float3 color = inColor * alpha;

	if(!all(float4(color, alpha) == 0))
	{
		uint count;

		InterlockedAdd(gOITFragmentCount[position.xy], 1, count);

		if (count < maxEntries)
		{
			uint Color;
			uint AlphaDepthSprite;

			Color = OIT_PackColor(color);

			AlphaDepthSprite = OIT_PackAlpha(alpha);
			AlphaDepthSprite = bitFieldInsert(11, 0, AlphaDepthSprite, OIT_PackDepth(depth));

			if(computeSprites)
				AlphaDepthSprite = bitFieldInsert(1, 0, OIT_PackComputeSprites(computeSprites), AlphaDepthSprite);

			gOITFragmentData[uint3(position, count)] = uint2(Color, AlphaDepthSprite);
			
			return 0;
		}

		return float4(inColor.rgb, 1.0);
	}

	return 0;
}

#endif

#endif