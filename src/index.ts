import { SceneDescriptionService } from './services/SceneDescriptionService';
import { SceneNode } from './types/SceneGraph';

async function main() {
    const service = new SceneDescriptionService();
    const imageElement = document.getElementById('sceneImage') as HTMLImageElement;
    const resultsElement = document.getElementById('results') as HTMLPreElement;

    // Wait for the image to load
    await new Promise((resolve) => {
        imageElement.onload = resolve;
    });

    try {
        // Analyze the scene
        const nodes = await service.describeScene(imageElement);
        
        // Analyze spatial relations
        const nodesWithRelations = await service.analyzeSpatialRelations(nodes);

        // Draw detection boxes
        const imageContainer = document.querySelector('.image-container') as HTMLElement;
        nodesWithRelations.forEach(node => {
            const [x, y, width, height] = node.bbox;
            
            // Create detection box
            const box = document.createElement('div');
            box.className = 'detection-box';
            box.style.left = `${x}px`;
            box.style.top = `${y}px`;
            box.style.width = `${width}px`;
            box.style.height = `${height}px`;
            imageContainer.appendChild(box);

            // Create label
            const label = document.createElement('div');
            label.className = 'detection-label';
            label.textContent = `${node.type} (${Math.round(node.confidence * 100)}%)`;
            label.style.left = `${x}px`;
            label.style.top = `${y - 20}px`;
            imageContainer.appendChild(label);
        });

        // Display results
        resultsElement.textContent = JSON.stringify(nodesWithRelations, null, 2);
    } catch (error) {
        console.error('Error analyzing scene:', error);
        resultsElement.textContent = `Error: ${error instanceof Error ? error.message : 'Unknown error occurred'}`;
    }
}

// Start the application
main().catch(console.error); 