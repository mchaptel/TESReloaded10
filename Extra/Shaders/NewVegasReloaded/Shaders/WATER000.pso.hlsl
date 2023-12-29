// autowater surface shader (closeup, no wading displacement)

float4 EyePos : register(c1);
float4 ShallowColor : register(c2);
float4 DeepColor : register(c3);
float4 ReflectionColor : register(c4);
float4 FresnelRI : register(c5); //x: reflectamount, y:fresnel, w: opacity, z:speed
float4 VarAmounts : register(c8); // x: water glossiness y: reflectivity z: refrac, w: lod
float4 FogParam : register(c9);
float4 FogColor : register(c10);
float2 DepthFalloff : register(c11); // start / end depth fog
float4 SunDir : register(c12);
float4 SunColor : register(c13);
float4 TESR_WaveParams : register(c14); // x: choppiness, y:wave width, z: wave speed, w: reflectivity?
float4 TESR_WaterVolume : register(c15); // x: caustic strength, y:shoreFactor, w: turbidity, z: caustic strength S ?
float4 TESR_WaterSettings : register(c16); // x: caustic strength, y:depthDarkness, w: turbidity, z: caustic strength S ?
float4 TESR_GameTime : register(c17);
float4 TESR_HorizonColor : register(c18);
float4 TESR_SunDirection : register(c19);
float4 TESR_ReciprocalResolution : register(c20);
float4 TESR_WetWorldData : register(c21);
float4 TESR_WaterShorelineParams : register(c22);

sampler2D ReflectionMap : register(s0);
sampler2D RefractionMap : register(s1);
sampler2D NoiseMap : register(s2);
sampler2D DisplacementMap : register(s3); //unused
sampler2D DepthMap : register(s4);
sampler2D TESR_samplerWater : register(s5) < string ResourceName = "Water\water_NRM.dds"; > = sampler_state { ADDRESSU = WRAP; ADDRESSV = WRAP; ADDRESSW = WRAP; MAGFILTER = ANISOTROPIC; MINFILTER = ANISOTROPIC; MIPFILTER = ANISOTROPIC; } ;
sampler2D TESR_RippleSampler : register(s6) < string ResourceName = "Precipitations\ripples.dds"; > = sampler_state { ADDRESSU = WRAP; ADDRESSV = WRAP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

#include "Includes/Helpers.hlsl"
#include "Includes/Water.hlsl"
//#include "../Effects/Includes/Depth.hlsl"

PS_OUTPUT main(PS_INPUT IN, float2 PixelPos : VPOS) {
    PS_OUTPUT OUT;

    float4 linSunColor = pows(SunColor,2.2); //linearise
    float4 linShallowColor = pows(ShallowColor,2.2); //linearise
    float4 linDeepColor = pows(DeepColor,2.2); //linearise
    float4 linHorizonColor = pows(TESR_HorizonColor,2.2); //linearise

    // float2 UVCoord = (PixelPos+0.5)*TESR_ReciprocalResolution.xy;
    // float4 worldPos = reconstructWorldPosition(UVCoord);
    // float3 floorNormal = normalize(cross(ddx(worldPos), ddy(worldPos)));


    float3 eyeVector = EyePos.xyz - IN.LTEXCOORD_0.xyz; // vector of camera position to point being shaded
    float3 eyeDirection = normalize(eyeVector);         // normalized eye to world vector (for lighting)
    float distance = length(eyeVector.xy);              // surface distance to eye
    float depth = length(eyeVector);                    // depth distance to eye


    // calculate fog coeffs
    float4 screenPos = getScreenpos(IN);                // point coordinates in screen space for water surface

    float2 waterDepth = tex2Dproj(DepthMap, screenPos).xy;  // x= shallowfog, y = deepfog?
    float depthFog = saturate(invlerp(DepthFalloff.x, DepthFalloff.y, waterDepth.y));
    
    float2 fadedDepth = saturate(lerp(waterDepth, 1, invlerp(0, 4096, distance)));
    float2 depths = float2(fadedDepth.y + depth, depth); // deepfog
    depths = saturate((FogParam.x - depths) / FogParam.y); 

    float LODfade = saturate(smoothstep(4096,4096 * 2, distance));
    float sunLuma = luma(linSunColor);
    float exteriorRefractionModifier = 0.5;		// reduce refraction because of the way interior depth is encoded
    float exteriorDepthModifier = 1;			// reduce depth value for fog because of the way interior depth is encoded

    float3 surfaceNormal = getWaveTexture(IN, distance).xyz;
    surfaceNormal = getRipples(IN, TESR_RippleSampler, surfaceNormal, distance, TESR_WetWorldData.x);

    float refractionCoeff = (waterDepth.y * depthFog) * ((saturate(distance * 0.002) * (-4 + VarAmounts.w)) + 4);
    float4 reflectionPos = getReflectionSamplePosition(IN, surfaceNormal, refractionCoeff * exteriorRefractionModifier);
    float4 reflection = tex2Dproj(ReflectionMap, reflectionPos);
    float4 refractionPos = reflectionPos;
    refractionPos.y = refractionPos.w - reflectionPos.y;
    float3 refractedDepth = tex2Dproj(DepthMap, refractionPos).rgb * exteriorDepthModifier;

    // float water = max(refractedDepth.y, 0.0000000001) * 4096;
    // float water = max(waterDepth.y, 0.0000000001) * 4096;
    // float4 floorNormal = float4(normalize(float4(ddx(water), ddy(water), 1, 1).rgb) + eyeDirection.rgb, 1);

    float4 color = tex2Dproj(RefractionMap, refractionPos);
    color = getLightTravel(refractedDepth, linShallowColor, linDeepColor, sunLuma, color);
    color = lerp(getTurbidityFog(refractedDepth, linShallowColor, sunLuma, color), float4(linShallowColor.rgb * sunLuma, 1), LODfade); // fade to full fog to hide LOD seam
    color = getDiffuse(surfaceNormal, TESR_SunDirection.xyz, eyeDirection, distance, linHorizonColor, color);
    color = getFresnel(surfaceNormal, eyeDirection, reflection, color);
    color = getSpecular(surfaceNormal, TESR_SunDirection.xyz, eyeDirection, linSunColor.rgb * dot(TESR_SunDirection.rgb, float3(0, 0, 1)), color);
    color = getShoreFade(IN, waterDepth.x, color);

    color = pows(color, 1.0/2.2);  //delinearise
    OUT.color_0 = color;
    // OUT.color_0.a = lerp(color.a, 1, LODfade); // fade to full opacity to hide LOD seam
    return OUT;
};