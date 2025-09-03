#!/usr/bin/env python3
"""
Unified generation script for all Coherence art assets.
Handles maps, tiles, characters, and other sprites.
"""

import json
import requests
import websocket
import uuid
import sys
from pathlib import Path
from datetime import datetime

COMFYUI_URL = "http://localhost:8188"
WS_URL = "ws://localhost:8188/ws"

# Generation presets for different asset types
PRESETS = {
    "map": {
        "workflow": "outdoor_map_api.json",
        "lora": "rpgMapsDora_v5.safetensors",
        "lora_strength": 0.8,
        "size": (1024, 1024),
        "prefix": "map"
    },
    "character": {
        "workflow": "character_api.json",
        "lora": "pixel-art-xl-v1.1.safetensors",
        "lora_strength": 0.9,
        "size": (512, 512),
        "prefix": "character"
    },
    "tile": {
        "workflow": "tile_api.json",
        "lora": "pixel-art-xl-v1.1.safetensors",  # Changed to Pixel Art for individual tiles
        "lora_strength": 0.8,
        "size": (256, 256),  # Will crop to 32x32 tiles
        "prefix": "tile"
    },
    "sprite": {
        "workflow": "sprite_api.json",
        "lora": "pixel-art-xl-v1.1.safetensors",
        "lora_strength": 0.9,
        "size": (256, 256),
        "prefix": "sprite"
    }
}

# Universe styles that can be applied to any asset type
UNIVERSES = {
    "neutral": {
        "map": "pixel art rpg overworld map top-down view, modern suburban neighborhood, research facility complex, paved roads, street lights, normal everyday earth location, mowed grass, concrete sidewalks, 32x32 tile grid",
        "character": "pixel art character sprite, modern day scientist, lab coat, jeans, normal human, front-facing sprite sheet",
        "description": "Present-day Earth - Normal modern setting"
    },
    "dystopian": {
        "map": "RPGmap, top-down perspective, battle map of abandoned suburban research district after societal collapse, cracked asphalt roads forming a grid pattern with grass and weeds breaking through, abandoned parking lots with rusted vehicles, collapsed research facility complex in the center with one intact laboratory building, residential areas with damaged houses and overgrown yards, dried fountain plaza, makeshift survivor camps with tarps and barricades, fallen power lines across streets, patches of dead trees and burnt vegetation, debris fields and rubble piles, stagnant water pooling in craters, weathered concrete and rusted metal textures throughout the scene, muted browns and grays with sickly yellows",
        "character": "pixel art character sprite, post-apocalyptic survivor scientist, torn lab coat, makeshift armor, weathered appearance, front-facing sprite sheet",  
        "description": "Collapsed society - Abandoned and decaying"
    },
    "utopian": {
        "map": "pixel art rpg overworld map top-down view, pristine futuristic suburban paradise, gleaming research campus, clean streets with bike lanes, solar panels, beautiful parks with fountains, perfect manicured lawns, bright optimistic colors, 32x32 tile grid",
        "character": "pixel art character sprite, futuristic scientist, sleek white uniform, high-tech visor, clean appearance, front-facing sprite sheet",
        "description": "Perfect society - Clean and advanced"
    }
}

NEGATIVE_PROMPTS = {
    "map": "blurry, realistic, 3d render, photograph, characters, people, NPCs, animals, isometric, angled perspective, first person, close-up, text, labels, UI elements, fantasy elements, medieval castles, dragons, magic, bright cheerful colors, farm, rural, countryside, antialiasing",
    "character": "blurry, realistic, 3d render, photograph, background, environment, multiple characters, text, UI elements",
    "default": "blurry, realistic, 3d render, photograph, text, labels, UI elements, antialiasing, smooth gradients"
}

