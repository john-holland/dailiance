import * as THREE from 'three';
import { Component } from './Component';

export interface ProximitySoundConfig {
    soundUrl: string;
    minDistance?: number;
    maxDistance?: number;
    volume?: number;
    loop?: boolean;
    rolloffFactor?: number;
    refDistance?: number;
}

export class ProximitySoundComponent extends Component {
    private listener: THREE.AudioListener;
    private sound: THREE.PositionalAudio;
    private config: ProximitySoundConfig;

    constructor(config: ProximitySoundConfig) {
        super();
        this.listener = new THREE.AudioListener();
        this.sound = new THREE.PositionalAudio(this.listener);
        this.config = {
            minDistance: 1,
            maxDistance: 100,
            volume: 1,
            loop: false,
            rolloffFactor: 1,
            refDistance: 1,
            ...config
        };
    }

    public async initialize(): Promise<void> {
        try {
            const audioLoader = new THREE.AudioLoader();
            const buffer = await new Promise<AudioBuffer>((resolve, reject) => {
                audioLoader.load(
                    this.config.soundUrl,
                    (buffer) => resolve(buffer),
                    undefined,
                    (error) => reject(error)
                );
            });

            this.sound.setBuffer(buffer);
            this.sound.setRefDistance(this.config.refDistance!);
            this.sound.setRolloffFactor(this.config.rolloffFactor!);
            this.sound.setLoop(this.config.loop!);
            this.sound.setVolume(this.config.volume!);

            if (this.entity) {
                this.entity.add(this.sound);
            }
        } catch (error) {
            console.error('Failed to initialize sound:', error);
            throw error;
        }
    }

    public update(deltaTime: number): void {
        // Update sound properties based on listener position
        if (this.entity && this.listener) {
            const distance = this.entity.position.distanceTo(this.listener.position);
            const volume = Math.max(0, Math.min(1, 1 - (distance - this.config.minDistance!) / (this.config.maxDistance! - this.config.minDistance!)));
            this.sound.setVolume(volume * this.config.volume!);
        }
    }

    public play(): void {
        if (!this.sound.isPlaying) {
            this.sound.play();
        }
    }

    public pause(): void {
        if (this.sound.isPlaying) {
            this.sound.pause();
        }
    }

    public stop(): void {
        if (this.sound.isPlaying) {
            this.sound.stop();
        }
    }

    public setVolume(volume: number): void {
        this.config.volume = Math.max(0, Math.min(1, volume));
        this.sound.setVolume(this.config.volume);
    }

    public setLoop(loop: boolean): void {
        this.config.loop = loop;
        this.sound.setLoop(loop);
    }

    public dispose(): void {
        this.stop();
        this.sound.disconnect();
        if (this.entity) {
            this.entity.remove(this.sound);
        }
    }
} 