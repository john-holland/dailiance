package dailiance.unity;

import dailiance.math.Vector3;
import dailiance.math.Matrix4x4;
import dailiance.math.BoundingBox;
import mori.Map;
import mori.Vector;

class UnityComponent {
    private var gameObject:GameObject;
    private var enabled:Bool;
    private var messageHandlers:Map<String, Array<Dynamic->Void>>;
    private var properties:Map<String, Dynamic>;

    public function new() {
        this.enabled = true;
        this.messageHandlers = mori.hashMap();
        this.properties = mori.hashMap();
        initializeMessageHandlers();
    }

    private function initializeMessageHandlers():Void {
        // Unity lifecycle methods
        registerMessageHandler("Awake", onAwake);
        registerMessageHandler("Start", onStart);
        registerMessageHandler("Update", onUpdate);
        registerMessageHandler("LateUpdate", onLateUpdate);
        registerMessageHandler("FixedUpdate", onFixedUpdate);
        registerMessageHandler("OnEnable", onEnable);
        registerMessageHandler("OnDisable", onDisable);
        registerMessageHandler("OnDestroy", onDestroy);
    }

    public function setGameObject(gameObject:GameObject):Void {
        this.gameObject = gameObject;
    }

    public function getGameObject():GameObject {
        return gameObject;
    }

    public function setEnabled(enabled:Bool):Void {
        this.enabled = enabled;
        if (enabled) {
            sendMessage("OnEnable");
        } else {
            sendMessage("OnDisable");
        }
    }

    public function isEnabled():Bool {
        return enabled;
    }

    public function registerMessageHandler(messageName:String, handler:Dynamic->Void):Void {
        var handlers = mori.get(messageHandlers, messageName);
        if (handlers == null) {
            handlers = mori.vector();
        }
        handlers = mori.conj(handlers, handler);
        messageHandlers = mori.assoc(messageHandlers, messageName, handlers);
    }

    public function sendMessage(messageName:String, ?data:Dynamic):Void {
        if (!enabled) return;

        var handlers = mori.get(messageHandlers, messageName);
        if (handlers != null) {
            mori.each(handlers, function(handler) {
                handler(data);
            });
        }
    }

    public function setProperty(name:String, value:Dynamic):Void {
        properties = mori.assoc(properties, name, value);
    }

    public function getProperty(name:String):Dynamic {
        return mori.get(properties, name);
    }

    // Unity lifecycle methods
    private function onAwake(data:Dynamic):Void {}
    private function onStart(data:Dynamic):Void {}
    private function onUpdate(data:Dynamic):Void {}
    private function onLateUpdate(data:Dynamic):Void {}
    private function onFixedUpdate(data:Dynamic):Void {}
    private function onEnable(data:Dynamic):Void {}
    private function onDisable(data:Dynamic):Void {}
    private function onDestroy(data:Dynamic):Void {}
}

class GameObject {
    private var components:Array<UnityComponent>;
    private var transform:Transform;
    private var name:String;
    private var active:Bool;

    public function new(name:String) {
        this.name = name;
        this.components = [];
        this.transform = new Transform();
        this.active = true;
    }

    public function addComponent<T:UnityComponent>(componentClass:Class<T>):T {
        var component = Type.createInstance(componentClass, []);
        component.setGameObject(this);
        components.push(component);
        return component;
    }

    public function getComponent<T:UnityComponent>(componentClass:Class<T>):T {
        for (component in components) {
            if (Std.isOfType(component, componentClass)) {
                return cast component;
            }
        }
        return null;
    }

    public function sendMessage(messageName:String, ?data:Dynamic):Void {
        if (!active) return;
        for (component in components) {
            component.sendMessage(messageName, data);
        }
    }

    public function setActive(active:Bool):Void {
        this.active = active;
        for (component in components) {
            component.setEnabled(active);
        }
    }

    public function isActive():Bool {
        return active;
    }

    public function getName():String {
        return name;
    }

    public function getTransform():Transform {
        return transform;
    }
}

class Transform {
    private var position:Vector3;
    private var rotation:Vector3;
    private var scale:Vector3;
    private var parent:Transform;
    private var children:Array<Transform>;
    private var localToWorldMatrix:Matrix4x4;
    private var worldToLocalMatrix:Matrix4x4;

    public function new() {
        this.position = new Vector3();
        this.rotation = new Vector3();
        this.scale = new Vector3(1, 1, 1);
        this.children = [];
        updateMatrices();
    }

    public function setPosition(position:Vector3):Void {
        this.position = position;
        updateMatrices();
    }

    public function getPosition():Vector3 {
        return position;
    }

    public function setRotation(rotation:Vector3):Void {
        this.rotation = rotation;
        updateMatrices();
    }

    public function getRotation():Vector3 {
        return rotation;
    }

    public function setScale(scale:Vector3):Void {
        this.scale = scale;
        updateMatrices();
    }

    public function getScale():Vector3 {
        return scale;
    }

    public function setParent(parent:Transform):Void {
        if (this.parent != null) {
            this.parent.children.remove(this);
        }
        this.parent = parent;
        if (parent != null) {
            parent.children.push(this);
        }
        updateMatrices();
    }

    public function getParent():Transform {
        return parent;
    }

    public function getChildren():Array<Transform> {
        return children;
    }

    public function getLocalToWorldMatrix():Matrix4x4 {
        return localToWorldMatrix;
    }

    public function getWorldToLocalMatrix():Matrix4x4 {
        return worldToLocalMatrix;
    }

    private function updateMatrices():Void {
        var translationMatrix = Matrix4x4.translation(position.x, position.y, position.z);
        var rotationMatrix = Matrix4x4.rotation(Vector3.up(), rotation.y)
            .multiply(Matrix4x4.rotation(Vector3.right(), rotation.x))
            .multiply(Matrix4x4.rotation(Vector3.forward(), rotation.z));
        var scaleMatrix = Matrix4x4.scaling(scale.x, scale.y, scale.z);

        localToWorldMatrix = translationMatrix.multiply(rotationMatrix.multiply(scaleMatrix));
        
        if (parent != null) {
            localToWorldMatrix = parent.getLocalToWorldMatrix().multiply(localToWorldMatrix);
        }

        worldToLocalMatrix = localToWorldMatrix.inverse();
    }

    public function transformPoint(point:Vector3):Vector3 {
        return localToWorldMatrix.transformPoint(point);
    }

    public function transformDirection(direction:Vector3):Vector3 {
        return localToWorldMatrix.transformVector(direction);
    }

    public function inverseTransformPoint(point:Vector3):Vector3 {
        return worldToLocalMatrix.transformPoint(point);
    }

    public function inverseTransformDirection(direction:Vector3):Vector3 {
        return worldToLocalMatrix.transformVector(direction);
    }
} 