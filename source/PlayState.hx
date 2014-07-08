package;

import effects.EffectPlayer;
import effects.EffectStart;
import token.StopSign;
import token.Player;
import token.Block;
import token.Ring;
import ui.HUD;
import ui.DialogUnlock;
import ui.ResultHUD;
import effects.EmitterBlockBlue;
import effects.EmitterBlockRed;
import effects.EmitterPlayer;
import effects.EmitterBrake;
import effects.EffectRing;
import jp_2dgames.TmxLoader;
import jp_2dgames.Layer2D;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flixel.util.FlxAngle;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import Attribute;
import flixel.util.FlxRect;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.group.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxState;

/**
 * 状態
 **/
private enum State {
    Start;          // 開始演出
    Main;           // メイン
    ChangeWait;     // 色変え演出中
    StageClearInit; // ステージクリア・初期化
    StageClearMain; // ステージクリア・メイン
    UnlockWait;     // ステージアンロック・ウィンドウ表示中
    GameoverInit;   // ゲームオーバー・初期化
    GameoverMain;   // ゲームオーバー・メイン
}

/**
 * メインゲーム
 */
class PlayState extends FlxState {

    // 定数
    private static inline var BACK_SCROLL_SPEED:Float = 0.1; // 背景スクロールの速さ
    private static inline var SPEED_START:Float = 50; // 開始時の速さ
    private static inline var SPEED_ADD:Float = 1; // ブロック衝突による速度の上昇
    private static inline var SPEED_MISS:Float = 0.9; // 異なるブロック衝突による速度の低下
    private static inline var SPEED_ADD_DEFAULT:Float = 0.3; // デフォルトでの速度上昇
    private static inline var SPEED_DEFAULT_MAX:Float = 100; // デフォルトでの速度上昇制限
    private static inline var SPEED_MAX:Float = 384; // 最大速度
    private static inline var SPEED_FRICTION_MIN:Float = 200; // 摩擦による最低速度
    private static inline var SPEED_STOP:Float = 0.97; // 停止標識の速度の低下

    // タイマー
    private static inline var TIMER_STAGE_CLEAR_INIT = 30;
    private static inline var TIMER_GAMEOVER_INIT = 30;
    private static inline var TIMER_CHANGE_WAIT = 100; // リング獲得時の停止タイマー
    private static inline var TIMER_CHANGE_WAIT_DEC = 3; // リング獲得時の停止タイマーの減少量
    private static inline var TIMER_CHANGE_WAIT_MIN = 4; // リング獲得時の停止タイマーの最低値
    private static inline var TIMER_DAMAGE = 30;
    private static inline var TIMER_FRICTION:Int = 30; // 摩擦タイマー
    private static inline var TIMER_STOP:Int = 30; // 停止タイマー

    // ゲームオブジェクト
    private var _player:Player;
    private var _follow:FlxSprite;
    private var _rings:FlxTypedGroup<Ring>;
    private var _blocks:FlxTypedGroup<Block>;
    private var _stopSigns:FlxTypedGroup<StopSign>;

    // エフェクト
    private var _eftPlayer:EffectPlayer;
    private var _emitterBlockBlue:EmitterBlockBlue;
    private var _emitterBlockRed:EmitterBlockRed;
    private var _emitterPlayer:EmitterPlayer;
    private var _emitterBrake:EmitterBrake;
    private var _eftStart:EffectStart;
    private var _eftRings:FlxTypedGroup<EffectRing>;

    // メッセージ
    private var _txtMessage:FlxText;

    // HUD
    private var _hud:HUD;

    // リザルト
    private var _result:ResultHUD;

    // アンロックウィンドウ
    private var _unlock:DialogUnlock;

    // マップ
    private var _tmx:TmxLoader;

    // 背景
    private var _back:FlxSprite;
    private var _back2:FlxSprite;

