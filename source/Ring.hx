package ;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * 色変えアイテム
 **/
class Ring extends FlxSprite {

    // 属性
    private var _attr:Attribute;

    public function new() {
        super(-100, -100);
        loadGraphic("assets/images/ring_blue.png", true);
        immovable = true;
        kill();
    }

    // 属性の取得
    public function getAttribute():Attribute { return _attr; }
    /**
     * 初期化
     * @param attr 属性
     * @param px   X座標
     * @param py   Y座標
     **/
    public function init(attr:Attribute, px:Float, py:Float):Void {
        x = px;
        y = py;
        if(attr == Attribute.Red) {
            loadGraphic("assets/images/ring_red.png", true);
        }
        else {
            loadGraphic("assets/images/ring_blue.png", true);
        }
        animation.add("play", [0, 1], 6);
        animation.play("play");
        _attr = attr;
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
            // 画面外に出たので消す
            kill();
        }
    }
}
