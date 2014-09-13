package jp.seconddgames.natsukiboost3.effects;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.util.FlxRandom;
import flixel.FlxSprite;
/**
 * 加速エフェクト
 **/
class EffectCross extends FlxSprite {
    private var _timer:Int = 0;
    public function new() {
        super();
        scrollFactor.set(0, 0);
        loadGraphic("assets/images/cross.png");
        kill();
        acceleration.y = 100;
        alpha = 0.75;
        blend = BlendMode.ADD;
    }

    public function start(X:Float, Y:Float):Void {
        X -= width/2;
        X += FlxRandom.floatRanged(-16, 16);
        Y -= 8;
        var sc = FlxRandom.float() * 0.5 + 0.5;
        scale.set(sc, sc);
        angularAcceleration = FlxRandom.floatRanged(30, 180);
        reset(X, Y);
        _timer = FlxRandom.intRanged(30, 60);
        visible = true;
        velocity.set(FlxRandom.floatRanged(-100, 100), FlxRandom.floatRanged(-20, -50));
        if(Y < FlxG.height/2) {
            velocity.y *= -0.5;
            y -= 4;
        }
        angle = FlxRandom.float() * 360;
    }

    override public function update():Void {
        super.update();
        velocity.x *= 0.97;
        _timer--;
        if(_timer < 15) {
            visible = visible == false;
            if(_timer < 0) {
                kill();
            }
        }
    }
}
