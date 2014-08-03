package ui;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;

/**
 * リザルトメニュー
 **/
class ResultHUD extends FlxGroup {

    private var _objs:Array<FlxObject>;
    // ゲームオブジェクト
    private var _panel:FlxSprite;

    /**
     * コンストラクタ
     **/
    public function new() {
        super();
        _objs = new Array<FlxObject>();

        _panel = new FlxSprite(FlxG.width/2, FlxG.height/2+40);
        _panel.loadGraphic("assets/images/result/scoer_fream.png");
        _panel.x -= _panel.width/2;

        _objs.push(_panel);
        for(obj in _objs) {
            obj.scrollFactor.set(0, 0);
            this.add(obj);
        }
    }

    public function isEnd():Bool {
        return true;
    }
}
