package token;

import flixel.FlxG;
import flixel.FlxSprite;

enum ItemID {
    Ring;     // 属性チェンジ
    Big;      // 拡大アイテム
    Small;    // 縮小アイテム
    Star;     // 無敵
    Damage;   // ダメージ
    Shield;   // バリア
    Bomb;     // ボム
    Warp;     // ワープ
    Dash;     // 加速アイテム
    Gravity;  // 重力
}

/**
 * アイテム共通クラス
 */
class Item extends FlxSprite {

    // アイテムID
    private var _id:ItemID;
    // 属性
    private var _attr:Attribute;

    /**
     * コンストラクタ
     */
    public function new() {
        super(-100, -100);
        immovable = true;
        kill();
    }

    // アイテムID
    public function getID():ItemID { return _id; }
    // 属性の取得
    public function getAttribute():Attribute { return _attr; }

    /**
     * 初期化
     * @param chipID チップ番号
     * @param px  座標(X)
     * @param py  座標(Y)
     **/
    public function init(chipID:Int, px:Float, py:Float):Void {
        x = px;
        y = py;
        switch(chipID) {
        case 3:
            loadGraphic("assets/images/ring_blue.png", true);
            _id = ItemID.Ring;
            _attr = Attribute.Blue;
        case 4:
            loadGraphic("assets/images/ring_red.png", true);
            _id = ItemID.Ring;
            _attr = Attribute.Red;
        }
        animation.add("play", [0, 1], 6);
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
     */
    override public function update():Void {
        super.update();

        if(x + width < FlxG.camera.scroll.x) {
            // 画面外に出たので消す
            kill();
        }
    }
}

