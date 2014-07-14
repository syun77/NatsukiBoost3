package ;

import flixel.FlxG;
import csv.CsvPlayer;
import flixel.util.FlxAngle;

/**
 * スピード制御
 **/
class SpeedController {
    public static inline var ADD:Float = 1; // ブロック衝突による速度の上昇
    public static inline var MISS_TOP:Float = 5; // ミスにより減少するトップスピードの値

    private var _now:Float = 0;     // 現在の速度
    private var _max:Float = 0;     // 最大速度
    private var _top:Float = 120;   // 現在の最大速度

    private var _accel_ratio:Float = 0.1;
    private var _deceleration_ratio:Float = 0.05;
    private var _brake_ratio:Float = 0.05;

    private var _damagetop_base:Float = 10;
    private var _damagetop_inc:Float = 5;

    private var _speedtop_deadline:Float = 0;
    private var _speedtop_max:Float = 0; // トップスピードの限界速度

    // タイマー
    private var _tBrake:Int = 0;    // ブレーキする時間
    private var _tWait:Int = 0;     // 速度が上がらない時間

    /**
     * コンストラクタ
     **/
    public function new(csvPlayer:CsvPlayer) {
        _now = csvPlayer.speed_start;
        _top = csvPlayer.speed_top;
        _accel_ratio = csvPlayer.accel_ratio;
        _deceleration_ratio = csvPlayer.deceleration_ratio;
        _brake_ratio = csvPlayer.brake_ratio;

        _damagetop_base = csvPlayer.damagetop_base;
        _damagetop_inc = csvPlayer.damagetop_inc;

        _speedtop_deadline = csvPlayer.speedtop_deadline;
        _speedtop_max = csvPlayer.speedtop_max;
    }

    public function getNow():Float { return _now; }
    public function getTop():Float { return _top; }
    public function getMax():Float { return _max; }
    public function getSpeedTopMax():Float { return _speedtop_max; }

    /**
     * 更新
     **/
    public function update():Void {
        if(_tWait > 0 || _tBrake > 0) {
            // 速度ペナルティ中なので上昇しない
        }
        else {
            // デフォルトの速度上昇
            var d = _top - _now;
            d *= _accel_ratio;
            add(d);
        }

        if(_tWait > 0) {
            _tWait--;
        }
        if(_tBrake > 0) {
            // ブレーキをかけているので速度は上がらない
            _tBrake--;
            brake();
        }
    }

    /**
     * ブレーキタイマーを設定
     * @param t ブレーキをかけるフレーム数
     **/
    public function setBrakeTimer(t:Int):Void {
        if(_tBrake <= 0) {
            _tBrake = t;
        }
    }

    /**
     * ブレーキをかけているかどうか
     **/
    public function isBrake():Bool {
        return _tBrake > 0;
    }

    /**
     * 速度上昇停止タイマーを設定
     * @param t 停止するフレーム数
     **/
    public function setWaitTimer(t:Int):Void {
        _tWait = t;
    }

    /**
     * フォローオブジェクトの描画オフセット座標(X)を取得する
     **/
    public function getFollowOffsetX():Float {
        var diffSpeed = _speedtop_max - _now;
        var dx:Float = 0;
        if(diffSpeed > 0) {
            diffSpeed = _speedtop_max - diffSpeed;
            dx = 64 * Math.cos(FlxAngle.TO_RAD * 90 * diffSpeed / _speedtop_max);
        }
        return dx;
    }

    /**
     * 加速する
     **/
    public function add(v:Float) {
        _now += v;

        if(_now > _top) {
            // トップスピードよりは上がらない
            _now = _top;
        }

        if(_now > _max) {
            // 最大スピード更新
            _max = _now;
        }
        if(_now < 0) {
            _now = 0;
        }
    }

    /**
     * トップスピード上昇
     **/
    public function addTop(v:Float):Void {
        _top += v;

        if(_top > _speedtop_max) {
            _top = _speedtop_max;
        }

        if(_top < 0) {
            _top = 0;
        }
    }

    /**
     * プレーキをかける
     **/
    public function brake():Void {
        var v = _now * _brake_ratio;
        _now -= v;
        if(_now < 0) {
            _now = 0;
        }
    }

    /**
     * ブロック衝突減速
     * @param 連続で衝突した回数
     **/
    public function hitBlock(cnt:Int):Void {
        var v = _now * _deceleration_ratio;
        _now -= v;
        if(_now < 0) {
            _now = 0;
        }

        var damage = _damagetop_base + _damagetop_inc * cnt;
        addTop(-damage);

        if(cnt > 1) {
            if(_top <= _speedtop_deadline) {
                // 初回ダメージ以外は死なない
                _top = _speedtop_deadline+1;
            }
        }
    }
}

