package token;
import flixel.util.loaders.TexturePackerData;
import flixel.util.FlxTimer;
import csv.CsvPlayer;
import Math;
import flash.events.AccelerometerEvent;
import flash.sensors.Accelerometer;
import flixel.util.FlxColor;
import flixel.addons.effects.FlxTrail;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * プレイヤー
 **/
class Player extends FlxSprite {

    // 定数
    private static inline var MOVE_DECAY = 0.9;
    private static inline var MOVE_REVISE = 5;
    private static inline var TIMER_DAMAGE = 30;
    private static inline var DAMAGE_INIT = 2; // 初期ダメージ
    private static inline var DAMAGE_MAX = 40; // 最大ダメージ
    private static inline var DAMAGE_CNT = 28; // 最大ダメージに到達するまでの連続ヒット数
    private static inline var DANGER_RATIO = 0.3; // 危険状態とするスピード

    // 変数
    private var _speed:Float; // スピード
    private var _attr:Attribute; // 属性
    private var _trailBlue:FlxTrail; // ブラー(青)
    private var _trailRed:FlxTrail; // ブラー(赤)
    private var _tDamage:Int; // ダメージタイマー
    private var _cntHit:Int; // 蓄積ダメージ数
    private var _tAnime:Int; // アニメ用タイマー
    private var _eftAttribute:FlxSprite; // 属性エフェクト
    private var _star:FlxSprite; // 無敵エフェクト
    private var _width:Float; // 元の幅
    private var _height:Float; // 元の高さ

    // 状態フラグ
    private var _bBig:Bool   = false; // 拡大フラグ
    private var _bSmall:Bool = false; // 縮小フラグ
    private var _bStar:Bool  = false; // 無敵フラグ
    private var _nShield:Int = 0; // シールドの有効回数
    private var _bDash:Bool  = false; // ダッシュフラグ
    private var _tBig:FlxTimer = null;
    private var _tSmall:FlxTimer = null;
    private var _tStar:FlxTimer = null;
    private var _tDash:FlxTimer = null;
    private var _bStop:Bool = false; // 動かせないフラグ

    // 重力アイテム
    private var _bGravity:Bool = false; // 近くに重力アイテムがあるかどうか
    private var _gravityX:Float = 0;    // 重力アイテムにより引っ張られる力（X）
    private var _gravityY:Float = 0;    // 重力アイテムにより引っ張られる力（Y）

    // タッチ情報
    private var _touchId:Int; // 現在のタッチID
    private var _touchStartX:Float; // タッチ開始X座標
    private var _touchStartY:Float; // タッチ開始Y座標

    // 加速度センサー
    private var _accelerometer:Accelerometer;
    private var _accelerometerY:Float = 0;

    // パラメータ
    private var _csv:CsvPlayer;
    private var _shield:Shield;

    /**
     * 生成
     **/
    public function new(px:Float, py:Float, shield:Shield) {
        super(px, py);
        _shield = shield;
        _shield.kill();

        var tex = new TexturePackerData("assets/images/player.json", "assets/images/player.png");
        loadGraphicFromTexture(tex);

        _width = width;
        _height = height;

        animation.add("blue", [0]);
        animation.add("red", [1]);
        animation.add("blue2", [ 2, 4, 6, 4, 2], 16);
        animation.add("red2", [ 3, 5, 7, 5, 3], 16);

        _eftAttribute = new FlxSprite();
        _eftAttribute.loadGraphic("assets/images/attribute.png", true);
        _eftAttribute.animation.add("blue", [0]);
        _eftAttribute.animation.add("red", [1]);
        _eftAttribute.alpha = 0.8;
        FlxG.state.add(_eftAttribute);

        _star = new FlxSprite();
        _star.loadGraphic("assets/images/star.png");
        _star.angularVelocity = 200;
        _star.kill();

        _setScale(1, width, height);

        _speed = 100;
        _attr = Attribute.Blue;
        immovable = true;

        animation.play("red");
        _trailRed = new FlxTrail(this);
        FlxG.state.add(_trailRed);
        _trailRed.kill();
        animation.play("blue");
        _eftAttribute.animation.play("blue");

        _trailBlue = new FlxTrail(this);
        FlxG.state.add(_trailBlue);

        _tDamage = 0;
        _cntHit = 0;
        _tAnime = 0;

        if(Accelerometer.isSupported) {
            // 加速度センサー有効
            _accelerometer = new Accelerometer();
            _accelerometer.setRequestedUpdateInterval(50);
            _accelerometer.addEventListener(AccelerometerEvent.UPDATE, onUpdateAccelerometer);
//            FlxG.watch.add(this, "_accelerometerY");
//            FlxG.debugger.visible = true;
        }
    }

