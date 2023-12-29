//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/WATER004.pso /Fcshaderdump19/WATER000.pso.dis
//
//
// Parameters:
//
float4 NotUsed0 : register(c0);
float4 EyePos : register(c1);
float4 ShallowColor : register(c2);
float4 DeepColor : register(c3);
float4 ReflectionColor : register(c4);
float4 FresnelRI : register(c5);
float4 BlendRadius : register(c6);
float4 NotUsed7 : register(c7);
float4 VarAmounts : register(c8);
float4 FogParam : register(c9);
float4 FogColor : register(c10);
float2 DepthFalloff : register(c11);
float4 SunDir : register(c12);
float4 SunColor : register(c13);
float4 TESR_SunColor : register(c14);
float4 TESR_WaterCoefficients : register(c15);
float4 TESR_WaveParams : register(c16);
float4 TESR_WaterVolume : register(c17);
float4 TESR_WaterSettings : register(c18);
float4 TESR_ReciprocalResolution : register(c19);
float4 TESR_GameTime : register(c20);
float4x4 TESR_ViewTransform : register(c21);
float4x4 TESR_ProjectionTransform : register(c25);
float4 TESR_WaterShorelineParams : register(c29);

sampler2D ReflectionMap : register(s0);
sampler2D RefractionMap : register(s1);
sampler2D NormalMap : register(s2);
sampler2D DisplacementMap : register(s3);
sampler2D DepthMap : register(s4);
sampler2D TESR_RenderedBuffer : register(s5) = sampler_state { };
sampler2D TESR_DepthBuffer : register(s6) = sampler_state { };

static const float nearZ = TESR_ProjectionTransform._34 / TESR_ProjectionTransform._33;
static const float farZ = (TESR_ProjectionTransform._33 * nearZ) / (TESR_ProjectionTransform._33 - 1.0f);
static const float Zmul = nearZ * farZ;
static const float Zdiff = farZ - nearZ;
static const float depthRange = nearZ - farZ;

static const float4x4 ditherMat = { 0.0588, 0.5294, 0.1765, 0.6471,
									0.7647, 0.2941, 0.8824, 0.4118,
									0.2353, 0.7059, 0.1176, 0.5882,
									0.9412, 0.4706, 0.8235, 0.3259 };

// Registers:
//
//   Name            Reg   Size
//   --------------- ----- ----
//   EyePos          const_1       1
//   ShallowColor    const_2       1
//   DeepColor       const_3       1
//   ReflectionColor const_4       1
//   FresnelRI       const_5       1
//   VarAmounts      const_8       1
//   FogParam        const_9       1
//   FogColor        const_10      1
//   DepthFalloff    const_11      1
//   SunDir          const_12      1
//   SunColor        const_13      1
//   ReflectionMap   texture_0       1
//   RefractionMap   texture_1       1
//   NormalMap       texture_2       1
//   DepthMap        texture_4       1
//


// Structures:

struct VS_OUTPUT {
    float4 texcoord_0 : TEXCOORD0_centroid;
    float4 texcoord_1 : TEXCOORD1_centroid;
    float4 texcoord_2 : TEXCOORD2_centroid;
    float4 texcoord_3 : TEXCOORD3_centroid;
    float4 texcoord_4 : TEXCOORD4_centroid;
    float4 texcoord_5 : TEXCOORD5_centroid;
    float4 texcoord_6 : TEXCOORD6;
	float4 texcoord_7 : TEXCOORD7;
};

struct PS_OUTPUT {
    float4 color_0 : COLOR0;
};

// Code:
float3 toWorld(float2 tex)
{
    float3 v = float3(TESR_ViewTransform[2][0], TESR_ViewTransform[2][1], TESR_ViewTransform[2][2]);
    v += ( 1/TESR_ProjectionTransform[0][0] * (2*tex.x-1)).xxx * float3(TESR_ViewTransform[0][0], TESR_ViewTransform[0][1], TESR_ViewTransform[0][2]);
    v += (-1/TESR_ProjectionTransform[1][1] * (2*tex.y-1)).xxx * float3(TESR_ViewTransform[1][0], TESR_ViewTransform[1][1], TESR_ViewTransform[1][2]);
    return v;
}

