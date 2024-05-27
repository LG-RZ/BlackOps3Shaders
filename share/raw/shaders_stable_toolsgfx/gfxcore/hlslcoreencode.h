#ifndef __CORE_ENCODE__
#define __CORE_ENCODE__

#include "hlslcorepssl_to_hlsl.h"
#include "hlslcoretypes.h"

float Normal_Encode(float Normal)
{
	return Normal * 0.5 + 0.5;
}

float2 Normal_Decode(float2 Normal)
{
	return Normal * 2.0 - 1.0;
}

#endif