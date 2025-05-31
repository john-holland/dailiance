export interface MemoryPressure {
    address: number;
    size: number;
    accessPattern: 'read' | 'write' | 'execute';
    frequency: number;
    timestamp: number;
}

export interface AlgorithmSignature {
    id: string;
    type: 'assignment' | 'loop' | 'branch' | 'function_call';
    memoryPressure: MemoryPressure[];
    cyclomaticComplexity: number;
    vectorizedPath: number[];
    confidence: number;
}

export interface ActorPosition {
    id: string;
    type: string;
    memoryRegion: {
        start: number;
        end: number;
    };
    behaviors: AlgorithmSignature[];
    metadata: {
        confidence: number;
        assumptions: string[];
        modelUrl?: string;
        textureUrls?: Record<string, string>;
    };
}

export interface SceneGraph {
    actors: ActorPosition[];
    relations: SceneRelation[];
    metadata: {
        timestamp: number;
        confidence: number;
        assumptions: string[];
    };
}

export interface SceneRelation {
    from: string;
    to: string;
    type: 'calls' | 'depends_on' | 'shares_memory' | 'communicates';
    confidence: number;
    metadata: {
        frequency: number;
        assumptions: string[];
    };
}

export interface LanguageModelPrediction {
    language: string;
    confidence: number;
    features: {
        memoryPatterns: string[];
        controlFlow: string[];
        dataStructures: string[];
    };
}

// Metaphor representation for the plumbing/waterbottles concept
export interface SystemMetaphor {
    id: string;
    type: 'plumbing' | 'electrical' | 'structural';
    original: {
        component: string;
        purpose: string;
    };
    metaphor: {
        component: string;
        description: string;
    };
    confidence: number;
    assumptions: string[];
} 