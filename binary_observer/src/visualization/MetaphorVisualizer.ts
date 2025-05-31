import { SceneGraph, SystemMetaphor } from '../core/types';

export class MetaphorVisualizer {
    private metaphors: Map<string, SystemMetaphor> = new Map();

    constructor() {
        this.initializeMetaphors();
    }

    private initializeMetaphors() {
        // Initialize common metaphors for binary components
        this.metaphors.set('memory_allocation', {
            id: 'memory_allocation',
            type: 'plumbing',
            original: {
                component: 'Memory Allocation',
                purpose: 'Dynamic memory management'
            },
            metaphor: {
                component: 'Water Bottle System',
                description: 'A network of water bottles connected by tubes, where each bottle represents a memory block and the tubes represent pointers'
            },
            confidence: 0.8,
            assumptions: [
                'Memory is allocated in discrete blocks',
                'Pointers connect memory blocks',
                'Memory pressure affects allocation patterns'
            ]
        });

        this.metaphors.set('function_call', {
            id: 'function_call',
            type: 'electrical',
            original: {
                component: 'Function Call',
                purpose: 'Control flow between functions'
            },
            metaphor: {
                component: 'Extension Cord',
                description: 'An extension cord that can be plugged into different outlets, where each outlet represents a function entry point'
            },
            confidence: 0.7,
            assumptions: [
                'Functions have clear entry points',
                'Control flow follows a path',
                'Functions can be called from multiple places'
            ]
        });

        this.metaphors.set('data_structure', {
            id: 'data_structure',
            type: 'structural',
            original: {
                component: 'Data Structure',
                purpose: 'Organization of data in memory'
            },
            metaphor: {
                component: 'Building Framework',
                description: 'A building\'s framework that supports different types of rooms and hallways, where each room represents a data element'
            },
            confidence: 0.75,
            assumptions: [
                'Data structures have a defined layout',
                'Elements are connected in specific ways',
                'Access patterns follow the structure'
            ]
        });
    }

    public visualizeSceneGraph(sceneGraph: SceneGraph): string {
        const visualization: string[] = [];
        
        // Add building description
        visualization.push('Building Analysis:');
        visualization.push('----------------');

        // Visualize actors as rooms
        sceneGraph.actors.forEach(actor => {
            const metaphor = this.findBestMetaphor(actor);
            visualization.push(`\nRoom: ${actor.id}`);
            visualization.push(`Type: ${metaphor.metaphor.component}`);
            visualization.push(`Description: ${metaphor.metaphor.description}`);
            visualization.push(`Confidence: ${(metaphor.confidence * 100).toFixed(1)}%`);
            
            // Add behaviors as room features
            if (actor.behaviors.length > 0) {
                visualization.push('\nRoom Features:');
                actor.behaviors.forEach(behavior => {
                    const behaviorMetaphor = this.findBestMetaphor(behavior);
                    visualization.push(`- ${behaviorMetaphor.metaphor.component}: ${behaviorMetaphor.metaphor.description}`);
                });
            }
        });

        // Visualize relations as connections
        if (sceneGraph.relations.length > 0) {
            visualization.push('\nConnections:');
            sceneGraph.relations.forEach(relation => {
                const relationMetaphor = this.findBestMetaphor(relation);
                visualization.push(`\n${relation.from} <--[${relationMetaphor.metaphor.component}]--> ${relation.to}`);
                visualization.push(`Type: ${relationMetaphor.metaphor.description}`);
                visualization.push(`Confidence: ${(relation.confidence * 100).toFixed(1)}%`);
            });
        }

        // Add assumptions
        if (sceneGraph.metadata.assumptions.length > 0) {
            visualization.push('\nAssumptions:');
            sceneGraph.metadata.assumptions.forEach(assumption => {
                visualization.push(`- ${assumption}`);
            });
        }

        return visualization.join('\n');
    }

    private findBestMetaphor(component: any): SystemMetaphor {
        // Find the most appropriate metaphor for a component
        // This is a simplified version - would need more sophisticated matching
        return this.metaphors.get('memory_allocation')!;
    }

    public addMetaphor(metaphor: SystemMetaphor) {
        this.metaphors.set(metaphor.id, metaphor);
    }

    public getMetaphor(id: string): SystemMetaphor | undefined {
        return this.metaphors.get(id);
    }

    public getAllMetaphors(): SystemMetaphor[] {
        return Array.from(this.metaphors.values());
    }
} 