// Exposure shader for Oblivion/Skyrim Reloaded
#define debug 0

float4 TESR_ExposureData; // x:min brightness, y;max brightness, z:dark adapt speed, w: light adapt speed

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_AvgLumaBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

#include "Includes/Helpers.hlsl"

struct VSOUT
{
	float4 vertPos : POSITION;
	float2 UVCoord : TEXCOORD0;
};

struct VSIN
{
	float4 vertPos : POSITION0;
	float2 UVCoord : TEXCOORD0;
};

VSOUT FrameVS(VSIN IN)
{
	VSOUT OUT = (VSOUT)0.0f;
	OUT.vertPos = IN.vertPos;
	OUT.UVCoord = IN.UVCoord;
	return OUT;
}


float4 Exposure(VSOUT IN) : COLOR0
{
	float4 color = tex2D(TESR_RenderedBuffer, IN.UVCoord);
	float averageLuma = tex2D(TESR_AvgLumaBuffer, float2(0.5, 0.5)).g;

	float negativeLumaDiff = invlerps(TESR_ExposureData.x, 0, averageLuma) * TESR_ExposureData.x;
	float additiveLumaDiff = invlerps(TESR_ExposureData.y, 1, averageLuma) * (1 - TESR_ExposureData.y) * 2;
	float lumaDiff = additiveLumaDiff - negativeLumaDiff;

#if debug
	if (IN.UVCoord.x > 0.7 && IN.UVCoord.x < 0.8 && IN.UVCoord.y>0.7 && IN.UVCoord.y<0.8) return averageLuma;
	if (IN.UVCoord.x > 0.7 && IN.UVCoord.x < 0.8 && IN.UVCoord.y>0.8 && IN.UVCoord.y<0.9) return float4(lumaDiff, -lumaDiff, 0, 1);
#endif

	color = pow(color, (1 + lumaDiff));
	return color;
}

technique
{
	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader  = compile ps_3_0 Exposure();
	}
}