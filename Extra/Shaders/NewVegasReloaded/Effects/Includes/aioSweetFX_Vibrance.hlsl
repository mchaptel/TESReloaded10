//VibranceData.r = Vibrance_Red, .g = Vibrance_Green, .b = Vibrance_Blue, .w = Vibrance_Intensity
void ApplyVibrance(inout float3 color, float4 VibranceData)
{

	float3 VibCoeff = float3((VibranceData.r * VibranceData.w), (VibranceData.g * VibranceData.w), (VibranceData.b * VibranceData.w));
	
	float Luma = dot(float3(0.2127, 0.7152, 0.0722), color.rgb);
	
	float VibSaturation = max(color.r, max(color.g, color.b) - min(color.r, min(color.g, color.b)));
	
	color.rgb = lerp(Luma, color.rgb, (1.0 + (VibCoeff * (1.0 - (sign(VibCoeff) * VibSaturation)))));
}