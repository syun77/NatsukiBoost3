package;

import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.FlxG;
import jp_2dgames.CsvLoader2;
import flash.Lib;
import flash.net.URLRequest;
import flixel.ui.FlxButton;
import effects.EffectCross;
import Reg.GameMode;
import ui.GameOverHUD;
import flixel.util.FlxAngle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
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
    WarpWait;       // ワープ演出中
    ItemWait;       // アイテム取得の共通ウェイト
    StageClearInit; // ステージクリア・初期化
    StageClearMain; // ステージクリア・メイン
    UnlockWait;     // ステージアンロック・ウィンドウ表示中
    GameoverInit;   // ゲームオーバー・初期化
    GameoverMain;   // ゲームオーバー・メイン
    End;            // ボタン入力待ち
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
    private var _eftCross:FlxTypedGroup<EffectCross>;

    // メッセージ
    private var _txtMessage:FlxText;

    // HUD
    private var _hud:HUD;

    // リザルト
    private var _result:ResultHUD;

    // ゲームオーバー演出
    private var _gameoverHUD:GameOverHUD;

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
    private var _tCombo:Float  = 0; // コンボタイマー
    private var _tChangeWait:Int = TIMER_CHANGE_WAIT; // リング獲得時の停止タイマー
    private var _cntSameBlock  = 0; // 同属性のブロックを破壊した数
    private var _offsetFieldX  = 0; // マップ情報のオフセット座標(X) ※Endlessモードのみ使用

    // リザルト用変数
    private var _cntBlock:Int   = 0; // ブロック破壊数
    private var _cntRing:Int    = 0; // リング獲得数
    private var _pasttime:Int   = 0; // 経過時間
    private var _comboMax:Int   = 0; // 最大コンボ数

    // 各種パラメータ
    private var _csvTopSpeed:CsvTopSpeed;
    private var _csvPlayer:CsvPlayer;

    // ボタン
    private var _btnBackToTitle:FlxButton; // タイトルへ戻る
    private var _iconTweet:FlxSprite; // ツイートアイコン
    private var _btnTweet:FlxButton; // ツイートボタン
    private var _txtTweet:FlxText; // ツイートポップアップ
    private var _strTweet:String; // ツイートメッセージ
    private var _bgTweet:FlxSprite;

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

        // 加速エフェクト
        _eftCross = new FlxTypedGroup<EffectCross>(32);
        for(i in 0..._eftCross.maxSize) {
            _eftCross.add(new EffectCross());
        }

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

        // ボタン生成
        _btnTweet = new FlxButton(FlxG.width-(40+80+24), FlxG.height-32+8, "", _cbTweet);
        _btnTweet.color = 0xFF55ACEE;
        _btnTweet.label.color = 0xFF77CEFF;
        _btnTweet.width = 16 + 3*2;
        _btnTweet.setGraphicSize(Std.int(_btnTweet.width), Std.int(_btnTweet.height));
        _btnTweet.centerOffsets();

        _iconTweet = new FlxSprite(FlxG.width-(40+80+23), FlxG.height-32+8+4).loadGraphic("assets/images/twitter.png");

        _btnBackToTitle = new FlxButton(FlxG.width-(80+8+16), FlxG.height-32, "Back to title", _cbBackToTitle);
        _btnBackToTitle.height *= 1.5;
        _btnBackToTitle.setGraphicSize(Std.int(_btnBackToTitle.width), Std.int(_btnBackToTitle.height));
        _btnBackToTitle.centerOffsets();
        for(ofs in _btnBackToTitle.labelOffsets) {
            ofs.y += _btnBackToTitle.height/4;
        }

        var fontpath = "assets/font/MT_TARE_P.ttf";
        _txtTweet = new FlxText(FlxG.width-200, _iconTweet.y-30, 100);
        _txtTweet.setFormat(fontpath, 16, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE, FlxColor.BLACK);
        _txtTweet.scrollFactor.set(0, 0);

        _bgTweet = new FlxSprite(_txtTweet.x, _txtTweet.y).makeGraphic(Std.int(_txtTweet.width), 24, 0xFF55ACEE);
        _bgTweet.alpha = 0.7;
        _bgTweet.scrollFactor.set(0, 0);

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
        this.add(_eftCross);

        // 各種オブジェクト生成
        _putObjects();

        // デバッグ用
        FlxG.debugger.toggleKeys = ["ALT"];

        // リザルトをすぐに表示する
