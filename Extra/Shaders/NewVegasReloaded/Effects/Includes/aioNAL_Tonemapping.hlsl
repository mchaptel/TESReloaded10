
//TM.x = TM_IntensityContrast, .y = TM_Saturation, .z = TM_ToneMappingCurve, .w = TM_Oversaturation
void ApplyToneMappingNLA(inout float3 color, float4 TM)
{
	
	float3 colorMod = normalize(color.xyz);
	
	float3 scl = color.xyz/colorMod.xyz;
	
	scl = pow(scl, TM.x); //Apply Tonemapping Intensity Contrast
	
	colorMod.xyz = pow(colorMod.xyz, TM.y); //Apply Tonemapping Saturation
	
	colorMod.xyz = scl*colorMod.xyz;

	color.xyz = (colorMod.xyz * (1.0 + colorMod.xyz/TM.w)) / (colorMod.xyz + TM.z); //Apply Tonemapping Oversaturation & Curve

}