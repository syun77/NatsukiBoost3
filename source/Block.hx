package ;
import flixel.FlxG;
import flixel.util.FlxRandom;
import flixel.FlxSprite;

/**
 * ブロック
 **/
class Block extends FlxSprite {

    private var _attr:Attribute;

    /**
     * コンストラクタ
     **/
    public function new() {
        super();
        kill();
    }

    // 属性を取得
    public function getAttribute():Attribute { return _attr; }

    /**
     * 初期化
     **/
    public function init(attr:Attribute, px:Float, py:Float) {
        x = px;
        y = py;
        _attr = attr;
        var size = 8;
        if(attr == Attribute.Blue) {
            loadGraphic("assets/images/block_blue.png", true);
        }
        else {
            loadGraphic("assets/images/block_red.png", true);
        }
        animation.add("play", [0, 1], FlxRandom.intRanged(3, 6));
        animation.play("play");
    }

    /**
     * 消滅
     **/
    public function vanish():Void {
        kill();
    }

    /**
     * 更新
     **/
    override public function update():Void {

        super.update();

        if(x + width < FlxG.camera.scroll.x) {
            // 画面外に出た
            kill();
        }
    }
}
