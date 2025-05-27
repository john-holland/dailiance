package dailiance.unity;

import dailiance.interfaces.ISceneGraph;
import dailiance.math.Vector3;
import dailiance.math.Quaternion;
import unityengine.GameObject;
import unityengine.Transform;
import unityengine.MonoBehaviour;

class UnitySceneGraph implements ISceneGraph {
    private var nodes:Map<String, GameObject>;
    private var connections:Map<String, Array<String>>;

    public function new() {
        nodes = new Map<String, GameObject>();
        connections = new Map<String, Array<String>>();
    }

    public function addNode(id:String, position:Vector3, rotation:Quaternion):Void {
        var go = new GameObject(id);
        var transform = go.transform;
        transform.position = new unityengine.Vector3(position.x, position.y, position.z);
        transform.rotation = new unityengine.Quaternion(rotation.x, rotation.y, rotation.z, rotation.w);
        nodes.set(id, go);
        connections.set(id, []);
    }

    public function removeNode(id:String):Void {
        if (nodes.exists(id)) {
            var go = nodes.get(id);
            GameObject.Destroy(go);
            nodes.remove(id);
            connections.remove(id);
        }
    }

    public function updateNode(id:String, position:Vector3, rotation:Quaternion):Void {
        if (nodes.exists(id)) {
            var go = nodes.get(id);
            var transform = go.transform;
            transform.position = new unityengine.Vector3(position.x, position.y, position.z);
            transform.rotation = new unityengine.Quaternion(rotation.x, rotation.y, rotation.z, rotation.w);
        }
    }

    public function getNodePosition(id:String):Vector3 {
        if (nodes.exists(id)) {
            var transform = nodes.get(id).transform;
            return new Vector3(transform.position.x, transform.position.y, transform.position.z);
        }
        return new Vector3();
    }

    public function getNodeRotation(id:String):Quaternion {
        if (nodes.exists(id)) {
            var transform = nodes.get(id).transform;
            return new Quaternion(transform.rotation.x, transform.rotation.y, transform.rotation.z, transform.rotation.w);
        }
        return new Quaternion();
    }

    public function connectNodes(sourceId:String, targetId:String, weight:Float):Void {
        if (nodes.exists(sourceId) && nodes.exists(targetId)) {
            var sourceConnections = connections.get(sourceId);
            if (!sourceConnections.contains(targetId)) {
                sourceConnections.push(targetId);
            }
        }
    }

    public function disconnectNodes(sourceId:String, targetId:String):Void {
        if (connections.exists(sourceId)) {
            var sourceConnections = connections.get(sourceId);
            sourceConnections.remove(targetId);
        }
    }

    public function getConnectedNodes(id:String):Array<String> {
        return connections.exists(id) ? connections.get(id) : [];
    }
} 