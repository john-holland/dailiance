import * as tf from '@tensorflow/tfjs';
import * as cocoSsd from '@tensorflow-models/coco-ssd';
import { SceneNode, SceneRelation, CodifiedOpinion } from '../types/SceneGraph';

export class SceneDescriptionService {
    private model: cocoSsd.ObjectDetection | null = null;
    private isModelLoaded: boolean = false;

    constructor() {
        this.initializeModel();
    }

    private async initializeModel() {
        try {
            this.model = await cocoSsd.load();
            this.isModelLoaded = true;
            console.log('COCO-SSD model loaded successfully');
        } catch (error) {
            console.error('Failed to load COCO-SSD model:', error);
        }
    }

    public async describeScene(imageElement: HTMLImageElement): Promise<SceneNode[]> {
        if (!this.isModelLoaded || !this.model) {
            throw new Error('Model not loaded');
        }

        const predictions = await this.model.detect(imageElement);
        return predictions.map(pred => this.createSceneNode(pred));
    }

    private createSceneNode(prediction: cocoSsd.DetectedObject): SceneNode {
        return {
            id: `node_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            type: prediction.class,
            confidence: prediction.score,
            bbox: [
                prediction.bbox[0],
                prediction.bbox[1],
                prediction.bbox[2],
                prediction.bbox[3]
            ],
            metadata: {
                positivePrompt: `A ${prediction.class} in the scene`,
                negativePrompt: `No ${prediction.class} in the scene`
            },
            relations: []
        };
    }

    public async analyzeSpatialRelations(nodes: SceneNode[]): Promise<SceneNode[]> {
        for (let i = 0; i < nodes.length; i++) {
            for (let j = i + 1; j < nodes.length; j++) {
                const relation = this.calculateSpatialRelation(nodes[i], nodes[j]);
                if (relation) {
                    nodes[i].relations.push(relation);
                    nodes[j].relations.push({
                        from: relation.to,
                        to: relation.from,
                        type: this.invertRelationType(relation.type),
                        confidence: relation.confidence
                    });
                }
            }
        }
        return nodes;
    }

    private calculateSpatialRelation(node1: SceneNode, node2: SceneNode): SceneRelation | null {
        const [x1, y1, w1, h1] = node1.bbox;
        const [x2, y2, w2, h2] = node2.bbox;

        const center1 = { x: x1 + w1/2, y: y1 + h1/2 };
        const center2 = { x: x2 + w2/2, y: y2 + h2/2 };

        // Calculate relative positions
        const dx = center2.x - center1.x;
        const dy = center2.y - center1.y;

        // Determine relation type based on relative positions
        let relationType = '';
        let confidence = 0.8; // Base confidence

        if (Math.abs(dx) > Math.abs(dy)) {
            relationType = dx > 0 ? 'to_the_right_of' : 'to_the_left_of';
        } else {
            relationType = dy > 0 ? 'below' : 'above';
        }

        return {
            from: node1.id,
            to: node2.id,
            type: relationType,
            confidence
        };
    }

    private invertRelationType(type: string): string {
        const inversions: { [key: string]: string } = {
            'to_the_right_of': 'to_the_left_of',
            'to_the_left_of': 'to_the_right_of',
            'above': 'below',
            'below': 'above'
        };
        return inversions[type] || type;
    }

    public async reinterpretPrompts(
        positivePrompt: string,
        negativePrompt: string,
        opinionPrompt: string
    ): Promise<CodifiedOpinion> {
        // Here we would typically call an AI service to reinterpret the prompts
        // For now, we'll return a mock implementation
        return {
            style: [0.5, 0.3, 0.2],
            mood: [0.4, 0.6, 0.0],
            quality: [0.8, 0.1, 0.1],
            parameters: {
                saturation: 0.7,
                contrast: 0.6,
                brightness: 0.5
            }
        };
    }
} 