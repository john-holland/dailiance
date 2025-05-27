package dailiance.actors;

import dailiance.ai.Prompt;
import dailiance.math.Vector3;
import dailiance.math.Matrix3x3;

class ActorAI {
    private var rnn:RNN;
    private var promptGenerator:PromptGenerator;
    private var context:ActorContext;
    private var nearbyActors:Array<Actor>;
    private var behaviorState:BehaviorState;

    public function new() {
        rnn = new RNN();
        promptGenerator = new PromptGenerator();
        context = new ActorContext();
        nearbyActors = [];
        behaviorState = new BehaviorState();
    }

    public function update(deltaTime:Float):Void {
        updateContext();
        generateBehavior();
        updatePrompts();
    }

    private function updateContext():Void {
        // Update actor context based on current state and nearby actors
        context.position = behaviorState.position;
        context.velocity = behaviorState.velocity;
        context.nearbyActors = nearbyActors;
        context.time = Date.now().getTime();
    }

    public function generateBehavior():Behavior {
        var input = prepareRNNInput();
        var output = rnn.predict(input);
        return interpretRNNOutput(output);
    }

    private function prepareRNNInput():Array<Float> {
        var input:Array<Float> = [];
        
        // Add position data
        input.push(context.position.x);
        input.push(context.position.y);
        input.push(context.position.z);
        
        // Add velocity data
        input.push(context.velocity.x);
        input.push(context.velocity.y);
        input.push(context.velocity.z);
        
        // Add nearby actor data
        for (actor in context.nearbyActors) {
            input.push(actor.position.x);
            input.push(actor.position.y);
            input.push(actor.position.z);
        }
        
        return input;
    }

    private function interpretRNNOutput(output:Array<Float>):Behavior {
        var behavior = new Behavior();
        
        // Interpret RNN output to determine behavior
        behavior.movement = new Vector3(
            output[0],
            output[1],
            output[2]
        );
        
        behavior.interaction = output[3] > 0.5;
        behavior.emotion = interpretEmotion(output.slice(4, 8));
        
        return behavior;
    }

    public function updatePrompts():Void {
        var basePrompt = promptGenerator.generateBasePrompt(context);
        var negativePrompt = promptGenerator.generateNegativePrompt(context);
        
        // Update prompts based on nearby actors
        for (actor in nearbyActors) {
            var influence = calculateActorInfluence(actor);
            basePrompt = mergePrompts(basePrompt, actor.prompt, influence);
            negativePrompt = mergePrompts(negativePrompt, actor.negativePrompt, influence);
        }
        
        context.prompt = basePrompt;
        context.negativePrompt = negativePrompt;
    }

    private function calculateActorInfluence(actor:Actor):Float {
        var distance = Vector3.distance(context.position, actor.position);
        var maxInfluence = 10.0; // Maximum influence distance
        return Math.max(0, 1 - (distance / maxInfluence));
    }

    private function mergePrompts(base:Prompt, other:Prompt, influence:Float):Prompt {
        var merged = new Prompt(base.text);
        merged.weight = base.weight * (1 - influence) + other.weight * influence;
        
        // Merge embeddings
        for (i in 0...base.embeddings.length) {
            merged.embeddings[i] = base.embeddings[i] * (1 - influence) + 
                                 other.embeddings[i] * influence;
        }
        
        return merged;
    }

    private function interpretEmotion(emotionVector:Array<Float>):Emotion {
        var maxIndex = 0;
        var maxValue = emotionVector[0];
        
        for (i in 1...emotionVector.length) {
            if (emotionVector[i] > maxValue) {
                maxValue = emotionVector[i];
                maxIndex = i;
            }
        }
        
        return switch(maxIndex) {
            case 0: Happy;
            case 1: Sad;
            case 2: Angry;
            case 3: Neutral;
            default: Neutral;
        };
    }
}

class RNN {
    private var weights:Array<Array<Float>>;
    private var biases:Array<Float>;
    private var hiddenState:Array<Float>;

    public function new() {
        // Initialize RNN weights and biases
        weights = [];
        biases = [];
        hiddenState = [];
    }

    public function predict(input:Array<Float>):Array<Float> {
        // Implement RNN forward pass
        return [];
    }
}

class PromptGenerator {
    public function new() {}

    public function generateBasePrompt(context:ActorContext):Prompt {
        // Generate base prompt based on context
        return new Prompt("");
    }

    public function generateNegativePrompt(context:ActorContext):Prompt {
        // Generate negative prompt based on context
        return new Prompt("");
    }
}

class ActorContext {
    public var position:Vector3;
    public var velocity:Vector3;
    public var nearbyActors:Array<Actor>;
    public var time:Float;
    public var prompt:Prompt;
    public var negativePrompt:Prompt;

    public function new() {
        position = new Vector3();
        velocity = new Vector3();
        nearbyActors = [];
        time = 0;
        prompt = new Prompt("");
        negativePrompt = new Prompt("");
    }
}

class Behavior {
    public var movement:Vector3;
    public var interaction:Bool;
    public var emotion:Emotion;

    public function new() {
        movement = new Vector3();
        interaction = false;
        emotion = Neutral;
    }
}

class BehaviorState {
    public var position:Vector3;
    public var velocity:Vector3;
    public var rotation:Quaternion;

    public function new() {
        position = new Vector3();
        velocity = new Vector3();
        rotation = new Quaternion();
    }
}

enum Emotion {
    Happy;
    Sad;
    Angry;
    Neutral;
} 