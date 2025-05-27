package dailiance.visualization;

import dailiance.math.Vector3;
import dailiance.math.Quaternion;
import dailiance.scene.SceneGraph;
import dailiance.actors.Actor;
import dailiance.narrative.ProximityNarrative;
import dailiance.ai.Prompt;
import dailiance.ai.RNN;

class ExteriorCamera {
    private var position:Vector3;
    private var rotation:Quaternion;
    private var sceneGraph:SceneGraph;
    private var narrative:ProximityNarrative;
    private var sceneRNN:RNN;
    private var pathingRNN:RNN;
    private var permanentPathing:Map<String, PathingPattern>;
    private var temporaryPathing:Map<String, PathingPattern>;
    private var sceneHistory:Array<SceneAnalysis>;
    private var maxHistoryLength:Int;

    public function new(sceneGraph:SceneGraph, narrative:ProximityNarrative) {
        this.sceneGraph = sceneGraph;
        this.narrative = narrative;
        this.position = new Vector3(0, 10, 0); // Elevated position
        this.rotation = new Quaternion();
        this.permanentPathing = new Map();
        this.temporaryPathing = new Map();
        this.sceneHistory = [];
        this.maxHistoryLength = 100;
        
        // Initialize RNNs
        this.sceneRNN = new RNN(256, 128); // Input size, hidden size
        this.pathingRNN = new RNN(128, 64);
    }

    public function update(deltaTime:Float):Void {
        // Analyze current scene
        var analysis = analyzeScene();
        sceneHistory.push(analysis);
        
        // Maintain history length
        if (sceneHistory.length > maxHistoryLength) {
            sceneHistory.shift();
        }
        
        // Update pathing patterns
        updatePathingPatterns();
        
        // Generate new pathing descriptions
        generatePathingDescriptions();
    }

    private function analyzeScene():SceneAnalysis {
        var analysis = new SceneAnalysis();
        
        // Get visible actors and their states
        var visibleActors = getVisibleActors();
        
        // Analyze spatial relationships
        analysis.spatialRelations = analyzeSpatialRelations(visibleActors);
        
        // Analyze temporal patterns
        analysis.temporalPatterns = analyzeTemporalPatterns();
        
        // Generate scene description
        analysis.description = generateSceneDescription(visibleActors);
        
        // Analyze pathing patterns
        analysis.pathingPatterns = analyzePathingPatterns(visibleActors);
        
        return analysis;
    }

    private function getVisibleActors():Array<Actor> {
        var visible:Array<Actor> = [];
        var viewFrustum = calculateViewFrustum();
        
        for (actor in sceneGraph.getActors()) {
            if (isInViewFrustum(actor.position, viewFrustum)) {
                visible.push(actor);
            }
        }
        
        return visible;
    }

    private function analyzeSpatialRelations(actors:Array<Actor>):Array<SpatialRelation> {
        var relations:Array<SpatialRelation> = [];
        
        for (i in 0...actors.length) {
            for (j in (i + 1)...actors.length) {
                var actor1 = actors[i];
                var actor2 = actors[j];
                
                var relation = new SpatialRelation();
                relation.actor1 = actor1;
                relation.actor2 = actor2;
                relation.distance = Vector3.distance(actor1.position, actor2.position);
                relation.relativeDirection = calculateRelativeDirection(actor1, actor2);
                relation.interactionType = determineInteractionType(actor1, actor2);
                
                relations.push(relation);
            }
        }
        
        return relations;
    }

    private function analyzeTemporalPatterns():Array<TemporalPattern> {
        var patterns:Array<TemporalPattern> = [];
        
        if (sceneHistory.length < 2) return patterns;
        
        // Analyze recent history for patterns
        for (i in 1...sceneHistory.length) {
            var current = sceneHistory[i];
            var previous = sceneHistory[i - 1];
            
            var pattern = new TemporalPattern();
            pattern.type = determineTemporalPatternType(previous, current);
            pattern.duration = current.timestamp - previous.timestamp;
            pattern.significance = calculatePatternSignificance(previous, current);
            
            patterns.push(pattern);
        }
        
        return patterns;
    }

    private function generateSceneDescription(actors:Array<Actor>):String {
        var description = "";
        
        // Use RNN to generate scene description
        var input = prepareSceneInput(actors);
        var output = sceneRNN.generate(input);
        
        // Format description
        description = formatSceneDescription(output, actors);
        
        return description;
    }

