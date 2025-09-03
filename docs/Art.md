# Art Pipeline

## Overview

AI-first approach to creating consistent pixel art for Coherence. We use ComfyUI with Stable Diffusion to generate all art assets, maintaining consistency through reference images and fixed workflows. Everything is version-controlled through YAML configs and JSON workflows.

## Core Principles

1. **Consistency over quality** - Better to have coherent art style than perfect individual pieces
2. **Version everything** - All prompts, seeds, and workflows in git
3. **Reference-based generation** - New art always references existing approved art
4. **Simple over complex** - File-based organization, no databases

## How Style Consistency Works

### The Problem
AI generates different styles each time you prompt it. "pixel art tree" today looks nothing like "pixel art tree" tomorrow.

### Our Solution
1. **Reference Images** - Feed approved art back into every generation via ControlNet
2. **Fixed Seeds** - Same randomness = reproducible results  
3. **Style Config Files** - All style decisions in version-controlled YAML
4. **Workflow Templates** - Reusable ComfyUI workflows as JSON files

## System Architecture

```
Your Computer:
├── ~/Code/ComfyUI/               # Separate installation (not in repo)
│   ├── models/checkpoints/       # Large model files (5-10GB each)
│   ├── models/loras/            # Style LoRAs/DoRAs (smaller ~100MB)
│   └── models/controlnet/       # ControlNet models for consistency
│
└── ~/Code/coherence/             # Your game repo
    └── art/
        ├── workflows/           # ComfyUI JSON workflows (versioned)
        ├── styles/              # Style definitions (versioned)
        ├── references/          # Key reference images (versioned)
        ├── outputs/             # Raw generations (gitignored)
        ├── library/             # Organized assets (partially versioned)
        └── scripts/             # Generation automation
```

## Directory Structure

```
art/
├── workflows/                    # ComfyUI workflow templates
│   ├── base_sprite.json        # Basic sprite generation
│   ├── with_reference.json     # Uses ControlNet for consistency
│   └── sprite_sheet.json       # Multi-frame animations
│
├── styles/                      # Style configuration
│   ├── global.yaml             # Shared style settings
│   ├── dystopia.yaml           # Dystopia universe style
│   ├── utopia.yaml             # Utopia universe style
│   └── neutral.yaml            # Default/lab style
│
├── references/                  # Canonical reference images
│   ├── player_base.png         # The "true" player look
│   ├── tile_grass.png          # Standard grass tile
│   └── style_guide.png         # Overall aesthetic reference
│
├── outputs/                     # Raw ComfyUI outputs (gitignored)
│   └── session_*/              # Organized by date/session
│
├── library/                     # Curated asset library
│   ├── approved/               # Ready for game use
│   ├── review/                 # Needs decision
│   └── archive/                # Previous versions
│
└── scripts/
    ├── generate.py             # Main generation script
    ├── setup.py                # First-time setup helper
    └── server.py               # Simple preview web UI
```

## Style Configuration

### Style YAML Format

```yaml
# art/styles/dystopia.yaml
name: "Dystopia"
description: "Dark industrial universe with muted colors"

# Base prompt components (combined for every generation)
base_prompt: "pixel art, top-down view, 32x32 pixels, game asset"
style_modifiers: "dystopian, industrial, dark, muted colors, concrete, metal"
negative_prompt: "blurry, realistic, 3d render, photograph"

# Visual parameters
colors:
  primary: ["#2C3E50", "#34495E", "#7F8C8D"]  # Grays
  accent: ["#E74C3C", "#C0392B"]              # Warning reds
  
perspective: "top-down 3/4 view"
lighting: "harsh shadows, limited light sources"

# Consistency controls
seed: 42                                       # Fixed for reproducibility
reference_image: "references/dystopia_base.png"
reference_strength: 0.7                        # How much to match reference

# Generation settings
steps: 20
cfg_scale: 7.5
sampler: "euler_a"
```

## Generation Process

### 1. First Reference (Bootstrap)

When starting fresh, manually create your first "perfect" reference:

```python
# generate.py --manual
# Opens ComfyUI web UI
# Generate and save as references/player_base.png
```

### 2. Consistent Generation

All future sprites reference the approved style:

```python
# generate.py "robot enemy" --style dystopia
# Automatically uses references/dystopia_base.png
# Maintains consistent style
```

### 3. Batch Generation

Generate full asset sets with consistency:

```python
# generate.py --batch tiles --style all
# Generates grass, stone, water for all universes
# Each references the previous for consistency
```

## ComfyUI Setup

### Installation (Separate from repo)

```bash
# Install in ~/Code directory (or your preferred location)
cd ~/Code
git clone https://github.com/comfyanonymous/ComfyUI
cd ComfyUI

# Create Python environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install with Apple Silicon support
pip install torch torchvision torchaudio
pip install -r requirements.txt
```

### Required Models

#### For High-End Systems (32GB RAM, M4 Max or similar):

1. **SDXL Base Model** (6.5GB):
   ```bash
   cd ~/Code/ComfyUI/models/checkpoints
   wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
   ```

2. **SDXL Refiner** (6GB - Optional but recommended):
   ```bash
   wget https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
   ```

3. **RPG Maps DoRA** (For map generation):
   - Download from: https://civitai.com/models/840900
   - Use DoRA version for better quality when running locally
   - Place in `~/Code/ComfyUI/models/loras/`

4. **Pixel Art XL LoRA** (For character/object sprites):
   - Download from: https://civitai.com/models/120096/pixel-art-xl
   - Place in `~/Code/ComfyUI/models/loras/`

