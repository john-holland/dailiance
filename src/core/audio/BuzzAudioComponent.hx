package dailiance.audio;

import dailiance.unity.UnityComponent;
import dailiance.unity.GameObject;
import js.buzz.Sound;
import js.buzz.Group;

class BuzzAudioComponent extends UnityComponent {
    private var sounds:Map<String, Sound>;
    private var groups:Map<String, Group>;
    private var masterVolume:Float;
    private var isMuted:Bool;

    public function new() {
        super();
        this.sounds = new Map();
        this.groups = new Map();
        this.masterVolume = 1.0;
        this.isMuted = false;
        initializeBuzz();
    }

    private function initializeBuzz():Void {
        // Configure buzz defaults
        Sound.defaults = {
            preload: true,
            autoplay: false,
            loop: false,
            volume: 100
        };
    }

    public function createSound(id:String, url:String, ?options:Dynamic):Sound {
        var sound = new Sound(url, options);
        sounds.set(id, sound);
        return sound;
    }

    public function createGroup(id:String, ?sounds:Array<Sound>):Group {
        var group = new Group(sounds != null ? sounds : []);
        groups.set(id, group);
        return group;
    }

    public function play(id:String, ?options:Dynamic):Void {
        var sound = sounds.get(id);
        if (sound != null) {
            sound.play(options);
        }
    }

    public function pause(id:String):Void {
        var sound = sounds.get(id);
        if (sound != null) {
            sound.pause();
        }
    }

    public function stop(id:String):Void {
        var sound = sounds.get(id);
        if (sound != null) {
            sound.stop();
        }
    }

    public function setVolume(id:String, volume:Float):Void {
        var sound = sounds.get(id);
        if (sound != null) {
            sound.setVolume(volume * 100); // Convert to percentage
        }
    }

    public function setGroupVolume(id:String, volume:Float):Void {
        var group = groups.get(id);
        if (group != null) {
            group.setVolume(volume * 100); // Convert to percentage
        }
    }

    public function setMasterVolume(volume:Float):Void {
        this.masterVolume = volume;
        Sound.all().setVolume(volume * 100); // Convert to percentage
    }

    public function getMasterVolume():Float {
        return masterVolume;
    }

    public function mute():Void {
        if (!isMuted) {
            Sound.all().mute();
            isMuted = true;
        }
    }

    public function unmute():Void {
        if (isMuted) {
            Sound.all().unmute();
            isMuted = false;
        }
    }

    public function isMuted():Bool {
        return isMuted;
    }

    public function fadeIn(id:String, duration:Int, ?callback:Void->Void):Void {
        var sound = sounds.get(id);
        if (sound != null) {
            sound.fadeIn(duration, callback);
        }
    }

    public function fadeOut(id:String, duration:Int, ?callback:Void->Void):Void {
        var sound = sounds.get(id);
        if (sound != null) {
            sound.fadeOut(duration, callback);
        }
    }

    public function setLoop(id:String, loop:Bool):Void {
        var sound = sounds.get(id);
        if (sound != null) {
            sound.setLoop(loop);
        }
    }

    public function setPlaybackRate(id:String, rate:Float):Void {
        var sound = sounds.get(id);
        if (sound != null) {
            sound.setPlaybackRate(rate);
        }
    }

    public function getDuration(id:String):Float {
        var sound = sounds.get(id);
        return sound != null ? sound.getDuration() : 0;
    }

    public function getCurrentTime(id:String):Float {
        var sound = sounds.get(id);
        return sound != null ? sound.getCurrentTime() : 0;
    }

    public function setCurrentTime(id:String, time:Float):Void {
        var sound = sounds.get(id);
        if (sound != null) {
            sound.setCurrentTime(time);
        }
    }

    public function isPlaying(id:String):Bool {
        var sound = sounds.get(id);
        return sound != null ? sound.isPlaying() : false;
    }

    public function isPaused(id:String):Bool {
        var sound = sounds.get(id);
        return sound != null ? sound.isPaused() : false;
    }

    public function isEnded(id:String):Bool {
        var sound = sounds.get(id);
        return sound != null ? sound.isEnded() : false;
    }

    override private function onDestroy(data:Dynamic):Void {
        // Clean up all sounds
        for (sound in sounds) {
            sound.stop();
        }
        sounds.clear();
        groups.clear();
    }
} 