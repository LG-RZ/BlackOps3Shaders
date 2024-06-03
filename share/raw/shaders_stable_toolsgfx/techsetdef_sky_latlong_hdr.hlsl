#include "lib/globals.hlsl"
#include "lib/transform.hlsl"
#include "lib/gpu_skin.hlsl"
#include "lib/oit_draw.hlsl"
#include "lib/hdrold.hlsl"
#include "lib/vertdecl_vertex_tangentspace.hlsl"
#include "gfxcore/hlslcorefog.h"

SamplerState colorSampler;
Texture2D<float4> colorMap;

#if USE_EMISSIVE
float skyScale;
float skyFogFraction;
#endif

#if USE_GROUNDPLANE
float3 skyOrigin;
float skyHorizonOffset;
#endif

struct VertexInput
{
	float3 position : POSITION;
	float4 weights : BLENDWEIGHT;
	uint4 indices : BLENDINDICES;
};

struct PixelInput
{
	float4 position : SV_Position;
    float3 coordinates : TEXCOORD0;
    float3 viewDirection : TEXCOORD1;
    #if USE_GROUNDPLANE
    float3 groundPlane : TEXCOORD2;
    #endif
};

PixelInput vs_main(const VertexInput vertex, const uint instance : INSTANCE_SEMANTIC)
{
	PixelInput pixel;
	
	float3 position = vertex.position;
	float3 normal = 0.0;
	float3 tangent = 0.0;
	
	GPUSkin_SkinVertex(position, normal, tangent, vertex.weights, vertex.indices, instance);

    float skySize = abs(GetSkySize());
    float2 skyRotation = GetSkyRotation();
    float3 camPos = Transform_GetCameraWorldPosition();

    #if !TOOLSGFX
    
    position -= camPos;

    #endif

    position = normalize(position);

	pixel.position = Transform_OffsetToClip(position * skySize + camPos);
    pixel.position.z = 0.0;

    pixel.coordinates = float3(
        dot(position.xy, skyRotation.yx * float2(1, -1)),
        dot(position.xy, skyRotation),
        GetSkySize().x >= 0 ? position.z : -position.z);
    
    pixel.viewDirection = position * skySize;

    #if USE_GROUNDPLANE
    float3 groundPosition = camPos - skyOrigin;

    pixel.groundPlane = float3(
        dot(groundPosition.xy, skyRotation.yx * float2(1, -1)),
        dot(groundPosition.xy, skyRotation),
        groundPosition.z);

    #endif

	return pixel;
}

float4 ps_main(const PixelInput pixel) : SV_TARGET
{
    float3 coordinates = normalize(pixel.coordinates);

    #if USE_GROUNDPLANE
    float groundScale = 131072.0;

    if(coordinates.z < skyHorizonOffset)
        groundScale = min(pixel.groundPlane.z / max(saturate(skyHorizonOffset - coordinates.z), 0.0001), 131072.0);

    coordinates = normalize((coordinates * groundScale) + (pixel.groundPlane + skyOrigin));
    #endif

    float longitude = atan2(coordinates.y, coordinates.x);
    float latitude = acos(coordinates.z);
    
    float3 texCoords = (float3(longitude, latitude, latitude) / float3(-M_PI * 2, M_PI, -M_PI)) + float3(0.5, 0.0, 1.0);

    float3 col0 = colorMap.Sample(colorSampler, texCoords.xy).rgb;
    float3 col1 = colorMap.Sample(colorSampler, texCoords.xz).rgb;

    float3 col = max(lerp(col0, col1, GetSkyTransition()), 0.0);

    #if USE_EMISSIVE

    col = col * skyScale;

    Fog_ApplyFog(col, normalize(pixel.viewDirection) * Fog_GetWorldFogSkySize(), true);
    HDR_ClampExposure(col);

    #else

    col = LinearToSRGB(col);

    #endif

    return float4(col, 1.0);
}