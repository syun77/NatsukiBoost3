package ;

import flixel.FlxG;
import jp_2dgames.CsvLoader;
import flixel.util.FlxAngle;

/**
 * スピード制御
 **/
class SpeedController {
    public static inline var MAX:Float = 384; // 最大速度
    public static inline var ADD:Float = 1; // ブロック衝突による速度の上昇
    public static inline var FRICTION_MIN:Float = 200; // 摩擦による最低速度
    public static inline var MISS_DECAY:Float = 0.9; // 異なるブロック衝突による速度の低下
    public static inline var MISS_TOP:Float = 5; // ミスにより減少するトップスピードの値

    private var _now:Float = 0;     // 現在の速度
    private var _max:Float = 0;     // 最大速度
    private var _top:Float = 120;   // 現在の最大速度

    private var _accel_ratio:Float = 0.1;
    private var _deceleration_ratio:Float = 0.05;
    private var _brake_ratio:Float = 0.05;
    /**
     * コンストラクタ
     **/
    public function new(csvPlayer:CsvLoader) {
        _now = csvPlayer.searchItemFloat("key", "speed_start", "value");
        _top = csvPlayer.searchItemFloat("key", "speedtop_start", "value");
        _accel_ratio = csvPlayer.searchItemFloat("key", "speedtop_accel", "value");
        _deceleration_ratio = csvPlayer.searchItemFloat("key", "speedtop_decceleration", "value");
        _brake_ratio = csvPlayer.searchItemFloat("key", "brake_ratio", "value");

        FlxG.watch.add(this, "_now");
    }

    public function getNow():Float { return _now; }
    public function getTop():Float { return _top; }
    public function getMax():Float { return _max; }

    /**
     * フォローオブジェクトの描画オフセット座標(X)を取得する
     **/
    public function getFollowOffsetX():Float {
        var diffSpeed = MAX - _now;
        var dx:Float = 0;
        if(diffSpeed > 0) {
            diffSpeed = MAX - diffSpeed;
            dx = 64 * Math.cos(FlxAngle.TO_RAD * 90 * diffSpeed / MAX);
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
     * 同属性ブロック習得によるスピードアップ
     **/
    public function speedUp():Void {
        add(ADD);
    }

    /**
     * トップスピード上昇
     **/
    public function addTop(v:Float):Void {
        _top += v;

        if(_top > MAX) {
            _top = MAX;
        }
    }

    /**
     * 更新
     **/
    public function update():Void {
        // デフォルトの速度上昇
        var d = _top - _now;
        d *= _accel_ratio;
        add(d);
    }

    /**
     * 摩擦による速度減少
     **/
    public function friction():Void {
        if(_now > FRICTION_MIN) {
            _now -= 0.2;
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
     **/
    public function hitBlock():Void {
        var v = _now * _deceleration_ratio;
        _now -= v;
        if(_now < 0) {
            _now = 0;
        }

        _top -= MISS_TOP;
        if(_top < 0) {
            _top = 0;
        }
    }
}