    // 変数
    private var _state:State; // 状態
    private var _timer:Int;   // 汎用タイマー
    private var _speed:Float; // 速度
    private var _scrollX:Float = 0; // スクロール
    private var _tDamage:Int   = 0; // ダメージによるペナルティ時間
    private var _combo:Int     = 0; // コンボ数
    private var _tFriction:Int = 0; // 摩擦タイマー
    private var _tChangeWait:Int = TIMER_CHANGE_WAIT; // リング獲得時の停止タイマー
    private var _tStop:Int     = 0; // 停止タイマー

    // リザルト用変数
    private var _cntBlock:Int   = 0; // ブロック破壊数
    private var _cntRing:Int    = 0; // リング獲得数
    private var _pasttime:Int   = 0; // 経過時間
    private var _comboMax:Int   = 0; // 最大コンボ数
    private var _speedMax:Float = 0; // 最大スピード

    // サウンド
    private var _seBlock:FlxSound = null;
    private var _seBlockPrev:Float = 0;

    /**
	 * 生成
	 */
    override public function create():Void {
        super.create();

        // 背景
        _back = new FlxSprite(0, 0);
        _back.loadGraphic("assets/images/back.png");
        _back.scrollFactor.set(0, 0);
        this.add(_back);
        _back2 = new FlxSprite(FlxG.width, 0);
        _back2.loadGraphic("assets/images/back.png");
        _back2.scrollFactor.set(0, 0);
        this.add(_back2);

        // マップ読み込み
        _tmx = new TmxLoader();
        var fTmx = "assets/levels/" + Reg.getLevelString() + ".tmx";
        _tmx.load(fTmx);

        // ゲームオブジェクト生成
        _player = new Player(32, FlxG.height/2);
        this.add(_player);
        _follow = new FlxSprite(_player.x+FlxG.width/2, _player.y);
        _follow.visible = false;
        this.add(_follow);

        // リング
        _rings = new FlxTypedGroup<Ring>(32);
        for(i in 0..._rings.maxSize) {
            _rings.add(new Ring());
        }
        this.add(_rings);

        // ブロック
        _blocks = new FlxTypedGroup<Block>(512);
        for(i in 0..._blocks.maxSize) {
            _blocks.add(new Block());
        }
        this.add(_blocks);

        // 停止標識
        _stopSigns = new FlxTypedGroup<StopSign>(32);
        for(i in 0..._stopSigns.maxSize) {
            _stopSigns.add(new StopSign());
        }
        this.add(_stopSigns);

        // エフェクト
        _eftPlayer = new EffectPlayer();
        this.add(_eftPlayer);

        // 開始エフェクト
        _eftStart = new EffectStart(FlxG.width/2-16, FlxG.height/2-16);
        this.add(_eftStart);

        // リング消滅エフェクト
        _eftRings = new FlxTypedGroup<EffectRing>(32);
        for(i in 0..._eftRings.maxSize) {
            _eftRings.add(new EffectRing());
        }
        this.add(_eftRings);

        // パーティクル
        _emitterBlockBlue = new EmitterBlockBlue();
        _emitterBlockRed = new EmitterBlockRed();
        _emitterPlayer = new EmitterPlayer();
        _emitterBrake = new EmitterBrake();
        this.add(_emitterBlockBlue);
        this.add(_emitterBlockRed);
        this.add(_emitterPlayer);
        this.add(_emitterBrake);

        // テキスト
        _txtMessage = new FlxText(0, FlxG.height/2-12, FlxG.width);
        _txtMessage.size = 24;
        _txtMessage.alignment = "center";
        _txtMessage.visible = false;
        _txtMessage.scrollFactor.set(0, 0);
        this.add(_txtMessage);

        // 変数初期化
        _state = State.Start;
        _timer = 0;
        _speed = SPEED_START;

        var width = _tmx.width * _tmx.tileWidth;
        var height = _tmx.height * _tmx.tileHeight;
        FlxG.camera.follow(_follow, FlxCamera.STYLE_NO_DEAD_ZONE);
        FlxG.camera.bounds = new FlxRect(0, 0, width, height);
        FlxG.worldBounds.set(0, 0, width, height);

        // HUD
        _hud = new HUD(_player, width, SPEED_MAX);
        this.add(_hud);

        _putObjects();

        // デバッグ用
        FlxG.debugger.toggleKeys = ["ALT"];
        FlxG.watch.add(this, "_state");
        FlxG.watch.add(this, "_timer");

        FlxG.watch.add(this, "_cntRing");
        FlxG.watch.add(this, "_cntBlock");
        FlxG.watch.add(this, "_comboMax");
        FlxG.watch.add(_player, "_hp");
    }