float readDepth(in float2 coord : TEXCOORD0)
{
	float posZ = tex2D(TESR_DepthBuffer, coord).x;
	posZ = Zmul / ((posZ * Zdiff) - farZ);

	return posZ;
}

float3 getWaterNorm( float2 tex, float dist, float camera_vector_z, inout float3 specNorm, inout float height )
{
	float choppiness = TESR_WaveParams.x;
	float waveWidth = TESR_WaveParams.y;
	float LODdistance = TESR_WaterSettings.z;
	float MinLOD = TESR_WaterSettings.w;

	float lod = max( saturate( (camera_vector_z*camera_vector_z) * 50 * TESR_ProjectionTransform[0][0] /(TESR_ReciprocalResolution.x * dist) * LODdistance ), MinLOD);
	float4 Coord = float4( tex / (1024 * waveWidth), 0, 0);

	float4 sampledResult = tex2Dlod( NormalMap, Coord  );
	
	height = sampledResult.a * TESR_WaterShorelineParams.x * lod;
	float2 temp_norm = sampledResult.rg * 2 - 1;
	float3 norm = normalize(float3(temp_norm * choppiness * lod,1));
	specNorm = normalize(float3(temp_norm * choppiness * max(0.5, lod), 1));
	return norm;
}

float getFresnelAboveWater( float3 ray, float3 norm )
{
	float temp_cos = dot( -ray, norm );
	float2 vec = float2(temp_cos, sqrt(1-temp_cos*temp_cos));

	float fresnel = vec.x - 1.33 * sqrt(1 - 0.565*vec.y*vec.y);
	fresnel /= vec.x + 1.33 * sqrt(1 - 0.565*vec.y*vec.y);
	fresnel = saturate(fresnel * fresnel);

	return fresnel;
}


