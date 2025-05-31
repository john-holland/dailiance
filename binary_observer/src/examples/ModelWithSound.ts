import * as THREE from 'three';
import { ModelComponent } from '../components/ModelComponent';
import { ProximitySoundComponent } from '../components/ProximitySoundComponent';

export class ModelWithSound {
    private entity: THREE.Object3D;
    private modelComponent: ModelComponent;
    private soundComponent: ProximitySoundComponent;

    constructor() {
        // Create the entity
        this.entity = new THREE.Object3D();

        // Create and configure the model component
        this.modelComponent = new ModelComponent({
            modelUrl: '/models/water_bottle.glb',
            textureUrls: {
                bottle: '/textures/water_bottle_diffuse.png',
                label: '/textures/water_bottle_label.png'
            },
            scale: 1.0,
            position: new THREE.Vector3(0, 0, 0),
            rotation: new THREE.Euler(0, 0, 0),
            castShadow: true,
            receiveShadow: true
        });

        // Create and configure the sound component
        this.soundComponent = new ProximitySoundComponent({
            soundUrl: '/sounds/water_flow.mp3',
            minDistance: 1,
            maxDistance: 100,
            volume: 0.5,
            loop: true,
            rolloffFactor: 1,
            refDistance: 1
        });

        // Set the entity for both components
        this.modelComponent.setEntity(this.entity);
        this.soundComponent.setEntity(this.entity);
    }

    public async initialize(): Promise<void> {
        // Initialize both components
        await this.modelComponent.initialize();
        await this.soundComponent.initialize();
    }

    public update(deltaTime: number): void {
        // Update both components
        this.modelComponent.update(deltaTime);
        this.soundComponent.update(deltaTime);
    }

    public getEntity(): THREE.Object3D {
        return this.entity;
    }

    public playSound(): void {
        this.soundComponent.play();
    }

    public stopSound(): void {
        this.soundComponent.stop();
    }

    public dispose(): void {
        this.modelComponent.dispose();
        this.soundComponent.dispose();
    }
} 