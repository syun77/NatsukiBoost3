package;

import token.Wefers;
import flixel.util.FlxRandom;
import effects.EffectBomb;
import token.Shield;
import token.Item;
import token.Item;
import token.FieldMap;
import util.Snd;
import csv.CsvTopSpeed;
import csv.CsvPlayer;
import effects.Back;
import effects.EffectPlayer;
import effects.EffectStart;
import token.Player;
import token.Block;
import ui.HUD;
import ui.DialogUnlock;
import ui.ResultHUD;
import effects.EmitterBlockBlue;
import effects.EmitterBlockRed;
import effects.EmitterPlayer;
import effects.EmitterBrake;
import effects.EffectRing;
import jp_2dgames.Layer2D;
import flixel.system.FlxSound;
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
    // タイマー
    private static inline var TIMER_STAGE_CLEAR_INIT = 30;
    private static inline var TIMER_GAMEOVER_INIT = 30;
    private static inline var TIMER_CHANGE_WAIT = 100; // リング獲得時の停止タイマー
    private static inline var TIMER_CHANGE_WAIT_DEC = 3; // リング獲得時の停止タイマーの減少量
    private static inline var TIMER_CHANGE_WAIT_MIN = 4; // リング獲得時の停止タイマーの最低値

    // ゲームオブジェクト
    private var _player:Player;
    private var _shield:Shield;
    private var _follow:FlxSprite;
    private var _items:FlxTypedGroup<Item>;
    private var _blocks:FlxTypedGroup<Block>;
    private var _weferses:FlxTypedGroup<Wefers>;

    // スピード管理
    private var _speedCtrl:SpeedController;

    // エフェクト
    private var _eftPlayer:EffectPlayer;
    private var _emitterBlockBlue:EmitterBlockBlue;
    private var _emitterBlockRed:EmitterBlockRed;
    private var _emitterPlayer:EmitterPlayer;
    private var _emitterBrake:EmitterBrake;
    private var _eftStart:EffectStart;
    private var _eftRings:FlxTypedGroup<EffectRing>;
    private var _eftBombs:FlxTypedGroup<EffectBomb>;

    // メッセージ
    private var _txtMessage:FlxText;

    // HUD
    private var _hud:HUD;

    // リザルト
    private var _result:ResultHUD;

    // アンロックウィンドウ
    private var _unlock:DialogUnlock;

    // マップ
    private var _field:FieldMap;

    // 背景
    private var _back:Back;

    // 変数
    private var _state:State; // 状態
    private var _timer:Int;   // 汎用タイマー
    private var _combo:Int     = 0; // コンボ数
    private var _tChangeWait:Int = TIMER_CHANGE_WAIT; // リング獲得時の停止タイマー
    private var _cntSameBlock  = 0; // 同属性のブロックを破壊した数

    // リザルト用変数
    private var _cntBlock:Int   = 0; // ブロック破壊数
    private var _cntRing:Int    = 0; // リング獲得数
    private var _pasttime:Int   = 0; // 経過時間
    private var _comboMax:Int   = 0; // 最大コンボ数

    // 各種パラメータ
    private var _csvTopSpeed:CsvTopSpeed;
    private var _csvPlayer:CsvPlayer;

    /**
	 * 生成
	 */
    override public function create():Void {
        super.create();

        // 背景
        _back = new Back();
        this.add(_back);

        // マップ読み込み
        _field = new FieldMap();

        // ゲームオブジェクト生成
        // シールド
        _shield = new Shield();
        this.add(_shield);
        // プレイヤー
        _player = new Player(32, FlxG.height/2, _shield);
        this.add(_player);
        this.add(_player.getStar());
        _follow = new FlxSprite(_player.x+FlxG.width/2, _player.y);
        _follow.visible = false;
        this.add(_follow);

        // アイテム
        _items = new FlxTypedGroup<Item>(64);
        for(i in 0..._items.maxSize) {
            _items.add(new Item());
        }
        this.add(_items);

        // ブロック
        _blocks = new FlxTypedGroup<Block>(512);
        for(i in 0..._blocks.maxSize) {
            _blocks.add(new Block());
        }
        this.add(_blocks);

        // ウエハース
        _weferses = new FlxTypedGroup<Wefers>(512);
        for(i in 0..._weferses.maxSize) {
            _weferses.add(new Wefers(_player));
        }
        this.add(_weferses);

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

        // ボムエフェクト
        _eftBombs = new FlxTypedGroup<EffectBomb>(64);
        for(i in 0..._eftBombs.maxSize) {
            _eftBombs.add(new EffectBomb());
        }
        this.add(_eftBombs);

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

        // 各種パラメータ
        _csvTopSpeed = new CsvTopSpeed();
        _csvPlayer = new CsvPlayer();
        _player.setCsvPlayer(_csvPlayer);

        // 変数初期化
        _state = State.Start;
        _timer = 0;

        // スピード管理
        _speedCtrl = new SpeedController(_csvPlayer);

        var width = _field.getRealWidth();
        var height = _field.getRealHeight();
        FlxG.camera.follow(_follow, FlxCamera.STYLE_NO_DEAD_ZONE);
        FlxG.camera.bounds = new FlxRect(0, 0, width, height);
        FlxG.worldBounds.set(0, 0, width, height);

        // HUD
        _hud = new HUD(_player, _speedCtrl, width);
        this.add(_hud);

        // 各種オブジェクト生成
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
        _items.active = b;
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
            var x = _field.toRealX(i);
            var y = _field.toRealY(j);
            var b:Block = _blocks.recycle();
            b.init(type, x, y);
        }
        // アイテムの生成
        var createItem = function(i, j, id:Int) {
            var x = _field.toRealX(i, 32);
            var y = _field.toRealY(j, 32);
            if(id == 36) {
                // 重力アイテムだけ48x48
                x = _field.toRealX(i, 48);
                y = _field.toRealY(j, 48);
            }
            var item:Item = _items.recycle();
            item.init(id, x, y);
        }

        var layer:Layer2D = _field.getLayer(0);
        var px = Math.floor(FlxG.camera.scroll.x / _field.tileWidth);
        var w = Math.floor(FlxG.width / _field.tileWidth);
        w += 8; // 検索範囲を広めに取る
          for(j in 0..._field.height) {
            for(i in px...(px+w)) {
                var id = layer.get(i, j);
                switch(layer.get(i, j)) {
                    case 1: // 青ブロック
                        createBlock(i, j, Attribute.Blue);
                        layer.set(i, j, 0);
                    case 2: // 赤ブロック
                        createBlock(i, j, Attribute.Red);
                        layer.set(i, j, 0);
                    case 3,4,17,18,19,20,21,33,34,35,36: // アイテム
                        createItem(i, j, id);
                        layer.set(i, j, 0);
                }
            }
        }
    }

    private function _setFolloPosition():Void {

        // カメラがフォローするオブジェクトの位置を調整
        var dx:Float = _speedCtrl.getFollowOffsetX();
        _follow.x = _player.x + FlxG.width/2 - dx;
    }

    private function _addSpeed(v:Float) {
        _speedCtrl.add(v);
    }

    /**
     * 各種スクロール処理
     **/
    private function _updateScroll():Void {

        // スピード更新
        _speedCtrl.update();

        // プレイヤーをスクロールする
        _player.velocity.x = _speedCtrl.getNow();
        _follow.velocity.x = _speedCtrl.getNow();

        _setFolloPosition();

        // 背景の更新
        _back.setDanger(_player.isDanger());

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
     * 更新・ボム
     **/
    private function _updateBomb():Void {
        if(_eftBombs.countLiving() > 0) {
            var check = function(b:Block):Void {
                if(b.isOnScreen()) {
                    var w:Wefers = _weferses.recycle();
                    w.init(b.getAttribute(), b.x, b.y);
                    b.vanish();
                }
            }

            // 画面内のブロックを消去
            _blocks.forEachAlive(check);
        }
    }

    /**
     * 更新・メイン
     **/
    private function _updateMain():Void {

        if(_player.isOnBrake()) {
            // ブレーキをかける
            _speedCtrl.setBrakeTimer(1);
            Snd.playSe("brake", true);
        }

        if(_speedCtrl.isBrake()) {
            // ブレーキ中
            // 足もとからブレーキエフェクト生成
            var px = _player.x+_player.width/2;
            var py = _player.y+_player.height;
            _emitterBrake.explode(px, py);
        }

        // スクロール処理
        _updateScroll();

        // ボムの処理
        _updateBomb();

        // クリア判定
        if(FlxG.camera.scroll.x >= _field.getRealWidth() - FlxG.width) {
            // クリア
            _state = State.StageClearInit;
            _timer = TIMER_STAGE_CLEAR_INIT;
            _txtMessage.text = "Stage Clear!";
            _txtMessage.visible = true;
            // 時間計測停止
            _hud.setIncTime(false);
            return;
        }
        if(_speedCtrl.getTop() <= _csvPlayer.speedtop_deadline) {
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
            Snd.playSe("kya");
            Snd.playSe("dead");
            if(FlxG.sound.music != null) {
                FlxG.sound.music.stop();
            }
            return;
        }

        // マップからオブジェクトを配置
        _putObjects();

        // 当たり判定
        FlxG.overlap(_player, _items, _vsPlayerItem, _collideCircle);
        FlxG.overlap(_player, _blocks, _vsPlayerBlock, _collideCircleBlock);
        FlxG.overlap(_player, _weferses, _vsPlayerWefers);
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
        if(_player.x > _field.getRealWidth()) {
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
        if(_player.x > _field.getRealWidth()) {
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
        _result = new ResultHUD(_cntRing, _cntBlock, _comboMax, _speedCtrl.getNow(), pasttime, _speedCtrl.getMax());
        this.add(_result);
        Snd.playMusic("gameover", false);
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

    // プレイヤー vs アイテム
    private function _vsPlayerItem(p:Player, item:Item):Void {

        switch(item.getID()) {
        case ItemID.Ring:
            if(p.getAttribute() != item.getAttribute()) {
                // 色変え実行
                p.changeAttribute(item.getAttribute());
            }
            item.vanish();

            // 同じX座標にあるリングを削除
            _vanishRingX(item.x);

            Snd.playSe("kin");

            // リング獲得数アップ
            _cntRing++;

            _startChangeWait();

        case ItemID.Big:
            _player.startBig();
            item.vanish();

        case ItemID.Small:
            _player.startSmall();
            item.vanish();

        case ItemID.Star:
            _player.startStar();
            item.vanish();

        case ItemID.Damage:
            _damage(_csvPlayer.item_damage_val);
            item.vanish();

        case ItemID.Shield:
            _player.startShield();
            item.vanish();

        case ItemID.Bomb:
            _startBomb();
            item.vanish();

        default:
            // 何もしない
        }

    }

    private function _damage(v:Float=0):Void {

        if(_player.isStar()) {
            // 無敵なのでノーダメージ
            return;
        }
        if(_player.checkShield()) {
            // シールドでガード
            return;
        }

        if(v == 0) {
            _player.damage();
        }
        else {
            _player.damage(v);
        }

        // ペナルティ
        _speedCtrl.hitBlock(_player.getHitCount(), v);
        _speedCtrl.setWaitTimer(_csvPlayer.damage_timer);

        // コンボ終了
        _resetCombo();

        Snd.playSe("block", true, 0.05);
    }

    private function _getBlock():Void {
        // スピードアップ
        _cntSameBlock++;

        // トップスピード上昇判定
        _csvTopSpeed.update(_speedCtrl.getTop());
        //            trace("" + _cntSameBlock + "/" + _csvTopSpeed.getCount() + " -> " + _csvTopSpeed.getValue());
        if(_cntSameBlock >= _csvTopSpeed.getCount()) {
            // トップスピードアップ
            _speedCtrl.addTop(_csvTopSpeed.getValue());
            _cntSameBlock = 0;
        }
        // コンボ数アップ
        _addCombo();

        Snd.playSe("eat", true, _csvPlayer.eat_se_timer);

    }

    // プレイヤー vs ブロック
    private function _vsPlayerBlock(p:Player, b:Block):Void {

        if(p.getAttribute() == b.getAttribute()) {
            _getBlock();
        }
        else {
            // ダメージ処理
            _damage();
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
     * プレイヤーとウエハースとの衝突
     **/
    private function _vsPlayerWefers(p:Player, w:Wefers):Void {
        _getBlock();
        w.kill();
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

        var check = function(item:Item) {
            if(item.getID() == ItemID.Ring && item.x == x) {
                item.vanish();
                var eft:EffectRing = _eftRings.recycle();
                eft.init(item.getAttribute(), item.x, item.y);
            }
        }

        _items.forEachAlive(check);
    }

    /**
     * ボムエフェクト開始
     **/
    private function _startBomb():Void {
        for(i in  0..._eftBombs.maxSize) {
            var b:EffectBomb = _eftBombs.recycle();
            var px = FlxG.camera.scroll.x + FlxRandom.intRanged(0, FlxG.width);
            var py = FlxG.camera.scroll.y + FlxRandom.intRanged(0, FlxG.height);
            b.start(px, py);
        }
        // 1秒間フラッシュする
        FlxG.camera.flash(0xffFFFFFF, 0.3);
    }

    /**
     * 更新・デバッグ
     **/
    private function _updateDebug():Void {

//    #if !FLX_NO_DEBUG
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
            _speedCtrl.addTop(10);
        }
        if(FlxG.keys.pressed.LEFT) {
            // 左キーでスピードダウン
            _speedCtrl.addTop(-10);
        }
        if(FlxG.keys.justPressed.D) {
            // 自爆
            _speedCtrl.addTop(-99999999);
        }
        if(FlxG.keys.justPressed.M) {
            // 無敵状態切替
            _player.startStar();
        }
        if(FlxG.keys.justPressed.B) {
            // 巨大化
            _player.startBig();
        }
        if(FlxG.keys.justPressed.S) {
            // 縮小化
            _player.startSmall();
        }
        if(FlxG.keys.justPressed.A) {
            // ボム
            _startBomb();
        }
//    #end
    }
}