package dailiance.narrative;

import dailiance.actors.Actor;
import dailiance.actors.ActorContext;
import dailiance.ai.Prompt;
import dailiance.math.Vector3;
import dailiance.math.Path;
import dailiance.scene.SceneNode;

class ProximityNarrative {
    private var actors:Map<String, Actor>;
    private var narrativeStates:Map<String, NarrativeState>;
    private var proximityThreshold:Float;
    private var pathingSystem:PathingSystem;
    private var promptGenerator:ProximityPromptGenerator;

    public function new() {
        actors = new Map();
        narrativeStates = new Map();
        proximityThreshold = 5.0;
        pathingSystem = new PathingSystem();
        promptGenerator = new ProximityPromptGenerator();
    }

    public function addActor(actor:Actor):Void {
        actors.set(actor.id, actor);
        narrativeStates.set(actor.id, new NarrativeState());
    }

    public function update(deltaTime:Float):Void {
        for (actor in actors) {
            updateActorNarrative(actor, deltaTime);
        }
    }

    private function updateActorNarrative(actor:Actor, deltaTime:Float):Void {
        var state = narrativeStates.get(actor.id);
        var nearbyActors = findNearbyActors(actor);
        
        // Update narrative state based on proximity
        updateNarrativeState(actor, state, nearbyActors);
        
        // Generate and update prompts based on narrative state
        var prompts = generatePrompts(actor, state, nearbyActors);
        actor.updatePrompts(prompts.base, prompts.negative);
        
        // Update pathing based on narrative state
        updatePathing(actor, state, nearbyActors);
    }

    private function findNearbyActors(actor:Actor):Array<Actor> {
        var nearby:Array<Actor> = [];
        
        for (other in actors) {
            if (other.id != actor.id) {
                var distance = Vector3.distance(actor.position, other.position);
                if (distance <= proximityThreshold) {
                    nearby.push(other);
                }
            }
        }
        
        return nearby;
    }

    private function updateNarrativeState(actor:Actor, state:NarrativeState, nearbyActors:Array<Actor>):Void {
        // Update emotional state based on nearby actors
        for (nearby in nearbyActors) {
            var influence = calculateEmotionalInfluence(actor, nearby);
            state.emotionalState = mergeEmotionalStates(state.emotionalState, nearby.narrativeState.emotionalState, influence);
        }
        
        // Update narrative context based on current pathing
        if (actor.currentPath != null) {
            updatePathBasedContext(actor, state);
        }
        
        // Update narrative goals
        updateNarrativeGoals(actor, state, nearbyActors);
    }

    private function generatePrompts(actor:Actor, state:NarrativeState, nearbyActors:Array<Actor>):{base:Prompt, negative:Prompt} {
        var basePrompt = promptGenerator.generateBasePrompt(actor, state);
        var negativePrompt = promptGenerator.generateNegativePrompt(actor, state);
        
        // Add proximity-based modifiers
        for (nearby in nearbyActors) {
            var influence = calculatePromptInfluence(actor, nearby);
            basePrompt = mergePrompts(basePrompt, nearby.prompt, influence);
            negativePrompt = mergePrompts(negativePrompt, nearby.negativePrompt, influence);
        }
        
        // Add pathing-based modifiers
        if (actor.currentPath != null) {
            var pathModifiers = generatePathModifiers(actor);
            basePrompt.text += " " + pathModifiers.base;
            negativePrompt.text += " " + pathModifiers.negative;
        }
        
        return {base: basePrompt, negative: negativePrompt};
    }

    private function updatePathing(actor:Actor, state:NarrativeState, nearbyActors:Array<Actor>):Void {
        // Check for narrative-driven pathing opportunities
        for (nearby in nearbyActors) {
            if (shouldInitiatePathing(actor, nearby, state)) {
                var path = generateNarrativePath(actor, nearby, state);
                if (path != null) {
                    actor.setPath(path);
                }
            }
        }
    }

    private function shouldInitiatePathing(actor:Actor, target:Actor, state:NarrativeState):Bool {
        // Check if current narrative state suggests pathing
        switch (state.narrativeGoal) {
            case Assist:
                return target.needsAssistance;
            case Confront:
                return state.emotionalState.intensity > 0.7;
            case Explore:
                return !actor.hasExplored(target.position);
            case Flee:
                return state.emotionalState.fear > 0.5;
            default:
                return false;
        }
    }

    private function generateNarrativePath(actor:Actor, target:Actor, state:NarrativeState):Path {
        var path = new Path();
        
        switch (state.narrativeGoal) {
            case Assist:
                // Generate path to help target
                path = pathingSystem.generateAssistPath(actor.position, target.position);
            case Confront:
                // Generate aggressive approach path
                path = pathingSystem.generateConfrontPath(actor.position, target.position);
            case Explore:
                // Generate exploration path
                path = pathingSystem.generateExplorePath(actor.position, target.position);
            case Flee:
                // Generate escape path
                path = pathingSystem.generateFleePath(actor.position, target.position);
            default:
                return null;
        }
        
        // Add narrative modifiers to path
        path.speed = calculateNarrativeSpeed(state);
        path.urgency = calculateNarrativeUrgency(state);
        
        return path;
    }

