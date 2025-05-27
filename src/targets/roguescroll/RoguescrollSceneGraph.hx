package dailiance.roguescroll;

import dailiance.interfaces.ISceneGraph;
import dailiance.math.Vector3;
import dailiance.math.Quaternion;
import roguescroll.core.Scene;
import roguescroll.core.Node;

class RoguescrollSceneGraph implements ISceneGraph {
    private var scene:Scene;
    private var nodes:Map<String, Node>;
    private var connections:Map<String, Array<String>>;

    public function new(scene:Scene) {
        this.scene = scene;
        nodes = new Map<String, Node>();
        connections = new Map<String, Array<String>>();
    }

    public function addNode(id:String, position:Vector3, rotation:Quaternion):Void {
        var node = new Node(id);
        node.setPosition(position.x, position.y, position.z);
        node.setRotation(rotation.x, rotation.y, rotation.z, rotation.w);
        scene.addNode(node);
        nodes.set(id, node);
        connections.set(id, []);
    }

    public function removeNode(id:String):Void {
        if (nodes.exists(id)) {
            var node = nodes.get(id);
            scene.removeNode(node);
            nodes.remove(id);
            connections.remove(id);
        }
    }

    public function updateNode(id:String, position:Vector3, rotation:Quaternion):Void {
        if (nodes.exists(id)) {
            var node = nodes.get(id);
            node.setPosition(position.x, position.y, position.z);
            node.setRotation(rotation.x, rotation.y, rotation.z, rotation.w);
        }
    }

    public function getNodePosition(id:String):Vector3 {
        if (nodes.exists(id)) {
            var node = nodes.get(id);
            var pos = node.getPosition();
            return new Vector3(pos.x, pos.y, pos.z);
        }
        return new Vector3();
    }

    public function getNodeRotation(id:String):Quaternion {
        if (nodes.exists(id)) {
            var node = nodes.get(id);
            var rot = node.getRotation();
            return new Quaternion(rot.x, rot.y, rot.z, rot.w);
        }
        return new Quaternion();
    }

    public function connectNodes(sourceId:String, targetId:String, weight:Float):Void {
        if (nodes.exists(sourceId) && nodes.exists(targetId)) {
            var sourceNode = nodes.get(sourceId);
            var targetNode = nodes.get(targetId);
            sourceNode.connect(targetNode, weight);
            
            var sourceConnections = connections.get(sourceId);
            if (!sourceConnections.contains(targetId)) {
                sourceConnections.push(targetId);
            }
        }
    }

    public function disconnectNodes(sourceId:String, targetId:String):Void {
        if (nodes.exists(sourceId) && nodes.exists(targetId)) {
            var sourceNode = nodes.get(sourceId);
            var targetNode = nodes.get(targetId);
            sourceNode.disconnect(targetNode);
            
            if (connections.exists(sourceId)) {
                var sourceConnections = connections.get(sourceId);
                sourceConnections.remove(targetId);
            }
        }
    }

    public function getConnectedNodes(id:String):Array<String> {
        return connections.exists(id) ? connections.get(id) : [];
    }
} 