class ComfyUIGenerator:
    def __init__(self):
        self.check_server()
    
    def check_server(self):
        """Verify ComfyUI is running"""
        try:
            response = requests.get(COMFYUI_URL)
            if response.status_code != 200:
                raise ConnectionError("ComfyUI server not responding")
        except requests.exceptions.ConnectionError:
            print("Error: Cannot connect to ComfyUI at http://localhost:8188")
            print("Start it with: cd ~/Code/ComfyUI && python main.py --listen")
            sys.exit(1)
    
    def load_workflow(self, workflow_name):
        """Load workflow JSON from file"""
        workflow_path = Path(__file__).parent.parent / "workflows" / workflow_name
        
        # Fallback to base workflow if specific one doesn't exist
        if not workflow_path.exists():
            workflow_path = Path(__file__).parent.parent / "workflows" / "outdoor_map_api.json"
            if not workflow_path.exists():
                raise FileNotFoundError(f"No workflow found: {workflow_name}")
        
        with open(workflow_path, 'r') as f:
            return json.load(f)
    
    def update_workflow(self, workflow, preset, universe, custom_prompt=None):
        """Update workflow with appropriate settings"""
        positive_prompt = custom_prompt if custom_prompt else UNIVERSES[universe].get(preset["prefix"].rstrip('s'), "")
        negative_prompt = NEGATIVE_PROMPTS.get(preset["prefix"].rstrip('s'), NEGATIVE_PROMPTS["default"])
        
        for node_id, node in workflow.items():
            # Update LoRA
            if node.get("class_type") == "LoraLoader":
                node["inputs"]["lora_name"] = preset["lora"]
                node["inputs"]["strength_model"] = preset["lora_strength"]
                node["inputs"]["strength_clip"] = preset["lora_strength"]
            
            # Update prompts
            if node.get("class_type") == "CLIPTextEncode":
                if "Positive" in node.get("_meta", {}).get("title", ""):
                    node["inputs"]["text"] = positive_prompt
                elif "Negative" in node.get("_meta", {}).get("title", ""):
                    node["inputs"]["text"] = negative_prompt
            
            # Update image size
            if node.get("class_type") == "EmptyLatentImage":
                node["inputs"]["width"] = preset["size"][0]
                node["inputs"]["height"] = preset["size"][1]
        
        return workflow
    
    def queue_prompt(self, workflow):
        """Send workflow to ComfyUI"""
        client_id = str(uuid.uuid4())
        p = {"prompt": workflow, "client_id": client_id}
        data = json.dumps(p).encode('utf-8')
        req = requests.post(f"{COMFYUI_URL}/prompt", data=data)
        return json.loads(req.text), client_id
    
    def wait_for_completion(self, prompt_id, client_id):
        """Wait for generation to complete"""
        ws = websocket.WebSocket()
        ws.connect(f"{WS_URL}?clientId={client_id}")
        
        print("Generating", end="", flush=True)
        try:
            while True:
                out = ws.recv()
                if isinstance(out, str):
                    message = json.loads(out)
                    if message['type'] == 'executing':
                        data = message['data']
                        # When node is None, execution is complete
                        if data['node'] is None and data['prompt_id'] == prompt_id:
                            break
                        else:
                            print(".", end="", flush=True)
        except Exception as e:
            print(f"\nError waiting for completion: {e}")
        finally:
            ws.close()
        
        print(" Done!")
    
    def generate(self, asset_type, universe="dystopian", seed=42, custom_prompt=None):
        """Main generation function"""
        if asset_type not in PRESETS:
            print(f"Unknown asset type: {asset_type}")
            print(f"Available types: {', '.join(PRESETS.keys())}")
            return
        
        if universe not in UNIVERSES:
            print(f"Unknown universe: {universe}")
            print(f"Available universes: {', '.join(UNIVERSES.keys())}")
            return
        
        preset = PRESETS[asset_type]
        
        print(f"\n=== Generating {universe.upper()} {asset_type.upper()} ===")
        if custom_prompt:
            print(f"Custom prompt: {custom_prompt[:100]}...")
        else:
            print(f"Description: {UNIVERSES[universe]['description']}")
        
        # Load and configure workflow
        workflow = self.load_workflow(preset["workflow"])
        workflow = self.update_workflow(workflow, preset, universe, custom_prompt)
        
        # Set seed
        for node_id, node in workflow.items():
            if node.get("class_type") == "KSampler":
                node["inputs"]["seed"] = seed
        
        # Queue and wait
        result, client_id = self.queue_prompt(workflow)
        prompt_id = result.get('prompt_id')
        
        if prompt_id:
            self.wait_for_completion(prompt_id, client_id)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"{preset['prefix']}_{universe}_{timestamp}_seed{seed}.png"
            print(f"Saved as: {filename}")
            print(f"Seed: {seed}")
            return filename
        else:
            print(f"Error: {result}")
            return None

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Generate art assets for Coherence')
    parser.add_argument('type', choices=['map', 'character', 'tile', 'sprite'],
                       help='Type of asset to generate')
    parser.add_argument('universe', nargs='?', default='dystopian',
                       choices=['neutral', 'dystopian', 'utopian'],
                       help='Universe style (default: dystopian)')
    parser.add_argument('-s', '--seed', type=int, default=42,
                       help='Random seed for generation')
    parser.add_argument('-p', '--prompt', type=str,
                       help='Custom prompt (overrides universe preset)')
    
    args = parser.parse_args()
    
    generator = ComfyUIGenerator()
    generator.generate(args.type, args.universe, args.seed, args.prompt)

if __name__ == "__main__":
    main()