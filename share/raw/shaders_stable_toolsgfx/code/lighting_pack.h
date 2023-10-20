#ifndef __CODE_LIGHTING_PACK__
#define __CODE_LIGHTING_PACK__

float lighting_pack_gloss(const float gloss, const float normal)
{
	return max((log2(exp2(saturate(gloss * 0.0588235296) * -17) + normal) * -0.0588235296), 0) * 0.49755621 + 0.00146627566;
}

#endif