    /**
     * コンポ数を増やす
     **/
    private function _addCombo():Void {
        _combo++;
        _hud.setCombo(_combo);

        if(_combo > _comboMax) {
            // コンボ最大数更新
            _comboMax = _combo;
        }
    }

    /**
     * コンボ数をリセット
     **/
    private function _resetCombo():Void {
        _combo = 0;
        _hud.setCombo(_combo);
    }

    /**
	 * 破棄
	 */
    override public function destroy():Void {
        super.destroy();
    }

    /**
	 * 更新
	 */
    override public function update():Void {
        super.update();
        _hud.updateAll();

        switch(_state) {
            case State.Start: _updateStart();
            case State.Main: _updateMain();
            case State.ChangeWait: _updateChangeWait();
            case State.StageClearInit: _updateStageClearInit();
            case State.StageClearMain: _updateStageClearMain();
            case State.UnlockWait: _updateUnlockWait();
            case State.GameoverInit: _updateGameoverInit();
            case State.GameoverMain: _updateGameoverMain();
        }

        // デバッグ処理
        _updateDebug();
    }

    private function _setActiveAll(b:Bool):Void {
        _follow.active = b;
        _blocks.active = b;
        _rings.active = b;
    }

    /**
     * 色変えエフェクト再生開始
     **/
    private function _startChangeWait():Void {
        _state = State.ChangeWait;
        _timer = _tChangeWait;

        // 停止タイマーを減らす
        _tChangeWait -= TIMER_CHANGE_WAIT_DEC;
        if(_tChangeWait < TIMER_CHANGE_WAIT_MIN) {
            // 最低値チェック
            _tChangeWait = TIMER_CHANGE_WAIT_MIN;
        }

        _eftPlayer.start(_player.getAttribute(), _player.x, _player.y, _timer);

        _setActiveAll(false);
        // プレイヤーだけ止めずに速度だけ0にする
        _player.velocity.x = 0;
    }

    /**
     * 現在の視界に対応するオブジェクトを配置する
     **/
    private function _putObjects():Void {

        // ブロックの生成
        var createBlock = function(i, j, type:Attribute) {
            var x = i * _tmx.tileWidth;
            var y = j * _tmx.tileHeight;
            var b:Block = _blocks.recycle();
            b.init(type, x, y);
        }
        // リングの生成
        var createRing = function(i, j, type:Attribute) {
            var x = i * _tmx.tileWidth - (32/2) - (_tmx.tileWidth/2);
            var y = j * _tmx.tileHeight - (32/2) - (_tmx.tileHeight/2);
            var r:Ring = _rings.recycle();
            r.init(type, x, y);
        }
        // 一時停止標識の生成
        var createStopSign = function(i, j) {
            var x = i * _tmx.tileWidth;
            var y = j * _tmx.tileHeight;
            var s:StopSign = _stopSigns.recycle();
            s.init(x, y);
        }

        var layer:Layer2D = _tmx.getLayer(0);
        var px = Math.floor(FlxG.camera.scroll.x / _tmx.tileWidth);
        var w = Math.floor(FlxG.width / _tmx.tileWidth);
        w += 8; // 検索範囲を広めに取る
        for(j in 0..._tmx.height) {
            for(i in px...(px+w)) {
                switch(layer.get(i, j)) {
                    case 1: // 青ブロック
                        createBlock(i, j, Attribute.Blue);
                        layer.set(i, j, 0);
                    case 2: // 赤ブロック
                        createBlock(i, j, Attribute.Red);
                        layer.set(i, j, 0);
                    case 3: // 青リング
                        createRing(i, j, Attribute.Blue);
                        layer.set(i, j, 0);
                    case 4: // 赤リング
                        createRing(i, j, Attribute.Red);
                        layer.set(i, j, 0);
                    case 5: // 一時停止標識
                        createStopSign(i, j);
                        layer.set(i, j, 0);
                }
            }
        }
    }

