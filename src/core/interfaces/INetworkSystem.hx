package dailiance.core;

import mori.Map;
import mori.Vector;

interface INetworkSystem {
    // Connection management
    public function connect(host:String, port:Int):Void;
    public function disconnect():Void;
    public function isConnected():Bool;
    public function getConnectionState():ConnectionState;
    
    // Player management
    public function createPlayer(id:String, data:Map<String, Dynamic>):Void;
    public function removePlayer(id:String):Void;
    public function getPlayer(id:String):Map<String, Dynamic>;
    public function getPlayers():Vector<String>;
    public function isLocalPlayer(id:String):Bool;
    
    // Object synchronization
    public function registerObject(id:String, type:String, data:Map<String, Dynamic>):Void;
    public function unregisterObject(id:String):Void;
    public function updateObject(id:String, data:Map<String, Dynamic>):Void;
    public function getObject(id:String):Map<String, Dynamic>;
    public function getObjects():Vector<String>;
    
    // RPC calls
    public function callRPC(target:String, method:String, args:Vector<Dynamic>):Void;
    public function registerRPC(method:String, callback:Vector<Dynamic>->Void):Void;
    public function unregisterRPC(method:String):Void;
    
    // Message handling
    public function sendMessage(target:String, type:String, data:Map<String, Dynamic>):Void;
    public function broadcastMessage(type:String, data:Map<String, Dynamic>):Void;
    public function addMessageHandler(type:String, handler:Map<String, Dynamic>->Void):Void;
    public function removeMessageHandler(type:String, handler:Map<String, Dynamic>->Void):Void;
    
    // Scene synchronization
    public function syncScene(data:Map<String, Dynamic>):Void;
    public function getSceneData():Map<String, Dynamic>;
    public function addSceneSyncHandler(handler:Map<String, Dynamic>->Void):Void;
    public function removeSceneSyncHandler(handler:Map<String, Dynamic>->Void):Void;
    
    // Network settings
    public function setUpdateRate(rate:Float):Void;
    public function setInterpolationDelay(delay:Float):Void;
    public function setExtrapolationLimit(limit:Float):Void;
    public function setCompressionEnabled(enabled:Bool):Void;
    public function setEncryptionEnabled(enabled:Bool):Void;
    
    // State queries
    public function getLatency():Float;
    public function getPacketLoss():Float;
    public function getBandwidth():Float;
    public function getConnectionQuality():ConnectionQuality;
    
    // Event handling
    public function addConnectionListener(callback:ConnectionEvent->Void):Void;
    public function removeConnectionListener(callback:ConnectionEvent->Void):Void;
    public function addPlayerListener(callback:PlayerEvent->Void):Void;
    public function removePlayerListener(callback:PlayerEvent->Void):Void;
    public function addObjectListener(callback:ObjectEvent->Void):Void;
    public function removeObjectListener(callback:ObjectEvent->Void):Void;
    
    // Debug visualization
    public function drawNetworkStats():Void;
    public function drawObjectSync():Void;
    public function drawPlayerConnections():Void;
}

enum ConnectionState {
    Disconnected;
    Connecting;
    Connected;
    Disconnecting;
}

enum ConnectionQuality {
    Excellent;
    Good;
    Fair;
    Poor;
    Bad;
}

class ConnectionEvent {
    public var state:ConnectionState;
    public var error:String;
    public var latency:Float;
    
    public function new() {
        state = Disconnected;
        error = "";
        latency = 0;
    }
}

class PlayerEvent {
    public var type:PlayerEventType;
    public var playerId:String;
    public var data:Map<String, Dynamic>;
    
    public function new() {
        type = Joined;
        playerId = "";
        data = mori.hashMap();
    }
}

class ObjectEvent {
    public var type:ObjectEventType;
    public var objectId:String;
    public var data:Map<String, Dynamic>;
    
    public function new() {
        type = Created;
        objectId = "";
        data = mori.hashMap();
    }
}

enum PlayerEventType {
    Joined;
    Left;
    Updated;
    Kicked;
    Banned;
}

enum ObjectEventType {
    Created;
    Destroyed;
    Updated;
    Replicated;
} 