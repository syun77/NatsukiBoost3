package ui;
import flixel.util.FlxGradient;
import flixel.group.FlxTypedGroup;
import StringTools;
import flixel.util.FlxRandom;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.CsvLoader2;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;

/**
 * 状態
 **/
enum State {
    ScoreIn; // スコアパネル表示
    BowlIn; // お皿表示
    BowlMain; // お皿にウェハース投擲
    ScoreMain; // スコア表示
    TimebonusIn; // タイムボーナス表示
    ScoreMain2; // タイムボーナスをスコアに加算
    CutIn; // カットイン表示
    Standby; // 入力待ち
    End; // 終了
}

/**
 * リザルトメニュー
 **/
class ResultHUD extends FlxGroup {

    private var SCORE_DIGIT = 12;
    private var TIMER_SCORE = 6;

    private var _objs:Array<FlxObject>;
    // ゲームオブジェクト
    private var _panel:FlxSprite;
    private var _scores:Array<FlxSprite>;
    private var _timebonus:FlxSprite;
    private var _wafer:FlxSprite;
    private var _natsuki:FlxSprite;
    private var _fukidashi:FlxSprite;
    private var _bowl:FlxSprite;
    private var _bowl2:FlxSprite;
    private var _bowlHit:FlxSprite; // お皿当たり判定
    private var _wafers:FlxGroup;

    // テキスト
    private var _txtRatio:FlxText;
    private var _txtRank:FlxText;
    private var _txtFukidashi:FlxText;

    // 変数
    private var _scoreDraw:Int; // スコア（描画用）
    private var _score:Int;     // 元のスコア
    private var _score2:Int;    // スコア（タイムボーナス加算後）
    private var _pasttime:Int; // ミリ秒
    private var _ratio:Float; // タイムボーナス倍率

    private var _state:State; // 状態
    private var _timer:Int;   // 汎用タイマー
    private var _digit:Int;   // スコア演出の桁数
    private var _digit2:Int;  // ボーナス演出の桁数
    private var _tScore:Int;  // スコア演出用タイマー
    private var _tPast:Int = 0; // 経過時間

