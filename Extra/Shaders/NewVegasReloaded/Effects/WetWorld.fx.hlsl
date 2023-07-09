// WetWorld fullscreen shader for Oblivion/NewVegas Reloaded
//----------------------------------------------------------
//Todo:
//----------------------------------------------------------
// Fix viewmodel issue
// Look into adding code from refraction for better looking water(?)
// Reflection buffer(?)
// Make better ripple normal(?)
// Add ripples to other water sources(?)
// Add world spec multi(?)
//----------------------------------------------------------
// Boomstick was here

float4 TESR_SunDirection;
float4 TESR_ReciprocalResolution;
float4x4 TESR_WorldViewProjectionTransform;
float4x4 TESR_ShadowCameraToLightTransformOrtho;

float4 TESR_GameTime;
float4 TESR_SkyColor;
float4 TESR_HorizonColor;
float4 TESR_SunColor;
float4 TESR_SunAmbient;
float4 TESR_WetWorldCoeffs; // Puddle color R, G, B + spec multiplier
float4 TESR_WaterSettings; // for water height to avoid rendering puddles underwater
float4 TESR_WetWorldData; // x: current rain amount, y: max rain amount, z: puddle amount, w:puddle darkness/intensity

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_DepthBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_SourceBuffer : register(s2) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_RippleSampler : register(s3) < string ResourceName = "Precipitations\ripples.dds"; > = sampler_state { ADDRESSU = WRAP; ADDRESSV = WRAP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_OrthoMapBuffer : register(s4) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_NormalsBuffer : register(s5) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = NONE; MINFILTER = NONE; MIPFILTER = NONE; };
sampler2D TESR_PointShadowBuffer : register(s6) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };


//------------------------------------------------------
// Custimizable
//------------------------------------------------------
static const float PI = 3.14159265; //changes intensity of the ripples normal
static const float time1 = TESR_GameTime.z * 0.96f; // Ripple timing, make sure to offset each by atleast a few
static const float time2 = TESR_GameTime.z * 0.97f; // Ripple timing, original 1.0-1.4
static const float time3 = TESR_GameTime.z * 0.98f; // Ripple timing
static const float time4 = TESR_GameTime.z * 0.99f; // Ripple timing
static const float DrawD = 2000.0f; // Max draw distance for puddles 0-1000000
static const float rippleScale = 80.0f;
static const float refractionScale = 25;
//------------------------------------------------------

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

#include "Includes/Helpers.hlsl"
#include "Includes/Depth.hlsl"
#include "Includes/Blur.hlsl"
#include "Includes/Normals.hlsl"


float3 ComputeRipple(float2 UV, float CurrentTime, float Weight)
{
    float4 Ripple = tex2D(TESR_RippleSampler, UV);
	
    Ripple.yz = expand(Ripple.yz); // convert from 0/1 to -1/1 

    float period = frac(Ripple.w + CurrentTime);
    float TimeFrac = period - 1.0f + Ripple.x;
    float DropFactor = saturate(0.2f + Weight * 0.8f - period);
    float FinalFactor = DropFactor * Ripple.x * sin( clamp(TimeFrac * 9.0f, 0.0f, 3.0f) * PI);

    return float3(Ripple.yz * FinalFactor * 0.35f, 1.0f);
}


float4 ScreenCoordToTexCoord(float4 coord, float mult){
	// apply perspective (perspective division) and convert from -1/1 to range to 0/1 (shadowMap range);
	coord.xyz /= coord.w;
	coord.x = coord.x * 0.5f + 0.5f;
	coord.y = coord.y * -0.5f + 0.5f;
	coord *= mult;

	return coord;
}


float4 WetMap (VSOUT IN ) : COLOR0
{
	// sample the ortho map and detect pockets by sampling around the center and comparing depth
	float2 uv = IN.UVCoord;
	float4 color = tex2D(TESR_SourceBuffer, uv);
	float bias = 0.000001;

	float radius = 0.05 * TESR_WetWorldData.z;// radius will increase with rain status
	float center = tex2D(TESR_OrthoMapBuffer, IN.UVCoord).r - bias;
	float left = tex2D(TESR_OrthoMapBuffer, IN.UVCoord + normalize(float2(-1, -0.3)) * radius).r;
	float right = tex2D(TESR_OrthoMapBuffer, IN.UVCoord + normalize(float2(1, -0.3)) * radius).r;
	float top = tex2D(TESR_OrthoMapBuffer, IN.UVCoord + float2(0, 1) * radius).r;

	float crease = (center > left && center > right && center > top);

	return float4(crease, center, 0, 1);
}


float4 BlurWetMap(VSOUT IN, uniform float2 OffsetMask, uniform float blurRadius) : COLOR0
{
	// blur puddles using a gaussian blur
	float WeightSum = 0.114725602f;
	float2 uv = IN.UVCoord;
	float color = tex2D(TESR_RenderedBuffer, uv).r * WeightSum;

    for (int i = 0; i < cKernelSize; i++)
    {
		float2 uvOff = (BlurOffsets[i] * OffsetMask) * blurRadius;
		color += BlurWeights[i] * tex2D(TESR_RenderedBuffer, uv + uvOff).r;
		WeightSum += BlurWeights[i];
    }
	color /= WeightSum;
    return color;
}