    private function _setFolloPosition():Void {

        // カメラがフォローするオブジェクトの位置を調整
        var diffSpeed = SPEED_MAX - _speed;
        var dx:Float = 0;
        if(diffSpeed > 0) {
            diffSpeed = SPEED_MAX - diffSpeed;
            dx = 64 * Math.cos(FlxAngle.TO_RAD * 90 * diffSpeed / SPEED_MAX);
        }
        _follow.x = _player.x + FlxG.width/2 - dx;
    }

    private function _addSpeed(v:Float) {
        _speed += v;

        if(_speed > _speedMax) {
            // 最大スピード更新
            _speedMax = _speed;
        }
    }

    /**
     * 各種スクロール処理
     **/
    private function _updateScroll():Void {
        if(_tDamage > 0) {
            // ダメージペナルティ
            _tDamage--;
        }
        else {
            if(_speed < SPEED_DEFAULT_MAX) {
                // デフォルトのスクロール速度上昇
                _addSpeed(SPEED_ADD_DEFAULT);
            }
        }

        // プレイヤーをスクロールする
        _player.velocity.x = _speed;
        _follow.velocity.x = _speed;

        _setFolloPosition();

        // 背景をスクロールする
        _scrollX -= BACK_SCROLL_SPEED;
        if(_scrollX < -FlxG.width) {
            // 折り返す
            _scrollX += FlxG.width;
        }
        _back.x = _scrollX;
        _back2.x = _scrollX + FlxG.width;

        // ピンチチェック
        if(_back.color != FlxColor.WHITE) {
            _back.color = FlxColor.WHITE;
            _back2.color = FlxColor.WHITE;
        }
        if(_player.isDanger()) {
            // 背景を赤くする
            _back.color = FlxColor.RED;
            _back2.color = FlxColor.RED;
        }

    }

    /**
     * 更新・スタート
     **/
    private function _updateStart():Void {
        _setFolloPosition();
        if(_eftStart.isEnd()) {
            // ゲーム開始
            _state = State.Main;
            // 時間計測開始
            _hud.setIncTime(true);
        }
    }

