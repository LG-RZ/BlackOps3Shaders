#ifndef __LIB_FLOATZ__
#define __LIB_FLOATZ__

float FloatZ_Process(float depth)
{
    if (depth >= (63.0 / 64.0))
		depth = depth * 64.0 - 63.0;
	else
		depth *= (64.0 / 63.0);

    return max(depth, 0.00000001);
}

#endif