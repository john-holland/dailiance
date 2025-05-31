import * as THREE from 'three';

export abstract class Component {
    protected entity: THREE.Object3D | null = null;

    public setEntity(entity: THREE.Object3D): void {
        this.entity = entity;
    }

    public abstract initialize(): Promise<void>;
    public abstract update(deltaTime: number): void;
    public abstract dispose(): void;
} 