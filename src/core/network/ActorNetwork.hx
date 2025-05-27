package dailiance.network;

import dailiance.actors.Actor;
import dailiance.actors.ActorContext;
import dailiance.actors.Behavior;
import dailiance.math.Vector3;
import dailiance.math.Quaternion;

class ActorNetwork {
    private var actors:Map<String, Actor>;
    private var connections:Map<String, Array<String>>;
    private var messageQueue:Array<NetworkMessage>;
    private var updateRate:Float;
    private var lastUpdate:Float;

    public function new(updateRate:Float = 0.016) {
        this.actors = new Map();
        this.connections = new Map();
        this.messageQueue = [];
        this.updateRate = updateRate;
        this.lastUpdate = 0;
    }

    public function addActor(id:String, actor:Actor):Void {
        actors.set(id, actor);
        connections.set(id, []);
    }

    public function connectActors(id1:String, id2:String):Void {
        if (!connections.exists(id1)) {
            connections.set(id1, []);
        }
        if (!connections.exists(id2)) {
            connections.set(id2, []);
        }
        
        if (!connections.get(id1).contains(id2)) {
            connections.get(id1).push(id2);
        }
        if (!connections.get(id2).contains(id1)) {
            connections.get(id2).push(id1);
        }
    }

    public function update(deltaTime:Float):Void {
        lastUpdate += deltaTime;
        
        if (lastUpdate >= updateRate) {
            synchronizeStates();
            processMessages();
            lastUpdate = 0;
        }
    }

    private function synchronizeStates():Void {
        for (id in actors.keys()) {
            var actor = actors.get(id);
            var connectedActors = connections.get(id);
            
            for (connectedId in connectedActors) {
                var connectedActor = actors.get(connectedId);
                if (connectedActor != null) {
                    broadcastState(id, connectedId, actor.getState());
                }
            }
        }
    }

    private function broadcastState(fromId:String, toId:String, state:ActorState):Void {
        var message = new NetworkMessage(
            fromId,
            toId,
            MessageType.StateUpdate,
            state
        );
        messageQueue.push(message);
    }

    private function processMessages():Void {
        while (messageQueue.length > 0) {
            var message = messageQueue.shift();
            var targetActor = actors.get(message.toId);
            
            if (targetActor != null) {
                switch (message.type) {
                    case StateUpdate:
                        handleStateUpdate(targetActor, message.data);
                    case BehaviorUpdate:
                        handleBehaviorUpdate(targetActor, message.data);
                    case Interaction:
                        handleInteraction(targetActor, message.data);
                }
            }
        }
    }

    private function handleStateUpdate(actor:Actor, state:ActorState):Void {
        actor.updateState(state);
    }

    private function handleBehaviorUpdate(actor:Actor, behavior:Behavior):Void {
        actor.updateBehavior(behavior);
    }

    private function handleInteraction(actor:Actor, interaction:Interaction):Void {
        actor.handleInteraction(interaction);
    }

    public function sendMessage(fromId:String, toId:String, type:MessageType, data:Dynamic):Void {
        var message = new NetworkMessage(fromId, toId, type, data);
        messageQueue.push(message);
    }

    public function getConnectedActors(id:String):Array<Actor> {
        var connectedIds = connections.get(id);
        if (connectedIds == null) return [];
        
        return connectedIds.map(function(connectedId) {
            return actors.get(connectedId);
        }).filter(function(actor) {
            return actor != null;
        });
    }
}

class NetworkMessage {
    public var fromId:String;
    public var toId:String;
    public var type:MessageType;
    public var data:Dynamic;
    public var timestamp:Float;

    public function new(fromId:String, toId:String, type:MessageType, data:Dynamic) {
        this.fromId = fromId;
        this.toId = toId;
        this.type = type;
        this.data = data;
        this.timestamp = Date.now().getTime();
    }
}

enum MessageType {
    StateUpdate;
    BehaviorUpdate;
    Interaction;
}

class ActorState {
    public var position:Vector3;
    public var rotation:Quaternion;
    public var velocity:Vector3;
    public var context:ActorContext;

    public function new() {
        position = new Vector3();
        rotation = new Quaternion();
        velocity = new Vector3();
        context = new ActorContext();
    }
}

class Interaction {
    public var type:String;
    public var data:Dynamic;
    public var timestamp:Float;

    public function new(type:String, data:Dynamic) {
        this.type = type;
        this.data = data;
        this.timestamp = Date.now().getTime();
    }
} 