    /**
     * 更新・メイン
     **/
    private function _updateMain():Void {

        // 摩擦タイマー更新
        if(_tFriction > 0) {
            _tFriction--;
        }
        else {
            // 速度減少
            if(_speed > SPEED_FRICTION_MIN) {
                _speed -= 0.2;
            }
        }

        if(_tStop > 0) {
            // 停止タイマー有効
            _speed *= SPEED_STOP;
            if(_speed < SPEED_START) {
                _speed = SPEED_START;
            }
            _tStop--;

            // 足もとからブレーキエフェクト生成
            var px = _player.x+_player.width/2;
            var py = _player.y+_player.height;
            _emitterBrake.explode(px, py);
        }

        // スクロール処理
        _updateScroll();

        // クリア判定
        if(FlxG.camera.scroll.x >= _tmx.width * _tmx.tileWidth - FlxG.width) {
            // クリア
            _state = State.StageClearInit;
            _timer = TIMER_STAGE_CLEAR_INIT;
            _txtMessage.text = "Stage Clear!";
            _txtMessage.visible = true;
            // 時間計測停止
            _hud.setIncTime(false);
            return;
        }
        if(_player.isDead()) {
            // プレイヤー死亡
            _player.vanish();
            _follow.kill();
            _state = State.GameoverInit;
            _timer = TIMER_GAMEOVER_INIT;
            // 画面を1秒間、白フラッシュします
            FlxG.camera.flash(0xffFFFFFF, 1);
            // 画面を5%の揺れ幅で0.35秒間、揺らします
            FlxG.camera.shake(0.05, 0.35);
            // エフェクト生成
            _emitterPlayer.explode(_player.x, _player.y);
            // メッセージ表示
            _txtMessage.text = "Game Over...";
            _txtMessage.visible = true;
            // 時間計測停止
            _hud.setIncTime(false);

            // サウンド再生
            FlxG.sound.play("kya");
            FlxG.sound.play("dead");
            if(FlxG.sound.music != null) {
                FlxG.sound.music.stop();
            }
            return;
        }

        // マップからオブジェクトを配置
        _putObjects();

        // 当たり判定
        FlxG.overlap(_player, _rings, _vsPlayerRing, _collideCircle);
        FlxG.overlap(_player, _blocks, _vsPlayerBlock, _collideCircleBlock);
        FlxG.overlap(_player, _stopSigns, _vsPlayerStop, _collideCircle);
    }

    private function _updateChangeWait():Void {
        if(_eftPlayer.isEnd()) {
            _setActiveAll(true);
            _state = State.Main;
        }
    }
    /**
     * ステージクリア
     **/
    private function _updateStageClearInit():Void {
        _timer--;
        if(_timer < 1) {
            _state = State.StageClearMain;
            _startResult();
        }
    }
    private function _updateStageClearMain():Void {
        if(_player.x > _tmx.width * _tmx.tileWidth) {
            _player.active = false;
        }
        if(FlxG.mouse.justPressed && _result.isEnd()) {
            if(_result.isNewLevel()) {
                // アンロックウィンドウをオープン
                _unlock = new DialogUnlock(Reg.level+1);
                this.add(_unlock);
                _state = State.UnlockWait;
            }
            else {
                FlxG.switchState(new MenuState());
            }
        }
    }

    /**
     * アンロックウィンドウのクローズ待ち
     **/
    private function _updateUnlockWait():Void {
        if(_player.x > _tmx.width * _tmx.tileWidth) {
            _player.active = false;
        }
        if(_unlock.isClose()) {
            FlxG.switchState(new MenuState());
        }
    }

    /**
     * リザルトの表示開始
     **/
    private function _startResult():Void {
        var pasttime:Int = _hud.getPastTime();
        _result = new ResultHUD(_cntRing, _cntBlock, _comboMax, _speed, pasttime, _speedMax);
        this.add(_result);
        Reg.playMusic("gameover", false);
    }

    /**
     * ゲームオーバー
     **/
    private function _updateGameoverInit():Void {
        _timer--;
        if(_timer < 1) {
            _state = State.GameoverMain;
            _startResult();
        }
    }
    private function _updateGameoverMain():Void {
        if(FlxG.mouse.justPressed && _result.isEnd()) {
            FlxG.switchState(new MenuState());
        }
    }

    // プレイヤー vs 色変えアイテム
    private function _vsPlayerRing(p:Player, v:Ring):Void {

        if(p.getAttribute() != v.getAttribute()) {
            // 色変え実行
            p.changeAttribute(v.getAttribute());
        }
        v.vanish();

        // 同じX座標にあるリングを削除
        _vanishRingX(v.x);

        FlxG.sound.play("kin");

        // リング獲得数アップ
        _cntRing++;

        _startChangeWait();

    }

