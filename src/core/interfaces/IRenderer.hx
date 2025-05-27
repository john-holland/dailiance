package dailiance.core;

import dailiance.math.Vector3;
import dailiance.math.Quaternion;
import dailiance.math.Matrix4x4;
import mori.Map;
import mori.Vector;

interface IRenderer {
    // Camera management
    public function setCamera(position:Vector3, rotation:Quaternion, fov:Float, near:Float, far:Float):Void;
    public function getCameraPosition():Vector3;
    public function getCameraRotation():Quaternion;
    public function getCameraMatrix():Matrix4x4;
    
    // Mesh management
    public function createMesh(vertices:Vector<Float>, indices:Vector<Int>, uvs:Vector<Float>, ?normals:Vector<Float>):String;
    public function destroyMesh(meshId:String):Void;
    public function updateMesh(meshId:String, vertices:Vector<Float>, indices:Vector<Int>, uvs:Vector<Float>, ?normals:Vector<Float>):Void;
    
    // Material management
    public function createMaterial(diffuse:Int, specular:Int, shininess:Float, ?texture:String):String;
    public function destroyMaterial(materialId:String):Void;
    public function updateMaterial(materialId:String, diffuse:Int, specular:Int, shininess:Float, ?texture:String):Void;
    
    // Instance management
    public function createInstance(meshId:String, materialId:String, position:Vector3, rotation:Quaternion, scale:Vector3):String;
    public function destroyInstance(instanceId:String):Void;
    public function updateInstance(instanceId:String, position:Vector3, rotation:Quaternion, scale:Vector3):Void;
    
    // Light management
    public function createLight(type:LightType, position:Vector3, color:Int, intensity:Float, ?range:Float):String;
    public function destroyLight(lightId:String):Void;
    public function updateLight(lightId:String, position:Vector3, color:Int, intensity:Float, ?range:Float):Void;
    
    // Rendering
    public function render():Void;
    public function clear():Void;
    public function setClearColor(color:Int):Void;
    public function setViewport(x:Int, y:Int, width:Int, height:Int):Void;
    
    // Post-processing
    public function addPostProcess(effect:PostProcessEffect, params:Map<String, Dynamic>):Void;
    public function removePostProcess(effect:PostProcessEffect):Void;
    public function updatePostProcess(effect:PostProcessEffect, params:Map<String, Dynamic>):Void;
    
    // Shader management
    public function createShader(vertexSource:String, fragmentSource:String):String;
    public function destroyShader(shaderId:String):Void;
    public function useShader(shaderId:String):Void;
    
    // Texture management
    public function createTexture(width:Int, height:Int, data:Vector<Int>):String;
    public function destroyTexture(textureId:String):Void;
    public function updateTexture(textureId:String, data:Vector<Int>):Void;
    
    // Render target management
    public function createRenderTarget(width:Int, height:Int):String;
    public function destroyRenderTarget(targetId:String):Void;
    public function setRenderTarget(targetId:String):Void;
    public function resetRenderTarget():Void;
    
    // Debug visualization
    public function drawLine(start:Vector3, end:Vector3, color:Int):Void;
    public function drawBox(center:Vector3, size:Vector3, color:Int):Void;
    public function drawSphere(center:Vector3, radius:Float, color:Int):Void;
    public function drawText(text:String, position:Vector3, color:Int):Void;
}

enum LightType {
    Point;
    Directional;
    Spot;
    Area;
}

enum PostProcessEffect {
    Bloom;
    SSAO;
    DepthOfField;
    MotionBlur;
    Vignette;
    ColorGrading;
} 