# Coherence - Art Pipeline

## Overview

AI-first approach to creating pixel art assets for Coherence using automated generation, with Aseprite for post-processing and tweaks. Since we're not artists, we rely on AI to generate all base assets while maintaining consistency through style references and controlled prompts.

## Art Creation Workflow

### Primary: AI Generation (All Base Assets)
The AI pipeline is **critical** for this project as it generates 100% of our initial art assets.

1. **What We Generate**
   - Chunk templates (10x10 tiles each)
   - Character sprites with directional variants
   - Tileable textures for terrain
   - Buildings and objects
   - UI elements and icons
   - Environmental props

2. **Asset Specifications**
   - **Chunks**: 10x10 tiles at 32x32px per tile = 320x320px per chunk
   - **Characters**: 32x32px base, 4-directional sprites
   - **Tiles**: 32x32px, must be tileable
   - **UI Elements**: 16x16px or 32x32px
   - **Palette**: 16-color restriction per universe
   - **Style**: Top-down perspective, Stardew Valley/Jarl aesthetic

3. **Why AI Generation is Essential**
   - No artistic skills required
   - Consistent style through reference images
   - Rapid iteration and experimentation
   - Can generate hundreds of variations
   - Batch processing for entire universes

### Secondary: Aseprite (Post-Processing Only)
Used only for:
- Minor touch-ups and fixes
- Adjusting colors/palettes
- Creating sprite sheets from AI outputs
- Fixing tile edges for seamless tiling
- Adding transparency where needed

## Directory Structure

Within the monorepo:
```
Coherence/
├── art/                     # This component
│   ├── src/
│   │   ├── generator.py         # Main PixelArtGenerator class
│   │   ├── style_manager.py     # Style consistency management
│   │   ├── batch_processor.py   # Batch generation logic
│   │   └── workflow_templates/  # ComfyUI workflow JSONs
│   ├── config/
│   │   ├── styles.yaml          # Universe style definitions
│   │   ├── assets.yaml          # Asset categories and specs
│   │   └── output.yaml          # Output path configuration
│   ├── references/              # Style reference images
│   │   ├── global/             # Shared reference images
│   │   └── universes/          # Universe-specific references
│   ├── scripts/
│   │   ├── generate.py         # Main generation script
│   │   └── setup_comfyui.py    # ComfyUI installation helper
│   ├── requirements.txt
│   └── README.md
├── game/                    # Bevy game that uses generated assets
│   └── assets/             # Output directory for generated assets
└── scripts/                # Root-level convenience scripts
    └── generate-assets.sh  # Wrapper for art generation
```

## Core Components

### 1. ComfyUI Backend Setup
```bash
# Install ComfyUI locally
git clone https://github.com/comfyanonymous/ComfyUI
cd ComfyUI
pip install -r requirements.txt

# Required models to download:
# - SDXL base model
# - Pixel Art XL LoRA
# - Microverse LoRA  
# - ControlNet models (Canny, Reference)
```

### 2. Configuration Files

**config/styles.yaml:**
```yaml
global:
  perspective: "top-down 3/4 view"
  resolution: 32
  palette_size: 16
  style_reference: "stardew_valley"

universes:
  dystopia:
    modifiers: "dark, industrial, muted colors, harsh edges"
    palette: "dystopia_16.pal"
    reference_dir: "references/universes/dystopia/"
  
  utopia:
    modifiers: "bright, pastel, soft edges, nature"
    palette: "utopia_16.pal"
    reference_dir: "references/universes/utopia/"
```

**config/output.yaml:**
```yaml
output:
  base_path: "../game/assets/"  # Relative to art-pipeline directory
  structure:
    sprites: "sprites/{category}/{name}/"
    metadata: "metadata/{universe}/"
    generation_log: "metadata/generation_log.json"
```

