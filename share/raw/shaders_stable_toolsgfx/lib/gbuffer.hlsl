#ifndef __LIB_GBUFFER__
#define __LIB_GBUFFER__

#include "gfxcore/hlslcoregbufferinput.h"
#include "gfxcore/hlslcoregbufferoutput.h"
#include "gfxcore/hlslcoremath.h"

float2 GBuffer_CalculateReflectance(const uint2 clipPosition, float3 specular, const float3 specColorTint, bool hasSpecular = false, bool hasSpecularColor = false)
{
    if(hasSpecular)
    {
        if(!hasSpecularColor)
            specular = lerp(0.04, specColorTint, specular);
        
        float3 reflectance;
	    reflectance.y = specular.x - specular.z;
	    float temp = reflectance.y * 0.5 + specular.z;
	    reflectance.z = specular.y - temp;
	    reflectance.x = reflectance.z * 0.5 + temp;
    
	    return ((clipPosition.x & 1) == (clipPosition.y & 1) ? reflectance.xy : reflectance.xz) * float2(1, 0.5) + float2(0, 0.5);
    }

    return float2(0.04, 0.5);
}

float4 GBuffer_DecodeNormal(float3 normal, float normalHeight)
{
	float4 output;
	output.xyz = lerp(float3(0.5, 0.5, 0.0), normal.xyz, normalHeight);
	output.xy = output.xy * 1.9921875 - 1.0;
	output.w = min((output.z * output.z) * (1.0 / 3.0), 1);
	output.z = sqrt(max(1 - dot(output.xy, output.xy), 0));
	return output;
}

float GBuffer_CalculateNormalDirection(in float3 worldNormal, inout float3 normal)
{
	uint normalDirection = 0.0;
	float nDotHalf = (worldNormal.x + worldNormal.y + worldNormal.z) * 0.5;
	float maxComponent = max4(nDotHalf, worldNormal - nDotHalf);
	worldNormal = worldNormal - nDotHalf;
	
	[unroll]
	for(int i = 0; i < 3; i++)
	{
		if (worldNormal[i] == maxComponent)
		{
			normal[i] *= -1;
			normal *= -1;
			maxComponent += 2;
			normalDirection = i + 1;
		}
	}
	
	return normalDirection * (1.0 / 3.0);
}

float2 GBuffer_PackNormal(float3 normal)
{
	float3 result;
	
	result.z = normal.x + normal.y + normal.z;
	result.x = -normal.y * 3 + result.z;
	result.y = normal.z - normal.x;
	result *= float3(0.408248, 0.707107, 0.577350);
	result.z = rsqrt(abs(result.z) + 1.0);
	
	return result.xy * result.z * float2(0.588235, 0.588235) + float2(0.500000, 0.500000);
}

float GBuffer_PackGloss(float gloss, float normal)
{
	return max((log2(exp2(saturate(gloss * 0.0588235296) * -17) + normal) * -0.0588235296), 0) * 0.49755621 + 0.00146627566;
}

float4 GBuffer_CalculateNormalGloss(float3 worldNormal, float3 worldTangent, float3 worldBinormal, const uint isFrontFace, float4 normal, float gloss, float2 glossRange)
{
	float direction = isFrontFace ? 1.0 : -1.0;
	
	worldTangent = normalize(worldTangent) * direction;
	worldBinormal = normalize(worldBinormal) * direction;
	worldNormal = normalize(worldNormal) * direction;
	
	float3x3 tangentToWorldSpace = float3x3(worldTangent, worldBinormal, worldNormal);

	normal.xyz = normalize(mul(normal.xyz, tangentToWorldSpace));

	float normalDirection = GBuffer_CalculateNormalDirection(worldNormal, normal.xyz);

	gloss = lerp(glossRange.x, glossRange.y, gloss);
	
	return float4(GBuffer_PackNormal(normal.xyz), GBuffer_PackGloss(gloss, normal.w), normalDirection);
}

float4 GBuffer_CalculateReflectanceOcclusion(uint2 position, const uint isFrontFace, inout float4 albedo, float3 specular, float3 specColorTint, float occlusion, bool hasSpecular = false, bool hasSpecularColor = false)
{
	if(hasSpecular && !hasSpecularColor)
		albedo *= saturate(1.0 - specular.x);
	
	return float4(GBuffer_CalculateReflectance(position, specular, specColorTint, hasSpecular, hasSpecularColor), occlusion, 1.0 / 3.0);
}

#endif