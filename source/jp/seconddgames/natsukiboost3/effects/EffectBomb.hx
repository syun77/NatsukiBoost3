package jp.seconddgames.natsukiboost3.effects;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

/**
 * ボムエフェクト
 **/
class EffectBomb extends FlxSprite {

    private var _timer:Float = 0;

    /**
     * コンストラクタ
     **/
    public function new() {
        super();
        scrollFactor.set(0, 0);
        loadGraphic("assets/images/bomb.png", true);
        animation.add("play", [0, 1, 2, 3, 4, 5, 6, 7], 30, false);
        kill();
    }

    /**
     * エフェクト再生開始
     **/
    public function start(px:Float, py:Float):Void {
        x = px;
        y = py;
        kill();
        new FlxTimer(FlxRandom.floatRanged(0, 1), _play);
    }

    private function _play(timer:FlxTimer):Void {
        revive();
        animation.play("play");
    }

    /**
     * 更新
     **/
    override public function update():Void {
        super.update();

        if(animation.finished) {
            kill();
        }
    }
}