    /**
     * コンストラクタ
     **/
    public function new(score:Int, pasttime:Int) {
        super();
//        score = 12345678;
        _score = score;
        _pasttime = pasttime;
        _calcRatio(); // タイムボーナスを計算
        _score2 = cast(_score * _ratio);

        // 小数点第一位より下を切り捨て
        {
            var tmp = Math.floor(_ratio * 10);
            _ratio = tmp / 10.0;
        }

        _objs = new Array<FlxObject>();

        // お皿とウエハース
        // お皿・後ろ
        _bowl = new FlxSprite();
        _bowl.loadGraphic("assets/images/result/boul_oku.png");
        _bowl.scrollFactor.set(0, 0);
        _bowl.visible = false;
        this.add(_bowl);
        // ウエハース
        _wafers = new FlxGroup();
        this.add(_wafers);
        // お皿・手前
        _bowl2 = new FlxSprite();
        _bowl2.loadGraphic("assets/images/result/boul_mae.png");
        _objs.push(_bowl2);
        // お皿・当たり判定
        _bowlHit = new FlxSprite(130, 191);
        _bowlHit.makeGraphic(409 - cast _bowlHit.x, 207 - cast _bowlHit.y);
        _bowlHit.visible = false;
        _bowlHit.immovable = true; // 動かない
        this.add(_bowlHit);

        // CSV読み込み
        var csv2:CsvLoader2 = new CsvLoader2("assets/params/fukidashi.csv");
        var fontpath = csv2.getString(0, "msg");
        var fontsize = csv2.getInt(1, "msg");
        var msgList = [];
        for(i in 2...csv2.size()) {
            // 吹き出しセリフは2から開始する
            msgList.push(csv2.getString(i, "msg"));
        }
        FlxRandom.shuffleArray(msgList, msgList.length);

        // カットイン
        _natsuki = new FlxSprite();
        _natsuki.loadGraphic("assets/images/result/natsuki02.png");
        _objs.push(_natsuki);
        _fukidashi = new FlxSprite();
        _fukidashi.loadGraphic("assets/images/result/fukidashi.png");
        _objs.push(_fukidashi);
        _txtFukidashi = new FlxText(290, 74, 120, 24);
        _txtFukidashi.setFormat(fontpath, fontsize, FlxColor.BLACK, "center", FlxText.BORDER_OUTLINE_FAST, FlxColor.WHITE);

        _txtFukidashi.text = StringTools.replace(msgList[0], "#", "\n");
        _objs.push(_txtFukidashi);

        // スコアパネルの生成
        _panel = new FlxSprite(FlxG.width/2-24, FlxG.height/2+60);
        _panel.loadGraphic("assets/images/result/scoer_fream.png");
        _panel.x -= _panel.width/2;
        _objs.push(_panel);

        // スコア文字の生成
        _scores = new Array<FlxSprite>();
        var px:Float = _panel.x + 6;
        var py:Float = _panel.y + 4;
        for(i in 0...SCORE_DIGIT) {
            var obj = new FlxSprite(px, py);
            obj.loadGraphic("assets/images/result/font_scoer.png", true, 9, 24);
            for(j in 0...12) {
                switch(j) {
                case 0,1,2,3,4,5,6,7,8,9:
                    obj.animation.add('${j}', [j]);
                case 10:
                    obj.animation.add(":", [10]);
                case 11:
                    obj.animation.add(";", [11]);
                }
            }
            obj.animation.play("0");
            px += obj.width;
            _scores.push(obj);
            _objs.push(obj);
        }
        _scoreDraw = 0;
        _setScore(_scoreDraw);

        // タイムボーナス
        _timebonus = new FlxSprite();
        _timebonus.loadGraphic("assets/images/result/timebonus.png");
        _objs.push(_timebonus);

        // ウェハース
        _wafer = new FlxSprite();
        _wafer.loadGraphic("assets/images/result/ueha-su.png");
        _objs.push(_wafer);

        // タイムボーナス
        _txtRatio = new FlxText(FlxG.width/2-16, FlxG.height/2+28, FlxG.width);
        _txtRatio.size = 20;
        _txtRatio.borderStyle = FlxText.BORDER_OUTLINE_FAST;
        _txtRatio.text = "x " + _ratio;
        _objs.push(_txtRatio);

        // ランク
        _txtRank = new FlxText(0, FlxG.height - 28, FlxG.width);
        _txtRank.alignment = "center";
        _txtRank.size = 20;
        _txtRank.borderStyle = FlxText.BORDER_OUTLINE_FAST;
        _txtRank.text = "Rank: A";
        _objs.push(_txtRank);

        // スプライト登録
        for(obj in _objs) {
            obj.scrollFactor.set(0, 0);
            obj.visible = false;
            this.add(obj);
        }

        // 変数初期化
        _state = State.ScoreIn;
        _tScore = 0;

        FlxG.watch.add(_wafers, "length");
    }


    /**
     * 更新
     **/
    override public function update():Void {
        super.update();

        _tPast++;
        if(_tPast%1 == 0) {
        }

        FlxG.collide(_wafers, _wafers);
        FlxG.collide(_wafers, _bowlHit);

        switch(_state) {
            case State.ScoreIn: // スコアパネル表示
                _updateScoreIn();
            case State.BowlIn: // お皿表示
                _updateBowlIn();
            case State.BowlMain: // お皿にウェハース投擲
                _updateBowlMain();
            case State.ScoreMain: // スコア表示
                _updateScoreMain();
            case State.TimebonusIn: // タイムボーナス表示
                _updateTimebonusIn();
            case State.ScoreMain2: // タイムボーナスをスコアに加算
                _updateScoreMain2();
            case State.CutIn: // カットイン表示
                _updateCutIn();
            case State.Standby: // 入力待ち
                _updateStandby();
            case State.End:
        }

        // スコア更新
        _updateScore();
    }

