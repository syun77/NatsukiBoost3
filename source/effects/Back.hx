package effects;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * 背景管理
 **/
class Back extends FlxGroup {

    private static inline var BACK_SCROLL_SPEED:Float = 0.1; // 背景スクロールの速さ

    private var _back:FlxSprite;
    private var _back2:FlxSprite;
    private var _scrollX:Float = 0;

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
    public function scroll():Void {
        // 背景をスクロールする
        _scrollX -= BACK_SCROLL_SPEED;
        if(_scrollX < -FlxG.width) {
            // 折り返す
            _scrollX += FlxG.width;
        }

        _back.x = _scrollX;
        _back2.x = _scrollX + FlxG.width;

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
