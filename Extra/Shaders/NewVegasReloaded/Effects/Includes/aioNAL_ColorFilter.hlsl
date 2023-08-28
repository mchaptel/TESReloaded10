#include "Includes/aioNAL_Utilities.hlsl"

//ColorFilterValues.x=UseColorSaturation, y=HueMid, z=HueRange, w=SaturationLimit

void prod80ColorFilter(inout float3 color, float3 colorMod, float4 ColorFilterValues, float ColorFilterStrength)
{

	 colorMod = saturate( color.xyz );
	 float greyVal = grayValue( colorMod.xyz );
	 float colorHue = Hue( colorMod.xyz );
	 
	 float colorSat = 0.0f;
	 float minColor = min( min ( colorMod.x, colorMod.y ), colorMod.z );
	 float maxColor = max( max ( colorMod.x, colorMod.y ), colorMod.z );
	 maxColor = max( max ( colorMod.x, colorMod.y ), colorMod.z );
	 float colorDelta = maxColor - minColor;
	 float colorInt = ( maxColor + minColor ) * 0.5f;
	 
	 if ( colorDelta != 0.0f )
	 {
			if ( colorInt < 0.5f )
				 colorSat = colorDelta / ( maxColor + minColor );
			else
				 colorSat = colorDelta / ( 2.0f - maxColor - minColor );
	 }
	 
	 //When color intensity not based on original saturation level
	 colorSat = lerp(1.0f, colorSat, ColorFilterValues.x);
	 
	 float4 hueMinMax = float4(0.0f, 0.0f, 0.0f, 0.04f);//x = hueMin_1, y = hueMin_2, z = hueMax_1, w = hueMax_2;
	 
	 if ( ColorFilterValues.z > ColorFilterValues.y )
	 {
			hueMinMax.x = ColorFilterValues.y - ColorFilterValues.z;
			hueMinMax.y = 1.0f + ColorFilterValues.y - ColorFilterValues.z;
			hueMinMax.z = ColorFilterValues.y + ColorFilterValues.z;
			hueMinMax.w = 1.0f + ColorFilterValues.y;
	 
			if ( colorHue >= hueMinMax.x && colorHue <= ColorFilterValues.y )
				 colorMod.xyz = lerp( greyVal.xxx, colorMod.xyz, smootherstep( hueMinMax.x, ColorFilterValues.y, colorHue ) * ( colorSat * ColorFilterValues.w ));
			else if ( colorHue > ColorFilterValues.y && colorHue <= hueMinMax.z )
				 colorMod.xyz = lerp( greyVal.xxx, colorMod.xyz, ( 1.0f - smootherstep( ColorFilterValues.y, hueMinMax.z, colorHue )) * ( colorSat * ColorFilterValues.w ));
			else if ( colorHue >= hueMinMax.y && colorHue <= hueMinMax.w )
				 colorMod.xyz = lerp( greyVal.xxx, colorMod.xyz, smootherstep( hueMinMax.y, hueMinMax.w, colorHue ) * ( colorSat * ColorFilterValues.w ));
			else
				 colorMod.xyz = greyVal.xxx;
	 
	 }
	 else if ( ColorFilterValues.y + ColorFilterValues.z > 1.0f )
	 {
			hueMinMax.x = ColorFilterValues.y - ColorFilterValues.z;
			hueMinMax.y = 0.0f - ( 1.0f - ColorFilterValues.y );
			hueMinMax.z = ColorFilterValues.y + ColorFilterValues.z;
			hueMinMax.w = ColorFilterValues.y + ColorFilterValues.z - 1.0f;
	 
			if ( colorHue >= hueMinMax.x && colorHue <= ColorFilterValues.y )
				 colorMod.xyz = lerp( greyVal.xxx, colorMod.xyz, smootherstep( hueMinMax.x, ColorFilterValues.y, colorHue ) * ( colorSat * ColorFilterValues.w ));
			else if ( colorHue > ColorFilterValues.y && colorHue <= hueMinMax.z )
				 colorMod.xyz = lerp( greyVal.xxx, colorMod.xyz, ( 1.0f - smootherstep( ColorFilterValues.y, hueMinMax.z, colorHue )) * ( colorSat * ColorFilterValues.w ));
			else if ( colorHue >= hueMinMax.y && colorHue <= hueMinMax.w )
				 colorMod.xyz = lerp( greyVal.xxx, colorMod.xyz, smootherstep( hueMinMax.y, hueMinMax.w, colorHue) * ( colorSat * ColorFilterValues.w ));
			else
				 colorMod.xyz = greyVal.xxx;
			
	 }
	 else
	 {
			hueMinMax.x = ColorFilterValues.y - ColorFilterValues.z;
			hueMinMax.z = ColorFilterValues.y + ColorFilterValues.z;
			
			if ( colorHue >= hueMinMax.x && colorHue <= ColorFilterValues.y )
				 colorMod.xyz = lerp( greyVal.xxx, colorMod.xyz, smootherstep( hueMinMax.x, ColorFilterValues.y, colorHue ) * ( colorSat * ColorFilterValues.w ));
			else if ( colorHue > ColorFilterValues.y && colorHue <= hueMinMax.z )
				 colorMod.xyz = lerp( greyVal.xxx, colorMod.xyz, ( 1.0f - smootherstep( ColorFilterValues.y, hueMinMax.z, colorHue )) * ( colorSat * ColorFilterValues.w ));
			else
				 colorMod.xyz = greyVal.xxx;
	 
	 }
	 
	 color.xyz = lerp(color.xyz, colorMod.xyz, ColorFilterStrength);
	 
}