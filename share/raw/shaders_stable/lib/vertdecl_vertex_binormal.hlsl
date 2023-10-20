#ifndef __LIB_VERTDECL_VERTEX_BINORMAL__
#define __LIB_VERTDECL_VERTEX_BINORMAL__

float decode_binormal_sign(const float binormalSign)
{
	#if TOOLSGFX
	return binormalSign;
	#else
	return binormalSign * 2 - 1;
	#endif
}

float3 get_vertex_binormal(const float3 normal, const float3 tangent, const float binormalSign)
{
	return cross(normal, tangent) * binormalSign;
}

#endif