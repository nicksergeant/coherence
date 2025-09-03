#!/usr/bin/env python3
"""
Upscale and add detail to existing generated images using img2img.
"""

import json
import requests
import websocket
import uuid
import sys
import os
import shutil
from pathlib import Path
from datetime import datetime
import base64

COMFYUI_URL = "http://localhost:8188"
WS_URL = "ws://localhost:8188/ws"
COMFYUI_INPUT = Path.home() / "Code" / "ComfyUI" / "input"
COMFYUI_OUTPUT = Path.home() / "Code" / "ComfyUI" / "output"

class ImageUpscaler:
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
    
    def upload_image(self, image_path):
        """Upload image to ComfyUI and return the filename"""
        image_path = Path(image_path)
        if not image_path.exists():
            # Check if it's in ComfyUI output
            output_path = COMFYUI_OUTPUT / image_path.name
            if output_path.exists():
                image_path = output_path
            else:
                raise FileNotFoundError(f"Image not found: {image_path}")
        
        # Copy to input folder with unique name
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        input_name = f"upscale_input_{timestamp}_{image_path.name}"
        input_path = COMFYUI_INPUT / input_name
        
        shutil.copy2(image_path, input_path)
        print(f"Copied image to: {input_path}")
        
        return input_name
    
    def create_workflow(self, input_image, scale=2, denoise=0.4, prompt_addition=""):
        """Create img2img upscaling workflow"""
        
        base_prompt = "highly detailed pixel art game 3/4 perspective view, ground tiles flat from above, buildings at gentle angle showing fronts"
        
        if prompt_addition:
            full_prompt = f"{base_prompt}, {prompt_addition}"
        else:
            full_prompt = f"{base_prompt}, post-apocalyptic suburban neighborhood, broken houses with visible window frames and door details, individual roof tiles visible, cracked pavement with detailed texture, grass blades growing between cracks, abandoned cars with rust patches and broken windows, research lab facility with equipment visible through windows, dead trees with bark texture, scattered debris with recognizable items, dystopian suburban area, ultra high resolution pixel art, sharp pixel details, intricate textures on every surface"
        
        # Calculate dimensions (assuming square input for simplicity)
        output_size = 1024 * scale
        
        workflow = {
            "1": {
                "class_type": "CheckpointLoaderSimple",
                "inputs": {
                    "ckpt_name": "sd_xl_base_1.0.safetensors"
                }
            },
            "2": {
                "class_type": "LoraLoader",
                "inputs": {
                    "lora_name": "rpgMapsDora_v5.safetensors",
                    "strength_model": 0.8,
                    "strength_clip": 0.8,
                    "model": ["1", 0],
                    "clip": ["1", 1]
                }
            },
            "3": {
                "class_type": "CLIPTextEncode",
                "_meta": {
                    "title": "Positive Prompt"
                },
                "inputs": {
                    "text": full_prompt,
                    "clip": ["2", 1]
                }
            },
            "4": {
                "class_type": "CLIPTextEncode",
                "_meta": {
                    "title": "Negative Prompt"
                },
                "inputs": {
                    "text": "blurry, low detail, smooth, antialiasing, characters, people, NPCs, text, labels, UI elements",
                    "clip": ["2", 1]
                }
            },
            "5": {
                "class_type": "LoadImage",
                "inputs": {
                    "image": input_image,
                    "upload": "image"
                }
            },
            "6": {
                "class_type": "ImageScale",
                "inputs": {
                    "upscale_method": "nearest-exact",
                    "width": output_size,
                    "height": output_size,
                    "crop": "disabled",
                    "image": ["5", 0]
                }
            },
            "7": {
                "class_type": "VAEEncode",
                "inputs": {
                    "pixels": ["6", 0],
                    "vae": ["1", 2]
                }
            },
            "8": {
                "class_type": "KSampler",
                "inputs": {
                    "seed": 42,
                    "control_after_generate": "fixed",
                    "steps": 30,
                    "cfg": 6.0,
                    "sampler_name": "dpmpp_2m",
                    "scheduler": "karras",
                    "denoise": denoise,
                    "model": ["2", 0],
                    "positive": ["3", 0],
                    "negative": ["4", 0],
                    "latent_image": ["7", 0]
                }
            },
            "9": {
                "class_type": "VAEDecode",
                "inputs": {
                    "samples": ["8", 0],
                    "vae": ["1", 2]
                }
            },
            "10": {
                "class_type": "SaveImage",
                "inputs": {
                    "filename_prefix": "map_upscaled",
                    "images": ["9", 0]
                }
            }
        }
        
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
        ws.settimeout(300)  # 5 minute timeout for large images
        ws.connect(f"{WS_URL}?clientId={client_id}")
        
        print("Processing", end="", flush=True)
        try:
            while True:
                try:
                    out = ws.recv()
                    if isinstance(out, str):
                        message = json.loads(out)
                        if message['type'] == 'executing':
                            data = message['data']
                            if data['node'] is None and data['prompt_id'] == prompt_id:
                                break
                            else:
                                print(".", end="", flush=True)
                except websocket.WebSocketTimeoutException:
                    print(".", end="", flush=True)
                    continue
        except Exception as e:
            print(f"\nError: {e}")
        finally:
            ws.close()
        
        print(" Done!")
    
    def upscale(self, image_path, scale=2, denoise=0.4, prompt_addition="", seed=42):
        """Main upscaling function"""
        print(f"\n=== Upscaling Image ===")
        print(f"Source: {image_path}")
        print(f"Scale: {scale}x")
        print(f"Denoise: {denoise}")
        print(f"Seed: {seed}")
        
        # Upload image
        input_name = self.upload_image(image_path)
        
        # Create and queue workflow
        workflow = self.create_workflow(input_name, scale, denoise, prompt_addition)
        
        # Set seed
        workflow["8"]["inputs"]["seed"] = seed
        
        result, client_id = self.queue_prompt(workflow)
        prompt_id = result.get('prompt_id')
        
        if prompt_id:
            self.wait_for_completion(prompt_id, client_id)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"map_upscaled_{scale}x_{timestamp}.png"
            print(f"Saved as: {filename}")
            return filename
        else:
            print(f"Error: {result}")
            return None

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Upscale and add detail to generated images')
    parser.add_argument('image', help='Path to image file or filename in ComfyUI output')
    parser.add_argument('-s', '--scale', type=int, default=2, choices=[2, 3, 4],
                       help='Scale factor (default: 2)')
    parser.add_argument('-d', '--denoise', type=float, default=0.4,
                       help='Denoise strength 0.0-1.0 (default: 0.4)')
    parser.add_argument('--seed', type=int, default=42,
                       help='Random seed (default: 42)')
    parser.add_argument('-p', '--prompt', type=str,
                       help='Additional prompt details to add')
    
    args = parser.parse_args()
    
    upscaler = ImageUpscaler()
    upscaler.upscale(args.image, args.scale, args.denoise, args.prompt, args.seed)

if __name__ == "__main__":
    main()