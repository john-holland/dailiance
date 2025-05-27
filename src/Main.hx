package;

import dailiance.unity.GameObject;
import dailiance.unity.UnityComponent;
import dailiance.three.ThreeComponent;
import dailiance.audio.BuzzAudioComponent;
import dailiance.math.Vector3;

class Main {
    public static function main() {
        // Create a game object
        var gameObject = new GameObject("MainObject");

        // Add Three.js component
        var threeComponent = gameObject.addComponent(ThreeComponent);
        
        // Create a box
        var box = threeComponent.createBox(1, 1, 1, 0xff0000);
        threeComponent.setObject3D(box);

        // Add audio component
        var audioComponent = gameObject.addComponent(BuzzAudioComponent);
        
        // Create and play a sound
        var sound = audioComponent.createSound("background", "assets/audio/background.mp3", {
            loop: true,
            volume: 50
        });
        audioComponent.play("background");

        // Set up animation
        var rotation = 0.0;
        threeComponent.registerMessageHandler("Update", function(data) {
            rotation += 0.01;
            var transform = gameObject.getTransform();
            transform.setRotation(new Vector3(0, rotation, 0));
        });

        // Start the game loop
        function gameLoop() {
            gameObject.sendMessage("Update");
            requestAnimationFrame(gameLoop);
        }
        gameLoop();
    }
} 