package effects;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

/**
 * 背景管理
 **/
class Back extends FlxGroup {

    private var _back:FlxBackdrop;

    public function new() {
        super();
        _back = new FlxBackdrop("assets/images/back.png", 0.1, 0, true, false);
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
