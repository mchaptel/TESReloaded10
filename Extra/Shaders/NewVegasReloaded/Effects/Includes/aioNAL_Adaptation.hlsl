void ApplyAdaptation(inout float3 color, float AdaptationMin, float AdaptationMax, float GrayAdaptation)
{

	GrayAdaptation = max(GrayAdaptation, 0.0); //0.0
	GrayAdaptation = min(GrayAdaptation, 1.0); //50.0
	
	color.xyz = color.xyz / (GrayAdaptation * AdaptationMax + AdaptationMin);
	
}