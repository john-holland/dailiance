export interface SceneNode {
    id: string;
    type: string;
    confidence: number;
    bbox: [number, number, number, number];
    metadata: {
        positivePrompt: string;
        negativePrompt: string;
        opinionPrompt?: string;
        codifiedOpinion?: CodifiedOpinion;
    };
    relations: SceneRelation[];
}

export interface SceneRelation {
    from: string;
    to: string;
    type: string;
    confidence: number;
}

export interface CodifiedOpinion {
    style: number[];
    mood: number[];
    quality: number[];
    parameters: { [key: string]: number };
}

export interface SpatialRelation {
    source: string;
    target: string;
    relation: string;
    confidence: number;
}

export class SceneGraph {
    private nodes: Map<string, SceneNode>;
    private relations: SpatialRelation[];

    constructor() {
        this.nodes = new Map();
        this.relations = [];
    }

    public addNode(node: SceneNode): void {
        this.nodes.set(node.id, node);
    }

    public addRelation(relation: SpatialRelation): void {
        this.relations.push(relation);
    }

    public getNodes(): SceneNode[] {
        return Array.from(this.nodes.values());
    }

    public getRelations(): SpatialRelation[] {
        return this.relations;
    }

    public getNodeById(id: string): SceneNode | undefined {
        return this.nodes.get(id);
    }
} 