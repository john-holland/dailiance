package dailiance.ai;

import dailiance.math.Matrix3x3;
import dailiance.visualization.PathingPattern;
import dailiance.actors.Actor;

class RNN {
    private var inputSize:Int;
    private var hiddenSize:Int;
    private var weights:Map<String, Matrix3x3>;
    private var biases:Map<String, Array<Float>>;
    private var hiddenState:Array<Float>;
    private var learningRate:Float;

    public function new(inputSize:Int, hiddenSize:Int) {
        this.inputSize = inputSize;
        this.hiddenSize = hiddenSize;
        this.learningRate = 0.01;
        
        // Initialize weights and biases
        initializeParameters();
    }

    private function initializeParameters():Void {
        weights = new Map();
        biases = new Map();
        
        // Initialize weight matrices
        weights.set("input_hidden", Matrix3x3.random(inputSize, hiddenSize));
        weights.set("hidden_hidden", Matrix3x3.random(hiddenSize, hiddenSize));
        weights.set("hidden_output", Matrix3x3.random(hiddenSize, inputSize));
        
        // Initialize bias vectors
        biases.set("hidden", Array.fill(hiddenSize, 0));
        biases.set("output", Array.fill(inputSize, 0));
        
        // Initialize hidden state
        hiddenState = Array.fill(hiddenSize, 0);
    }

    public function generate(input:Array<Float>):Array<Float> {
        // Forward pass
        var hidden = forward(input);
        
        // Generate output
        var output = generateOutput(hidden);
        
        return output;
    }

    private function forward(input:Array<Float>):Array<Float> {
        // Update hidden state
        var inputHidden = weights.get("input_hidden").transformVector(input);
        var hiddenHidden = weights.get("hidden_hidden").transformVector(hiddenState);
        
        // Combine and apply activation
        for (i in 0...hiddenSize) {
            hiddenState[i] = tanh(inputHidden[i] + hiddenHidden[i] + biases.get("hidden")[i]);
        }
        
        return hiddenState;
    }

    private function generateOutput(hidden:Array<Float>):Array<Float> {
        var output = weights.get("hidden_output").transformVector(hidden);
        
        // Add bias and apply activation
        for (i in 0...inputSize) {
            output[i] = tanh(output[i] + biases.get("output")[i]);
        }
        
        return output;
    }

    public function train(input:Array<Float>, target:Array<Float>):Void {
        // Forward pass
        var hidden = forward(input);
        var output = generateOutput(hidden);
        
        // Calculate gradients
        var outputGradients = calculateOutputGradients(output, target);
        var hiddenGradients = calculateHiddenGradients(hidden, outputGradients);
        
        // Update parameters
        updateParameters(input, hidden, outputGradients, hiddenGradients);
    }

    private function calculateOutputGradients(output:Array<Float>, target:Array<Float>):Array<Float> {
        var gradients = new Array<Float>();
        
        for (i in 0...output.length) {
            var error = target[i] - output[i];
            var gradient = error * (1 - output[i] * output[i]); // tanh derivative
            gradients.push(gradient);
        }
        
        return gradients;
    }

    private function calculateHiddenGradients(hidden:Array<Float>, outputGradients:Array<Float>):Array<Float> {
        var gradients = new Array<Float>();
        
        for (i in 0...hidden.length) {
            var gradient = 0.0;
            
            // Backpropagate through output layer
            for (j in 0...outputGradients.length) {
                gradient += outputGradients[j] * weights.get("hidden_output").get(i, j);
            }
            
            // Apply tanh derivative
            gradient *= (1 - hidden[i] * hidden[i]);
            gradients.push(gradient);
        }
        
        return gradients;
    }

    private function updateParameters(input:Array<Float>, hidden:Array<Float>, 
                                   outputGradients:Array<Float>, hiddenGradients:Array<Float>):Void {
        // Update weights
        updateWeightMatrix("hidden_output", hidden, outputGradients);
        updateWeightMatrix("hidden_hidden", hidden, hiddenGradients);
        updateWeightMatrix("input_hidden", input, hiddenGradients);
        
        // Update biases
        updateBias("output", outputGradients);
        updateBias("hidden", hiddenGradients);
    }

    private function updateWeightMatrix(name:String, input:Array<Float>, gradients:Array<Float>):Void {
        var weightMatrix = weights.get(name);
        
        for (i in 0...weightMatrix.rows) {
            for (j in 0...weightMatrix.cols) {
                var gradient = input[i] * gradients[j];
                weightMatrix.set(i, j, weightMatrix.get(i, j) + learningRate * gradient);
            }
        }
    }

