package jp.seconddgames.natsukiboost3.token;

import jp.seconddgames.natsukiboost3.Attribute;
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

    private static inline var TIMER_VANISH = 60;

    // アイテムID
    private var _id:ItemID;
    // 属性
    private var _attr:Attribute;
    // 消滅タイマー
    private var _tVanish:Int;

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
        _tVanish = 0;
        visible = true;

        x = px;
        y = py;
        switch(chipID) {
        case 3:
            // 属性チェンジ（青）
            loadGraphic("assets/images/item/ring_blue.png", true);
            _id = ItemID.Ring;
            _attr = Attribute.Blue;
        case 4:
            // 属性チェンジ（赤）
            loadGraphic("assets/images/item/ring_red.png", true);
            _id = ItemID.Ring;
            _attr = Attribute.Red;

        case 17:
            // 拡大
            _id = ItemID.Big;
            loadGraphic("assets/images/item/kakudai.png", true);

        case 18:
            // 縮小
            _id = ItemID.Small;
            loadGraphic("assets/images/item/syukusyou.png", true);

        case 19:
            // 無敵
            _id = ItemID.Star;
            loadGraphic("assets/images/item/muteki.png", true);

        case 20:
            // ダメージ
            _id = ItemID.Damage;
            loadGraphic("assets/images/item/damage.png", true);

        case 21:
            // バリア
            _id = ItemID.Shield;
            loadGraphic("assets/images/item/bariya.png", true);

        case 33:
            // ボム
            _id = ItemID.Bomb;
            loadGraphic("assets/images/item/bomb.png", true);

        case 34:
            // ワープ
            _id = ItemID.Warp;
            loadGraphic("assets/images/item/stop.png", true);

        case 35:
            // 加速
            _id = ItemID.Dash;
            loadGraphic("assets/images/item/kasoku.png", true);

        case 36:
            // 重力
            _id = ItemID.Gravity;
            loadGraphic("assets/images/item/jyuryoku.png", true);

        }
        animation.add("play", [0, 1], 6);
        animation.play("play");
    }

    /**
     * 消滅
     **/
    public function vanish():Void {
        if(_id == ItemID.Warp) {
            _tVanish = TIMER_VANISH;
        }
        else {
            // そのまま消す
            kill();
        }
    }

    /**
     * 更新
     */
    override public function update():Void {
        super.update();

        if(_tVanish > 0) {
            visible = _tVanish%4 < 2;
            _tVanish--;
            if(_tVanish <= 0) {
                kill();
            }
        }

        if(x + width < FlxG.camera.scroll.x) {
            // 画面外に出たので消す
            kill();
        }
    }
}

