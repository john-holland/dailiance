package dailiance.core;

import dailiance.math.Vector3;
import mori.Map;
import mori.Vector;

interface IAudioSystem {
    // Sound management
    public function loadSound(id:String, url:String, ?options:Map<String, Dynamic>):Void;
    public function unloadSound(id:String):Void;
    public function playSound(id:String, ?options:Map<String, Dynamic>):Void;
    public function stopSound(id:String):Void;
    public function pauseSound(id:String):Void;
    public function resumeSound(id:String):Void;
    
    // Sound properties
    public function setVolume(id:String, volume:Float):Void;
    public function setPitch(id:String, pitch:Float):Void;
    public function setLoop(id:String, loop:Bool):Void;
    public function setPosition(id:String, position:Vector3):Void;
    public function setVelocity(id:String, velocity:Vector3):Void;
    
    // Sound groups
    public function createGroup(id:String, ?sounds:Vector<String>):Void;
    public function destroyGroup(id:String):Void;
    public function addToGroup(groupId:String, soundId:String):Void;
    public function removeFromGroup(groupId:String, soundId:String):Void;
    public function setGroupVolume(groupId:String, volume:Float):Void;
    public function setGroupPitch(groupId:String, pitch:Float):Void;
    
    // 3D audio
    public function setListenerPosition(position:Vector3):Void;
    public function setListenerOrientation(forward:Vector3, up:Vector3):Void;
    public function setListenerVelocity(velocity:Vector3):Void;
    public function set3DAudioEnabled(enabled:Bool):Void;
    public function set3DAudioSettings(settings:Map<String, Dynamic>):Void;
    
    // Effects
    public function addEffect(id:String, type:AudioEffectType, params:Map<String, Dynamic>):Void;
    public function removeEffect(id:String, type:AudioEffectType):Void;
    public function updateEffect(id:String, type:AudioEffectType, params:Map<String, Dynamic>):Void;
    
    // Global settings
    public function setMasterVolume(volume:Float):Void;
    public function setMasterPitch(pitch:Float):Void;
    public function setMute(mute:Bool):Void;
    public function setPause(pause:Bool):Void;
    
    // State queries
    public function isPlaying(id:String):Bool;
    public function isPaused(id:String):Bool;
    public function isMuted(id:String):Bool;
    public function getVolume(id:String):Float;
    public function getPitch(id:String):Float;
    public function getPosition(id:String):Vector3;
    public function getDuration(id:String):Float;
    public function getCurrentTime(id:String):Float;
    
    // Event handling
    public function addEventListener(id:String, event:AudioEventType, callback:Map<String, Dynamic>->Void):Void;
    public function removeEventListener(id:String, event:AudioEventType, callback:Map<String, Dynamic>->Void):Void;
    
    // Resource management
    public function preloadSounds(urls:Vector<String>):Void;
    public function unloadUnusedSounds():Void;
    public function getLoadedSounds():Vector<String>;
    public function getLoadingProgress():Float;
}

enum AudioEffectType {
    Reverb;
    Echo;
    Distortion;
    LowPass;
    HighPass;
    BandPass;
    Compressor;
    Limiter;
}

enum AudioEventType {
    Loaded;
    Started;
    Stopped;
    Paused;
    Resumed;
    Ended;
    Error;
    Progress;
} 