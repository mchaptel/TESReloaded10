void ApplyBrightness(inout float3 color, float BrightnessIntensity)
{
	color.xyz *= BrightnessIntensity;
	
	color.xyz += 0.000001;
}