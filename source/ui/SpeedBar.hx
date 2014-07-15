package ui;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
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

    private var _y1:Float;
    private var _y2:Float;
    private var _bBottom:Bool;

    private var _objs:Array<FlxObject>;

    public function new(px:Float, py:Float, w:Int, h:Int) {
        super();

        _y1 = 4;
        _y2 = FlxG.height - 16;
        _bBottom = true;

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
        setRatio(player.velocity.x / ctrl.getSpeedTopMax());

        // トップスピードの位置更新
        var top = ctrl.getTop();
        var rTop = top / ctrl.getSpeedTopMax();
        _top.x = _x - 1 + _width * rTop;

        if(player.y < FlxG.height/3) {
            // 上にいるので下に移動
            _move(true);
        }
        if(player.y > FlxG.height*2/3) {
            // 下にいるので上に移動
            _move(false);
        }
    }

    private function _move(bBottom:Bool):Void {
        if(_bBottom == bBottom) {
            // 位置が同じなので何もしない
            return;
        }

        _bBottom = bBottom;

        var py1:Float = 0;
        var py2:Float = 0;
        if(bBottom) {
            // 下に移動
            py1 = _y2 + 32;
            py2 = _y2;
        }
        else {
            // 上に移動
            py1 = _y1 - 32;
            py2 = _y1;
        }

        var size = 1;
        _frame.y = py1 - size;
        _frame2.y = py1;
        _frame3.y = py1;
        _meter.y = py1;
        _top.y = py1;

        var time = 0.3;
        FlxTween.tween(_frame, {y:(py2-size)}, time, {ease:FlxEase.expoOut});
        FlxTween.tween(_frame2, {y:py2}, time, {ease:FlxEase.expoOut});
        FlxTween.tween(_frame3, {y:py2}, time, {ease:FlxEase.expoOut});
        FlxTween.tween(_meter, {y:py2}, time, {ease:FlxEase.expoOut});
        FlxTween.tween(_top, {y:py2}, time, {ease:FlxEase.expoOut});

    }

}

