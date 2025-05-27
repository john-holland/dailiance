package dailiance.interfaces;

import dailiance.math.Vector3;
import dailiance.math.Quaternion;

interface ISceneGraph {
    public function addNode(id:String, position:Vector3, rotation:Quaternion):Void;
    public function removeNode(id:String):Void;
    public function updateNode(id:String, position:Vector3, rotation:Quaternion):Void;
    public function getNodePosition(id:String):Vector3;
    public function getNodeRotation(id:String):Quaternion;
    public function connectNodes(sourceId:String, targetId:String, weight:Float):Void;
    public function disconnectNodes(sourceId:String, targetId:String):Void;
    public function getConnectedNodes(id:String):Array<String>;
} 