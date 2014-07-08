package effects;

import flixel.FlxSprite;
/**
 * プレイヤーエフェクト
 **/
class EffectPlayer extends FlxSprite {

    private static inline var TIMER_CHANGE_WAIT = 90;
    private var _timer:Float = 0;
    /**
     * コンストラクタ
     **/
    public function new() {
        super();
        loadGraphic("assets/images/player.png", true);
        animation.add("blue", [0]);
        animation.add("red", [1]);
        kill(); // 非表示にする
    }

    /**
     * エフェクト再生開始
     **/
    public function start(attr:Attribute, px:Float, py:Float, timer:Int):Void {
        revive();
        if(attr == Attribute.Red) {
            animation.play("red");
        }
        else {
            animation.play("blue");
        }

        x = px;
        y = py;
        alpha = 1;
        scale.set(1, 1);
        _timer = timer;
    }

    /**
     * 更新
     **/
    override public function update():Void {
        super.update();

        _timer *= 0.9;
        alpha = _timer / TIMER_CHANGE_WAIT;
        var sc:Float = 1.0 + 2.0 * (TIMER_CHANGE_WAIT - _timer) / TIMER_CHANGE_WAIT;
        scale.set(sc, sc);
        if(isEnd()) {
            kill();
        }
    }

    /**
     * 終了したかどうか
     **/
    public function isEnd():Bool {
        return _timer < 1;
    }
}
