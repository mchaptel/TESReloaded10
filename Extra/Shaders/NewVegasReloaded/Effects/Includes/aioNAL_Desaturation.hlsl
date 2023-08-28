void ApplyDesaturation(inout float3 color, float greyscale, float3 desaturation)
{

	color.r = lerp(greyscale, color.r, desaturation.r);
    color.g = lerp(greyscale, color.g, desaturation.g);
    color.b = lerp(greyscale, color.b, desaturation.b);	
	
}