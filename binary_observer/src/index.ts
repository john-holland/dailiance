import { BinaryObserver } from './core/BinaryObserver';
import { ThreeDVisualizer } from './visualization/ThreeDVisualizer';
import { SceneGraph } from './core/types';

// Initialize the binary observer
const observer = new BinaryObserver();

// Create a sample scene graph for testing
const sampleSceneGraph: SceneGraph = {
    actors: [
        {
            id: 'main',
            type: 'function',
            memoryRegion: {
                start: 0x1000,
                end: 0x2000
            },
            behaviors: [
                {
                    id: 'algo1',
                    type: 'loop',
                    memoryPressure: [
                        {
                            address: 0x1000,
                            size: 1024,
                            accessPattern: 'read',
                            frequency: 100,
                            timestamp: Date.now()
                        }
                    ],
                    cyclomaticComplexity: 2,
                    vectorizedPath: [1, 2, 3],
                    confidence: 0.8
                }
            ],
            metadata: {
                confidence: 0.9,
                assumptions: ['Main function entry point'],
                modelUrl: '/models/water_bottle.glb',
                textureUrls: {
                    'bottle': '/textures/water_bottle_diffuse.png',
                    'label': '/textures/water_bottle_label.png'
                }
            }
        },
        {
            id: 'helper',
            type: 'function',
            memoryRegion: {
                start: 0x2000,
                end: 0x3000
            },
            behaviors: [
                {
                    id: 'algo2',
                    type: 'branch',
                    memoryPressure: [
                        {
                            address: 0x2000,
                            size: 512,
                            accessPattern: 'write',
                            frequency: 50,
                            timestamp: Date.now()
                        }
                    ],
                    cyclomaticComplexity: 3,
                    vectorizedPath: [4, 5, 6],
                    confidence: 0.7
                }
            ],
            metadata: {
                confidence: 0.8,
                assumptions: ['Helper function'],
                modelUrl: '/models/extension_cord.glb',
                textureUrls: {
                    'cord': '/textures/extension_cord_diffuse.png',
                    'plug': '/textures/extension_cord_plug.png'
                }
            }
        }
    ],
    relations: [
        {
            from: 'main',
            to: 'helper',
            type: 'calls',
            confidence: 0.9,
            metadata: {
                frequency: 10,
                assumptions: ['Direct function call']
            }
        }
    ],
    metadata: {
        timestamp: Date.now(),
        confidence: 0.85,
        assumptions: ['Sample binary analysis']
    }
};

// Initialize the 3D visualizer
const container = document.getElementById('container');
if (container) {
    const visualizer = new ThreeDVisualizer(container);
    visualizer.visualizeSceneGraph(sampleSceneGraph);
} 