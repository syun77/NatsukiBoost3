package ;

import flixel.util.FlxAngle;

/**
 * スピード制御
 **/
class SpeedController {
    public static inline var SPEED_START:Float = 50; // 開始時の速さ
    public static inline var SPEED_MAX:Float = 384; // 最大速度
    public static inline var SPEED_ADD:Float = 1; // ブロック衝突による速度の上昇
    public static inline var SPEED_ADD_DEFAULT:Float = 0.3; // デフォルトでの速度上昇
    public static inline var SPEED_DEFAULT_MAX:Float = 100; // デフォルトでの速度上昇制限
    public static inline var SPEED_FRICTION_MIN:Float = 200; // 摩擦による最低速度
    public static inline var SPEED_STOP:Float = 0.97; // 停止標識の速度の低下
    public static inline var SPEED_MISS:Float = 0.9; // 異なるブロック衝突による速度の低下

    private var _speed:Float = SPEED_START;
    private var _speedMax:Float = 0;
    private var _speedTop:Float = SPEED_MAX; // 現在の最大速度

    public function getSpeed():Float { return _speed; }
    public function getTop():Float { return _speedTop; }
    public function getSpeedMax():Float { return _speedMax; }

    /**
     * フォローオブジェクトの描画オフセット座標(X)を取得する
     **/
    public function getFollowOffsetX():Float {
        var diffSpeed = SPEED_MAX - _speed;
        var dx:Float = 0;
        if(diffSpeed > 0) {
            diffSpeed = SPEED_MAX - diffSpeed;
            dx = 64 * Math.cos(FlxAngle.TO_RAD * 90 * diffSpeed / SPEED_MAX);
        }
        return dx;
    }

    /**
     * 加速する
     **/
    public function addSpeed(v:Float) {
        _speed += v;

        if(_speed > _speedMax) {
            // 最大スピード更新
            _speedMax = _speed;
        }
        if(_speed < SPEED_START) {
            _speed = SPEED_START;
        }
    }

    /**
     * 同属性ブロック習得によるスピードアップ
     **/
    public function speedUp():Void {
        addSpeed(SPEED_ADD);
    }

    /**
     * 更新
     **/
    public function update():Void {
        if(_speed < SPEED_DEFAULT_MAX) {
            // デフォルトのスクロール速度上昇
            addSpeed(SPEED_ADD_DEFAULT);
        }
    }

    /**
     * 摩擦による速度減少
     **/
    public function friction():Void {
        if(_speed > SPEED_FRICTION_MIN) {
            _speed -= 0.2;
        }
    }

    /**
     * プレーキをかける
     **/
    public function brake():Void {
        _speed *= SPEED_STOP;
        if(_speed < SPEED_START) {
            _speed = SPEED_START;
        }
    }

    /**
     * ブロック衝突減速
     **/
    public function hitBlock():Void {
        _speed *= SPEED_MISS ;
        if(_speed < SPEED_START) {
            _speed = SPEED_START;
        }
    }
}

