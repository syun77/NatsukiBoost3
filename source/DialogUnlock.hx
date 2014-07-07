package ;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * アンロックダイアログ
 **/
class DialogUnlock extends FlxGroup {
    private static inline var TIMER = 60;

    private var _frame:FlxSprite;
    private var _window:FlxSprite;
    private var _txt:FlxText;
    private var _btn:FlxButton;
    private var _objs:Array<FlxObject>;
    private var _bClose:Bool = false; // 閉じたかどうか
    private var _timer:Float = TIMER;

    /**
     * コンストラクタ
     * @param lv アンロックしたレベル
     **/
    public function new(lv:Int) {
        super();

        _objs = new Array<FlxObject>();

        var w = 120;
        var h = 60;
        var x = FlxG.width/2 - w/2;
        var y = FlxG.height/2 - h/2;
        _frame = new FlxSprite(x-2, y-2);
        _frame.makeGraphic(w+4, h+4, FlxColor.SILVER);
        _frame.scale.y = 0;
        _window = new FlxSprite(x, y);
        _window.makeGraphic(w, h, FlxColor.NAVY_BLUE);
        _window.scale.y = 0;
        _txt = new FlxText(0, y + 8, FlxG.width);
        _txt.alignment = "center";
        _txt.text = "Unlock " + Reg.getLevelName(lv) + " mode.";
        _txt.visible = false;
        _btn = new FlxButton(FlxG.width/2-40, y + 32, _cbOk);
        _btn.text = "OK";
        _btn.color = FlxColor.AZURE;
        _btn.label.color = FlxColor.AQUAMARINE;
        _btn.visible = false;

        _objs.push(_frame);
        _objs.push(_window);
        _objs.push(_txt);
        _objs.push(_btn);

        for(o in _objs) {
            o.scrollFactor.set(0, 0);
            this.add(o);
        }

        FlxG.sound.play("push");
    }

    /**
     * 更新
     **/
    override public function update():Void {
        super.update();

        if(_timer > 1) {
            _timer = _timer * 0.8;
            var v = (TIMER - _timer) / TIMER;
            _frame.scale.y = v;
            _window.scale.y = v;
            if(_timer <= 1) {
                _btn.visible = true;
                _txt.visible = true;
                _frame.scale.y = 1;
                _window.scale.y = 1;
            }
        }

    }

    /**
     * ウィンドウを閉じたかどうか
     * @return 閉じたのであればtrue
     **/
    public function isClose():Bool {
        return _bClose;
    }

    /**
     * OKボタンを押した
     **/
    private function _cbOk():Void {
        _bClose = true;
    }
}
