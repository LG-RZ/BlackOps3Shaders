#ifndef __LIB_VERTDECL_VERTEX_TANGENTSPACE__
#define __LIB_VERTDECL_VERTEX_TANGENTSPACE__

#include "vertdecl_packedunitvec.hlsl"
#include "vertdecl_vertex_binormal.hlsl"

float3 decode_normal(const float3 normal)
{
	#if TOOLSGFX
	return normal;
	#else
	return normal * 2 - 1;
	#endif
}

#endif