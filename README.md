# TerrainURPLitHeightBlend

A custom Unity terrain shader for Universal Render Pipeline (URP) featuring height-based texture blending.

**Created by sinica / free to use**

## Features

- 🎨 **4 Texture Layers** - Support for up to 4 different terrain textures
- 🏔️ **Height-Based Blending** - Realistic terrain transitions using height maps
- 💎 **PBR Support** - Full physically-based rendering with metallic and smoothness controls
- 🌟 **URP Compatible** - Optimized for Universal Render Pipeline
- 🔆 **Advanced Lighting** - Support for main light, shadows, additional lights, and fog
- 📐 **Normal Mapping** - Per-layer normal map support for detailed surfaces

## Installation

### Option 1: Unity Package Manager (Recommended)

1. Open Unity with a URP project
2. Clone this repository or download as ZIP
3. In Unity, go to `Window > Package Manager`
4. Click the `+` button and select `Add package from disk...`
5. Navigate to the cloned repository and select `package.json`

### Option 2: Manual Installation

1. Download or clone this repository
2. Copy the `Assets/TerrainURPLitHeightBlend` folder into your Unity project's `Assets` folder

## Quick Start Guide

### Creating a Terrain Material

1. **Create a new material:**
   - In Unity, right-click in the Project window
   - Select `Create > Material`
   - Name it (e.g., "MyTerrainMaterial")

2. **Assign the shader:**
   - Select the newly created material
   - In the Inspector, click the Shader dropdown
   - Navigate to `Custom > TerrainURPLitHeightBlend`

3. **Assign to terrain:**
   - Select your Terrain object in the Hierarchy
   - In the Terrain Inspector, go to the Paint Terrain section
   - Drag your material to the Material slot
   - **You will see the result immediately!**

### Using the Example Material

A pre-configured material is included at:
```
Assets/TerrainURPLitHeightBlend/Materials/TerrainMaterial.mat
```

Simply assign this material to your terrain to get started quickly.

## Shader Properties

### Layer Properties (0-3)

Each of the 4 layers has the following properties:

- **Layer X (Albedo)** - The color/diffuse texture for the layer
- **Layer X (Normal)** - Normal map for surface detail
- **Layer X (Height)** - Height map for blend control (grayscale)
- **Layer X Metallic** - Metallic value (0-1)
- **Layer X Smoothness** - Smoothness/glossiness value (0-1)

### Control Map

- **Control (RGBA)** - A texture that determines layer distribution
  - R channel = Layer 0 weight
  - G channel = Layer 1 weight
  - B channel = Layer 2 weight
  - A channel = Layer 3 weight

### Height Blend Settings

- **Height Blend Strength** (0-1) - How much height influences blending
  - 0 = Uses control map only
  - 1 = Maximum height-based blending
- **Height Transition** (0.01-1) - Smoothness of height blend transitions
  - Lower values = Sharper transitions
  - Higher values = Softer transitions

### Tiling

- **Tiling** - Scale factor for all texture layers (useful for adjusting texture density)

## How Height Blending Works

The shader combines two blending methods:

1. **Control Map Blending** - Traditional terrain blending using a control texture
2. **Height-Based Blending** - Adds realism by considering the height of each texture

When textures meet:
- Higher areas in height maps appear "on top"
- Creates natural-looking transitions (e.g., gravel appears in rock crevices)
- Reduces the artificial look of standard alpha blending

## Requirements

- Unity 2020.3 or newer
- Universal Render Pipeline (URP) 10.0 or newer
- A URP project setup (see Unity documentation for URP setup)

## Technical Details

### Shader Passes

1. **ForwardLit** - Main rendering pass with full PBR lighting
2. **ShadowCaster** - For casting shadows
3. **DepthOnly** - For depth rendering

### Supported Features

- ✅ Main directional light with shadows
- ✅ Shadow cascades
- ✅ Additional lights (point/spot)
- ✅ Soft shadows
- ✅ Fog
- ✅ Normal mapping
- ✅ PBR materials

## Tips for Best Results

1. **Height Maps:**
   - Use high-contrast height maps for better blending
   - Black = low areas, White = high areas
   - Can be generated from textures or created manually

2. **Control Map:**
   - Paint your control map in an image editor or use Unity's terrain tools
   - Each color channel represents one layer's weight

3. **Tiling:**
   - Start with Tiling = 10-20 for natural terrain scale
   - Adjust based on your terrain size

4. **Height Blend Strength:**
   - Start with 0.5 and adjust to taste
   - Higher values create more dramatic height-based effects

## Troubleshooting

**Shader appears pink:**
- Ensure you're using a URP project
- Check that URP is properly configured (Edit > Project Settings > Graphics)

**Textures appear too large/small:**
- Adjust the Tiling parameter in the material

**Blending looks wrong:**
- Check your control map - ensure channels are properly painted
- Verify height maps are grayscale images
- Adjust Height Blend Strength and Height Transition

## License

Free to use for personal and commercial projects.

Created by sinica.

## Credits

Shader implementation for Unity URP terrain with height-based blending.