    private function calculateNarrativeSpeed(state:NarrativeState):Float {
        var baseSpeed = 1.0;
        
        // Modify speed based on emotional state
        baseSpeed *= (1.0 + state.emotionalState.intensity);
        
        // Modify speed based on narrative goal
        switch (state.narrativeGoal) {
            case Flee:
                baseSpeed *= 1.5;
            case Assist:
                baseSpeed *= 1.2;
            default:
                // No modification
        }
        
        return baseSpeed;
    }

    private function calculateNarrativeUrgency(state:NarrativeState):Float {
        var urgency = 0.0;
        
        // Base urgency on emotional intensity
        urgency += state.emotionalState.intensity;
        
        // Add urgency based on narrative goal
        switch (state.narrativeGoal) {
            case Assist:
                urgency += 0.3;
            case Flee:
                urgency += 0.5;
            case Confront:
                urgency += 0.4;
            default:
                // No additional urgency
        }
        
        return Math.min(1.0, urgency);
    }

    private function generatePathModifiers(actor:Actor):{base:String, negative:String} {
        var path = actor.currentPath;
        var goal = actor.narrativeState.narrativeGoal;
        
        var baseModifier = switch (goal) {
            case Assist: "rushing to help, determined, focused";
            case Confront: "approaching aggressively, tense, ready";
            case Explore: "cautiously exploring, curious, alert";
            case Flee: "fleeing in panic, desperate, scared";
            default: "";
        }
        
        var negativeModifier = switch (goal) {
            case Assist: "hesitant, slow, uncaring";
            case Confront: "hesitant, weak, unprepared";
            case Explore: "reckless, noisy, obvious";
            case Flee: "slow, calm, unafraid";
            default: "";
        }
        
        return {
            base: baseModifier,
            negative: negativeModifier
        };
    }
}

class NarrativeState {
    public var emotionalState:EmotionalState;
    public var narrativeGoal:NarrativeGoal;
    public var context:Map<String, Dynamic>;
    public var history:Array<NarrativeEvent>;

    public function new() {
        emotionalState = new EmotionalState();
        narrativeGoal = NarrativeGoal.None;
        context = new Map();
        history = [];
    }
}

class EmotionalState {
    public var intensity:Float;
    public var fear:Float;
    public var anger:Float;
    public var joy:Float;
    public var sadness:Float;

    public function new() {
        intensity = 0;
        fear = 0;
        anger = 0;
        joy = 0;
        sadness = 0;
    }
}

enum NarrativeGoal {
    None;
    Assist;
    Confront;
    Explore;
    Flee;
}

class NarrativeEvent {
    public var type:String;
    public var target:Actor;
    public var timestamp:Float;
    public var data:Dynamic;

    public function new(type:String, target:Actor, data:Dynamic) {
        this.type = type;
        this.target = target;
        this.timestamp = Date.now().getTime();
        this.data = data;
    }
}

class ProximityPromptGenerator {
    public function new() {}

    public function generateBasePrompt(actor:Actor, state:NarrativeState):Prompt {
        var prompt = new Prompt("");
        
        // Add emotional state to prompt
        prompt.text += describeEmotionalState(state.emotionalState);
        
        // Add narrative goal to prompt
        prompt.text += " " + describeNarrativeGoal(state.narrativeGoal);
        
        return prompt;
    }

    public function generateNegativePrompt(actor:Actor, state:NarrativeState):Prompt {
        var prompt = new Prompt("");
        
        // Add opposite emotional state
        prompt.text += describeOppositeEmotionalState(state.emotionalState);
        
        // Add opposite narrative goal
        prompt.text += " " + describeOppositeNarrativeGoal(state.narrativeGoal);
        
        return prompt;
    }

    private function describeEmotionalState(state:EmotionalState):String {
        var descriptions = [];
        
        if (state.fear > 0.5) descriptions.push("fearful");
        if (state.anger > 0.5) descriptions.push("angry");
        if (state.joy > 0.5) descriptions.push("joyful");
        if (state.sadness > 0.5) descriptions.push("sad");
        
        return descriptions.join(", ");
    }

    private function describeOppositeEmotionalState(state:EmotionalState):String {
        var descriptions = [];
        
        if (state.fear > 0.5) descriptions.push("fearless");
        if (state.anger > 0.5) descriptions.push("calm");
        if (state.joy > 0.5) descriptions.push("miserable");
        if (state.sadness > 0.5) descriptions.push("happy");
        
        return descriptions.join(", ");
    }

    private function describeNarrativeGoal(goal:NarrativeGoal):String {
        return switch (goal) {
            case Assist: "helping others, supportive, caring";
            case Confront: "confrontational, aggressive, challenging";
            case Explore: "exploring, curious, adventurous";
            case Flee: "fleeing, escaping, running away";
            case None: "neutral, calm, composed";
        };
    }

    private function describeOppositeNarrativeGoal(goal:NarrativeGoal):String {
        return switch (goal) {
            case Assist: "selfish, uncaring, indifferent";
            case Confront: "submissive, passive, avoiding conflict";
            case Explore: "stationary, cautious, hesitant";
            case Flee: "confronting, standing ground, brave";
            case None: "emotional, reactive, unstable";
        };
    }
} 