//        _startResult();
//        setButtons();
    }

    public function setButtons():Void {
        _iconTweet.scrollFactor.set(0, 0);
        this.add(_btnBackToTitle);
        this.add(_btnTweet);
        this.add(_iconTweet);

        // ツイート文言生成
        var txtMode = Reg.getModeString();
        var txtLevel = Reg.getLevelName(Reg.level)+"ステージ";
        if(Reg.mode == GameMode.Endless) {
            // エンドレスモード時はレベル不要
            txtLevel = "";
        }
        var score = _hud.getScore();
        var rank = "E";
        if(_result != null ) {
            score = _result.getScore();
            rank = _result.getRank();
        }
        // ランクメッセージ取得
        var txtRank = "";
        {
            var csvTweet = new CsvLoader2("assets/params/tweet.csv");
            txtRank = csvTweet.searchItem("id", rank, "value");
        }
        _strTweet = '[菜月ブースト3]: ${txtMode} ${txtLevel}で${score}ウエハースを獲得！ ${txtRank}';
        _txtTweet.text = "ツイートする" ;//+ _strTweet;
        _txtTweet.visible = false;
        _bgTweet.visible = false;
        this.add(_bgTweet);
        this.add(_txtTweet);
    }

    /**
     * タイトル画面へ戻る
     **/
    private function _cbBackToTitle():Void {
        FlxG.switchState(new MenuState());
    }

    /**
     * ツイートボタンを押した
     **/
    private function _cbTweet():Void {
        var urlString = "https://twitter.com/intent/tweet";

        // 本文
        var text = StringTools.urlEncode(_strTweet);
        // ゲームのURL(誘導用)
        var url  = "http://bit.ly/1oNhxFv";
        // ハッシュタグ
        var tags = "natsukiboost3";

        // URL文字列連結
        urlString += "?text="     + text;
        urlString += "&hashtags=" + tags;
        urlString += "&url="      + url;

        var request = new URLRequest(urlString);
        // "_blank"で開く
        flash.Lib.getURL(request, "_blank");
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

        // コンボタイマー初期化
        _tCombo = 0;
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
        if(_btnTweet.status != FlxButton.NORMAL) {
            _txtTweet.visible = true;
            _bgTweet.visible = true;
        }
        else {
            _txtTweet.visible = false;
            _bgTweet.visible = false;
        }

        switch(_state) {
            case State.Start: _updateStart();
            case State.Main: _updateMain();
            case State.ChangeWait: _updateChangeWait();
            case State.WarpWait: _updateWarpWait();
            case State.ItemWait: _updateItemWait();
            case State.StageClearInit: _updateStageClearInit();
            case State.StageClearMain: _updateStageClearMain();
            case State.UnlockWait: _updateUnlockWait();
            case State.GameoverInit: _updateGameoverInit();
            case State.GameoverMain: _updateGameoverMain();
            case State.End: // 何もしない
        }

        // デバッグ処理
        _updateDebug();
    }

    private function _setActiveForChangeWait(b:Bool):Void {
        _follow.active = b;
        _blocks.active = b;
        _items.active = b;
    }

    private function _setActiveForWarpWait(b:Bool):Void {
        _follow.active = b;
        _player.active = b;
    }

    /**
     * 色変えエフェクト再生開始
     **/
    private function _startChangeWait():Void {
        _state = State.ChangeWait;
        _timer = _tChangeWait;

        _setActiveForChangeWait(false);
        // プレイヤーだけ止めずに速度だけ0にする
        _player.velocity.x = 0;

        // 停止タイマーを減らす
        _tChangeWait -= TIMER_CHANGE_WAIT_DEC;
        if(_tChangeWait < TIMER_CHANGE_WAIT_MIN) {
            // 最低値チェック
            _tChangeWait = TIMER_CHANGE_WAIT_MIN;
        }

        _eftPlayer.start(_player.getAttribute(), _player.x, _player.y, _timer);

    }

    private function _startItemWait(tWait:Int = 0):Void {
        _setActiveForChangeWait(false);
        // プレイヤーだけ止めずに速度だけ0にする
        _player.velocity.x = 0;

        _state = State.ItemWait;

        if(tWait == 0) {
            tWait = _tChangeWait;
        }
        _timer = tWait;
    }

    /**
     * ワープ演出開始
     **/
    private function _startWarpWait(warp:Item):Void {
        var py:Float = 0;
        var check = function(item:Item) {
            if(item.getID() == ItemID.Warp) {
                if(warp.x == item.x && warp.y != item.y) {
                    // ワープ先を発見
                    py = item.y;
                    item.vanish();
                }
            }
        }

        _items.forEachAlive(check);

        if(py != 0) {
            // ワープ開始
            _state = State.WarpWait;
            _setActiveForWarpWait(false);
            FlxTween.tween(_player, {y:py}, 1, {ease:FlxEase.expoOut, complete:_cb_warpend});
        }
        warp.vanish();
    }

    /**
     * ワープ演出終了
     **/
    private function _cb_warpend(tween:FlxTween):Void {

        // メインに戻る
        _state = State.Main;
        _setActiveForWarpWait(true);
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
            var bSame = (type == _player.getAttribute());
            b.init(type, x, y, bSame);
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

        var px = Math.floor(FlxG.camera.scroll.x / _field.tileWidth);
        var w = Math.floor(FlxG.width / _field.tileWidth);
        w += 8; // 検索範囲を広めに取る
        if(Reg.mode == GameMode.Endless) {
            // エンドレスステージ用ステージ読み込みチェック
            if(px + w > _field.width+_offsetFieldX) {
                // 追加読み込みが必要
                _offsetFieldX += _field.width;
                _field.addEndless(_offsetFieldX);
                // カメラを広げる
                FlxG.camera.bounds.width += _field.getRealWidth();
                FlxG.worldBounds.width += _field.getRealWidth();
            }
            px -= _offsetFieldX;
            var layer = _field.getLayer(0);
            for(j in 0..._field.height) {
                for(i in px...(px+w)) {
                    var id = layer.get(i, j);
                    var i2 = i + _offsetFieldX;
                    switch(id) {
                        case 1: // 青ブロック
                            createBlock(i2, j, Attribute.Blue);
                            layer.set(i, j, 0);
                        case 2: // 赤ブロック
                            createBlock(i2, j, Attribute.Red);
                            layer.set(i, j, 0);
                        case 3,4,17,18,19,20,21,33,34,35,36: // アイテム
                            createItem(i2, j, id);
                            layer.set(i, j, 0);
                    }
                }
            }
        }
        else {
            var layer = _field.getLayer(0);
            for(j in 0..._field.height) {
                for(i in px...(px+w)) {
                    var id = layer.get(i, j);
                    switch(id) {
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
     * 重力アイテムのチェック
     **/
    private function _checkGravity():Void {

        var bFind:Bool = false;
        var dx:Float = 0;
        var dy:Float = 0;
        var check = function(item:Item) {
            // 一番近い重力アイテムの座標を取得する
            if(item.getID() == ItemID.Gravity) {
                bFind = true;
                var d = FlxMath.distanceBetween(item, _player);
                if(d < _csvPlayer.item_gravity_length) {
                    var rad = FlxAngle.angleBetween(_player, item);
                    var power = _csvPlayer.item_gravity_power;
                    dx += power * Math.cos(rad);
                    dy += power * Math.sin(rad);
                }
            }
        }

        _items.forEachAlive(check);

        // 重力情報の設定
        _player.setGravity(bFind, dx, dy);
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
     * クリア判定
     * @return クリアしていたらtrue
     **/
    private function _checkClear():Bool {

        if(Reg.mode == GameMode.Endless) {
            // エンドレスモードにクリアはない
            return false;
        }

        if(FlxG.camera.scroll.x >= _field.getRealWidth() - FlxG.width) {
            // クリアした
            return true;
        }

        return false;
    }

    /**
     * コンボ終了チェック
     **/
    private function _checkComboEnd():Void {

        if(_combo > 0) {
            _tCombo += FlxG.elapsed;

            var max:Float = _csvPlayer.combo_timer;
            var percent:Float = (max - _tCombo) / max;
            _hud.setComboBar(percent);

            if(_tCombo > max * 0.666) {
                // 点滅開始
                _hud.blinkCombo();
            }
            if(_tCombo > max) {
                // 一定時間経過したのでコンボ終了
                _resetCombo();
            }
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

        // 加速アイテムの処理
        if(_player.isDash()) {
            _speedCtrl.enableKasoku();
        }

        // 重力アイテムのチェック
        _checkGravity();

        // スクロール処理
        _updateScroll();

        // ボムの処理
        _updateBomb();

        // コンボ終了チェック
        _checkComboEnd();

        // クリア判定
        if(_checkClear()) {
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
            _gameoverHUD = new GameOverHUD(_player);
            this.add(_gameoverHUD);
            _player.vanish();
            _follow.kill();
            _state = State.GameoverInit;
            _timer = TIMER_GAMEOVER_INIT;

            // エフェクト生成
            _emitterPlayer.explode(_player.x, _player.y);

            // メッセージ表示
            _txtMessage.text = "Game Over...";
            _txtMessage.visible = true;

            // 時間計測停止
            _hud.setIncTime(false);

            // サウンド再生
            Snd.playSe("kya");

            // 終了BGM
            Snd.playMusic("gameover", false);

            // ハイスコアのみ保存
            Reg.saveScore(_hud.getScore());

            if(Reg.mode == GameMode.Endless) {
                // エンドレスモードはリザルトを表示する
                _startResult();
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

    /**
     * 更新・属性変更
     **/
    private function _updateChangeWait():Void {
        if(_eftPlayer.isEnd()) {
            _setActiveForChangeWait(true);
            _state = State.Main;
        }
    }

    /**
     * 更新・ワープ
     **/
    private function _updateWarpWait():Void {
        // 特に何もしない
    }

    /**
     * 更新・共通のアイテムウェイト
     **/
    private function _updateItemWait():Void {
        _timer--;
        if(_timer < 1) {
            _setActiveForChangeWait(true);
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
        if(_result.isEnd()) {
            // ボタン配置
            setButtons();
            _state = State.End;
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
        var bEndless:Bool = Reg.mode == GameMode.Endless;
        _result = new ResultHUD(_hud.getScore(), pasttime, bEndless, _player);
        this.add(_result);

        // 終了BGM
        Snd.playMusic("gameover", false);
    }

    /**
     * ゲームオーバー
     **/
    private function _updateGameoverInit():Void {
        _timer--;

        if(_timer < 1) {
            _state = State.GameoverMain;
        }
    }
    private function _updateGameoverMain():Void {
        if(_gameoverHUD.isEnd()) {
            setButtons();
            _state = State.End;
        }
    }

    // プレイヤー vs アイテム
    private function _vsPlayerItem(p:Player, item:Item):Void {

        switch(item.getID()) {
        case ItemID.Ring:
            // 属性チェンジアイテム
            if(p.getAttribute() != item.getAttribute()) {
                // 色変え実行
                p.changeAttribute(item.getAttribute());
            }
            item.vanish();

            // 同じX座標にあるリングを削除
            _vanishRingX(item.x);

            // ブロックの色を変える
            var changeBlock = function(b:Block) {
                var bSame = b.getAttribute() == p.getAttribute();
                b.change(bSame);
            }
            _blocks.forEachAlive(changeBlock);

            Snd.playSe("kin");

            // リング獲得数アップ
            _cntRing++;

            _startChangeWait();

        case ItemID.Big:
            _player.startBig();
            Snd.playSe("big");
            item.vanish();
            // 動きを止める
            _startItemWait(cast _tChangeWait/2);

        case ItemID.Small:
            _player.startSmall();
            Snd.playSe("big");
            item.vanish();
            // 動きを止める
            _startItemWait(cast _tChangeWait/2);

        case ItemID.Star:
            _player.startStar();
            Snd.playSe("muteki");
            item.vanish();

        case ItemID.Damage:
            _damage(_csvPlayer.item_damage_val);
            Snd.playSe("damage");
            item.vanish();

        case ItemID.Shield:
            _player.startShield();
            Snd.playSe("shield");
            item.vanish();

        case ItemID.Bomb:
            _startBomb();
            Snd.playSe("bomb");
            item.vanish();

        case ItemID.Warp:
            _startWarpWait(item);
            Snd.playSe("warp");

        case ItemID.Dash:
            // 開始速度を記録しておく
            _speedCtrl.recordKasokuInit();
            _player.startDash();
            Snd.playSe("kasoku");
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
        // ダメージで終了しないようにする
        //_resetCombo();

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

        // コンボ数をそのままスコアとする
        _hud.addScore(_combo);

        var px = _hud.getSpeedBarX();
        var py = _hud.getSpeedBarY()-16;
        var cross:EffectCross = _eftCross.recycle();
        cross.start(px, py);

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
            var px = FlxRandom.intRanged(0, FlxG.width-32);
            var py = FlxRandom.intRanged(0, FlxG.height-32);
            b.start(px, py);
        }
        // 1秒間フラッシュする
        FlxG.camera.flash(0xffFFFFFF, 0.3);
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
        if(FlxG.keys.justPressed.K) {
            // 加速アイテム
            // 開始速度を記録しておく
            _speedCtrl.recordKasokuInit();
            _player.startDash();
        }
    #end
    }
}