PS_OUTPUT main(VS_OUTPUT IN, float2 PixelPos : VPOS){
    PS_OUTPUT OUT;

	float2 UVCoord = (PixelPos+0.5)*TESR_ReciprocalResolution.xy;
	float3 eyepos = IN.texcoord_2.xyz;
	eyepos.z = -IN.texcoord_0.z;

    float4 color = tex2D(TESR_RenderedBuffer, UVCoord);
    color.rgb = pow(color.rgb,2.2); //linearise
    float4 linFogColor = pow(FogColor,2.2); //linearise

    float depth = readDepth(UVCoord);
    float3 camera_vector = toWorld(UVCoord);
	float3 norm_camera_vector = normalize( camera_vector );
    float3 world_pos = eyepos + camera_vector*depth;

	float4 sunColor = float4(pow(TESR_SunColor.rgb,2.2), 1);
	float nightAmount = TESR_SunColor.a;
	float causticsStrength = TESR_WaterVolume.x;
	float shoreFactor = TESR_WaterVolume.y;
	float turbidity = TESR_WaterVolume.z;
	float3 extCoeff = TESR_WaterCoefficients.xyz * turbidity;
	float scattCoeff = TESR_WaterCoefficients.w * turbidity;
	float reflectivity = TESR_WaveParams.w;
	float waveWidth = TESR_WaveParams.y;

	float uw_pos = world_pos.z / camera_vector.z;
	float2 surfPos = world_pos.xy - camera_vector.xy * uw_pos;

	float3 normal = 0;
	float3 specNorm = 0;
	float height = 0;
	normal = getWaterNorm( surfPos, depth - uw_pos, -camera_vector.z, specNorm, height);
	eyepos.z += height;
	world_pos = eyepos + camera_vector*depth;
	uw_pos = world_pos.z / camera_vector.z;
	
	float4 refract_color = color;

	float2 refPos = UVCoord + 0.01*normal.yx;
	float3 refract_world_pos = eyepos + toWorld( refPos )*readDepth( refPos );

	if (refract_world_pos.z < 0) {
		refract_color = tex2D( TESR_RenderedBuffer, refPos );
    	refract_color = pow(refract_color,2.2); //linearise
		}
	else {
		refract_world_pos = world_pos;
	}
	//Render Caustics
	float3 dx = ddx(world_pos);
    float3 dy = ddy(world_pos);
    float3 waterfloorNorm = normalize(cross(dx,dy));

	float3 causticsPos = refract_world_pos - SunDir.xyz * (refract_world_pos.z / SunDir.z);
	float caustics = causticsStrength*tex2D(NormalMap, causticsPos.xy / (512*waveWidth) ).b;
	float causticsAngle = saturate( dot(-waterfloorNorm, SunDir.xyz) );
	refract_color.rgb *=  1 + caustics * causticsAngle * sunColor.xyz - 0.3;

	//Calculate Refraction color
	float refract_uw_pos = refract_world_pos.z / camera_vector.z;
    refract_color.rgb *= exp( -extCoeff * (refract_uw_pos - refract_world_pos.z) / 70 );

	float SinBoverSinA = -norm_camera_vector.z;
	float3 waterVolColor = scattCoeff * linFogColor.xyz / ( extCoeff * (1 + SinBoverSinA) );

	waterVolColor *= 1 - exp( -extCoeff * (1 + SinBoverSinA) * refract_uw_pos / 70 );

	refract_color.rgb += waterVolColor;

	//Calculate reflection color
	float4 reflection = linFogColor;

	//refPos = UVCoord + 0.05*normal.yx;
	//float3 reflect_world_pos = eyepos + toWorld( refPos )*readDepth( refPos );

	//if (reflect_world_pos.z > 0)
		refPos = UVCoord;

	//reflection = tex2D(ReflectionMap, float2(refPos.x,1-refPos.y) );

	float fresnel = saturate( getFresnelAboveWater( norm_camera_vector, normal ) * reflectivity );
	float4 water_result = lerp( refract_color, reflection, fresnel );
	
	float sunReflectionStrength = dot(reflection.rgb, float3(0.21,0.72,0.07) )/0.865;
	sunReflectionStrength = 5 * pow( sunReflectionStrength, 5);
	sunReflectionStrength *= lerp(1,15,saturate(nightAmount*nightAmount));

	float specular = saturate(dot( norm_camera_vector, reflect( SunDir.xyz, specNorm ) ));
	water_result.xyz += 4*saturate(sunReflectionStrength)*pow(specular, (depth-uw_pos)*0.3 + 750) * sunColor.xyz;

	float eyeFogDist = eyepos.z * (1.28 - 0.28 * (2*UVCoord.x-1)*(2*UVCoord.x-1));
	float eyeFog = saturate(eyeFogDist/30500 + 0.37);
	reflection = lerp(reflection, linFogColor, eyeFog);

	//Add above water fog
    float fog = 1 - saturate((FogParam.x - length(IN.texcoord_0.xyz)) / FogParam.y);
	water_result.rgb = (fog * (reflection.rgb - water_result.rgb)) + water_result.rgb;

	water_result.rgb += ditherMat[ PixelPos.x%4 ][ PixelPos.y%4 ] / 255;

	color.rgb = lerp(water_result.rgb, color.rgb, saturate( pow(saturate(exp(world_pos.z/(800*shoreFactor))), 90) ));
    color.rgb = pow(color.rgb, 1.0/2.2); //delinearise
	//Smooth shore transitions
	OUT.color_0.rgb = color.rgb;
	OUT.color_0.a = 1;
	
    //OUT.color_0 = float4(0.0, 0.0, 1.0, 1.0);

    return OUT;
};