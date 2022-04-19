//
// Generated by Microsoft (R) HLSL Shader Compiler 9.23.949.2378
//
// Parameters:

float4 AmbientColor : register(c1);
sampler2D BaseMap : register(s0);
sampler2D NormalMap : register(s1);
float4 PSLightColor[10] : register(c3);
float4 TESR_ShadowData : register(c32);
sampler2D TESR_ShadowMapBufferNear : register(s14) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_ShadowMapBufferFar : register(s15) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

// Registers:
//
//   Name         Reg   Size
//   ------------ ----- ----
//   AmbientColor const_1       1
//   PSLightColor[0] const_3       1
//   BaseMap      texture_0       1
//   NormalMap    texture_1       1
//


// Structures:

struct VS_INPUT {
    float2 BaseUV : TEXCOORD0;
    float3 LCOLOR_0 : COLOR0;
    float4 LCOLOR_1 : COLOR1;
    float3 texcoord_1 : TEXCOORD1_centroid;
	float4 texcoord_6 : TEXCOORD6;
	float4 texcoord_7 : TEXCOORD7;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

#include "Includes/Shadow.hlsl"

PS_OUTPUT main(VS_INPUT IN) {
    PS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	shade(n, l)		max(dot(n, l), 0)
#define	shades(n, l)		saturate(dot(n, l))

    float3 noxel0;
    float3 q1;
    float3 q3;
    float4 r1;

    noxel0.xyz = tex2D(NormalMap, IN.BaseUV.xy).xyz;
    r1.xyzw = tex2D(BaseMap, IN.BaseUV.xy);
    q3.xyz = r1.xyz * IN.LCOLOR_0.xyz;
    r1.w = r1.w * AmbientColor.a;
    q1.xyz = (GetLightAmount(IN.texcoord_6, IN.texcoord_7) * (shades(normalize(expand(noxel0.xyz)), IN.texcoord_1.xyz) * PSLightColor[0].rgb)) + AmbientColor.rgb;
    r1.xyz = (IN.LCOLOR_1.w * (IN.LCOLOR_1.xyz - (q3.xyz * max(q1.xyz, 0)))) + (max(q1.xyz, 0) * q3.xyz);
    OUT.color_0.rgba = r1.xyzw;

    return OUT;
};

// approximately 17 instruction slots used (2 texture, 15 arithmetic)