float4 Wet( VSOUT IN ) : COLOR0
{
	float4 baseColor = tex2D(TESR_SourceBuffer, IN.UVCoord);

	float depth = readDepth(IN.UVCoord);
	float3 eyeDirection = toWorld(IN.UVCoord);
	float3 camera_vector = eyeDirection * depth;
	float4 worldPos = float4(TESR_CameraPosition.xyz + camera_vector, 1.0f);
	float3 normal = GetWorldNormal(IN.UVCoord);
	float3 up = float3(0, 0, 1);
	float floorAngle = smoothstep(0.94,1, dot(normal, up));
	eyeDirection = normalize(eyeDirection);

	// early out to avoid computing pixels that aren't puddles
    if (depth > DrawD || floorAngle == 0) return baseColor;

	float LODfade = smoothstep(DrawD, 0, depth);
	float thickness = 0.003; // thickness of the valid areas around the ortho map depth that will receive the effect (cancels out too far above or below ortho value)

	// get puddle mask from ortho map
	float4 pos = mul(worldPos, TESR_WorldViewProjectionTransform);
	float4 ortho_pos = mul(pos, TESR_ShadowCameraToLightTransformOrtho);
	float puddles = tex2D(TESR_RenderedBuffer, ScreenCoordToTexCoord(ortho_pos, 1).xy).r; // puddles, ortho height
	float ortho = tex2D(TESR_OrthoMapBuffer, ScreenCoordToTexCoord(ortho_pos, 1).xy).r; // puddles, ortho height

	float aboveGround = ortho_pos.z < ortho + thickness;
	float belowGround = ortho_pos.z > ortho - thickness;

	puddles = puddles * 2 * belowGround;
	float puddlemask = pow(puddles, 3);  // sharpen puddle mask to get the deeper part of the puddle
	puddlemask = saturate(puddlemask); 

	// sample and combine rain ripples
	float2 rippleUV = worldPos.xy / rippleScale;
	float4 Weights = float4(1, 0.75, 0.5, 0.25) * TESR_WetWorldData.x;
	Weights = saturate(Weights * 4);
	float3 Ripple1 = ComputeRipple(rippleUV + float2( 0.25f,0.0f), time1, Weights.x);
	float3 Ripple2 = ComputeRipple(rippleUV * 1.1 + float2(-0.55f,0.3f), time2, Weights.y);
	float3 Ripple3 = ComputeRipple(rippleUV * 1.3 + float2(0.6f, 0.85f), time3, Weights.z);
	float3 Ripple4 = ComputeRipple(rippleUV * 1.5 + float2(0.5f,-0.75f), time4, Weights.w);

	float4 Z = lerp(1, float4(Ripple1.z, Ripple2.z, Ripple3.z, Ripple4.z), Weights);
	float3 ripple = float3( Weights.x * Ripple1.xy + Weights.y * Ripple2.xy + Weights.z * Ripple3.xy + Weights.w * Ripple4.xy, Z.x * Z.y * Z.z * Z.w);
	float3 ripnormal = normalize(ripple);
	float3 combinedNormals = float3(ripnormal.xy * aboveGround * belowGround * LODfade, 1); //only add ripple to surfaces that match ortho depth

	// refract image through ripple normals
	float2 refractionUV = expand(projectPosition(combinedNormals)).xy * TESR_ReciprocalResolution.xy * (refractionScale);
	float4 rippleColor = tex2D(TESR_SourceBuffer, refractionUV + IN.UVCoord);

	// sample and strenghten the shadow map
	float inShadow = saturate(pow(tex2D(TESR_PointShadowBuffer, IN.UVCoord) / luma(TESR_SunAmbient), 5));

	// calculate puddle color
	float4 puddleColor = rippleColor * lerp(1, 0.5, TESR_WetWorldData.w); // base color is just darkened ground color
	float4 fresnelColor = TESR_HorizonColor * 0.8;
	float glossiness = 300;
	float fresnel = lerp(0, pow(1 - dot(-eyeDirection, combinedNormals), 5) * inShadow, TESR_WetWorldData.w);

	float3 halfwayDir = normalize(TESR_SunDirection.xyz - eyeDirection);

	float specular = pow(shades(combinedNormals, halfwayDir), glossiness * lerp(2, 5, puddlemask)) * inShadow;

	puddleColor = lerp(puddleColor, fresnelColor, saturate(fresnel * puddlemask));
	puddleColor += specular * TESR_SunColor * 8;

	// transition between surface ripple and deeper puddles
	float4 color = lerp(rippleColor, puddleColor, puddlemask);

    return lerp(baseColor, color, LODfade); // fade out puddles
}


technique
{
	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 WetMap();
	}
	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 BlurWetMap(float2(1.0f, 0.0f), 2);
	}
	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 BlurWetMap(float2(0.0f, 1.0f), 2);
	}
	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 Wet();
	}
}
