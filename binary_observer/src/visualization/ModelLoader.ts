import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader';
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader';

export class ModelLoader {
    private gltfLoader: GLTFLoader;
    private textureLoader: THREE.TextureLoader;
    private dracoLoader: DRACOLoader;
    private cache: Map<string, THREE.Object3D | THREE.Texture> = new Map();

    constructor() {
        this.gltfLoader = new GLTFLoader();
        this.textureLoader = new THREE.TextureLoader();
        this.dracoLoader = new DRACOLoader();
        this.dracoLoader.setDecoderPath('/draco/');
        this.gltfLoader.setDRACOLoader(this.dracoLoader);
    }

    public async loadModel(url: string): Promise<THREE.Object3D> {
        if (this.cache.has(url)) {
            return this.cache.get(url) as THREE.Object3D;
        }

        try {
            const gltf = await this.gltfLoader.loadAsync(url);
            const model = gltf.scene;
            this.cache.set(url, model);
            return model;
        } catch (error) {
            console.error(`Error loading model ${url}:`, error);
            throw error;
        }
    }

    public async loadTexture(url: string): Promise<THREE.Texture> {
        if (this.cache.has(url)) {
            return this.cache.get(url) as THREE.Texture;
        }

        try {
            const texture = await this.textureLoader.loadAsync(url);
            this.cache.set(url, texture);
            return texture;
        } catch (error) {
            console.error(`Error loading texture ${url}:`, error);
            throw error;
        }
    }

    public async loadModelWithTextures(modelUrl: string, textureUrls: Record<string, string>): Promise<THREE.Object3D> {
        const model = await this.loadModel(modelUrl);
        
        // Load and apply textures
        for (const [materialName, textureUrl] of Object.entries(textureUrls)) {
            const texture = await this.loadTexture(textureUrl);
            const material = (model.getObjectByName(materialName) as THREE.Mesh)?.material as THREE.MeshStandardMaterial;
            if (material) {
                material.map = texture;
                material.needsUpdate = true;
            }
        }

        return model;
    }

    public clearCache() {
        this.cache.clear();
    }

    public getCachedModel(url: string): THREE.Object3D | undefined {
        return this.cache.get(url) as THREE.Object3D;
    }

    public getCachedTexture(url: string): THREE.Texture | undefined {
        return this.cache.get(url) as THREE.Texture;
    }
} 