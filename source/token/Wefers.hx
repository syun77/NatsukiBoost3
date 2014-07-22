package token;
import flash.Vector;
import flixel.util.FlxRandom;
import flixel.FlxSprite;

/**
 * ウエハース
 **/
class Wefers extends FlxSprite{

    private var _attr:Attribute;
    private var _timer:Int = 0;
    private var _target:Player;

    public function new(target:Player) {
        super();
        _target = target;
        immovable = true;
        kill();
    }

    public function getAttribute():Attribute { return _attr; }

    public function init(attr:Attribute, px:Float, py:Float):Void {
        _attr = attr;
        x = px;
        y = py;

        if(attr == Attribute.Blue) {
            loadGraphic("assets/images/bomb_blue.png", true);
        }
        else {
            loadGraphic("assets/images/bomb_red.png", true);
        }

        animation.add("play", [0, 1], FlxRandom.intRanged(5, 10));
        _timer = FlxRandom.intRanged(10, 30);
        velocity.set(0, -2*FlxRandom.intRanged(30, 100));
    }

    override function update():Void {
        super.update();

        velocity.x *= 0.97;
        velocity.y *= 0.97;
        if(_timer > 0) {
            _timer--;
        }
        else {
            var dx = _target.x + _target.width/2 - (x + width/2);
            var dy = _target.y + _target.height/2 - (y + height/2);
            x += dx * 0.1;
            y += dy * 0.1;
        }
    }
}