    private function _updateScore():Void {
        _tScore++;
        for(i in 0...SCORE_DIGIT) {
            if(i >= _digit) {
                var str = if(_tScore%4 < 2) ':' else ';';
                var obj = _scores[SCORE_DIGIT-i-1];
                obj.animation.play(str);
            }
        }
    }

    // スコアパネル出現
    private function _updateScoreIn():Void {
        // TODO:
        _panel.visible = true;
        for(s in _scores) {
            s.visible = true;
        }
        _wafer.visible = true;

        var py = _panel.y;
        _panel.y = FlxG.height;
        FlxTween.tween(_panel, {y:py}, 1, {ease:FlxEase.expoOut});
        for(s in _scores) {
            var py3 = s.y;
            s.y = FlxG.height;
            FlxTween.tween(s, {y:py3}, 1, {ease:FlxEase.expoOut});
        }
        var py2 = _wafer.y;
        _wafer.y = FlxG.height;
        FlxTween.tween(_wafer, {y:py2}, 1, {ease:FlxEase.expoOut});

        _state = State.BowlIn;
    }

    // お皿出現
    private function _updateBowlIn():Void {
        {
            var py = _bowl.y;
            _bowl.y = FlxG.height;
            FlxTween.tween(_bowl, {y:py}, 1, {ease:FlxEase.expoOut});
        }
        {
            var py = _bowl2.y;
            _bowl2.y = FlxG.height;
            FlxTween.tween(_bowl2, {y:py}, 1, {ease:FlxEase.expoOut});
        }
        _bowl.visible = true;
        _bowl2.visible = true;
        _state = State.BowlMain;
    }

    // お皿にウェハースを投げ込む
    private function _updateBowlMain():Void {
        // TODO:
        _state = State.ScoreMain;
        _timer = 0;
        _digit = 0;
    }

    private function _appearWafers():Void {
        for(i in 0...1) {
            var spr = new FlxSprite(FlxG.width/5*3+FlxRandom.intRanged(-80, 80), 0);
            if(FlxRandom.chanceRoll()) {
                spr.loadGraphic("assets/images/bomb_red.png", true);
            }
            else {
                spr.loadGraphic("assets/images/bomb_blue.png", true);
            }
            var scale = 2;
            spr.scale.set(scale, scale);
            spr.width *= scale;
            spr.height *= scale;
            spr.centerOffsets();
            spr.velocity.set(FlxRandom.intRanged(-10, 10), FlxRandom.intRanged(50, 100));
            spr.angularVelocity = FlxRandom.intRanged(-100, 100);
            spr.angularDrag = 10;
            spr.mass = 10;
            spr.animation.add("play", [1], 30);
            spr.animation.play("play");
            spr.scrollFactor.set(0, 0);
            spr.acceleration.y = 100;
            _wafers.add(spr);
        }
    }

    // スコアカウントアップ
    private function _updateScoreMain():Void {
        _appearWafers();
        _timer++;
        if(_timer > TIMER_SCORE) {
            _timer = 0;
            var pow:Int = cast Math.pow(10, _digit);
            var tmp:Int = cast(Math.floor(_score / pow));
            var tmp2 = tmp%10;
            var d:Int = tmp2 * pow;
            _scoreDraw += d;

            _digit++;
            if(_digit > SCORE_DIGIT || _score == _scoreDraw) {
                // タイムボーナス演出へ
                _digit = SCORE_DIGIT;
                _state = State.TimebonusIn;
                _timer = 0;
                {
                    var py = _txtRatio.y;
                    _txtRatio.y = FlxG.height;
                    FlxTween.tween(_txtRatio, {y:py}, 1, {ease:FlxEase.expoOut});
                }
                {
                    var py = _timebonus.y;
                    _timebonus.y = FlxG.height;
                    FlxTween.tween(_timebonus, {y:py}, 1, {ease:FlxEase.expoOut, complete:_cb_timebonusin});
                }
                _txtRatio.visible = true;
                _timebonus.visible = true;
            }
        }
        _setScore(_scoreDraw);
    }

