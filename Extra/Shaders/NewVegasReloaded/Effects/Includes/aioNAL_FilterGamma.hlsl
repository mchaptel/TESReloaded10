void ApplyFilterGamma(inout float3 color, float4 FilterGamma)
{

	color = pow(color, FilterGamma.a);
	
	color.r = pow(color.r, FilterGamma.r);
	color.g = pow(color.g, FilterGamma.g);
	color.b = pow(color.b, FilterGamma.b);
	
}