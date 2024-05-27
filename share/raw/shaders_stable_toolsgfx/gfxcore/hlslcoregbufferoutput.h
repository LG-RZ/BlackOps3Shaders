#ifndef __GFX_CORE_GBUFFER_OUTPUT__
#define __GFX_CORE_GBUFFER_OUTPUT__

#include "hlslcoreencode.h"
#include "hlslcorerept.h"

struct GBufferPixelOutput
{
	float4 Albedo				: SV_TARGET0;
	float4 NormalGloss			: SV_TARGET1;
	float4 ReflectanceOcclusion	: SV_TARGET2;
	#if GENERATE_MOTION_VECTOR
	float2 Velocity				: SV_TARGET3;
	#endif
};

#endif