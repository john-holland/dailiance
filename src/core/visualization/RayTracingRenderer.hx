package dailiance.visualization;

import dailiance.math.Vector3;
import dailiance.math.Ray;
import dailiance.math.Matrix3x3;
import dailiance.ai.StableDiffusionManager;
import dailiance.ai.Prompt;
import dailiance.ai.Image;
import dailiance.ai.Mask;

class RayTracingRenderer extends Renderer {
    private var depthBuffer:Array<Float>;
    private var screenBuffer:Image;
    private var stableDiffusion:StableDiffusionManager;
    private var rayBounceLimit:Int;
    private var samplesPerPixel:Int;

    public function new(stableDiffusion:StableDiffusionManager) {
        super();
        this.stableDiffusion = stableDiffusion;
        this.rayBounceLimit = 5;
        this.samplesPerPixel = 4;
    }

    override public function initialize():Void {
        super.initialize();
        initializeBuffers();
    }

    private function initializeBuffers():Void {
        var width = viewport.width;
        var height = viewport.height;
        depthBuffer = new Array<Float>();
        screenBuffer = new Image(width, height);
        
        // Initialize depth buffer with maximum depth
        for (i in 0...width * height) {
            depthBuffer[i] = Float.POSITIVE_INFINITY;
        }
    }

    override public function renderScene():Void {
        clearBuffers();
        traceRays();
        processBuffers();
    }

    private function clearBuffers():Void {
        for (i in 0...depthBuffer.length) {
            depthBuffer[i] = Float.POSITIVE_INFINITY;
        }
        screenBuffer.clear();
    }

    private function traceRays():Void {
        var width = viewport.width;
        var height = viewport.height;
        
        for (y in 0...height) {
            for (x in 0...width) {
                var color = new Vector3();
                
                // Multi-sample anti-aliasing
                for (s in 0...samplesPerPixel) {
                    var ray = generateRay(x, y, s);
                    color = color.add(traceRay(ray, 0));
                }
                
                color = color.divide(samplesPerPixel);
                screenBuffer.setPixel(x, y, color);
            }
        }
    }

    private function generateRay(x:Int, y:Int, sample:Int):Ray {
        var ndcX = (2.0 * (x + Math.random()) / viewport.width - 1.0) * viewport.aspect;
        var ndcY = 1.0 - 2.0 * (y + Math.random()) / viewport.height;
        
        var ray = new Ray();
        ray.origin = camera.position;
        ray.direction = new Vector3(ndcX, ndcY, -1.0).normalize();
        ray.direction = camera.rotation.rotate(ray.direction);
        
        return ray;
    }

    private function traceRay(ray:Ray, depth:Int):Vector3 {
        if (depth >= rayBounceLimit) {
            return new Vector3(); // Return black for max depth
        }

        var hit = sceneGraph.intersect(ray);
        if (hit == null) {
            return new Vector3(); // Return black for no hit
        }

        // Update depth buffer
        var pixelIndex = hit.screenX + hit.screenY * viewport.width;
        if (hit.distance < depthBuffer[pixelIndex]) {
            depthBuffer[pixelIndex] = hit.distance;
        }

        // Calculate lighting and material properties
        var color = calculateLighting(hit);
        
        // Recursive ray tracing for reflections and refractions
        if (hit.material.reflectivity > 0) {
            var reflectedRay = calculateReflection(ray, hit);
            var reflectedColor = traceRay(reflectedRay, depth + 1);
            color = color.add(reflectedColor.multiply(hit.material.reflectivity));
        }

        return color;
    }

    private function processBuffers():Void {
        // Convert depth buffer to normalized values
        var normalizedDepth = normalizeDepthBuffer();
        
        // Create depth-based mask for in-painting/out-painting
        var mask = createDepthMask(normalizedDepth);
        
        // Generate prompts based on scene content
        var prompts = generateScenePrompts();
        
        // Apply image-to-image transformation
        var transformedImage = stableDiffusion.inPaint(screenBuffer, mask);
        
        // Update screen buffer with transformed image
        screenBuffer = transformedImage;
    }

    private function normalizeDepthBuffer():Array<Float> {
        var min = Float.POSITIVE_INFINITY;
        var max = Float.NEGATIVE_INFINITY;
        
        // Find min and max depth values
        for (depth in depthBuffer) {
            if (depth < min) min = depth;
            if (depth > max) max = depth;
        }
        
        // Normalize depth values to [0, 1]
        return depthBuffer.map(function(depth) {
            return (depth - min) / (max - min);
        });
    }

    private function createDepthMask(normalizedDepth:Array<Float>):Mask {
        var mask = new Mask(viewport.width, viewport.height);
        
        for (i in 0...normalizedDepth.length) {
            // Create mask based on depth thresholds
            var depth = normalizedDepth[i];
            var maskValue = 0.0;
            
            if (depth < 0.3) { // Near objects
                maskValue = 1.0;
            } else if (depth > 0.7) { // Far objects
                maskValue = 0.0;
            } else { // Smooth transition
                maskValue = 1.0 - (depth - 0.3) / 0.4;
            }
            
            mask.data[i] = maskValue;
        }
        
        return mask;
    }

    private function generateScenePrompts():{base:Prompt, negative:Prompt} {
        var sceneContent = analyzeSceneContent();
        var basePrompt = new Prompt(sceneContent.description);
        var negativePrompt = new Prompt(sceneContent.negativeDescription);
        
        // Add depth-based prompt modifications
        var depthInfo = analyzeDepthInformation();
        basePrompt.text += " " + depthInfo.promptModifier;
        negativePrompt.text += " " + depthInfo.negativeModifier;
        
        return {base: basePrompt, negative: negativePrompt};
    }

    private function analyzeSceneContent():{description:String, negativeDescription:String} {
        // Analyze scene content to generate appropriate prompts
        return {
            description: "high quality, detailed scene",
            negativeDescription: "low quality, blurry, distorted"
        };
    }

    private function analyzeDepthInformation():{promptModifier:String, negativeModifier:String} {
        // Analyze depth information to modify prompts
        return {
            promptModifier: "with proper depth and perspective",
            negativeModifier: "flat, no depth"
        };
    }
}

class Ray {
    public var origin:Vector3;
    public var direction:Vector3;

    public function new() {
        origin = new Vector3();
        direction = new Vector3();
    }
}

class HitResult {
    public var position:Vector3;
    public var normal:Vector3;
    public var distance:Float;
    public var screenX:Int;
    public var screenY:Int;
    public var material:Material;

    public function new() {
        position = new Vector3();
        normal = new Vector3();
        distance = 0;
        screenX = 0;
        screenY = 0;
        material = new Material();
    }
}

class Material {
    public var color:Vector3;
    public var reflectivity:Float;
    public var roughness:Float;
    public var metallic:Float;

    public function new() {
        color = new Vector3(1, 1, 1);
        reflectivity = 0;
        roughness = 1;
        metallic = 0;
    }
} 