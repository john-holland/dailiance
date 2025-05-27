package dailiance.three;

import dailiance.unity.UnityComponent;
import dailiance.unity.GameObject;
import dailiance.math.Vector3;
import dailiance.math.Matrix4x4;
import js.three.Object3D;
import js.three.Scene;
import js.three.Mesh;
import js.three.Material;
import js.three.Geometry;
import js.three.MeshBasicMaterial;
import js.three.BoxGeometry;
import js.three.SphereGeometry;
import js.three.CylinderGeometry;
import js.three.PerspectiveCamera;
import js.three.WebGLRenderer;
import js.three.AmbientLight;
import js.three.DirectionalLight;
import js.three.PointLight;
import js.three.SpotLight;

class ThreeComponent extends UnityComponent {
    private var object3D:Object3D;
    private var scene:Scene;
    private var camera:PerspectiveCamera;
    private var renderer:WebGLRenderer;
    private var lights:Array<Object3D>;

    public function new() {
        super();
        this.lights = [];
        initializeThree();
    }

    private function initializeThree():Void {
        // Create scene
        scene = new Scene();

        // Create camera
        camera = new PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        camera.position.z = 5;

        // Create renderer
        renderer = new WebGLRenderer();
        renderer.setSize(window.innerWidth, window.innerHeight);
        document.body.appendChild(renderer.domElement);

        // Add default lighting
        addAmbientLight(0x404040);
        addDirectionalLight(0xffffff, 1, new Vector3(1, 1, 1));
    }

    public function createMesh(geometry:Geometry, material:Material):Mesh {
        var mesh = new Mesh(geometry, material);
        scene.add(mesh);
        return mesh;
    }

    public function createBox(width:Float, height:Float, depth:Float, ?color:Int):Mesh {
        var geometry = new BoxGeometry(width, height, depth);
        var material = new MeshBasicMaterial({ color: color != null ? color : 0x00ff00 });
        return createMesh(geometry, material);
    }

    public function createSphere(radius:Float, ?color:Int):Mesh {
        var geometry = new SphereGeometry(radius);
        var material = new MeshBasicMaterial({ color: color != null ? color : 0x00ff00 });
        return createMesh(geometry, material);
    }

    public function createCylinder(radiusTop:Float, radiusBottom:Float, height:Float, ?color:Int):Mesh {
        var geometry = new CylinderGeometry(radiusTop, radiusBottom, height);
        var material = new MeshBasicMaterial({ color: color != null ? color : 0x00ff00 });
        return createMesh(geometry, material);
    }

    public function addAmbientLight(color:Int, ?intensity:Float):AmbientLight {
        var light = new AmbientLight(color, intensity != null ? intensity : 1);
        scene.add(light);
        lights.push(light);
        return light;
    }

    public function addDirectionalLight(color:Int, intensity:Float, direction:Vector3):DirectionalLight {
        var light = new DirectionalLight(color, intensity);
        light.position.set(direction.x, direction.y, direction.z);
        scene.add(light);
        lights.push(light);
        return light;
    }

    public function addPointLight(color:Int, intensity:Float, position:Vector3):PointLight {
        var light = new PointLight(color, intensity);
        light.position.set(position.x, position.y, position.z);
        scene.add(light);
        lights.push(light);
        return light;
    }

    public function addSpotLight(color:Int, intensity:Float, position:Vector3, target:Vector3):SpotLight {
        var light = new SpotLight(color, intensity);
        light.position.set(position.x, position.y, position.z);
        light.target.position.set(target.x, target.y, target.z);
        scene.add(light);
        scene.add(light.target);
        lights.push(light);
        return light;
    }

    override private function onUpdate(data:Dynamic):Void {
        // Update Three.js objects based on Unity transforms
        if (object3D != null) {
            var transform = gameObject.getTransform();
            var position = transform.getPosition();
            var rotation = transform.getRotation();
            var scale = transform.getScale();

            object3D.position.set(position.x, position.y, position.z);
            object3D.rotation.set(rotation.x, rotation.y, rotation.z);
            object3D.scale.set(scale.x, scale.y, scale.z);
        }

        // Render scene
        renderer.render(scene, camera);
    }

    public function setObject3D(object3D:Object3D):Void {
        if (this.object3D != null) {
            scene.remove(this.object3D);
        }
        this.object3D = object3D;
        if (object3D != null) {
            scene.add(object3D);
        }
    }

    public function getObject3D():Object3D {
        return object3D;
    }

    public function getScene():Scene {
        return scene;
    }

    public function getCamera():PerspectiveCamera {
        return camera;
    }

    public function getRenderer():WebGLRenderer {
        return renderer;
    }
} 