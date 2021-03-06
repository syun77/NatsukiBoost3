package effects;
import flixel.util.FlxRandom;
import Reg.GameMode;
import util.Snd;
import jp_2dgames.TextUtil;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

/**
 * 開始演出オブジェクト
 **/
class EffectStart extends FlxSprite {

    private static inline var TIMER_START = 0.75;
    private var _tStart = 0;

    public function new(px:Float, py:Float) {
        super(px, py);
        loadGraphic("assets/images/start/3.png");
        scrollFactor.set(0, 0);
        scale.set(2, 2);
        FlxTween.tween(scale, {x:1, y:1}, TIMER_START, { ease: FlxEase.expoOut, complete:_cbStart});

        Snd.playSe("3");
    }

    /**
     * 演出コールバック
     **/
    private function _cbStart(tween:FlxTween):Void {
        switch(_tStart) {
            case 0:
                Snd.playSe("2");
                scale.set(2, 2);
                loadGraphic("assets/images/start/2.png");
                FlxTween.tween(scale, {x:1, y:1}, TIMER_START, { ease: FlxEase.expoOut, complete:_cbStart});
                _tStart++;
            case 1:
                Snd.playSe("1");
                scale.set(2, 2);
                loadGraphic("assets/images/start/1.png");
                FlxTween.tween(scale, {x:1, y:1}, TIMER_START, { ease: FlxEase.expoOut, complete:_cbStart});
                _tStart++;
            case 2:
                Snd.playSe("go");
                var level = Reg.level;
                if(Reg.mode == GameMode.Endless) {
                    // エンドレスモードの時のBGMはランダムで1〜3
                    level = FlxRandom.intRanged(1, 3);
                }
                Snd.playMusic(TextUtil.fillZero(level, 3));
                scale.set(2, 2);
                loadGraphic("assets/images/start/go.png");
                x -= 16;
                FlxTween.tween(scale, {x:1, y:1}, TIMER_START, { ease: FlxEase.expoOut, complete:_cbStart});
                _tStart++;
            case 3:
                FlxTween.tween(scale, {x:0.25, y:4}, 0.1, { ease: FlxEase.expoInOut, complete:_cbStart});
                _tStart++;
            case 4:
                FlxTween.tween(scale, {x:16, y:0}, 0.75, { ease: FlxEase.expoOut, complete:_cbStart});
                FlxTween.tween(this, {alpha:0}, 0.75, { ease: FlxEase.expoOut});
                _tStart++;
            case 5:
                kill();
        }

    }

    /**
     * 終了したかどうか
     **/
    public function isEnd():Bool {
        if(_tStart >= 3) {
            return true;
        }
        return false;
    }
}
