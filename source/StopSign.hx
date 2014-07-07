package ;
import flixel.FlxSprite;

/**
 * 停止標識
 **/
class StopSign extends FlxSprite {
    public function new() {
        super();
        loadGraphic("assets/images/stop.png", true);
        animation.add("play", [0, 1], 6);
        animation.play("play");
        kill();
    }

    /**
     * 初期化
     **/
    public function init(px:Float, py:Float):Void {
        x = px;
        y = py;
    }
}
