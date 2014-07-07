package ;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
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
    private static inline var HP_MAX = 100;
    private static inline var HP_RECOVER = 1; // デフォルトのHP回復量
    private static inline var TIMER_DAMAGE = 30;
    private static inline var DAMAGE_INIT = 2; // 初期ダメージ
    private static inline var DAMAGE_MAX = 40; // 最大ダメージ
    private static inline var DAMAGE_CNT = 28; // 最大ダメージに到達するまでの連続ヒット数
    private static inline var DANGER_RATIO = 0.3; // 危険状態とするHPの残量

    // 変数
    private var _attr:Attribute; // 属性
    private var _trailBlue:FlxTrail; // ブラー(青)
    private var _trailRed:FlxTrail; // ブラー(赤)
    private var _hp:Float; // 体力
    private var _tDamage:Int; // ダメージタイマー
    private var _barHp:FlxBar; // 体力バー
    private var _cntHit:Int; // 蓄積ダメージ数
    private var _tAnime:Int; // アニメ用タイマー
    private var _eftAttribute:FlxSprite; // 属性エフェクト

    // タッチ情報
    private var _touchId:Int; // 現在のタッチID
    private var _touchStartX:Float; // タッチ開始X座標
    private var _touchStartY:Float; // タッチ開始Y座標

    /**
     * 生成
     **/
    public function new(px:Float, py:Float) {
        super(px, py);

        loadGraphic("assets/images/player.png", true);

        animation.add("blue", [0]);
        animation.add("red", [1]);

        _eftAttribute = new FlxSprite();
        _eftAttribute.loadGraphic("assets/images/attribute.png", true);
        _eftAttribute.animation.add("blue", [0]);
        _eftAttribute.animation.add("red", [1]);
        _eftAttribute.alpha = 0.8;
        FlxG.state.add(_eftAttribute);

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

        _hp = HP_MAX;
        _tDamage = 0;
        _cntHit = 0;
        _tAnime = 0;
    }

    // 属性の取得
    public function getAttribute():Attribute { return _attr; }
    // HPの割合の取得
    public function getHpRatio():Float { return 1.0 * _hp / HP_MAX; }
    // 死亡しているかどうか
    public function isDead():Bool { return _hp <= 0; }
    // 危険チェック
    public function isDanger():Bool { return getHpRatio() < DANGER_RATIO; }
    // HPバー
    public function setHpBar(bar:FlxBar) { _barHp = bar; }

    /**
     * 更新
     **/
    override public function update():Void {
        super.update();
        // エフェクトの位置を更新
        _eftAttribute.x = x - 16;
        _eftAttribute.y = y - 16;

        // 画面外に出ないようする
        if(y < 0) { y = 0; }
        if(y > FlxG.height-16) { y = FlxG.height-16; }

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

        // マルチタッチは無効
        /*
        for(touch in FlxG.touches.list) {
            if(touch.justPressed) {
                // タッチIDを格納
                _touchId = touch.touchPointID;
                _touchStartX = touch.screenX;
                _touchStartY = touch.screenY;
            }

            if(touch.touchPointID != _touchId) {
                // 最後のタッチのみ判定
                continue;
            }
            var tx = touch.screenX;
            var ty = touch.screenY;

            var dx2 = tx - _touchStartX;
            var dy2 = ty - _touchStartY;
            dx2 *= FlxG.updateFramerate * 0.2;
            dy2 *= FlxG.updateFramerate * 0.2;
            dx = velocity.x + dx2;
            dy = velocity.y + dy2;
            dx *= 0.9;
            dy *= 0.9;

            _touchStartX = tx;
            _touchStartY = ty;
        }
        */
        // 無効化ここまで

        // シングルタッチのみ
        if(FlxG.mouse.justPressed) {
            // タッチ開始座標を保存する
            var p = FlxG.mouse.getWorldPosition();
            _touchStartX = p.x;
            _touchStartY = p.y;
        }
        else if(FlxG.mouse.pressed) {
            var p = FlxG.mouse.getWorldPosition();
            var dx2 = p.x - _touchStartX;
            var dy2 = p.y - _touchStartY;
            dx2 *= FlxG.updateFramerate * 0.2;
            dy2 *= FlxG.updateFramerate * 0.2;
            dx = velocity.x + dx2;
            dy = velocity.y + dy2;
            dx *= 0.9;
            dy *= 0.9;

            _touchStartX = p.x;
            _touchStartY = p.y;
        }
        // シングルタッチ処理はここまで
#end
//        velocity.set(dx, dy);
        velocity.y = dy;

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
        if(getHpRatio() < DANGER_RATIO) {
            if(_tAnime%24 < 12) {
                color = FlxColor.RED;
            }
        }

        // 体力バーの更新
        if(_hp == HP_MAX) {
            _barHp.visible = false;
        }
        else {
            _barHp.visible = true;
            _barHp.percent = getHpRatio() * 100;
            _barHp.x = x;
            _barHp.y = y + 30;
        }
    }

    public function vanish():Void {
        kill();
        _eftAttribute.kill();
        _trailBlue.kill();
        _trailRed.kill();
    }

    /**
     * HP回復
     **/
    public function addHp(v:Float=HP_RECOVER):Void {
        _hp += v;
        _hp = if(_hp > HP_MAX) HP_MAX else _hp;
    }

    /**
     * ダメージ処理
     * @param v ダメージ量
     **/
    public function damage(v:Int=DAMAGE_INIT):Void {

        if(_tDamage > 0) {
            // 連続ダメージなのでペナルティ
            var diff:Float = (DAMAGE_MAX - DAMAGE_INIT) / DAMAGE_CNT;
            var val = v + diff * _cntHit;
            _hp -= val;
            _cntHit++;
            // 連続ダメージでは死なない
            if(_hp < 0) {
                _hp = 1;
            }
        }
        else {
            // 初期ダメージ
            _hp -= v;
            _tDamage = TIMER_DAMAGE;
            _cntHit = 1;
        }
        _hp = if(_hp < 0) 0 else _hp;
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
}
