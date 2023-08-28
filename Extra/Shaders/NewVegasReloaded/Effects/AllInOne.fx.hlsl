// AIO post process shader for Oblivion/Skyrim Reloaded
#define debug 0

//#include "Includes/aioFyTy_LUT.hlsl"
#include "Includes/aioNAL_Desaturation.hlsl"
#include "Includes/aioNAL_FilterGamma.hlsl"
#include "Includes/aioNAL_ColorFilter.hlsl"
#include "Includes/aioNAL_Adaptation.hlsl"
#include "Includes/aioNAL_Brightness.hlsl"
#include "Includes/aioNAL_Tonemapping.hlsl"
#include "Includes/aioSweetFX_Vibrance.hlsl"

float4 TESR_AllInOneDesat;
float4 TESR_AllInOneGF;
float4 TESR_AllInOneCF;
float4 TESR_AllInOneCFAB;
float4 TESR_AllInOneTM;
float4 TESR_AllInOneVibrance;

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


float4 AllInOne(VSOUT IN) : COLOR0
{
	float4 color = tex2D(TESR_RenderedBuffer, IN.UVCoord);
	float4 Adaptation = tex2D(TESR_AvgLumaBuffer, 0.5);
	//float GrayAdaptation = max(max(Adaptation.x, Adaptation.y), 0.01);
	float GrayAdaptation = max(tex2D(TESR_AvgLumaBuffer, float2(0.5, 0.5)).g, 0.01);

	float greyscale = dot(color.xyz, float3(0.3, 0.59, 0.11));

	ApplyDesaturation(color.xyz, greyscale, TESR_AllInOneDesat.rgb);

	ApplyFilterGamma(color.xyz, TESR_AllInOneGF);
	
	ApplyAdaptation(color.xyz, TESR_AllInOneCFAB.y, TESR_AllInOneCFAB.z, GrayAdaptation);

	ApplyBrightness(color.xyz, TESR_AllInOneCFAB.w);

	//ApplyLUT(color.xyz, ENightDayFactor, EInteriorFactor);

	float3 colorMod = color.xyz;
	
	prod80ColorFilter(color.xyz, colorMod.xyz, TESR_AllInOneCF, TESR_AllInOneCFAB.x);
	
	ApplyToneMappingNLA(color.xyz, TESR_AllInOneTM);
	
	ApplyVibrance(color.xyz, TESR_AllInOneVibrance.xyzw);

	return color;
}

technique
{
	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader  = compile ps_3_0 AllInOne();
	}
}