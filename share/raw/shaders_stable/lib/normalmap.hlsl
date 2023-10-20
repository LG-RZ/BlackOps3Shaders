#ifndef __LIB_NORMAL_MAP__
#define __LIB_NORMAL_MAP__

SamplerState normalSampler;
Texture2D<float4> normalMap;

float baseNormalHeight;
float2 glossRange;

#if USE_DETAIL_MAP

Texture2D<float4> detailMap;

float2 detailScale;
float detailScaleHeight;

#endif

// TO-DO:
// Move to tangent space hlsl
// maybe try to 
float3 get_normal(const Texture2D normalTexture, const SamplerState normalSampler, const float2 texCoords, const float normalHeight)
{
	// Sample the texture
	float3 normal = normalTexture.Sample(normalSampler, texCoords).xyz;

	// Scale the normal with the height
	normal = lerp(float3(0.5, 0.5, 0.0), normal, normalHeight);

	// Decode the normal
	normal.xy = normal.xy * 1.9921875 - 1;
	normal.z = min(normal.z * normal.z * 0.333333343, 1);
	
	// Return the normal
	return normal;
}

void add_detail(const Texture2D detailTexture, const SamplerState detailSampler, const float2 texCoords, const float2 detailScale, const float detailHeight, inout float3 normal)
{
	// Sample the texture
	float3 detail = detailTexture.Sample(detailSampler, texCoords * detailScale).xyz;
	
	// Decode the normal
	detail.xy = detail.xy * 1.9921875 - 1;
	detail.z = min(detail.z * detail.z * 0.333333343, 1);
	
	// Add the detail
	normal = normal + (detail * detailHeight);
}

#endif