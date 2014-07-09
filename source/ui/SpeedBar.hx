package ui;

import token.Player;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
/**
 * スピードバー
 **/
class SpeedBar extends FlxGroup {

    private var _frame:FlxSprite;  // 外枠
    private var _frame2:FlxSprite; // 内枠
    private var _frame3:FlxSprite; // メーターのブレ隠し
    private var _meter:FlxSprite;  // メーター
    private var _top:FlxSprite;    // トップの位置表示

    private var _x:Float; // X座標
    private var _y:Float; // Y座標
    private var _width:Int; // 幅
    private var _height:Int; // 高さ

    private var _objs:Array<FlxObject>;

    public function new(px:Float, py:Float, w:Int, h:Int) {
        super();
        _x = px;
        _y = py;
        _width = w;
        _height = h;

        _objs = new Array<FlxObject>();

        var size = 1;
        _frame = new FlxSprite(_x-size, _y-size);
        _frame.makeGraphic(_width+size*2, _height+size*2, FlxColor.WHITE);
        _frame2 = new FlxSprite(_x, _y);
        _frame2.makeGraphic(_width, _height, FlxColor.BLACK);
        _frame3 = new FlxSprite(_x-size, _y);
        _frame3.makeGraphic(size, _height, FlxColor.WHITE);

        _meter = new FlxSprite(_x-1, _y);
        _meter.makeGraphic(_width+1, _height, FlxColor.YELLOW);

        _top = new FlxSprite(_x-1, _y);
        _top.makeGraphic(1, _height, FlxColor.RED);

        _objs.push(_frame);
        _objs.push(_frame2);
        _objs.push(_meter);
        _objs.push(_frame3);
        _objs.push(_top);

        for(o in _objs) {
            o.scrollFactor.set(0, 0);
            this.add(o);
        }
    }

    public function getY():Float { return _y; }

    public function setRatio(per:Float):Void {
        if(per < 0) { per = 0; }
        if(per > 1) { per = 1; }

        _meter.scale.x = per;
        _meter.x = _x - (1 - per) * _width/2;
    }

    public function updateAll(player:Player, ctrl:SpeedController):Void {

        // スピードを設定
        setRatio(player.velocity.x / SpeedController.MAX);

        // トップスピードの位置更新
        var top = ctrl.getTop();
        var rTop = top / SpeedController.MAX;
        _top.x = _x - 1 + _width * rTop;
    }


}

