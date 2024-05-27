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

// TO-DO: Add the common stuff here

/*
float2 GBuffer_CalculateReflectance(const uint2 clipPosition, const float3 specular)
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

float GBuffer_CalculateOcclusion(const GBufferPixelInput pixel)
{
	#if BASE_TEXTURES
	
	float occlusion = 1;
	
	#else
	
	float occlusion = aoMap.Sample(aoSampler, pixel.texCoords).x;
	
	#endif
	
	return occlusion;
}

float4 GBuffer_CalculateAlbedo(const GBufferPixelInput pixel, const uint isFrontFace)
{
	float4 albedo = colorMap.Sample(colorSampler, pixel.texCoords);
	
	#if USE_COLOR_TINT

	albedo.xyz *= lerp(1, colorTint, albedo.a);
	
	#endif

	albedo.a = 1;
	
	return albedo;
}

float4 GBuffer_CalculateNormalGloss(const GBufferPixelInput pixel, const uint isFrontFace)
{
	float4 bump = GBuffer_DecodeNormal(normalMap.Sample(normalSampler, pixel.texCoords).xyz, baseNormalHeight);
	float direction = isFrontFace ? 1.0 : -1.0;
	
	float3 pixelTangent = normalize(pixel.tangent) * direction;
	float3 pixelBitangent = normalize(pixel.biTangent) * direction;
	float3 pixelNormal = normalize(pixel.normal) * direction;
	
	float3x3 tangentToWorldSpace = float3x3(pixelTangent, pixelBitangent, pixelNormal);

	float3 normal = normalize(mul(bump.xyz, tangentToWorldSpace));
	float norDir = GBuffer_CalculateNormalDirection(pixelNormal, normal);
	
	#if BASE_TEXTURES

	float gloss = glossRange.y;
	
	#else
	
	float gloss = lerp(glossRange.x, glossRange.y, glossMap.Sample(specColorSampler, pixel.texCoords).x);
	
	#endif
	
	return float4(GBuffer_PackNormal(normal), GBuffer_PackGloss(gloss, bump.w), norDir);
}

float4 GBuffer_CalculateReflectanceOcclusion(const GBufferPixelInput pixel, const uint isFrontFace, inout float4 albedo)
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
	
	return float4(GBuffer_CalculateReflectance(pixel.position.xy, specular), GBuffer_CalculateOcclusion(pixel), 1);
}

float4 GBuffer_CalculateReflectanceOcclusion(const GBufferPixelInput pixel, const uint isFrontFace, const float specular, inout float4 albedo)
{
	albedo *= saturate(1 - specular);
	
	return float4(GBuffer_CalculateReflectance(pixel.position.xy, specular), GBuffer_CalculateOcclusion(pixel), 1);
}

*/

#endif