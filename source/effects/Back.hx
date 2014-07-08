package effects;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * 背景管理
 **/
class Back extends FlxGroup {
    var _back:FlxSprite;
    var _back2:FlxSprite;
    public function new() {
        super();

        _back = new FlxSprite(0, 0);
        _back.loadGraphic("assets/images/back.png");
        _back.scrollFactor.set(0, 0);
        this.add(_back);

        _back2 = new FlxSprite(FlxG.width, 0);
        _back2.loadGraphic("assets/images/back.png");
        _back2.scrollFactor.set(0, 0);
        this.add(_back2);
    }

    /**
     * 更新
     **/
    public function scroll(scrollX:Float):Void {
        // 背景をスクロールする
        _back.x = scrollX;
        _back2.x = scrollX + FlxG.width;

    }

    public function setDanger(b:Bool):Void {

        // ピンチチェック
        if(_back.color != FlxColor.WHITE) {
            _back.color = FlxColor.WHITE;
            _back2.color = FlxColor.WHITE;
        }
        if(b) {
            // 背景を赤くする
            _back.color = FlxColor.RED;
            _back2.color = FlxColor.RED;
        }
    }
}