    private function _cb_timebonusin(t:FlxTween):Void {
        _digit2 = 0;
        _state = State.ScoreMain2;
        _timer = 0;
    }

    // タイムボーナス出現
    private function _updateTimebonusIn():Void {
        // TODO:
    }

    // タイムボーナススコア加算
    private function _updateScoreMain2():Void {
        // TODO:
        _timer++;
        if(_timer > TIMER_SCORE) {
            _timer = 0;
            {
                var pow:Int = cast Math.pow(10, _digit2);
                var tmp:Int = cast(Math.floor(_score / pow));
                var tmp2 = tmp%10;
                var d:Int = tmp2 * pow;
                _scoreDraw -= d;
            }
            {
                var pow:Int = cast Math.pow(10, _digit2);
                var tmp:Int = cast(Math.floor(_score2 / pow));
                var tmp2 = tmp%10;
                var d:Int = tmp2 * pow;
                _scoreDraw += d;
            }
            _digit2++;
            if(_digit2 > SCORE_DIGIT || _score2 == _scoreDraw) {
                {
                    var px = _natsuki.x;
                    _natsuki.x = -FlxG.width;
                    FlxTween.tween(_natsuki, {x:px}, 1, {ease:FlxEase.expoOut, complete:_cb_cutin});
                }
                _natsuki.visible = true;
                _state = State.CutIn;
            }
        }
        _setScore(_scoreDraw);
    }

    // カットイン出現
    private function _updateCutIn():Void {
        // TODO:
    }

    private function _cb_cutin(t:FlxTween):Void {
        var px = _natsuki.x;
        _fukidashi.visible = true;
    #if flash
        _txtFukidashi.visible = true;
    #end
        _txtRank.visible = true;
        var size = _txtRank.size;
        _txtRank.size *= 2;
        FlxTween.tween(_txtRank, {size:size}, 1, {ease:FlxEase.expoOut});
        _state = State.Standby;
    }

    // 待機
    private function _updateStandby():Void {
        if(FlxG.mouse.justPressed) {
            _state = State.End;
        }
    }

    /**
     * スコアを設定
     **/
    private function _setScore(v:Int):Void {
        for(i in 0...SCORE_DIGIT) {
            var div = Math.pow(10, SCORE_DIGIT-i-1);
            var num = Math.floor(v / div);
            if(num < 0) {
                trace('v=${v} div=${div} num=${num}');
                throw "Error";
            }
            num %= 10;
            var obj = _scores[i];
            obj.animation.play('${num}');
        }
    }

    /**
     * タイムボーナスの倍率を計算する
     **/
    private function _calcRatio():Void {

        var csvTb:CsvLoader2 = new CsvLoader2("assets/levels/timebonus.csv");
        var mode = Reg.getModeString();
        var level = "" + Reg.level;

        var check = function(data:Map<String,String>) {
            if(data["mode"] == mode && data["level"] == level) {
                return true;
            }
            return false;
        }
        var id = csvTb.foreachSearchID(check);

        var sec:Int = Math.floor(_pasttime / 1000);
        var base:Float = csvTb.getFloat(id, "start"); // 基本倍率
        var dRatio = base - 1;
        var limit:Float = csvTb.getFloat(id, "sec"); // 1倍になるまでの時間（秒）
        var dRatioPerSec = dRatio / limit; // 1秒ごとに減少する倍率
//        trace('base=${base} dRatio=${dRatio} limit=${limit} dRatioPerSec=${dRatioPerSec}');
        base -= dRatioPerSec * (sec);
        if(base < 1) {
            // 1より小さくならない
            base = 1;
        }
        _ratio = base;
    }

    /**
     * 終了したかどうか
     **/
    public function isEnd():Bool {
        return _state == State.End;
    }
}
