//#include "globals.hlsl"

Texture2D inputTexture : register(t0);
SamplerState inputSampler : register(s0);

struct VertexInput						
{										
	float3 position		: POSITION;		
	float2 texCoords	: TEXCOORD0;
};										

struct PixelInput						
{										
	float4 position		: SV_POSITION;		
	float2 texCoords	: TEXCOORD0;
};										

PixelInput vs_main( const VertexInput vertex )	
{												
	PixelInput pixel;			
	pixel.position = float4( vertex.position, 1 );
	pixel.texCoords = vertex.texCoords;
	return pixel;								
}												

float4 ps_main( const PixelInput pixel ) : SV_TARGET
{
#if IMAGE_SHOW_ALPHA
	return inputTexture.SampleLevel( inputSampler, pixel.texCoords, IMAGE_MIP_LEVEL ).aaaa;
#else
	return inputTexture.SampleLevel( inputSampler, pixel.texCoords, IMAGE_MIP_LEVEL );
#endif
}												
