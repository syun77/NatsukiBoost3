package ui;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;

/**
 * リザルトメニュー
 **/
class ResultHUD extends FlxGroup {

    private var SCORE_DIGIT = 12;

    private var _objs:Array<FlxObject>;
    // ゲームオブジェクト
    private var _panel:FlxSprite;
    private var _scores:Array<FlxSprite>;
    private var _timebonus:FlxSprite;
    private var _wafer:FlxSprite;
    // テキスト
    private var _txtRatio:FlxText;
    private var _txtRank:FlxText;

    // 変数
    private var _score:Int;
    private var _pasttime:Int; // ミリ秒
    private var _ratio:Float; // タイムボーナス倍率

    /**
     * コンストラクタ
     **/
    public function new(score:Int, pasttime:Int) {
        super();
        _score = score;
        _pasttime = pasttime;
        _calcRatio(); // タイムボーナスを計算
        _score = cast(_score * _ratio);

        _objs = new Array<FlxObject>();

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
        _setScore(_score);

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
            this.add(obj);
        }
    }

    /**
     * スコアを設定
     **/
    private function _setScore(v:Int):Void {
        for(i in 0...SCORE_DIGIT) {
            var div = Math.pow(10, SCORE_DIGIT-i-1);
            var num = Math.floor(v / div);
            num %= 10;
            trace('${i} ${num}');
            var obj = _scores[i];
            obj.animation.play('${num}');
        }
    }

    /**
     * タイムボーナスの倍率を計算する
     **/
    private function _calcRatio():Void {
        var sec:Int = Math.floor(_pasttime / 1000);
        var base:Float = 4; // 基本倍率
        base -= 0.1 * Math.floor(sec / 6);
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
        return true;
    }
}
