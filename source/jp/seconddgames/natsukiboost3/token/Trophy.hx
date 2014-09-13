package jp.seconddgames.natsukiboost3.token;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

/**
 * トロフィー
 **/
class Trophy extends FlxSprite {
    public function new(px:Float, py:Float, rank:Int) {
        super(px, py);
        if(rank < 3 || 5 < rank) {
            kill();
            return;
        }
        loadGraphic("assets/images/trophy.png", true);
        animation.add("5", [0]); // 金
        animation.add("4", [1]); // 銀
        animation.add("3", [2]); // 銅
        animation.play('$rank');
        scale.set(3, 3);
        alpha = 0;
        FlxTween.tween(scale, {x:1, y:1}, 1, {ease:FlxEase.expoOut});
        FlxTween.tween(this, {alpha:1}, 1, {ease:FlxEase.expoOut});
    }
}
