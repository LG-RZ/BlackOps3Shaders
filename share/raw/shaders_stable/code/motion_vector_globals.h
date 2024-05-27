#ifndef __CODE_MOTION_VECTOR_GLOBALS__
#define __CODE_MOTION_VECTOR_GLOBALS__

#include "hlslcodedefines.h"
#include "gfxcore/hlslcoreenums.h"
#include "lib/globals.hlsl"

#if !TOOLSGFX

struct MotionVectorConstants
{
    row_major float4x4 prevFrameOffToClpMatrixFull;
    row_major float4x4 prevFrameOffToClpMatrixPartial;
    row_major float4x4 curFrameCamToOffMatrix;
    float3 prevFrameEyeOffset;
    float motionStrength;
    float3 eyeOffsetFrameDelta;
    float _padding_23;
    float2 curFrameHalfNearPlaneSize;
    float2 _padding_26;
};

cbuffer MotionVectorParams : register(b7)
{
    MotionVectorConstants motionVectorConstants : packoffset(c0);
}

// cba to think of anything rn maybe sometime later
float2 MotionVector_CalculateVelocity(float2 position, float4 motionVector)
{
    float4 r0, r1;
    r0.xy = motionVector.xy / motionVector.ww;
    r0.zw = renderTargetSize.xy * 0.5;
    r1.x = r0.x * r0.z;
    r1.y = r0.y * -r0.w;
    r0.xy = renderTargetSize.xy * 0.5 + r1.xy;
    r0.xy = position + -r0.xy;
    r0.zw = abs(r0.xy) * 0.1;
    r0.zw = min(r0.zw, 1.0);
    r1.xy = abs(r0.xy) - 10.0;
    r1.xy = saturate(r1.xy / 30.0);
    r0.zw = r0.zw - r1.xy;
    r0.zw = r0.zw * 0.5 + r1.xy;
    return r0.xy >= 0.0 ? r0.zw : -r0.zw;
}

#endif

#endif