    private function updateBias(name:String, gradients:Array<Float>):Void {
        var bias = biases.get(name);
        
        for (i in 0...bias.length) {
            bias[i] += learningRate * gradients[i];
        }
    }

    private function tanh(x:Float):Float {
        return (Math.exp(x) - Math.exp(-x)) / (Math.exp(x) + Math.exp(-x));
    }

    // Utility functions for pathing pattern generation
    public function generatePathingDescription(pattern:PathingPattern):String {
        var input = preparePathingInput(pattern);
        var output = generate(input);
        return formatPathingDescription(output);
    }

    private function preparePathingInput(pattern:PathingPattern):Array<Float> {
        var input = new Array<Float>();
        
        // Add path characteristics
        input = input.concat(normalizePathCharacteristics(pattern.path));
        
        // Add actor context
        input = input.concat(normalizeActorContext(pattern.actor));
        
        // Add spatial context
        input = input.concat(normalizeSpatialContext(pattern));
        
        return input;
    }

    private function normalizePathCharacteristics(path:Path):Array<Float> {
        var characteristics = new Array<Float>();
        
        // Normalize path properties
        characteristics.push(path.speed / 2.0); // Assuming max speed is 2.0
        characteristics.push(path.urgency);
        
        // Add behavior encoding
        characteristics = characteristics.concat(encodeBehavior(path.behavior));
        
        return characteristics;
    }

    private function normalizeActorContext(actor:Actor):Array<Float> {
        var context = new Array<Float>();
        
        // Add actor properties
        context.push(actor.narrativeState.emotionalState.intensity);
        context.push(actor.narrativeState.emotionalState.fear);
        context.push(actor.narrativeState.emotionalState.anger);
        
        // Add narrative goal encoding
        context = context.concat(encodeNarrativeGoal(actor.narrativeState.narrativeGoal));
        
        return context;
    }

    private function normalizeSpatialContext(pattern:PathingPattern):Array<Float> {
        var context = new Array<Float>();
        
        // Add spatial relationships
        if (pattern.context.exists("nearestActor")) {
            var nearestActor = pattern.context.get("nearestActor");
            context.push(normalizeDistance(nearestActor.distance));
            context = context.concat(encodeDirection(nearestActor.direction));
        }
        
        return context;
    }

    private function encodeBehavior(behavior:PathBehavior):Array<Float> {
        var encoding = new Array<Float>();
        
        switch (behavior) {
            case Assist: encoding = [1, 0, 0, 0, 0];
            case Confront: encoding = [0, 1, 0, 0, 0];
            case Explore: encoding = [0, 0, 1, 0, 0];
            case Flee: encoding = [0, 0, 0, 1, 0];
            case None: encoding = [0, 0, 0, 0, 1];
        }
        
        return encoding;
    }

    private function encodeNarrativeGoal(goal:NarrativeGoal):Array<Float> {
        var encoding = new Array<Float>();
        
        switch (goal) {
            case Assist: encoding = [1, 0, 0, 0, 0];
            case Confront: encoding = [0, 1, 0, 0, 0];
            case Explore: encoding = [0, 0, 1, 0, 0];
            case Flee: encoding = [0, 0, 0, 1, 0];
            case None: encoding = [0, 0, 0, 0, 1];
        }
        
        return encoding;
    }

    private function normalizeDistance(distance:Float):Float {
        return Math.min(1.0, distance / 10.0); // Assuming max distance is 10 units
    }

    private function encodeDirection(direction:Vector3):Array<Float> {
        return [direction.x, direction.y, direction.z];
    }

    private function formatPathingDescription(output:Array<Float>):String {
        // Convert numerical output to descriptive text
        var description = "";
        
        // Add movement type
        description += getMovementType(output[0]);
        
        // Add speed description
        description += ", " + getSpeedDescription(output[1]);
        
        // Add behavior description
        description += ", " + getBehaviorDescription(output[2]);
        
        return description;
    }

    private function getMovementType(value:Float):String {
        if (value > 0.8) return "Direct";
        if (value > 0.6) return "Meandering";
        if (value > 0.4) return "Circular";
        if (value > 0.2) return "Zigzag";
        return "Random";
    }

    private function getSpeedDescription(value:Float):String {
        if (value > 0.8) return "rushing";
        if (value > 0.6) return "moving quickly";
        if (value > 0.4) return "moving steadily";
        if (value > 0.2) return "moving slowly";
        return "crawling";
    }

    private function getBehaviorDescription(value:Float):String {
        if (value > 0.8) return "with purpose";
        if (value > 0.6) return "with determination";
        if (value > 0.4) return "with caution";
        if (value > 0.2) return "with hesitation";
        return "with uncertainty";
    }
} 