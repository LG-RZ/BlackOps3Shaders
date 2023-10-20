#ifndef __LIB_PIXELOUTPUT_COLOR__
#define __LIB_PIXELOUTPUT_COLOR__

float linear_to_srgb(const float x)
{
	return x <= 0.04045 ? x * 0.0773993808 : pow((x + 0.055) / 1.055, 2.4);
}

float3 linear_to_srgb(const float3 rgb)
{
	return float3(linear_to_srgb(rgb.x), linear_to_srgb(rgb.y), linear_to_srgb(rgb.z));
}

float srgb_to_linear(const float x)
{
	return x <= 0.0031308 ? x * 12.92 : pow(x, 0.41666) * 1.055 - 0.055;
}

float3 srgb_to_linear(const float3 rgb)
{
	return float3(srgb_to_linear(rgb.x), srgb_to_linear(rgb.y), srgb_to_linear(rgb.z));
}

#endif