    private function _setScale(sc:Float, w:Float, h:Float):Void {
        scale.set(sc, sc);
        width = w;
        height = h;
        centerOffsets();

        _eftAttribute.scale.set(sc, sc);
        _eftAttribute.width = w;
        _eftAttribute.height = h;
        _eftAttribute.centerOffsets();

        _star.scale.set(sc, sc);
        _star.width = w;
        _star.height = h;
        _star.centerOffsets();
    }

    public function getStar():FlxSprite {
        return _star;
    }
    public function isStar():Bool {
        return _bStar;
    }

    /**
     * 重力アイテムの情報を設定する
     * @param b 近くに重力アイテムがあるかどうか
     * @param dx 重力アイテムにより引っ張られる力（X）
     * @param dy 重力アイテムにより引っ張られる力（Y）
     **/
    public function setGravity(b:Bool, dx:Float, dy:Float):Void {
        _bGravity = b;
        _gravityX = dx;
        _gravityY = dy;
    }

    public function onUpdateAccelerometer(e:AccelerometerEvent):Void {
        var d = (e.accelerationX * 100 - 58); // 中央
        var sign = 1;
        if(d < 0) { sign = -1; } // 符号
        if(d < -15) { d = -15; } // 速度制限
        if(d > 15) { d = 15; }
        _accelerometerY += sign * Math.abs(d) * 5;
        _accelerometerY *= 0.75; // 減衰

        // さらに速度制限
        if(_accelerometerY > 300) { _accelerometerY = 300; }
        if(_accelerometerY < -300) { _accelerometerY = -300; }
    }

    // スピードの設定
    public function setSpeed(v:Float):Void { _speed = v; }
    // 属性の取得
    public function getAttribute():Attribute { return _attr; }
    // スピードの割合の取得
    public function getSpeedRatio():Float { return 1.0; }
    // 死亡しているかどうか
    public function isDead():Bool { return _speed <= 0; }
    // 危険チェック
    public function isDanger():Bool { return getSpeedRatio() < DANGER_RATIO; }
    // ブレーキボタンを押しているかどうかチェック
    public function isOnBrake():Bool {
        if(FlxG.mouse.pressed) {
            return true;
        }

        return false;
    }
    // CSVパラメータを設定
    public function setCsvPlayer(csv:CsvPlayer):Void { _csv = csv; }
    // 加速が有効かどうか
    public function isDash():Bool { return _bDash; }

    /**
     * 更新
     **/
    override public function update():Void {
        super.update();

        _eftAttribute.x = x;
        _eftAttribute.y = y;
        _star.x = x;
        _star.y = y;
        _shield.x = width + x;
        _shield.y = y;

        // 画面外に出ないようする
        if(y < 0) { y = 0; _accelerometerY *= 0.8; }
        if(y > FlxG.height-16) { y = FlxG.height-16; _accelerometerY *= 0.8; }

        if(_bStop) {
            // 動かせない
            // 特定位置に近づける
            var targetX = FlxG.camera.scroll.x + 32;
            var dx = targetX - x;
            x += dx * 0.05;
            return;
        }

#if FLX_NO_TOUCH
        // マウスの座標に向かって移動する
        var p = FlxG.mouse.getWorldPosition();

        var dx = p.x - (x + width/2);
        var dy = p.y - (y + height/2);
        dx *= MOVE_DECAY * MOVE_REVISE;
        dy *= MOVE_DECAY * MOVE_REVISE;
#elseif FLASH
        // マウスの座標に向かって移動する
        var p = FlxG.mouse.getWorldPosition();

        var dx = p.x - (x + width/2);
        var dy = p.y - (y + height/2);
        dx *= MOVE_DECAY * MOVE_REVISE;
        dy *= MOVE_DECAY * MOVE_REVISE;
#else
        var dx:Float = 0;
        var dy:Float = 0;

        // 加速度センサーを使う
        var dy = _accelerometerY;
#end
//        velocity.set(dx, dy);
        velocity.y = dy;

        if(_bGravity) {
            // 重力アイテムが近くにある
            velocity.y += _gravityY;
        }

        // ダメージタイマー
        if(_tDamage > 0) {
            visible = _tDamage%4 < 2;
            _tDamage--;
        }

        _tAnime++;
        // ピンチ状態の更新
        if(color != FlxColor.WHITE) {
            color = FlxColor.WHITE;
        }
        if(getSpeedRatio() < DANGER_RATIO) {
            if(_tAnime%24 < 12) {
                color = FlxColor.RED;
            }
        }
    }

    public function vanish():Void {
        kill();
        _eftAttribute.kill();
        _star.kill();
        _trailBlue.kill();
        _trailRed.kill();
    }

