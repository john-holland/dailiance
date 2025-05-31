import * as THREE from 'three';
import { ModelLoader } from '../visualization/ModelLoader';
import { Component } from './Component';

export interface ModelComponentConfig {
    modelUrl: string;
    textureUrls?: Record<string, string>;
    scale?: number;
    position?: THREE.Vector3;
    rotation?: THREE.Euler;
    castShadow?: boolean;
    receiveShadow?: boolean;
}

export class ModelComponent extends Component {
    private modelLoader: ModelLoader;
    private model: THREE.Object3D | null = null;
    private config: ModelComponentConfig;

    constructor(config: ModelComponentConfig) {
        super();
        this.modelLoader = new ModelLoader();
        this.config = {
            scale: 1,
            position: new THREE.Vector3(),
            rotation: new THREE.Euler(),
            castShadow: true,
            receiveShadow: true,
            ...config
        };
    }

    public async initialize(): Promise<void> {
        try {
            this.model = await this.modelLoader.loadModelWithTextures(
                this.config.modelUrl,
                this.config.textureUrls || {}
            );

            // Apply transformations
            this.model.scale.setScalar(this.config.scale!);
            this.model.position.copy(this.config.position!);
            this.model.rotation.copy(this.config.rotation!);

            // Setup shadows
            this.model.traverse((child) => {
                if (child instanceof THREE.Mesh) {
                    child.castShadow = this.config.castShadow!;
                    child.receiveShadow = this.config.receiveShadow!;
                }
            });

            // Add to parent entity
            if (this.entity) {
                this.entity.add(this.model);
            }
        } catch (error) {
            console.error('Failed to initialize model:', error);
            throw error;
        }
    }

    public update(deltaTime: number): void {
        // Add any animation or update logic here
    }

    public getModel(): THREE.Object3D | null {
        return this.model;
    }

    public setPosition(position: THREE.Vector3): void {
        if (this.model) {
            this.model.position.copy(position);
        }
    }

    public setRotation(rotation: THREE.Euler): void {
        if (this.model) {
            this.model.rotation.copy(rotation);
        }
    }

    public setScale(scale: number): void {
        if (this.model) {
            this.model.scale.setScalar(scale);
        }
    }

    public dispose(): void {
        if (this.model) {
            this.model.traverse((child) => {
                if (child instanceof THREE.Mesh) {
                    child.geometry.dispose();
                    if (Array.isArray(child.material)) {
                        child.material.forEach(material => material.dispose());
                    } else {
                        child.material.dispose();
                    }
                }
            });
            this.model = null;
        }
    }
} 