### 3. Python Pipeline Controller
```python
# src/generator.py
import json
import requests
from pathlib import Path
import yaml

class PixelArtGenerator:
    def __init__(self, config_path="./config"):
        self.api_url = "http://127.0.0.1:8188"
        self.config = self.load_config(config_path)
        self.workflow_template = self.load_workflow()
    
    def generate_sprite(self, 
                       prompt: str,
                       category: str,  # "character", "item", "tile", "effect"
                       variant: str = None,  # "idle", "walking", "attacking"
                       use_reference: bool = True):
        """Generate a single sprite with consistent style"""
        
        workflow = self.workflow_template.copy()
        
        # Inject prompt with style consistency tags
        full_prompt = self.build_prompt(prompt, category)
        workflow["nodes"]["prompt"]["text"] = full_prompt
        
        # Add reference image for style consistency
        if use_reference and category in self.style_references:
            workflow["nodes"]["controlnet_reference"]["image"] = \
                self.style_references[category]
        
        # Send to ComfyUI API
        response = requests.post(f"{self.api_url}/prompt", 
                                json={"prompt": workflow})
        return self.wait_for_result(response.json()["prompt_id"])
    
    def generate_sprite_sheet(self, base_prompt: str, animations: list):
        """Generate full sprite sheet with all animations"""
        sprites = []
        for animation in animations:
            sprite = self.generate_sprite(
                f"{base_prompt} {animation}",
                category="character",
                variant=animation
            )
            sprites.append(sprite)
        return self.combine_sprites(sprites)
```

### 4. Style Consistency System

```python
class StyleManager:
    def __init__(self):
        self.style_db = {
            "global": {
                "palette": "16-color restricted palette",
                "resolution": "16x16 or 32x32 pixels",
                "perspective": "top-down 3/4 view like Stardew Valley",
                "lighting": "soft ambient with subtle shadows"
            },
            "universes": {
                "utopia": {
                    "modifiers": "bright, pastel, soft edges, nature elements",
                    "reference_image": "utopia_ref.png"
                },
                "dystopia": {
                    "modifiers": "dark, muted colors, industrial, harsh edges",
                    "reference_image": "dystopia_ref.png"
                },
                "retro": {
                    "modifiers": "8-bit, limited palette, blocky",
                    "reference_image": "retro_ref.png"
                }
            }
        }
    
    def get_universe_prompt(self, universe_type: str, base_prompt: str):
        """Build consistent prompts for specific universe aesthetics"""
        global_style = self.style_db["global"]
        universe_style = self.style_db["universes"].get(universe_type, {})
        
        return f"""
        {base_prompt},
        {global_style['perspective']},
        {global_style['resolution']} pixel art,
        {universe_style.get('modifiers', '')},
        {global_style['palette']},
        miniature, game asset, sprite
        """
```

### 5. Batch Generation with Consistency

```python
class BatchAssetGenerator:
    def __init__(self, style_manager, art_generator):
        self.style = style_manager
        self.generator = art_generator
        self.generated_assets = []
    
    def generate_universe_assets(self, universe_type: str):
        """Generate all assets for a specific universe"""
        
        asset_list = {
            "tiles": ["grass", "stone", "water", "path"],
            "objects": ["tree", "rock", "building", "portal"],
            "characters": ["player", "npc_friendly", "npc_hostile"],
            "items": ["key", "fuel_cell", "quantum_device"]
        }
        
        for category, assets in asset_list.items():
            for asset_name in assets:
                prompt = self.style.get_universe_prompt(
                    universe_type, 
                    f"{asset_name} {category}"
                )
                
                # Use previous generations as additional references
                if self.generated_assets:
                    # This ensures style drift doesn't occur
                    reference = self.generated_assets[-1]
                else:
                    reference = None
                
                image = self.generator.generate_sprite(
                    prompt, 
                    category,
                    use_reference=reference
                )
                
                self.generated_assets.append(image)
                self.save_asset(universe_type, category, asset_name, image)
```

### 6. ComfyUI Workflow Template

```json
{
  "workflow": {
    "nodes": {
      "sdxl_loader": {
        "class": "CheckpointLoaderSimple",
        "inputs": {
          "ckpt_name": "sdxl_base.safetensors"
        }
      },
      "lora_pixel_art": {
        "class": "LoraLoader",
        "inputs": {
          "lora_name": "pixel-art-xl.safetensors",
          "strength": 0.8
        }
      },
      "controlnet_reference": {
        "class": "ControlNetApply",
        "inputs": {
          "control_net": "control_v11p_sd15_reference.pth",
          "strength": 0.6,
          "mode": "style_transfer"
        }
      },
      "controlnet_canny": {
        "class": "ControlNetApply",
        "inputs": {
          "control_net": "control_v11p_sd15_canny.pth",
          "strength": 0.4,
          "mode": "structure"
        }
      },
      "sampler": {
        "class": "KSampler",
        "inputs": {
          "steps": 20,
          "cfg": 7.5,
          "sampler_name": "euler_a",
          "scheduler": "karras"
        }
      },
      "pixel_perfect_postprocess": {
        "class": "ImageScaleBy",
        "inputs": {
          "upscale_method": "nearest-exact",
          "scale_by": 1.0
        }
      }
    }
  }
}
```

