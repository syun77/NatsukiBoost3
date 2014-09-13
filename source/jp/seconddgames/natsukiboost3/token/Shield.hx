package jp.seconddgames.natsukiboost3.token;

import jp.seconddgames.natsukiboost3.Attribute;
import flixel.FlxSprite;

/**
 * シールドクラス
 */
class Shield extends FlxSprite {

    private var _attr:Attribute;
    private var _tBlink:Int = 0;

    /**
     * コンストラクタ
     */
    public function new() {
        super();
        loadGraphic("assets/images/shield.png", true);

        animation.add("blue", [0]);
        animation.add("red", [1]);

        setAttribute(Attribute.Blue);
    }

    /**
     * 属性の設定
     * @param attr 属性
     **/
    public function setAttribute(attr:Attribute):Void {
        if(attr == Attribute.Blue) {
            animation.play("blue");
        }
        else {
            animation.play("red");
        }
        _attr = attr;
    }

    public function blink():Void {
        _tBlink = 24;
    }

    /**
     * 更新
     */
    override public function update():Void {
        super.update();

        if(_tBlink > 0) {
            visible = _tBlink%4 < 2;
            _tBlink--;
        }
    }
}

