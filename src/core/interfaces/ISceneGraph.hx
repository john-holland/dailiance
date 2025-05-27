package dailiance.core;

import dailiance.math.Vector3;
import dailiance.math.Quaternion;
import dailiance.math.BoundingBox;
import mori.Map;
import mori.Vector;

interface ISceneGraph {
    // Node management
    public function addNode(id:String, position:Vector3, rotation:Quaternion):Void;
    public function removeNode(id:String):Void;
    public function updateNode(id:String, position:Vector3, rotation:Quaternion):Void;
    public function getNodePosition(id:String):Vector3;
    public function getNodeRotation(id:String):Quaternion;
    
    // Spatial queries
    public function getNodesInBounds(bounds:BoundingBox):Vector<String>;
    public function getNodesInRadius(center:Vector3, radius:Float):Vector<String>;
    public function getNearestNode(point:Vector3):String;
    
    // Hierarchy management
    public function setParent(childId:String, parentId:String):Void;
    public function getParent(childId:String):String;
    public function getChildren(parentId:String):Vector<String>;
    
    // Scene bounds
    public function getBoundingBox():BoundingBox;
    public function getWorldBounds():BoundingBox;
    
    // Scene graph operations
    public function clear():Void;
    public function getNodeCount():Int;
    public function getNodeIds():Vector<String>;
    
    // Spatial partitioning
    public function updateSpatialIndex():Void;
    public function querySpatialIndex(bounds:BoundingBox):Vector<String>;
    
    // Scene graph serialization
    public function serialize():Map<String, Dynamic>;
    public function deserialize(data:Map<String, Dynamic>):Void;
} 