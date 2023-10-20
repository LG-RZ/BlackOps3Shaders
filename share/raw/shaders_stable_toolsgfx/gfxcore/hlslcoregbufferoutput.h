#ifndef __GFX_CORE_GBUFFER_OUTPUT__
#define __GFX_CORE_GBUFFER_OUTPUT__

#include "hlslcoreencode.h"
#include "hlslcorerept.h"

struct GBufferPixelOutput
{
	float4 albedo				: SV_TARGET0;
	float4 normalGloss			: SV_TARGET1;
	float4 reflectanceOcclusion	: SV_TARGET2;
};

#endif