    public function getHitCount():Int {
        return _cntHit;
    }

    /**
     * シールドの有効チェック
     * @return シールドが残っていればtrue
     **/
    public function checkShield():Bool {
        if(_nShield <= 0) {
            return false;
        }

        _nShield--;
        if(_nShield <= 0) {
            _shield.kill();
        }
        else {
            _shield.blink();
        }
        return true;
    }

    /**
     * ダメージ処理
     * @param v ダメージ量
     **/
    public function damage(v:Float=DAMAGE_INIT):Void {

        if(_tDamage > 0) {
            // 連続ダメージなのでペナルティ
            var diff:Float = (DAMAGE_MAX - DAMAGE_INIT) / DAMAGE_CNT;
            var val = v + diff * _cntHit;
            _speed -= val;
            _cntHit++;
            // 連続ダメージでは死なない
            if(_speed < 0) {
                _speed = 1;
            }
        }
        else {
            // 初期ダメージ
            _speed -= v;
            _tDamage = TIMER_DAMAGE;
            _cntHit = 1;
        }
        _speed = if(_speed < 0) 0 else _speed;
    }


    /**
     * 属性チェンジ
     * @param 属性
     **/
    public function changeAttribute(attr:Attribute):Void {
        _attr = attr;
        var name:String = "blue";
        _trailBlue.kill();
        _trailRed.kill();
        if(_attr == Attribute.Red) {
            name = "red";
            _trailRed.revive();
        }
        else {
            _trailBlue.revive();
        }
        animation.play(name);
        _eftAttribute.animation.play(name);
        _shield.setAttribute(_attr);
    }

    /**
     * 属性を反転させる
     **/
    public function reverseAttribute():Void {

        if(_attr == Attribute.Blue) {
            changeAttribute(Attribute.Red);
        }
        else {
            changeAttribute(Attribute.Blue);
        }
    }

    /**
     * 巨大化開始
     **/
    public function startBig():Void {

        var size = _csv.item_big_size;
        _setScale(size, _width*size, _height*size);

        _bBig = true;
        _bSmall = false;
        if(_tBig != null) {
            _tBig.destroy();
        }
        if(_tSmall != null) {
            _tSmall.destroy();
        }
        _tBig = new FlxTimer(_csv.item_big_timer, _CB_endBig);
    }

    /**
     * 縮小開始
     **/
    public function startSmall():Void {

        var size = _csv.item_small_size;
        _setScale(size, _width*size, _height*size);

        _bBig = false;
        _bSmall = true;
        if(_tBig != null) {
            _tBig.destroy();
        }
        if(_tSmall != null) {
            _tSmall.destroy();
        }
        _tSmall = new FlxTimer(_csv.item_small_timer, _CB_endSmall);
    }

    /**
     * 無敵開始
     **/
    public function startStar():Void {

        _star.revive();

        _bStar = true;
        if(_tStar != null) {
            _tStar.destroy();
        }
        _tStar = new FlxTimer(_csv.item_star_timer, _CB_endStar);
    }

    /**
     * シールドアイテム有効開始
     **/
    public function startShield():Void {

        _shield.revive();
        _nShield =  _csv.item_shield_count;
    }

    /**
     * 加速開始
     **/
    public function startDash():Void {

        _bDash = true;
        if(_tDash != null) {
            _tDash.destroy();
        }
        _tDash = new FlxTimer(_csv.item_dash_timer, _CB_endDash);
    }

    // ■各種数量用コールバック関数
    // 拡大終了
    private function _CB_endBig(timer:FlxTimer):Void {
        if(_bBig == false) { return; }

        _setScale(1, _width, _height);
        _bBig = false;
    }
    // 縮小終了
    private function _CB_endSmall(timer:FlxTimer):Void {
        if(_bSmall == false) { return; }

        _setScale(1, _width, _height);
        _bSmall = false;
    }
    // 無敵終了
    private function _CB_endStar(timer:FlxTimer):Void {
        if(_bStar == false) { return; }

        _star.kill();
        _bStar = false;
    }
    // 加速終了
    private function _CB_endDash(timer:FlxTimer):Void {
        if(_bDash == false) { return; }

        _bDash = false;
    }

    public function startResult():Void {

        // 移動しないようにする
        velocity.set(0, 0);
        _bStop = true;
    }

    public function playResult():Void {

        if(getAttribute() == Attribute.Red) {
            animation.play("red2");
        }
        else {
            animation.play("blue2");
        }
    }

    public function endResult():Void {
        if(getAttribute() == Attribute.Red) {
            animation.play("red");
        }
        else {
            animation.play("blue");
        }
    }
}
