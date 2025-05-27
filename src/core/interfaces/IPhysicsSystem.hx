package dailiance.core;

import dailiance.math.Vector3;
import dailiance.math.Quaternion;
import dailiance.math.BoundingBox;
import mori.Map;
import mori.Vector;

interface IPhysicsSystem {
    // Rigidbody management
    public function createRigidbody(id:String, mass:Float, position:Vector3, rotation:Quaternion):Void;
    public function destroyRigidbody(id:String):Void;
    public function setRigidbodyMass(id:String, mass:Float):Void;
    public function setRigidbodyPosition(id:String, position:Vector3):Void;
    public function setRigidbodyRotation(id:String, rotation:Quaternion):Void;
    public function setRigidbodyVelocity(id:String, velocity:Vector3):Void;
    public function setRigidbodyAngularVelocity(id:String, angularVelocity:Vector3):Void;
    
    // Collider management
    public function createBoxCollider(id:String, size:Vector3, offset:Vector3, isTrigger:Bool):Void;
    public function createSphereCollider(id:String, radius:Float, offset:Vector3, isTrigger:Bool):Void;
    public function createCapsuleCollider(id:String, radius:Float, height:Float, offset:Vector3, isTrigger:Bool):Void;
    public function createMeshCollider(id:String, vertices:Vector<Float>, indices:Vector<Int>, isTrigger:Bool):Void;
    public function destroyCollider(id:String):Void;
    public function setColliderOffset(id:String, offset:Vector3):Void;
    public function setColliderTrigger(id:String, isTrigger:Bool):Void;
    
    // Force application
    public function addForce(id:String, force:Vector3, ?mode:ForceMode):Void;
    public function addTorque(id:String, torque:Vector3, ?mode:ForceMode):Void;
    public function addForceAtPosition(id:String, force:Vector3, position:Vector3, ?mode:ForceMode):Void;
    public function addRelativeForce(id:String, force:Vector3, ?mode:ForceMode):Void;
    public function addRelativeTorque(id:String, torque:Vector3, ?mode:ForceMode):Void;
    
    // Constraints
    public function createFixedJoint(id1:String, id2:String, anchor:Vector3):Void;
    public function createHingeJoint(id1:String, id2:String, anchor:Vector3, axis:Vector3):Void;
    public function createSpringJoint(id1:String, id2:String, anchor:Vector3, spring:Float, damper:Float):Void;
    public function destroyJoint(id:String):Void;
    
    // Raycasting
    public function raycast(origin:Vector3, direction:Vector3, distance:Float):RaycastHit;
    public function raycastAll(origin:Vector3, direction:Vector3, distance:Float):Vector<RaycastHit>;
    public function sphereCast(origin:Vector3, radius:Float, direction:Vector3, distance:Float):RaycastHit;
    public function boxCast(center:Vector3, size:Vector3, direction:Vector3, distance:Float):RaycastHit;
    
    // Queries
    public function checkCollision(id1:String, id2:String):Bool;
    public function getCollisionContacts(id:String):Vector<ContactPoint>;
    public function getCollidingBodies(id:String):Vector<String>;
    public function getBodiesInBounds(bounds:BoundingBox):Vector<String>;
    public function getBodiesInRadius(center:Vector3, radius:Float):Vector<String>;
    
    // Physics settings
    public function setGravity(gravity:Vector3):Void;
    public function setFixedTimeStep(timeStep:Float):Void;
    public function setMaxSteps(maxSteps:Int):Void;
    public function setSolverIterations(iterations:Int):Void;
    public function setSleepThreshold(threshold:Float):Void;
    
    // Debug visualization
    public function drawCollider(id:String, color:Int):Void;
    public function drawVelocity(id:String, color:Int):Void;
    public function drawForces(id:String, color:Int):Void;
    public function drawJoints(color:Int):Void;
    
    // State queries
    public function isAwake(id:String):Bool;
    public function isKinematic(id:String):Bool;
    public function isStatic(id:String):Bool;
    public function getVelocity(id:String):Vector3;
    public function getAngularVelocity(id:String):Vector3;
    public function getMass(id:String):Float;
    public function getInertia(id:String):Vector3;
    
    // Event handling
    public function addCollisionListener(id:String, callback:CollisionEvent->Void):Void;
    public function removeCollisionListener(id:String, callback:CollisionEvent->Void):Void;
    public function addTriggerListener(id:String, callback:TriggerEvent->Void):Void;
    public function removeTriggerListener(id:String, callback:TriggerEvent->Void):Void;
}

enum ForceMode {
    Force;
    Impulse;
    VelocityChange;
    Acceleration;
}

class RaycastHit {
    public var point:Vector3;
    public var normal:Vector3;
    public var distance:Float;
    public var colliderId:String;
    public var rigidbodyId:String;
    
    public function new() {
        point = new Vector3();
        normal = new Vector3();
        distance = 0;
        colliderId = "";
        rigidbodyId = "";
    }
}

class ContactPoint {
    public var point:Vector3;
    public var normal:Vector3;
    public var separation:Float;
    public var impulse:Float;
    
    public function new() {
        point = new Vector3();
        normal = new Vector3();
        separation = 0;
        impulse = 0;
    }
}

class CollisionEvent {
    public var id1:String;
    public var id2:String;
    public var contacts:Vector<ContactPoint>;
    public var relativeVelocity:Vector3;
    
    public function new() {
        id1 = "";
        id2 = "";
        contacts = mori.vector();
        relativeVelocity = new Vector3();
    }
}

class TriggerEvent {
    public var id1:String;
    public var id2:String;
    public var isEnter:Bool;
    
    public function new() {
        id1 = "";
        id2 = "";
        isEnter = false;
    }
} 