package ;
import flixel.FlxSprite;

/**
 * リング消滅エフェクト
 **/
class EffectRing extends FlxSprite {

    private var _timer:Int;

    public function new() {
        super();
        kill();
    }

    public function init(attr:Attribute, px:Float, py:Float):Void {
        if(attr == Attribute.Blue) {
            loadGraphic("assets/images/ring_blue.png", true);
        }
        else {
            loadGraphic("assets/images/ring_red.png", true);
        }
        x = px;
        y = py;
        _timer = 0;
    }

    override public function update():Void {
        _timer++;
        visible = _timer%4 < 2;
        if(_timer > 12) {
            kill();
        }
    }
}
