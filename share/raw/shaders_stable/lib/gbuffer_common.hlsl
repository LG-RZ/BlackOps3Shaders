#ifndef __LIB_GBUFFER_COMMON__
#define __LIB_GBUFFER_COMMON__

#include "globals.hlsl"
#include "transform.hlsl"
#include "gbuffer.hlsl"
#include "code/lighting.h"
#include "gpu_skin.hlsl"
#include "glass_shard.hlsl"
#include "gfxcore/hlslcoregbuffercommon.h"
#include "gfxcore/hlslcoreimportancesampling.h"
#include "reveal_map.hlsl"
#include "vertdecl_vertex_tangentspace.hlsl"
#include "normalmap.hlsl"
#include "vertdecl_vertex.hlsl"
#include "gfxcore/hlslcoreminmax.h"

float2 gbuffer_calculate_reflectance(const uint2 clipPosition, const float3 specular)
{
#if !BASE_TEXTURES && !BASE_SPEC
	
#if !USE_COLOR_SPEC
	
	float3 color = lerp(0.04, specColorTint, specular);
	
#endif
	
	float3 reflectance;
	reflectance.y = color.x - color.z;
	float temp = reflectance.y * 0.5 + color.z;
	reflectance.z = color.y - temp;
	reflectance.x = reflectance.z * 0.5 + temp;
	
	return ((clipPosition.x & 1) == (clipPosition.y & 1) ? reflectance.xy : reflectance.xz) * float2(1, 0.5) + float2(0, 0.5);

#else
	
	return float2(0.0399999991, 0.5);
	
#endif
}

float gbuffer_calculate_occlusion(const GBufferPixelInput pixel)
{
#if BASE_TEXTURES
	
	float occlusion = 1;
	
#else
	
	float occlusion = aoMap.Sample(aoSampler, pixel.texCoords).x;
	
#endif
	
	return occlusion;
}

float4 gbuffer_calculate_albedo(const GBufferPixelInput pixel, const uint isFrontFace)
{
	float4 albedo = colorMap.Sample(colorSampler, pixel.texCoords);
	
#if USE_COLOR_TINT

	albedo.xyz *= lerp(1, colorTint, albedo.a);
	
#endif

	albedo.a = 1;
	
	return albedo;
}

float4 gbuffer_decode_normal(float3 normal, float normalHeight)
{
	float4 output;
	output.xyz = lerp(float3(0.5, 0.5, 0.0), normal.xyz, normalHeight);
	output.xy = output.xy * 1.9921875 - 1;
	output.w = min(output.z * output.z * 0.333333343, 1);
	output.z = sqrt(max(1 - dot(output.xy, output.xy), 0));
	return output;
}

float gbuffer_calc_normal_direction(in float3 pixelNormal, inout float3 normal)
{
	float norDir = 0.0;
	float sum = pixelNormal.x + pixelNormal.y + pixelNormal.z * 0.5;
	float maxComponent = max4(sum, pixelNormal - sum);
	pixelNormal = pixelNormal - sum;
	
	[unroll]
	for (int i = 0; i < 3; i++)
	{
		if (pixelNormal[i] == maxComponent)
		{
			normal[i] *= -1;
			normal *= -1;
			maxComponent += 2;
			norDir = i + 1;
		}
	}
	
	return norDir * (1.0 / 3.0);
}

float2 gbuffer_pack_normal(float3 normal)
{
	float3 temp;
	
	temp.z = normal.x + normal.y + normal.z;
	temp.x = -normal.y * 3 + temp.z;
	temp.y = normal.z - normal.x;
	temp *= float3(0.408248, 0.707107, 0.577350);
	temp.z = rsqrt(abs(temp.z) + 1.0);
	
	return temp.xy * temp.z * float2(0.588235, 0.588235) + float2(0.500000, 0.500000);
}

float gbuffer_pack_gloss(float gloss, float normal)
{
	return max((log2(exp2(saturate(gloss * 0.0588235296) * -17) + normal) * -0.0588235296), 0) * 0.49755621 + 0.00146627566;
}

float4 gbuffer_calculate_normal_gloss(const GBufferPixelInput pixel, const uint isFrontFace)
{
	float4 bump = gbuffer_decode_normal(normalMap.Sample(normalSampler, pixel.texCoords).xyz, baseNormalHeight);
	float direction = isFrontFace ? 1.0 : -1.0;
	
	float3 pixelTangent = normalize(pixel.tangent) * direction;
	float3 pixelBitangent = normalize(pixel.biTangent) * direction;
	float3 pixelNormal = normalize(pixel.normal) * direction;
	
	float3x3 tangentToWorldSpace = float3x3(pixelTangent, pixelBitangent, pixelNormal);

	float3 normal = normalize(mul(bump.xyz, tangentToWorldSpace));
	float norDir = gbuffer_calc_normal_direction(pixelNormal, normal);
	
#if BASE_TEXTURES

	float gloss = glossRange.y;
	
#else
	
	float gloss = lerp(glossRange.x, glossRange.y, glossMap.Sample(specColorSampler, pixel.texCoords).x);
	
#endif
	
	return float4(gbuffer_pack_normal(normal), gbuffer_pack_gloss(gloss, bump.w), norDir);
}

float4 gbuffer_calculate_reflectance_occlusion(const GBufferPixelInput pixel, const uint isFrontFace, inout float4 albedo)
{
	float3 specular;
	
#if !BASE_TEXTURES && !BASE_SPEC
	
#if USE_COLOR_SPEC
	
	specular = specColorMap.Sample(specColorSampler, IN.TexCoord).xyz;
	
#else
	
	specular = specColorMap.Sample(specColorSampler, pixel.texCoords).x;
	albedo *= saturate(1 - specular.x);
	
#endif
	
#endif
	
	return float4(gbuffer_calculate_reflectance(pixel.position.xy, specular), gbuffer_calculate_occlusion(pixel), 1);
}

float4 gbuffer_calculate_reflectance_occlusion(const GBufferPixelInput pixel, const uint isFrontFace, const float specular, inout float4 albedo)
{
	albedo *= saturate(1 - specular);
	
	return float4(gbuffer_calculate_reflectance(pixel.position.xy, specular), gbuffer_calculate_occlusion(pixel), 1);
}

#endif