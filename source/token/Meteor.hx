package token;
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

    public function init(px:Float, py:Float):Void {
        x = px;
        y = py;
        angle = -FlxRandom.floatRanged(10, 80);
        var speed = FlxRandom.floatRanged(50, 200);
        velocity.x = speed * Math.cos(angle*FlxAngle.TO_RAD);
        velocity.y = speed * Math.sin(angle*FlxAngle.TO_RAD);
    }

    override function update():Void {
        super.update();
        if(isOnScreen() == false) {
            kill();
        }
    }
}
