package jp.seconddgames.natsukiboost3.token;
import flixel.FlxG;
import flixel.util.FlxAngle;
import flixel.util.FlxRandom;
import flixel.FlxSprite;

/**
 * 流れ星
 **/
class Meteor extends FlxSprite {
    public function new() {
        super();
        loadGraphic("assets/images/hosi.png");
        scrollFactor.set(0, 0);
        kill();
    }

    public function init():Void {
        x = -50 - FlxRandom.float() * 50;
        y = 50 + FlxG.height + FlxRandom.float() * 50;
        angle = -FlxRandom.floatRanged(10, 80);
        var speed = FlxRandom.floatRanged(10, 50);
        velocity.x = speed * Math.cos(angle*FlxAngle.TO_RAD);
        velocity.y = speed * Math.sin(angle*FlxAngle.TO_RAD);
        acceleration.x = velocity.x * 5;
        acceleration.y = velocity.y * 5;
    }

    override function update():Void {
        super.update();
        var sc:Float;
        var dx = 0 - x;
        var dy = FlxG.height - y;
        var length = Math.sqrt(dx*dx + dy*dy);
        sc = 0.1 + 0.001 * length;
        scale.x = sc;
        scale.y = sc;

        if(x > FlxG.width || y < 0) {
            kill();
        }
    }
}
