//
// Generated by Microsoft (R) HLSL Shader Compiler 9.23.949.2378
//
// Parameters:

row_major float4x4 ModelViewProj : register(c0);
float4 FogParam : register(c14);
float3 FogColor : register(c15);
float4 EyePosition : register(c16);
float4 LightData[10] : register(c25);
row_major float4x4 TESR_InvViewProjectionTransform : register(c35);

// Registers:
//
//   Name          Reg   Size
//   ------------- ----- ----
//   ModelViewProj[0] const_0        1
//   ModelViewProj[1] const_1        1
//   ModelViewProj[2] const_2        1
//   ModelViewProj[3] const_3        1
//   FogParam      const_14      1
//   FogColor      const_15      1
//   EyePosition   const_16      1
//   LightData[0]     const_25      2
//


// Structures:

struct VS_INPUT {
    float4 LPOSITION : POSITION;
    float3 LTANGENT : TANGENT;
    float3 LBINORMAL : BINORMAL;
    float3 LNORMAL : NORMAL;
    float4 LTEXCOORD_0 : TEXCOORD0;
    float4 LCOLOR_0 : COLOR0;
};

struct VS_OUTPUT {
    float4 color_0 : COLOR0;
    float4 color_1 : COLOR1;
    float4 position : POSITION;
    float2 texcoord_0 : TEXCOORD0;
    float4 texcoord_1 : TEXCOORD1;
    float4 texcoord_2 : TEXCOORD2;
    float3 texcoord_3 : TEXCOORD3;
    float3 texcoord_4 : TEXCOORD4;
    float4 texcoord_5 : TEXCOORD5;
	float4 texcoord_6 : TEXCOORD6;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)

    float3 m21;
    float3 m28;
    float3 q2;
    float3 q4;
    float3 q5;
    float1 q6;
    float4 r0;
	float4 r1;
	
	r0 = mul(ModelViewProj, IN.LPOSITION);
	r1 = mul(r0, TESR_InvViewProjectionTransform);
	
    q2.xyz = normalize(normalize(EyePosition.xyz - IN.LPOSITION.xyz) + LightData[0].xyz);
    m28.xyz = mul(float3x3(IN.LTANGENT.xyz, IN.LBINORMAL.xyz, IN.LNORMAL.xyz), q2.xyz);
    m21.xyz = mul(float3x3(IN.LTANGENT.xyz, IN.LBINORMAL.xyz, IN.LNORMAL.xyz), LightData[0].xyz);
    OUT.color_0.rgba = IN.LCOLOR_0.xyzw;
    q6.x = log2(1 - saturate((FogParam.x - length(r0.xyz)) / FogParam.y));
    OUT.color_1.rgb = FogColor.rgb;
    OUT.color_1.a = exp2(q6.x * FogParam.z);
    OUT.position = r0;
    OUT.texcoord_0.xy = IN.LTEXCOORD_0.xy;
    OUT.texcoord_1.w = LightData[0].w;
    OUT.texcoord_1.xyz = normalize(m21.xyz);
    q4.xyz = normalize(LightData[1].xyz - IN.LPOSITION.xyz);
    q5.xyz = normalize(normalize(EyePosition.xyz - IN.LPOSITION.xyz) + q4.xyz);
    OUT.texcoord_2.w = 1;
    OUT.texcoord_2.xyz = mul(float3x3(IN.LTANGENT.xyz, IN.LBINORMAL.xyz, IN.LNORMAL.xyz), q4.xyz);
    OUT.texcoord_3.xyz = normalize(m28.xyz);
    OUT.texcoord_4.xyz = mul(float3x3(IN.LTANGENT.xyz, IN.LBINORMAL.xyz, IN.LNORMAL.xyz), q5.xyz);
    OUT.texcoord_5.w = 0.5;
    OUT.texcoord_5.xyz = compress((LightData[1].xyz - IN.LPOSITION.xyz) / LightData[1].w);	// [-1,+1] to [0,1]
	OUT.texcoord_6 = r1;
    return OUT;
};

// approximately 59 instruction slots used
 