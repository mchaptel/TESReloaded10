#pragma once
#define SamplerStatesMax 12
#define ShadowCubeMapsMax 12
#define TrackedLightsMax 12

class TextureRecord {
public:
	TextureRecord();
	
	enum TextureRecordType {
		None,
		PlanarBuffer,
		VolumeBuffer,
		CubeBuffer,
		SourceBuffer,
		RenderedBuffer,
		DepthBuffer,
		NormalsBuffer,
		AvgLumaBuffer,
		ShadowMapBufferNear,
		ShadowMapBufferMiddle,
		ShadowMapBufferFar,
		ShadowMapBufferLod,
		OrthoMapBuffer,
		ShadowCubeMapBuffer0,
		ShadowCubeMapBuffer1,
		ShadowCubeMapBuffer2,
		ShadowCubeMapBuffer3,
		ShadowCubeMapBuffer4,
		ShadowCubeMapBuffer5,
		ShadowCubeMapBuffer6,
		ShadowCubeMapBuffer7,
		ShadowCubeMapBuffer8,
		ShadowCubeMapBuffer9,
		ShadowCubeMapBuffer10,
		ShadowCubeMapBuffer11,
		PointShadowBuffer,
		WaterHeightMapBuffer, /*Textures assigned after init*/
        WaterReflectionMapBuffer,
	};

	bool					LoadTexture(TextureRecordType Type, const char* Filename);

	IDirect3DBaseTexture9*	Texture;
	DWORD					SamplerStates[SamplerStatesMax];
};

typedef std::map<std::string, IDirect3DBaseTexture9*> TextureList;
typedef std::vector<TextureRecord*> WaterMapList;

class TextureManager { // Never disposed
public:
	static void				Initialize();
	static void					InitTexture(IDirect3DTexture9** Texture, IDirect3DSurface9** Surface, int Width, int Height, D3DFORMAT format);

	TextureRecord*			LoadTexture(ID3DXBuffer* ShaderSource, D3DXPARAMETER_TYPE ConstantType, LPCSTR ConstantName, UINT RegisterIndex, bool* HasRenderedBuffer, bool* HasDepthBuffer);
	void 					GetSamplerStates(std::string& samplerStateSubstring, TextureRecord* textureRecord );
	void					SetWaterHeightMap(IDirect3DBaseTexture9* WaterHeightMap);
    void                    SetWaterReflectionMap(IDirect3DBaseTexture9* WaterReflectionMap);
	std::string				GetFilenameForTexture(std::string&  resourceSubstring);
    IDirect3DBaseTexture9* 	GetCachedTexture(std::string& pathS);

	IDirect3DTexture9*		SourceTexture;
	IDirect3DSurface9*		SourceSurface;
	IDirect3DTexture9* 		RenderedTexture;
	IDirect3DSurface9*		RenderedSurface;
	IDirect3DTexture9* 		NormalsTexture;
	IDirect3DSurface9*		NormalsSurface;
	IDirect3DTexture9* 		ShadowPassTexture;
	IDirect3DSurface9*		ShadowPassSurface;
	IDirect3DTexture9* 		AvgLumaTexture;
	IDirect3DSurface9*		AvgLumaSurface;
	IDirect3DTexture9* 		BloomTexture;
	IDirect3DSurface9*		BloomSurface;
	IDirect3DTexture9*		DepthTexture;
	IDirect3DTexture9*		DepthTextureINTZ;
	IDirect3DSurface9*		DepthSurface;
	IDirect3DTexture9*		ShadowMapTexture[5];
	IDirect3DSurface9*		ShadowMapSurface[5];
	IDirect3DTexture9*		ShadowMapTextureBlurred[4];
	IDirect3DSurface9*		ShadowMapSurfaceBlurred[4];
	IDirect3DSurface9*		ShadowMapDepthSurface[5];
	IDirect3DCubeTexture9*	ShadowCubeMapTexture[ShadowCubeMapsMax];
	IDirect3DSurface9*		ShadowCubeMapSurface[ShadowCubeMapsMax][6];
	IDirect3DSurface9*		ShadowCubeMapDepthSurface;
	TextureList				Textures;
    WaterMapList         	WaterHeightMapTextures;
    WaterMapList         	WaterReflectionMapTextures;

    IDirect3DBaseTexture9*  WaterHeightMapB;
    IDirect3DBaseTexture9*  WaterReflectionMapB;

};
