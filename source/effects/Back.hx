package effects;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

/**
 * 背景管理
 **/
class Back extends FlxGroup {

//    private var _back:FlxBackdrop;
    private var _back:FlxSprite;

    public function new() {
        super();
//        _back = new FlxBackdrop("assets/images/back.png", 0.1, 0, true, false);
        _back = new FlxSprite("assets/images/bg.png");
        _back.scrollFactor.set();
        this.add(_back);
    }

    public function setDanger(b:Bool):Void {

        // ピンチチェック
        if(_back.color != FlxColor.WHITE) {
            _back.color = FlxColor.WHITE;
        }
        if(b) {
            // 背景を赤くする
            _back.color = FlxColor.RED;
        }
    }
}
