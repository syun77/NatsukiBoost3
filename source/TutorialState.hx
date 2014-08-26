package ;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import jp_2dgames.TextUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

/**
 * チュートリアル画面
 **/
class TutorialState extends FlxState {
    private var _nPage:Int = 0; // 現在のページ番号
    private var _btn:FlxButton;
    private var _spr:FlxSprite;

    override public function create() {
        super.create();

        this.add(new FlxSprite().loadGraphic("assets/images/title/bg.png"));
        this.add(new FlxSprite().loadGraphic("assets/images/title/charctor.png"));
        this.add(new FlxSprite().loadGraphic("assets/images/title/wafer1.png"));
        this.add(new FlxSprite().loadGraphic("assets/images/title/wafer2.png"));
        this.add(new FlxSprite().loadGraphic("assets/images/title/wafer3.png"));
        this.add(new FlxSprite().loadGraphic("assets/images/title/wafer4.png"));
        this.add(new FlxSprite().loadGraphic("assets/images/title/wafer5.png"));
        var logo = new FlxSprite().loadGraphic("assets/images/title/logo.png");
        logo.x = FlxG.width/2 - logo.width/2;
        logo.y = 8;
        this.add(logo);
        var fade = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        fade.alpha = 0.0;
        FlxTween.tween(fade, {alpha:0.7}, 1, {ease:FlxEase.expoOut});
        this.add(fade);

        _spr = new FlxSprite();
        _cbBtn();
        this.add(_spr);

        _btn = new FlxButton(FlxG.width-80, FlxG.height-24, "Next", _cbBtn);
        this.add(_btn);
    }

    private function _cbBtn():Void {

        _nPage++;
        if(_nPage > 3) {
            // おしまい
            // タイトル画面へ戻る
            FlxG.switchState(new MenuState());
            return;
        }
        else if(_nPage == 3) {
            _btn.text = "End";
        }
        var path = 'assets/images/tutorial/${TextUtil.fillZero(_nPage, 3)}.png';
        _spr.loadGraphic(path);
        _spr.alpha = 0;
    }

    override public function update():Void {
        super.update();

        if(_spr.alpha < 1) {
            _spr.alpha += 0.02;
        }
    }
}