5. **ControlNet for SDXL** (2.5GB - For style consistency):
   ```bash
   cd ~/Code/ComfyUI/models/controlnet
   wget https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors -O controlnet_sdxl.safetensors
   ```

#### For Standard Systems:

1. **Base Model**: Stable Diffusion 1.5 (4GB)
2. **LoRA**: Pixel Art XL from Civitai
3. **ControlNet**: control_v11f1e_sd15_tile

### Running ComfyUI

```bash
# Terminal 1: Run ComfyUI server
cd ~/Code/ComfyUI
source venv/bin/activate
python main.py --listen

# Terminal 2: Run generation scripts
cd ~/Code/coherence/art
python scripts/generate.py "player sprite"
```

### Testing Installation

```bash
# Start ComfyUI
cd ~/Code/ComfyUI
source venv/bin/activate
python main.py --listen

# Open browser to http://localhost:8188
# You should see the ComfyUI interface
```

## Workflow Examples

### Example 1: Generate Player Sprite

```bash
python generate.py "player character" \
  --style dystopia \
  --reference references/player_base.png \
  --variations 5
```

Creates 5 variations, all matching the reference style.

### Example 2: Generate Tile Set

```bash
python generate.py --batch tiles \
  --styles all \
  --reference references/tile_grass.png
```

Generates grass, stone, water, path tiles for all universes.

### Example 3: Review and Approve

```bash
# Start preview server
python server.py

# Browse at http://localhost:5000
# Click images to move from outputs/ to library/approved/
```

## Python Scripts

### Core Generator (Simplified)

```python
# scripts/generate.py
import json
import yaml
import requests
from pathlib import Path

class ArtGenerator:
    def __init__(self):
        self.comfy_url = "http://localhost:8188"
        self.load_styles()
    
    def load_styles(self):
        """Load all style definitions"""
        self.styles = {}
        for style_file in Path("styles").glob("*.yaml"):
            with open(style_file) as f:
                self.styles[style_file.stem] = yaml.safe_load(f)
    
    def generate(self, prompt, style="neutral", reference=None):
        """Generate single asset with style consistency"""
        
        # Load workflow template
        with open("workflows/with_reference.json") as f:
            workflow = json.load(f)
        
        # Get style configuration
        style_config = self.styles[style]
        
        # Build full prompt
        full_prompt = f"{prompt}, {style_config['base_prompt']}, {style_config['style_modifiers']}"
        
        # Inject into workflow
        workflow["prompt"]["inputs"]["text"] = full_prompt
        workflow["negative_prompt"]["inputs"]["text"] = style_config['negative_prompt']
        workflow["seed"]["inputs"]["seed"] = style_config['seed']
        
        # Add reference image if provided
        if reference or style_config.get('reference_image'):
            ref_path = reference or style_config['reference_image']
            workflow["load_image"]["inputs"]["image"] = ref_path
            workflow["controlnet"]["inputs"]["strength"] = style_config.get('reference_strength', 0.7)
        
        # Send to ComfyUI
        response = requests.post(f"{self.comfy_url}/prompt", json={"prompt": workflow})
        
        # Wait for result
        return self.wait_for_output(response.json()['prompt_id'])
```

## Best Practices

### DO:
- Generate multiple variations, pick the best
- Save approved sprites as new references
- Use consistent naming: `{object}_{style}_{variant}.png`
- Document style decisions in YAML files
- Test assets in-game before finalizing

### DON'T:
- Change seeds unless intentionally varying
- Generate without references after initial bootstrap
- Mix styles within a universe
- Rely on single generations (always make variations)

## Troubleshooting

### Style Drift
**Problem**: New sprites don't match existing ones
**Solution**: Increase `reference_strength` in style YAML

### Inconsistent Colors
**Problem**: Colors vary between generations
**Solution**: Use fixed color palette in prompt

### Blurry Sprites
**Problem**: AI generates anti-aliased edges
**Solution**: Add "pixel perfect, no antialiasing, sharp pixels" to prompt

### Can't Connect to ComfyUI
**Problem**: Scripts can't reach localhost:8188
**Solution**: Ensure ComfyUI is running with `--listen` flag

## Model Usage Strategy

### Concept-First Workflow
1. **Generate full concept maps** using RPG Maps DoRA for inspiration
2. **Extract individual tiles** from concepts you like
3. **Generate clean tile versions** using extracted tiles as ControlNet references
4. **Create transition tiles** for seamless blending between terrain types

### Model Combinations
- **RPG Maps DoRA alone**: Full map concepts, room layouts
- **Pixel Art XL alone**: Individual sprites, characters, objects  
- **Both together** (reduced strength): Consistent style across maps and sprites
- **With ControlNet**: Enforce style matching between different generations

### Tile Edge Handling
- **Autotiling**: Use Tiled's terrain brushes with 15-47 tile sets
- **Wang Tiles**: Create specific edge combinations, let Tiled auto-connect
- **AI Transitions**: Generate specific transition tiles ("grass to stone transition, left grass, right stone")

## Next Steps

1. ✅ **Install ComfyUI** in ~/Code directory
2. ✅ **Download models** (SDXL + RPG Maps DoRA + Pixel Art XL + ControlNet)
3. **Test ComfyUI server** - Run and access web UI
4. **Generate first concept map** for overall style vision
5. **Create art directory structure** in coherence repo
6. **Set up style YAMLs** for each universe
7. **Generate first reference sprites** manually in ComfyUI
8. **Build generation scripts** for automation
9. **Extract and create individual tiles** from concepts
10. **Set up Tiled** with autotiling rules

The key is starting with concept maps for vision, then building individual assets to match that vision.