    // プレイヤー vs ブロック
    private function _vsPlayerBlock(p:Player, b:Block):Void {

        if(p.getAttribute() == b.getAttribute()) {
            // スピードアップ
            _addSpeed(SPEED_ADD);
            // コンボ数アップ
            _addCombo();
            // 摩擦タイマーをリセット
            _tFriction = TIMER_FRICTION;
        }
        else {
            // ペナルティ
            _speed *= SPEED_MISS ;
            if(_speed < SPEED_START) {
                _speed = SPEED_START;
            }
            _tDamage = TIMER_DAMAGE;

            // ダメージ処理
            _player.damage();
            // コンボ終了
            _resetCombo();

            if(_hud.getPastTime() - _seBlockPrev > 20 ) {
                if(_seBlock != null) {
                    _seBlock.kill();
                }
                _seBlock = FlxG.sound.play("block");
                _seBlockPrev = _hud.getPastTime();
            }
        }

        if(b.getAttribute() == Attribute.Red) {
            _emitterBlockRed.explode(b.x, b.y);
        }
        else {
            _emitterBlockBlue.explode(b.x, b.y);
        }
        b.vanish();



        // ブロック破壊数アップ
        _cntBlock++;
    }

    /**
     * プレイヤ vs 停止標識
     **/
    private function _vsPlayerStop(p:Player, s:StopSign):Void {
        _tStop = TIMER_STOP;
        s.kill();
        FlxG.sound.play("brake");
    }

    /**
     * 円同士で当たり判定をする
     **/
    private function _collideCircle(spr1:FlxSprite, spr2:FlxSprite):Bool {

        var r1 = spr1.width/2;
        var r2 = spr2.width/2;
        var px1 = spr1.x + r1;
        var py1 = spr1.y + r1;
        var px2 = spr2.x + r2;
        var py2 = spr2.y + r2;
        var p1 = FlxPoint.get(px1, py1);
        var p2 = FlxPoint.get(px2, py2);
        var dist = FlxMath.getDistance(p1, p2);
        if(r1*r1 + r2*r2 >= dist*dist) {
            return true;
        }
        return false;
    }

    /**
     * プレイヤーとブロックの当たり判定
     **/
    private function _collideCircleBlock(p:Player, b:Block):Bool {

        var r1 = p.width/2;
        if(p.getAttribute() == b.getAttribute()) {
            // 同じ属性なら大きめに取る
            r1 = p.width * 0.6;
        }
        var r2 = b.width/2;
        var px1 = p.x + r1;
        var py1 = p.y + r1;
        var px2 = b.x + r2;
        var py2 = b.y + r2;
        var p1 = FlxPoint.get(px1, py1);
        var p2 = FlxPoint.get(px2, py2);
        var dist = FlxMath.getDistance(p1, p2);
        if(r1*r1 + r2*r2 >= dist*dist) {
            return true;
        }
        return false;
    }

    /**
     * X座標が一致するリングを消す
     * @param x 検索するX座標
     **/
    private function _vanishRingX(x:Float):Void {

        var check = function(r:Ring) {
            if(r.x == x) {
                r.vanish();
                var eft:EffectRing = _eftRings.recycle();
                eft.init(r.getAttribute(), r.x, r.y);
            }
        }

        _rings.forEachAlive(check);
    }

    /**
     * 更新・デバッグ
     **/
    private function _updateDebug():Void {

    #if !FLX_NO_DEBUG
        if(FlxG.keys.justPressed.ESCAPE) {
            throw "Terminate.";
        }

        if(FlxG.keys.justPressed.SPACE) {
            _player.reverseAttribute();
        }

        if(FlxG.keys.justPressed.R) {
            FlxG.resetState();
        }
        if(FlxG.keys.justPressed.E) {
            // セーブデータ初期化
            Reg.clear();
        }

        if(FlxG.keys.pressed.RIGHT) {
            // 右キーでスピードアップ
            _speed += 10;
        }
        if(FlxG.keys.pressed.LEFT) {
            // 左キーでスピードダウン
            _speed -= 10;
            if(_speed < SPEED_START) {
                _speed = SPEED_START;
            }
        }
        if(FlxG.keys.justPressed.D) {
            // 自爆
            _player.damage(99999);
        }
    #end
    }
}