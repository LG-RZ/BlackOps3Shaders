#ifndef __LIB_VERTDECL_VERTEX_BINORMAL__
#define __LIB_VERTDECL_VERTEX_BINORMAL__

float Vertex_DecodeBiNormalSign(const float binormalSign)
{
	#if TOOLSGFX
	return binormalSign;
	#else
	return binormalSign * 2 - 1;
	#endif
}

float3 Vertex_CalculateBiNormal(const float3 normal, const float3 tangent, const float binormalSign)
{
	return cross(normal, tangent) * binormalSign;
}

#endif