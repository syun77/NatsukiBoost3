package token;
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
     * @attr  属性
     * @px    座標(X)
     * @py    座標(Y)
     * @bSame プレイヤーと同じ属性かどうか
     **/
    public function init(attr:Attribute, px:Float, py:Float, bSame:Bool) {
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
        var animSpeed = FlxRandom.intRanged(3, 6);
        animation.add("play1", [0, 1], animSpeed);
        animation.add("play2", [2, 3], animSpeed);

        // 見た目を変える
        change(bSame);
    }

    /**
     * 見た目を変える
     * @param bSame プレイヤーと同じ属性かどうか
     **/
    public function change(bSame:Bool):Void {
        if(bSame) {
            // 取得可能
            animation.play("play2");
        }
        else {
            // ダメージブロック
            animation.play("play1");
        }
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
