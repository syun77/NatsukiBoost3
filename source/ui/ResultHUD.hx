package ui;
import flixel.group.FlxGroup;

/**
 * リザルトメニュー
 **/
class ResultHUD extends FlxGroup {

    /**
     * コンストラクタ
     **/
    public function new() {
        super();
    }

    public function isEnd():Bool {
        return true;
    }
}
