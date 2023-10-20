#ifndef __GFX_CORE_GBUFFER_INPUT__
#define __GFX_CORE_GBUFFER_INPUT__

#include "hlslcoreencode.h"
#include "hlslcoretransform.h"
#include "hlslcorerept.h"

struct GBufferVertexInput
{
	float3 position		: POSITION;
	float4 color		: COLOR;
	float2 texCoords	: TEXCOORD0;
	float3 normal		: NORMAL0;
	float4 tangent		: TANGENT0;
	float4 weights		: BLENDWEIGHT0;
	uint4  indices		: BLENDINDICES0;
};

struct GBufferPixelInput
{
	float4 position		: SV_POSITION;
	float  color		: COLOR1;
	float2 texCoords	: TEXCOORD0;
	float3 normal		: TEXCOORD1;
	float3 tangent		: TEXCOORD2;
	float3 biTangent	: TEXCOORD3;
};

#endif