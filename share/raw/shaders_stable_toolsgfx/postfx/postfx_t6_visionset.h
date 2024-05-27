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

void PostFx_T6_VisionSetCalculateRanges(inout float4 colorRangeS, inout float4 colorRangeE)
{
	const float OneOver4096 = 1.0 / 4096.0;

	float4 rangeStart = colorRangeS;
	float4 rangeEnd = colorRangeE;

	float fVar7 = rangeStart.x;
	float fVar8 = rangeEnd.x;

	if (fVar8 <= fVar7)
		fVar8 = fVar7 + OneOver4096;

	float fVar6 = rangeStart.y;
	float fVar9 = rangeEnd.y;

	if (fVar9 <= fVar6)
		fVar6 = fVar9 - OneOver4096;

	float fVar5 = rangeStart.z;
	float fVar10 = rangeEnd.z;

	if (fVar10 <= fVar5)
		fVar5 = fVar10 - OneOver4096;

	float fVar11 = rangeStart.w;

	if (fVar11 <= fVar10)
		fVar11 = fVar10 + OneOver4096;

	float fVar4 = rangeEnd.w;

	if (fVar4 <= fVar11)
		fVar4 = fVar11 + OneOver4096;

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

float3 PostFx_T6_GetLutTexCoords(float2 texCoords)
{
	const float4 postFxControlF = float4(0.5, 0.5, 0.5, 0.0);

	return float3(texCoords.x, (texCoords.y * postFxControlF.y) + postFxControlF.yz);
}

float4 PostFx_T6_SampleLut(
	Texture2D<float4> lutTexture,
	SamplerState lutSampler,
	float3 lutTexCoords,
	const float4 colorRangeS,
	const float4 colorRangeE,
	const row_major float3x4 smhRed,
	const row_major float3x4 smhGreen,
	const row_major float3x4 smhBlue,
	const float4 finalGamma,
	const float4 finalSaturation,
	const float4 finalBlend)
{
	const float4 postFxControlE = float4(0.5, 0.5, 0.0, 0.0);

	float4 r0, r1, r2, r3, r4, o0;
	r0.xyzw = lutTexture.Sample(lutSampler, lutTexCoords.xz).xyzw;
	r0.xyzw = postFxControlE.yyyy * r0.xyzw;
	r1.xyzw = lutTexture.Sample(lutSampler, lutTexCoords.xy).xyzw;
	r0.xyzw = r1.xyzw * postFxControlE.xxxx + r0.xyzw;
	r1.x = dot(r0.xyz, float3(0.212585449,0.715194702,0.0722198486));
	r1.xyzw = saturate(r1.xxxx * colorRangeS.xzyw + colorRangeE.xzyw);
	r1.y = r1.y * r1.w;
	r2.xyz = r1.xyz * r1.xyz;
	r1.xyz = r1.xyz * -2.0 + 3.0;
	r1.xyz = r2.xyz * r1.xyz;
	r1.w = dot(r1.xzy, 1.0);
	r1.w = 1 / r1.w;
	r1.xyz = r1.xyz * r1.www;
	r2.xyz = r0.xyz * r0.xyz;
	r2.w = r0.w;
	r3.x = dot(r2.xyzw, smhRed[0].xyzw);
	r3.y = dot(r2.xyzw, smhRed[1].xyzw);
	r3.z = dot(r2.xyzw, smhRed[2].xyzw);
	r0.w = saturate(dot(r3.xyz, r1.xyz));
	r3.x = log2(r0.w);
	r4.x = dot(r2.xyzw, smhGreen[0].xyzw);
	r4.y = dot(r2.xyzw, smhGreen[1].xyzw);
	r4.z = dot(r2.xyzw, smhGreen[2].xyzw);
	r0.w = saturate(dot(r4.xyz, r1.xyz));
	r3.y = log2(r0.w);
	r4.x = dot(r2.xyzw, smhBlue[0].xyzw);
	r4.y = dot(r2.xyzw, smhBlue[1].xyzw);
	r4.z = dot(r2.xyzw, smhBlue[2].xyzw);
	o0.w = r2.w;
	r0.w = saturate(dot(r4.xyz, r1.xyz));
	r3.z = log2(r0.w);
	r1.xyz = finalGamma.xyz * r3.xyz;
	r1.xyz = exp2(r1.xyz);
	r0.w = dot(r1.xyz, finalSaturation.xyz);
	r1.xyz = r1.xyz + -r0.www;
	r1.xyz = finalSaturation.www * r1.xyz + r0.www;
	r0.xyz = -r0.xyz * r0.xyz + r1.xyz;
	r0.xyz = finalBlend.xyz * r0.xyz + r2.xyz;
	r0.w = 1;
	r1.x = saturate(dot(r0.xyzw, float4(1.0, 0.0, 0.0, 0.0)));
	o0.x = sqrt(r1.x);
	r1.x = saturate(dot(r0.xyzw, float4(0.0, 1.0, 0.0, 0.0)));
	r0.x = saturate(dot(r0.xyzw, float4(0.0, 0.0, 1.0, 0.0)));
	o0.z = sqrt(r0.x);
	o0.y = sqrt(r1.x);
	return o0;
}

float4 PostFx_T6_VisionSetApply(
	const float4 color,
	const float4 colorRangeS,
	const float4 colorRangeE,
	const row_major float3x4 smhRed,
	const row_major float3x4 smhGreen,
	const row_major float3x4 smhBlue,
	const float4 finalGamma,
	const float4 finalSaturation,
	const float4 finalBlend)
{
	const float4 postFxControlE = float4(0.5, 0.5, 0.0, 0.0);

	float4 r0, r1, r2, r3, r4, o0;
	r0.xyzw = color;
	r0.xyzw = postFxControlE.yyyy * r0.xyzw;
	r1.xyzw = color;
	r0.xyzw = r1.xyzw * postFxControlE.xxxx + r0.xyzw;
	r1.x = dot(r0.xyz, float3(0.212585449,0.715194702,0.0722198486));
	r1.xyzw = saturate(r1.xxxx * colorRangeS.xzyw + colorRangeE.xzyw);
	r1.y = r1.y * r1.w;
	r2.xyz = r1.xyz * r1.xyz;
	r1.xyz = r1.xyz * -2.0 + 3.0;
	r1.xyz = r2.xyz * r1.xyz;
	r1.w = dot(r1.xzy, 1.0);
	r1.w = 1 / r1.w;
	r1.xyz = r1.xyz * r1.www;
	r2.xyz = r0.xyz * r0.xyz;
	r2.w = r0.w;
	r3.x = dot(r2.xyzw, smhRed[0].xyzw);
	r3.y = dot(r2.xyzw, smhRed[1].xyzw);
	r3.z = dot(r2.xyzw, smhRed[2].xyzw);
	r0.w = saturate(dot(r3.xyz, r1.xyz));
	r3.x = log2(r0.w);
	r4.x = dot(r2.xyzw, smhGreen[0].xyzw);
	r4.y = dot(r2.xyzw, smhGreen[1].xyzw);
	r4.z = dot(r2.xyzw, smhGreen[2].xyzw);
	r0.w = saturate(dot(r4.xyz, r1.xyz));
	r3.y = log2(r0.w);
	r4.x = dot(r2.xyzw, smhBlue[0].xyzw);
	r4.y = dot(r2.xyzw, smhBlue[1].xyzw);
	r4.z = dot(r2.xyzw, smhBlue[2].xyzw);
	o0.w = r2.w;
	r0.w = saturate(dot(r4.xyz, r1.xyz));
	r3.z = log2(r0.w);
	r1.xyz = finalGamma.xyz * r3.xyz;
	r1.xyz = exp2(r1.xyz);
	r0.w = dot(r1.xyz, finalSaturation.xyz);
	r1.xyz = r1.xyz + -r0.www;
	r1.xyz = finalSaturation.www * r1.xyz + r0.www;
	r0.xyz = -r0.xyz * r0.xyz + r1.xyz;
	r0.xyz = finalBlend.xyz * r0.xyz + r2.xyz;
	r0.w = 1;
	r1.x = saturate(dot(r0.xyzw, float4(1.0, 0.0, 0.0, 0.0)));
	o0.x = sqrt(r1.x);
	r1.x = saturate(dot(r0.xyzw, float4(0.0, 1.0, 0.0, 0.0)));
	r0.x = saturate(dot(r0.xyzw, float4(0.0, 0.0, 1.0, 0.0)));
	o0.z = sqrt(r0.x);
	o0.y = sqrt(r1.x);
	return o0;
}

float4 PostFx_T6_VisionSetApply(
	in float4 color,
	float4 colorRangeS,
	float4 colorRangeE,
	const float4 shadowsMatrixR,
	const float4 shadowsMatrixG,
	const float4 shadowsMatrixB,
	const float4 hilightsMatrixR,
	const float4 hilightsMatrixG,
	const float4 hilightsMatrixB,
	const float4 midtonesMatrixR,
	const float4 midtonesMatrixG,
	const float4 midtonesMatrixB,
	const float4 gamma,
	const float4 saturation,
	const float4 blend)
{
	PostFx_T6_VisionSetCalculateRanges(colorRangeS, colorRangeE);

	return PostFx_T6_VisionSetApply(
		color,
		colorRangeS,
		colorRangeE,
		float3x4(shadowsMatrixR, midtonesMatrixR, hilightsMatrixR),
		float3x4(shadowsMatrixG, midtonesMatrixG, hilightsMatrixG),
		float3x4(shadowsMatrixB, midtonesMatrixB, hilightsMatrixB),
		gamma,
		saturation,
		blend);
}

#if USE_T6_VISIONSET

float4 PostFx_T6_VisionSetApply(float4 color)
{
	return PostFx_T6_VisionSetApply(
		float4(color.rgb * visionSetBrightness, color.a),
		visColorRangeS,
		visColorRangeE,
		visColorShadowMatrixR,
		visColorShadowMatrixG,
		visColorShadowMatrixB,
		visColorHilightMatrixR,
		visColorHilightMatrixG,
		visColorHilightMatrixB,
		visColorMidtoneMatrixR,
		visColorMidtoneMatrixG,
		visColorMidtoneMatrixB,
		visColorFinalGamma,
		visColorFinalSaturation,
		visColorFinalBlend);
}

#endif

#endif