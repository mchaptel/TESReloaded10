#pragma once
#pragma warning (disable: 4244) //disable warning for possible loss of data in implicit cast between int, float and double

#define DETOURS_INTERNAL
#define DIRECTINPUT_VERSION 0x0800

#include <windows.h>
#include <CommCtrl.h>
#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <sstream>
#include <fstream>
#include <algorithm>
#include <d3d9.h>
#include <d3dx9math.h>
#include <dinput.h>
#include <dsound.h>
#include "../Common/Lib/Detours/detours.h"
#include "../Common/Lib/Nvidia/nvapi.h"
#include "../Common/Lib/Bink/bink.h"
#include "../Common/Base/Logger.h"
#include "../Common/Base/Types.h"
#include "../Common/Base/SafeWrite.h"
#include "../Common/Base/PluginVersion.h"
#include "Plugin.h"
#include "GameNi.h"
#include "GameHavok.h"
#include "Game.h"
#include "Defines.h"
#include "Base.h"
#include "Managers.h"
#include "../Core/Hooks/GameCommon.h"
#include "../Core/Hooks/FormsCommon.h"
#include "../Core/Hooks/NewVegas/Settings.h"
#include "../Core/Hooks/NewVegas/Game.h"
#include "../Core/Hooks/NewVegas/ShaderIO.h"
#include "../Core/Hooks/NewVegas/Render.h"
#include "../Core/Hooks/NewVegas/Forms.h"
#include "../Core/Hooks/NewVegas/Shadows.h"
#include "../Core/Hooks/NewVegas/FlyCam.h"
