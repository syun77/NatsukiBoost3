package ui;
import SpeedController;
import token.Player;
import flixel.util.FlxStringUtil;
import flixel.ui.FlxBar;
import Math;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * Head up display.
 **/
class HUD extends FlxGroup {

    // 定数
    // スピードゲージ
    private static inline var SPEEDBAR_POS_X = 32;
    private static inline var SPEEDBAR_POS_Y1 = 16;
    private var SPEEDBAR_POS_Y2 = FlxG.height-16;
    private var SPEEDBAR_WIDTH = FlxG.width*0.75;
    private var SPEEDBAR_HEIGHT = 8;
    private var SPEEDTXT_POS_X:Float;
    // スピードテキスト

    // 参照用ゲームオブジェクト
    private var _player:Player;
    private var _speedCtrl:SpeedController;

    // 表示オブジェクト
    private var _txtSpeed:FlxText;
    private var _txtDistance:FlxText;
    private var _txtLevel:FlxText;
    private var _txtCombo:FlxText;
    private var _txtCombo2:FlxText;
    private var _txtTime:FlxText;

    // 経過時間
    private var _pastTime:Float = 0;
    private var _bIncTime:Bool = false; // 経過時間の増加フラグ

    // ゲージ
    private var _barDistance:FlxBar;
    private var _barSpeed:SpeedBar;

    private var _objs:Array<FlxObject>;

    // ゴールまでの距離
    private var _goal:Int;

    private var _tLevel:Int = 60;

    /**
     * コンストラクタ
     **/
    public function new(p:Player, speedCtrl:SpeedController, goal:Int) {
        SPEEDTXT_POS_X = SPEEDBAR_POS_X + SPEEDBAR_WIDTH;

        super();
        _player = p;
        _speedCtrl = speedCtrl;
        _goal = goal;

        _objs = new Array<FlxObject>();

        // テキスト
        var width = FlxG.width;
        var x = FlxG.width - 112;
        var y2 = 4;
        var y1 = FlxG.height-16;
        var dy = 12;
        y1 += dy;
        // スピードゲージ
        _barSpeed = new SpeedBar(SPEEDBAR_POS_X, SPEEDBAR_POS_Y2, cast SPEEDBAR_WIDTH, SPEEDBAR_HEIGHT);
        this.add(_barSpeed);
        _txtSpeed = new FlxText(SPEEDTXT_POS_X, _barSpeed.getY(), width);
        _txtDistance = new FlxText(x, y2, width);
        _txtLevel = new FlxText(-8, y1-24, width);
        _txtLevel.text = Reg.getLevelName();
        y2 += dy;

        // 残り距離
        _barDistance = new FlxBar(x, y2-2, FlxBar.FILL_LEFT_TO_RIGHT, cast FlxG.width/3, 2);
        _txtTime = new FlxText(x, y2, width);
        _txtTime.text = "Time: " + FlxStringUtil.formatTime(0, true);
        y2 += dy;

        // レベル
        _txtLevel.alignment = "right";

        // コンボ数
        _txtCombo = new FlxText(FlxG.width-72, y2, 64);
        _txtCombo.alignment = "center";
        _txtCombo2 = new FlxText(FlxG.width-56, y2+24, 80);
        _txtCombo2.text = "combo";
        _txtCombo2.visible = false;

        _objs.push(_barDistance);
        _objs.push(_txtTime);
        _objs.push(_txtSpeed);
        _objs.push(_txtDistance);
        _objs.push(_txtLevel);
        _objs.push(_txtCombo);
        _objs.push(_txtCombo2);

        for(o in _objs) {
            // スクロール無効
            o.scrollFactor.set(0, 0);
            this.add(o);
        }
    }

    /**
     * タイマー開始フラグを設定
     **/
    public function setIncTime(b:Bool):Void {
        _bIncTime = b;
    }

    /**
     * 経過時間を取得
     **/
    public function getPastTime():Int {
        return cast _pastTime;
    }

    override public function update():Void {

        if(_tLevel > 0) {
            _txtLevel.visible = _tLevel%4 < 2;
            _tLevel--;
        }

        if(_bIncTime) {
            // 経過時間の更新
            _pastTime += FlxG.elapsed * 1000;
            _txtTime.text = "Time: " + FlxStringUtil.formatTime(_pastTime/1000.0, true);
        }

        // スピードゲージの更新
        _barSpeed.updateAll(_player, _speedCtrl);
    }

    /**
     * コンボ数の設定
     **/
    public function setCombo(v:Int):Void {
        if(v == 0) {
            _txtCombo.visible = false;
            _txtCombo2.visible = false;
        }
        else {
            _txtCombo.visible = true;
            _txtCombo.text = "" + v;
            _txtCombo.size = 24;
            _txtCombo2.visible = true;
        }
    }

    /**
     * 更新
     **/
    public function updateAll():Void {
        _txtSpeed.text = "Speed: " + Math.ceil(_player.velocity.x);
        _txtDistance.text = "Distance: " + Math.floor(_player.x/10) + "/" + Math.floor(_goal/10);

        _barDistance.percent = 100*_player.x / _goal;

        if(_txtCombo.size > 16) {
            _txtCombo.size--;
        }
    }
}
