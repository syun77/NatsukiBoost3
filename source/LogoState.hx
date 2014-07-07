package ;
import flixel.addons.effects.FlxGlitchSprite;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxState;

/**
 * 起動ロゴ表示
 **/
class LogoState extends FlxState {

    private var _logo:FlxSprite;
    private var _glitch:FlxGlitchSprite;

    /**
	 * 生成
	 */
    override public function create():Void {
        super.create();
        /*
        _logo = new FlxSprite(0, 0);
        _logo.loadGraphic("assets/images/logo.png");
        FlxSpriteUtil.screenCenter(_logo);
        _glitch = new FlxGlitchSprite(_logo);
        _glitch.alpha = 0;
        _glitch.size = 1;
        _glitch.strength = 80;
        _glitch.delay = 0.01;
        add(_glitch);

        FlxTween.tween(_glitch, {strength:0}, 1.5, {ease:FlxEase.bounceOut, complete:_cbEnd});
        FlxTween.tween(_glitch, {alpha:1}, 1, {ease:FlxEase.expoOut});
        */
        Reg.cacheMusic();
        FlxG.switchState(new MenuState());
    }
    /**
	 * 破棄
	 */
    override public function destroy():Void {
        super.destroy();
    }

    /**
	 * 更新
	 */
    override public function update():Void {
        super.update();
    }

    private function _cbEnd(tween:FlxTween):Void {
        // ロゴ表示待ちの代わりにキャッシュする
        Reg.cacheMusic();
        FlxG.switchState(new MenuState());
    }
 }
