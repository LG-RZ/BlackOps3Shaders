#ifndef __CODE_CONSTANT_BUFFERS__
#define __CODE_CONSTANT_BUFFERS__

#include "hlslcodedefines.h"
#include "../gfxcore/hlslcoretypes.h"

cbuffer CodeSceneConstBuffer : register(b9) 
{
	CodeSceneConsts gScene : packoffset(c0.x);
};

cbuffer CodeObjectConstBuffer : register(b10) 
{
	CodeObjectConsts gObject : packoffset(c0.x);
};

cbuffer CodeObjectBonesConstBuffer : register(b11) 
{
	CodeObjectBonesConst gObjectBones[1024] : packoffset(c0.x);
};

#endif