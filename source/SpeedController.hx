package ;

import flixel.util.FlxAngle;

/**
 * スピード制御
 **/
class SpeedController {
    public static inline var START:Float = 50; // 開始時の速さ
    public static inline var TOP:Float = 250; // トップスピード
    public static inline var MAX:Float = 384; // 最大速度
    public static inline var ADD:Float = 1; // ブロック衝突による速度の上昇
    public static inline var ADD_DEFAULT:Float = 0.3; // デフォルトでの速度上昇
    public static inline var DEFAULT_MAX:Float = 100; // デフォルトでの速度上昇制限
    public static inline var FRICTION_MIN:Float = 200; // 摩擦による最低速度
    public static inline var STOP_DECAY:Float = 0.97; // 停止標識の速度の低下
    public static inline var MISS_DECAY:Float = 0.9; // 異なるブロック衝突による速度の低下

    private var _now:Float = START; // 現在の速度
    private var _max:Float = 0;     // 最大速度
    private var _top:Float = TOP;   // 現在の最大速度

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
        if(_now < START) {
            _now = START;
        }
    }

    /**
     * 同属性ブロック習得によるスピードアップ
     **/
    public function speedUp():Void {
        add(ADD);
    }

    /**
     * 更新
     **/
    public function update():Void {
        if(_now < DEFAULT_MAX) {
            // デフォルトのスクロール速度上昇
            add(ADD_DEFAULT);
        }
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
        _now *= STOP_DECAY;
        if(_now < START) {
            _now = START;
        }
    }

    /**
     * ブロック衝突減速
     **/
    public function hitBlock():Void {
        _now *= MISS_DECAY ;
        if(_now < START) {
            _now = START;
        }
    }
}

