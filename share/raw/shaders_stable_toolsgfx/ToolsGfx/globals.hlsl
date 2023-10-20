#ifndef __LIB_GLOBALS__
#define __LIB_GLOBALS__

// TO-DO:
// Move most normal operations to vertdecl_vertex_tangentspace.hlsl
// Put all operations related to bi-tangents/bi-normals in vertdecl_vertex_binormal.hlsl

// Credits to scobulala for this
#if TOOLSGFX
#define INSTANCE_SEMANTIC INSTANCEID
#else
#define INSTANCE_SEMANTIC TEXCOORD15
#endif

#include "../code/hlslcodeinstancing.h"
#include "../code/hlslregreserve.h"
#include "../code/hlslcodeconstantbuffers.h"
//#include "../gfxcore/nvhlslextns.h" // fix later

#endif