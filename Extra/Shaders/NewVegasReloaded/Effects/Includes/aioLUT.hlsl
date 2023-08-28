texture2D textureLutInterior
<
	string ResourceName="enblut_interior.bmp";
>;

texture2D textureLutDay
<
	string ResourceName="enblut_day.bmp";
>;

texture2D textureLutNight
<
	string ResourceName="enblut_night.bmp";
>;

sampler2D	samplerLutInterior
{
	Texture = <textureLutInterior>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU = Clamp;
	AddressV = Clamp;
	SRGBTexture = FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D	samplerLutDay
{
	Texture = <textureLutDay>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU = Clamp;
	AddressV = Clamp;
	SRGBTexture = FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D samplerLutNight
{
	Texture = <textureLutNight>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU = Clamp;
	AddressV = Clamp;
	SRGBTexture = FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

/*
LOAD_TEXTURE( LUT_ExtNight, enblut_interior.png, LINEAR, CLAMP ); // exterior night
LOAD_TEXTURE( LUT_ExtNight, enblut_day.png, LINEAR, CLAMP ); // exterior night
LOAD_TEXTURE( LUT_ExtNight, enblut_night.png, LINEAR, CLAMP ); // exterior night
*/


void	ApplyLUT(inout float3 color, float ENightDayFactor, float EInteriorFactor)
{
	float3 ColorLutDay;  // CLuT for Days
	float3 ColorLutDayRow;

	float3 ColorLutNight;  // CLuT for Nights
	float3 ColorLutNightRow;

	float3 ColorLutInterior;  // CLuT for Interiors
	float3 ColorLutInteriorRow;

	float3 ColorLutBlend;  // CLuT Averages
	float3 ColorLutBlendRow;


	//float2 f2LutResolution = float2(0.00390625, 0.0625);  // 1 / float2(256, 16);
	float2 f2LutResolution = float2(0.00390625, 0.0625);
	color.rgb = saturate(color.rgb);
	color.b *= 15;
	float4 CLut_UV  = 0;

	CLut_UV.w = floor(color.b);
	CLut_UV.xy = color.rg * 15 * f2LutResolution + 0.5 * f2LutResolution;
	CLut_UV.x += CLut_UV.w * f2LutResolution.y;
	
	ColorLutDay.rgb = tex2Dlod(samplerLutDay, CLut_UV.xyzz).rgb;
	ColorLutDayRow.rgb = tex2Dlod(samplerLutDay, CLut_UV.xyzz + float4(f2LutResolution.y, 0, 0, 0)).rgb;
	
	ColorLutNight.rgb = tex2Dlod(samplerLutNight, CLut_UV.xyzz).rgb;
	ColorLutNightRow.rgb = tex2Dlod(samplerLutNight, CLut_UV.xyzz + float4(f2LutResolution.y, 0, 0, 0)).rgb;
	
	ColorLutInterior.rgb = tex2Dlod(samplerLutInterior, CLut_UV.xyzz).rgb;
	ColorLutInteriorRow.rgb = tex2Dlod(samplerLutInterior, CLut_UV.xyzz + float4(f2LutResolution.y, 0, 0, 0)).rgb;

	ColorLutBlend.rgb = lerp( lerp(ColorLutNight.rgb, ColorLutDay.rgb, ENightDayFactor), ColorLutInterior.rgb, EInteriorFactor);
	ColorLutBlendRow.rgb = lerp( lerp(ColorLutNightRow.rgb, ColorLutDayRow.rgb, ENightDayFactor), ColorLutInteriorRow.rgb, EInteriorFactor);

	color.rgb = lerp(ColorLutBlend.rgb, ColorLutBlendRow.rgb, color.b - CLut_UV.w);
}
