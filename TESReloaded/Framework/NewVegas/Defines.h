#pragma once

#define CommandPrefix "NVR"
#define SettingsFile "\\Data\\NVSE\\Plugins\\NewVegasReloaded.dll.config"
#define TomlSettingsFile "\\Data\\NVSE\\Plugins\\NewVegasReloaded.dll.toml"
#define DefaultsSettingsFile "\\Data\\NVSE\\Plugins\\NewVegasReloaded.dll.defaults.toml"
#define ShadersPath "Data\\Shaders\\NewVegasReloaded\\Shaders\\"
#define EffectsPath "Data\\Shaders\\NewVegasReloaded\\Effects\\"
#define RenderStateArgs 0, 0
#define TerrainShaders "SLS2100.vso SLS2116.pso SLS2124.pso SLS2132.pso SLS2136.pso SLS2140.pso SLS2144.pso"
#define BloodShaders ""
static const char* IntroMovie = "NVRGameStudios.bik";
static const char* MainMenuMovie = "\\Data\\Video\\NVRMainMenu.bik";
static const char* MainMenuMusic = "NVRMainMenu";
static char* TitleMenu = (char*)"New Vegas Reloaded - Settings";

// to review
static const char* WeatherColorTypes[TESWeather::kNumColorTypes] = { "SkyUpper", "Fog", "CloudsLower", "Ambient", "Sunlight", "Sun", "Stars", "SkyLower", "Horizon", "CloudsUpper" };
static const char* WeatherTimesOfDay[TESWeather::kNumTimeOfDay] = { "Sunrise", "Day", "Sunset", "Night" };
static const char* WeatherHDRTypes[14] = { "EyeAdaptation", "BlurRadius", "BlurPasses", "EmissiveMult", "TargetLUM", "UpperLUMClamp", "BrightScale", "BrightClamp", "LUMRampNoTex", "LUMRampMin", "LUMRampMax", "SunlightDimmer", "GrassDimmer", "TreeDimmer" };