#ifndef __CODE_INSTANCING__
#define __CODE_INSTANCING__

struct CodeObjectConsts 
{
	row_major float4x4 worldMatrix;
	float4 customFloat4s[7];
	int4 customInt4s;
	uint hasBones;
	uint hasSiegeAnim;
	float siegeAnimOffset;
	float sortDepth;
};

StructuredBuffer<CodeObjectConsts> gObjectInstanceData : register(t30);

#endif