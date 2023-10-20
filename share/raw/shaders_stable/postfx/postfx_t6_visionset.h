#ifndef __POSTFX_T6_VISIONSET__
#define __POSTFX_T6_VISIONSET__

#if USE_T6_VISIONSET
float visionSetBrightness;
float4 visColorRangeS;
float4 visColorRangeE;
float4 visColorShadowMatrixR;
float4 visColorShadowMatrixG;
float4 visColorShadowMatrixB;
float4 visColorHilightMatrixR;
float4 visColorHilightMatrixG;
float4 visColorHilightMatrixB;
float4 visColorMidtoneMatrixR;
float4 visColorMidtoneMatrixG;
float4 visColorMidtoneMatrixB;
float4 visColorFinalGamma;
float4 visColorFinalSaturation;
float4 visColorFinalBlend;
#endif

void postfx_t6_visionset_calculate_ranges(inout float4 colorRangeS, inout float4 colorRangeE)
{
	float4 rangeStart = colorRangeS;
	float4 rangeEnd = colorRangeE;

	float fVar7 = rangeStart.x;
	float fVar8 = rangeEnd.x;

	if (fVar8 <= fVar7)
		fVar8 = fVar7 + 0.0002441406;

	float fVar6 = rangeStart.y;
	float fVar9 = rangeEnd.y;

	if (fVar9 <= fVar6)
		fVar6 = fVar9 - 0.0002441406;

	float fVar5 = rangeStart.z;
	float fVar10 = rangeEnd.z;

	if (fVar10 <= fVar5)
		fVar5 = fVar10 - 0.0002441406;

	float fVar11 = rangeStart.w;

	if (fVar11 <= fVar10)
		fVar11 = fVar10 + 0.0002441406;

	float fVar4 = rangeEnd.w;

	if (fVar4 <= fVar11)
		fVar4 = fVar11 + 0.0002441406;

	float local_d0 = 1.0 / (fVar7 - fVar8);
	float auVar2 = fVar8 * local_d0 * -1;
	fVar9 = 1.0 / (fVar9 - fVar6);
	float auVar3 = fVar6 * fVar9 * -1;
	fVar6 = 1.0 / (fVar10 - fVar5);
	fVar10 = 1.0 / (fVar11 - fVar4);
	fVar8 = fVar5 * fVar6 * -1;
	fVar7 = fVar4 * fVar10 * -1;
	colorRangeS = float4(local_d0, fVar9, fVar6, fVar10);
	colorRangeE = float4(auVar2, auVar3, fVar8, fVar7);
}

float4 postfx_t6_visionset_apply_vision(
	in float4 color,
	const float4 colorRangeS,
	const float4 colorRangeE,
	const float3x4 smrRed,
	const float3x4 smrGreen,
	const float3x4 smrBlue,
	const float4 finalGamma,
	const float4 finalSaturation,
	const float4 finalBlend)
{
	const float3 luminanceValue = float3(0.2126, 0.7152, 0.0722);
	float4 r0, r1, r2, r3, r4;
	float4 o0;
	r0.xyzw = color.xyzw;
	r1.x = dot(r0.xyz, luminanceValue);
	r1.xyzw = saturate(r1.x * colorRangeS.xzyw + colorRangeE.xzyw);
	r1.y = r1.w * r1.y;
	r2.xyz = r1.xyz * r1.xyz;
	r1.xyz = r1.xyz * -2.0 + 3.0;
	r1.xyz = r1.xyz * r2.xyz;
	r1.w = dot(r1.xzy, 1.0);
	r1.w = 1 / r1.w;
	r1.xyz = r1.w * r1.xyz;
	r2.xyz = r0.xyz * r0.xyz;
	r2.w = r0.w;
	r3.xyz = mul(smrRed, r2.xyzw);
	r0.w = saturate(dot(r3.xyz, r1.xyz));
	r3.x = log2(r0.w);
	r4.xyz = mul(smrGreen, r2.xyzw);
	r0.w = saturate(dot(r4.xyz, r1.xyz));
	r3.y = log2(r0.w);
	r4.xyz = mul(smrBlue, r2.xyzw);
	o0.w = r2.w;
	r0.w = saturate(dot(r4.xyz, r1.xyz));
	r3.z = log2(r0.w);
	r1.xyz = r3.xyz * finalGamma.xyz;
	r1.xyz = exp2(r1.xyz);
	r0.w = dot(r1.xyz, finalSaturation.xyz);
	r1.xyz = -r0.w + r1.xyz;
	r1.xyz = finalSaturation.w * r1.xyz + r0.w;
	r0.xyz = -r0.xyz * r0.xyz + r1.xyz;
	r0.xyz = finalBlend.xyz * r0.xyz + r2.xyz;
	r0.w = 1.0;
	o0.xyz = sqrt(r0.xyz);
	return o0;
}

float4 postfx_t6_visionset_apply_vision(
	in float4 color,
	float4 colorRangeS,
	float4 colorRangeE,
	const float4 shadowMatrixR,
	const float4 shadowMatrixG,
	const float4 shadowMatrixB,
	const float4 hilightMatrixR,
	const float4 hilightMatrixG,
	const float4 hilightMatrixB,
	const float4 midtoneMatrixR,
	const float4 midtoneMatrixG,
	const float4 midtoneMatrixB,
	const float4 finalGamma,
	const float4 finalSaturation,
	const float4 finalBlend)
{
	postfx_t6_visionset_calculate_ranges(colorRangeS, colorRangeE);

	return postfx_t6_visionset_apply_vision(
		color,
		colorRangeS,
		colorRangeE,
		float3x4(shadowMatrixR, midtoneMatrixR, hilightMatrixR),
		float3x4(shadowMatrixG, midtoneMatrixG, hilightMatrixG),
		float3x4(shadowMatrixB, midtoneMatrixB, hilightMatrixB),
		finalGamma,
		finalSaturation,
		finalBlend);
}

#endif