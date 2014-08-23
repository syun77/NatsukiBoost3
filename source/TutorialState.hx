package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

/**
 * チュートリアル画面
 **/
class TutorialState extends FlxState {
    override public function create() {
        super.create();

        var spr = new FlxSprite();
        spr.loadGraphic("assets/images/tutorial/001.png");
        this.add(spr);
    }

    override public function update():Void {
        super.update();

        if(FlxG.mouse.justPressed) {
            // タイトル画面へ戻る
            FlxG.switchState(new MenuState());
        }
    }
}