    private function analyzePathingPatterns(actors:Array<Actor>):Array<PathingPattern> {
        var patterns:Array<PathingPattern> = [];
        
        for (actor in actors) {
            if (actor.currentPath != null) {
                var pattern = new PathingPattern();
                pattern.actor = actor;
                pattern.path = actor.currentPath;
                pattern.context = analyzePathingContext(actor);
                pattern.frequency = calculatePatternFrequency(actor);
                
                patterns.push(pattern);
            }
        }
        
        return patterns;
    }

    private function updatePathingPatterns():Void {
        // Update temporary patterns
        for (pattern in temporaryPathing) {
            pattern.frequency += 1;
            
            // Check if pattern should become permanent
            if (pattern.frequency > 5 && pattern.fitness > 0.7) {
                permanentPathing.set(pattern.id, pattern);
                temporaryPathing.remove(pattern.id);
            }
        }
    }

    private function generatePathingDescriptions():Void {
        // Generate new pathing descriptions using RNN
        for (pattern in temporaryPathing) {
            var input = preparePathingInput(pattern);
            var output = pathingRNN.generate(input);
            
            // Update pattern description
            pattern.description = formatPathingDescription(output);
            pattern.fitness = calculatePatternFitness(pattern);
        }
    }

    private function calculatePatternFitness(pattern:PathingPattern):Float {
        var fitness = 0.0;
        
        // Calculate fitness based on:
        // 1. Pattern frequency
        fitness += pattern.frequency * 0.3;
        
        // 2. Pattern consistency
        fitness += calculatePatternConsistency(pattern) * 0.3;
        
        // 3. Pattern usefulness
        fitness += calculatePatternUsefulness(pattern) * 0.4;
        
        return Math.min(1.0, fitness);
    }

    private function calculatePatternConsistency(pattern:PathingPattern):Float {
        var consistency = 0.0;
        var count = 0;
        
        // Compare pattern with similar patterns in history
        for (analysis in sceneHistory) {
            for (historicalPattern in analysis.pathingPatterns) {
                if (isSimilarPattern(pattern, historicalPattern)) {
                    consistency += calculatePatternSimilarity(pattern, historicalPattern);
                    count++;
                }
            }
        }
        
        return count > 0 ? consistency / count : 0;
    }

    private function calculatePatternUsefulness(pattern:PathingPattern):Float {
        var usefulness = 0.0;
        
        // Calculate usefulness based on:
        // 1. Pattern clarity
        usefulness += pattern.description.length > 0 ? 0.3 : 0;
        
        // 2. Pattern specificity
        usefulness += calculatePatternSpecificity(pattern) * 0.3;
        
        // 3. Pattern applicability
        usefulness += calculatePatternApplicability(pattern) * 0.4;
        
        return Math.min(1.0, usefulness);
    }
}

class SceneAnalysis {
    public var timestamp:Float;
    public var spatialRelations:Array<SpatialRelation>;
    public var temporalPatterns:Array<TemporalPattern>;
    public var description:String;
    public var pathingPatterns:Array<PathingPattern>;

    public function new() {
        timestamp = Date.now().getTime();
        spatialRelations = [];
        temporalPatterns = [];
        pathingPatterns = [];
    }
}

class SpatialRelation {
    public var actor1:Actor;
    public var actor2:Actor;
    public var distance:Float;
    public var relativeDirection:Vector3;
    public var interactionType:InteractionType;
}

class TemporalPattern {
    public var type:TemporalPatternType;
    public var duration:Float;
    public var significance:Float;
}

class PathingPattern {
    public var id:String;
    public var actor:Actor;
    public var path:Path;
    public var context:Map<String, Dynamic>;
    public var frequency:Int;
    public var fitness:Float;
    public var description:String;

    public function new() {
        id = generateUniqueId();
        context = new Map();
        frequency = 0;
        fitness = 0;
    }
}

enum InteractionType {
    None;
    Approach;
    Retreat;
    Circle;
    Follow;
    Lead;
}

enum TemporalPatternType {
    None;
    Repetitive;
    Progressive;
    Cyclic;
    Random;
}

private function generateUniqueId():String {
    return "pattern_" + Date.now().getTime() + "_" + Math.floor(Math.random() * 1000);
} 