## CLI Usage

```bash
# From project root
./scripts/generate-assets.sh dystopia  # Convenience wrapper

# Or from art directory
cd art
python scripts/generate.py --universe dystopia

# Generate single sprite with custom prompt
python scripts/generate.py \
  --prompt "glowing quantum portal device" \
  --category object \
  --universe dystopia \
  --single

# Batch generate from asset list
python scripts/generate.py --config config/assets.yaml --universe utopia
```

## Python API Usage

```python
# From within the monorepo
import sys
sys.path.append('../art/src')

from generator import PixelArtGenerator
from batch_processor import BatchProcessor

# Initialize - automatically uses ../game/assets/ as output
generator = PixelArtGenerator()

# Generate with universe style
sprite = generator.generate_sprite(
    prompt="friendly robot NPC",
    universe="utopia",
    category="character"
)

# Batch generate all assets for a universe
processor = BatchProcessor(generator)
processor.generate_universe("dystopia")
```

## Key Features

1. **Style Consistency**: Every asset references previous generations and style guides
2. **Batch Processing**: Generate entire universe asset sets programmatically
3. **Version Control**: All prompts and settings saved with outputs
4. **Reproducibility**: Same seed + prompt = same output
5. **Progressive Refinement**: Can iterate on specific assets while maintaining style

## Output Structure

The generator outputs assets to the game directory:

```
../game/assets/
├── sprites/
│   ├── characters/
│   │   └── player/
│   │       ├── idle.png
│   │       ├── walk.png (sprite sheet)
│   │       └── metadata.json
│   ├── tiles/
│   │   ├── grass_dystopia.png
│   │   ├── grass_utopia.png
│   │   └── tileset.json
│   └── objects/
│       └── portal.png
└── metadata/
    ├── dystopia/
    │   └── generation_log.json
    └── utopia/
        └── generation_log.json
```

Each asset includes metadata:
```json
{
  "prompt": "friendly robot NPC, top-down 3/4 view, 32x32 pixel art",
  "universe": "utopia",
  "seed": 12345,
  "model": "sdxl_base",
  "loras": ["pixel-art-xl"],
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## Advantages Over Web UIs

- **Programmatic control**: Generate 100s of assets with consistent style
- **Git-trackable**: Workflow definitions and prompts in version control
- **Reproducible**: Exact same outputs from same inputs
- **Batch operations**: Generate entire sprite sheets automatically
- **Style enforcement**: Can't accidentally drift from established aesthetic
- **Reference learning**: Each generation improves consistency

## Setup Instructions

1. **From project root:**
   ```bash
   ./scripts/setup.sh  # Installs everything including ComfyUI
   ```

2. **Or manually:**
   ```bash
   cd art
   pip install -r requirements.txt
   python scripts/setup_comfyui.py
   ```

3. **Download required models:**
   - SDXL base model from Hugging Face
   - Pixel Art XL LoRA from Civitai
   - ControlNet models (Canny, Reference)

4. **Generate test assets:**
   ```bash
   cd art
   python scripts/generate.py --prompt "test sprite" --category test --single
   ```

## Development Workflow

1. **Create style references:** Draw or generate initial reference images for each universe
2. **Configure styles:** Define universe aesthetics in `art/config/styles.yaml`
3. **Test generation:** Generate single sprites to validate style
4. **Batch generate:** Create full asset sets for each universe
5. **Test in game:** Run game to see assets in context
6. **Iterate:** Refine prompts and references based on results

## Integration with Game Development

The monorepo structure allows for tight integration:

1. Generate assets: `cd art && python scripts/generate.py`
2. Assets appear immediately in `game/assets/`
3. Bevy hot-reloads if running
4. Commit both generator changes and new assets together

This workflow ensures art generation and game development stay in sync.