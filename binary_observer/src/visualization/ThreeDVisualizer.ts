import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import { SceneGraph, SystemMetaphor } from '../core/types';
import { MetaphorVisualizer } from './MetaphorVisualizer';
import { ModelLoader } from './ModelLoader';

export class ThreeDVisualizer {
    private scene: THREE.Scene;
    private camera: THREE.PerspectiveCamera;
    private renderer: THREE.WebGLRenderer;
    private metaphorVisualizer: MetaphorVisualizer;
    private modelLoader: ModelLoader;
    private billboards: Map<string, THREE.Sprite> = new Map();
    private buildingElements: Map<string, THREE.Object3D> = new Map();

    constructor(container: HTMLElement) {
        this.scene = new THREE.Scene();
        this.camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        this.renderer = new THREE.WebGLRenderer({ antialias: true });
        this.metaphorVisualizer = new MetaphorVisualizer();
        this.modelLoader = new ModelLoader();
        
        this.initializeScene(container);
        this.setupLights();
    }

    private initializeScene(container: HTMLElement) {
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        container.appendChild(this.renderer.domElement);
        
        this.camera.position.set(5, 5, 5);
        this.camera.lookAt(0, 0, 0);
        
        // Add orbit controls
        const controls = new OrbitControls(this.camera, this.renderer.domElement);
        controls.enableDamping = true;
        controls.dampingFactor = 0.05;
        
        // Handle window resize
        window.addEventListener('resize', () => {
            this.camera.aspect = window.innerWidth / window.innerHeight;
            this.camera.updateProjectionMatrix();
            this.renderer.setSize(window.innerWidth, window.innerHeight);
        });
    }

    private setupLights() {
        const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
        this.scene.add(ambientLight);
        
        const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
        directionalLight.position.set(5, 5, 5);
        this.scene.add(directionalLight);
    }

    public async visualizeSceneGraph(sceneGraph: SceneGraph) {
        // Clear existing elements
        this.clearScene();
        
        // Create building elements for each actor
        for (const actor of sceneGraph.actors) {
            const buildingElement = await this.createBuildingElement(actor);
            this.buildingElements.set(actor.id, buildingElement);
            this.scene.add(buildingElement);
            
            // Add billboard with deobfuscated code
            this.addCodeBillboard(actor, buildingElement);
        }
        
        // Create connections between elements
        sceneGraph.relations.forEach(relation => {
            this.createConnection(relation);
        });
        
        // Start animation loop
        this.animate();
    }

    private async createBuildingElement(actor: SceneGraph['actors'][0]): Promise<THREE.Object3D> {
        const metaphor = this.metaphorVisualizer.getAllMetaphors()[0]; // Using first metaphor for now
        
        // Try to load custom model if specified in metadata
        if (actor.metadata.modelUrl) {
            try {
                const model = await this.modelLoader.loadModelWithTextures(
                    actor.metadata.modelUrl,
                    actor.metadata.textureUrls || {}
                );
                model.userData = { actor, metaphor };
                return model;
            } catch (error) {
                console.warn(`Failed to load custom model for ${actor.id}, falling back to default:`, error);
            }
        }
        
        // Fallback to default geometry
        let geometry: THREE.BufferGeometry;
        let material: THREE.MeshPhongMaterial;
        
        switch (metaphor.type) {
            case 'plumbing':
                geometry = new THREE.CylinderGeometry(0.2, 0.2, 2, 8);
                material = new THREE.MeshPhongMaterial({ color: 0x8888ff });
                break;
            case 'electrical':
                geometry = new THREE.BoxGeometry(1, 1, 1);
                material = new THREE.MeshPhongMaterial({ color: 0xffcc00 });
                break;
            case 'structural':
            default:
                geometry = new THREE.BoxGeometry(2, 2, 2);
                material = new THREE.MeshPhongMaterial({ color: 0xcccccc });
                break;
        }
        
        const mesh = new THREE.Mesh(geometry, material);
        mesh.userData = { actor, metaphor };
        return mesh;
    }

    private addCodeBillboard(actor: SceneGraph['actors'][0], element: THREE.Object3D) {
        // Create canvas for text
        const canvas = document.createElement('canvas');
        const context = canvas.getContext('2d');
        if (!context) return;
        
        canvas.width = 512;
        canvas.height = 256;
        
        // Draw deobfuscated code
        context.fillStyle = '#ffffff';
        context.fillRect(0, 0, canvas.width, canvas.height);
        context.fillStyle = '#000000';
        context.font = '16px monospace';
        
        // Add code snippets from behaviors
        let y = 20;
        actor.behaviors.forEach(behavior => {
            const code = this.deobfuscateCode(behavior);
            context.fillText(code, 10, y);
            y += 20;
        });
        
        // Create texture and sprite
        const texture = new THREE.CanvasTexture(canvas);
        const material = new THREE.SpriteMaterial({ map: texture });
        const sprite = new THREE.Sprite(material);
        
        // Position sprite relative to building element
        sprite.position.set(0, 1.5, 0);
        sprite.scale.set(2, 1, 1);
        
        element.add(sprite);
        this.billboards.set(actor.id, sprite);
    }

    private deobfuscateCode(behavior: any): string {
        // TODO: Implement actual deobfuscation logic
        return `// ${behavior.type} at ${behavior.memoryPressure[0].address.toString(16)}`;
    }

    private createConnection(relation: SceneGraph['relations'][0]) {
        const from = this.buildingElements.get(relation.from);
        const to = this.buildingElements.get(relation.to);
        if (!from || !to) return;
        
        const points = [
            from.position,
            to.position
        ];
        
        const geometry = new THREE.BufferGeometry().setFromPoints(points);
        const material = new THREE.LineBasicMaterial({ color: 0x00ff00 });
        const line = new THREE.Line(geometry, material);
        
        this.scene.add(line);
    }

    private clearScene() {
        this.buildingElements.forEach(element => {
            this.scene.remove(element);
        });
        this.buildingElements.clear();
        this.billboards.clear();
    }

    private animate() {
        requestAnimationFrame(() => this.animate());
        this.renderer.render(this.scene, this.camera);
    }

    public async loadCustomModel(url: string, textureUrls?: Record<string, string>): Promise<THREE.Object3D> {
        return this.modelLoader.loadModelWithTextures(url, textureUrls || {});
    }

    public async loadCustomTexture(url: string): Promise<THREE.Texture> {
        return this.modelLoader.loadTexture(url);
    }
} 