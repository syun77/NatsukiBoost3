package ;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;

/**
 * リザルトメニュー
 **/
class ResultHUD extends FlxGroup {

    private var SCORE_STR = " --> ";

    // 表示オブジェクト
    private var _back:FlxSprite;
    private var _txtTitle:FlxText;
    private var _txtBlock:FlxText;
    private var _txtRing:FlxText;
    private var _txtSpeed:FlxText;
    private var _txtCombo:FlxText;
    private var _txtTime:FlxText;
    private var _txtHp:FlxText;
    private var _txtTotal:FlxText;
    private var _txtRank:FlxText;
    private var _txtRank2:FlxText;
    private var _natsuki:FlxSprite;

    private var _objs:Array<FlxObject>;

    private var _bEnd:Bool = false; // 演出が完了したかどうか
    private var _bNewLevel:Bool = false; // 最大レベルを更新したかどうか

    /**
     * コンストラクタ
     * @param cntRing リング獲得数
     * @param cntBlock ブロック破壊数
     * @param comboMax コンボ最大数
     * @parma hp 残りHP(0〜100)
     * @param pasttime 経過時間
     **/
    public function new(
        cntRing:Int,
        cntBlock:Int,
        comboMax:Int,
        hp:Int,
        pasttime:Int,
        speedMax:Float
    ) {

        // スコア計算
        var scBlock = 10 * cntBlock;
        var scRing  = 100 * cntRing;
        var scSpeed = 10 * Math.floor(speedMax);
        var scCombo = 50 * comboMax;
        var scTime  = 0;
        var t:Int = cast(pasttime / 1000); // msecからsecに変換

        // 時間スコアを取得
        var getTimeScore = function() {

            if(hp <= 0) { return false; }

            // 時間スコアCSVロード
            var csvTime:CsvLoader = new CsvLoader();
            csvTime.load("assets/levels/" + Reg.getLevelString() + "_time.csv");

            for(i in 1...csvTime.size()) {
                var sec = csvTime.getInt(i, "sec");
                if(t <= sec) {
                    // スコア決定
                    scTime = csvTime.getInt(i, "score");
                    break;
                }
            }
            return true;
        }
        // 有効なスコアかどうか
        var bScTime = getTimeScore();

        var scHp    = Math.floor(hp * hp * 0.5 / 10) * 10;
        if(hp == 100) {
            // HP最大ボーナス
            scHp = 10000;
        }
        var scTotal = scBlock + scRing + scSpeed + scCombo + scTime + scHp;


        // ランクCSVロード
        var csv:CsvLoader = new CsvLoader();
        csv.load("assets/levels/" + Reg.getLevelString() + ".csv");

        var rank = "S";
        // ランク判定
        for(i in 1...csv.size()+1) {
            var a = 0;
            if(i > 1) { a = csv.getInt(i-1, "score"); }
            var b = csv.getInt(i, "score");
            if(a <= scTotal && scTotal < b) {
                // ランク決定
                rank = csv.getString(i, "rank");
                break;
            }
        }

        // ■セーブ
        {
            var hitime = pasttime;
            if(bScTime == false) {
                // ゲームオーバー時はタイム更新なし
                hitime = Reg.TIME_INIT;
            }
            _bNewLevel = Reg.save(scTotal, hitime, rank, bScTime);
        }


        // ■描画情報設定
        super();
        _objs = new Array<FlxObject>();

        // 菜月さん
        if(hp > 0) {
            _natsuki = new FlxSprite(0, 0);
            _natsuki.loadGraphic("assets/images/natsuki02.png");
            _natsuki.x = -(_natsuki.width - FlxG.width)/2;
            _natsuki.scale.set(2, 2);
            _natsuki.alpha = 1;
            _objs.push(_natsuki);
            FlxTween.tween(_natsuki.scale, {x:1, y:1}, 2, {ease:FlxEase.expoOut});
        }

        // 背景
        _back = new FlxSprite();
        _back.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        FlxTween.color(_back, 1, FlxColor.WHITE, FlxColor.WHITE, 0, 0.8);
        _objs.push(_back);

        // テキスト
        _txtTitle = new FlxText(0, -32, FlxG.width);
        _txtTitle.alignment = "center";
        _txtTitle.size = 24;
        _txtTitle.text = "Result";
        FlxTween.tween(_txtTitle, {y:8}, 1, {ease:FlxEase.expoOut});

        // 各種スコア
        var x = FlxG.width;
        var y = FlxG.height/4;
        var dy = 16;
        var w = FlxG.width;
        _txtBlock = new FlxText(x, y, w, "Break Blocks: " + cntBlock + SCORE_STR + scBlock);
        y += dy;
        _txtRing = new FlxText(x, y, w,  "Get Rings: " + cntRing + SCORE_STR + scRing);
        y += dy;
        _txtSpeed = new FlxText(x, y, w, "Max Speed: " + Math.floor(speedMax) + SCORE_STR + scSpeed);
        y += dy;
        _txtCombo = new FlxText(x, y, w, "Max Combo: " + comboMax + SCORE_STR + scCombo);
        if(bScTime) {
            // 時間スコア有効
            y += dy;
            _txtTime = new FlxText(x, y, w, "Time: " + FlxStringUtil.formatTime(pasttime/1000.0, true) + SCORE_STR + scTime);

            // HPスコア有効
            y += dy;
            _txtHp = new FlxText(x, y, w,    "HP: " + hp + "%" + SCORE_STR + scHp);
        }
        else {
            // 時間スコア無効
            _txtTime = new FlxText();
            _txtHp = new FlxText();
        }
        y += dy;

        // トータル
        _txtTotal = new FlxText(FlxG.width, FlxG.height-64, FlxG.width);
        _txtTotal.alignment = "center";
        _txtTotal.size = 16;
        _txtTotal.text = "Total: " + scTotal;
        FlxTween.tween(_txtTotal, {x:0}, 0.5, {ease:FlxEase.bounceOut, startDelay:1.5});

        // ランク
        _txtRank = new FlxText(FlxG.width-128, FlxG.height-48, 128);
        _txtRank.setFormat(null, 24, FlxColor.AZURE, "center", FlxText.BORDER_OUTLINE, FlxColor.WHITE);
        _txtRank.text = rank;
        _txtRank.alpha = 0;
        _txtRank.scale.set(8, 8);
        FlxTween.tween(_txtRank, {alpha:1}, 1, {ease:FlxEase.expoOut, startDelay:2, complete:_cbEnd});
        FlxTween.tween(_txtRank.scale, {x:1, y:1}, 1, {ease:FlxEase.expoOut, startDelay:2});
        new FlxTimer(2.5, _cbShake);
        _txtRank2 = new FlxText(_txtRank.x, _txtRank.y, 128);
        _txtRank2.setFormat(null, _txtRank.size, FlxColor.AZURE, "center", FlxText.BORDER_OUTLINE, FlxColor.WHITE);
        _txtRank2.visible = false;
        _txtRank2.text = rank;

        _objs.push(_txtTitle);
        _objs.push(_txtBlock);
        _objs.push(_txtRing);
        _objs.push(_txtSpeed);
        _objs.push(_txtCombo);
        _objs.push(_txtTime);
        _objs.push(_txtHp);
        _objs.push(_txtTotal);
        _objs.push(_txtRank);
        _objs.push(_txtRank2);

        var cnt:Int = 0;
        for(o in _objs) {
            if(Std.is(o, FlxText)) {
                var txt:FlxText = cast(o, FlxText);
                var check = function():Bool {
                    if(txt.text == "Result") {
                        return false;
                    }
                    if(txt.text == rank) {
                        return false;
                    }
                    if(txt.text == "Total: " + scTotal) {
                        return false;
                    }
                    return true;
                }
                if(check()) {
                    cnt++;
                    var delay = 0.7 + 0.1 * cnt;
                    FlxTween.tween(txt, {x:FlxG.width/3 }, 0.7, {ease:FlxEase.elasticOut, startDelay:delay});
                }

            }
            o.scrollFactor.set(0, 0);
            this.add(o);
        }
    }

    private function _cbEnd(tween:FlxTween):Void {
        _txtRank2.visible = true;
        FlxTween.tween(_txtRank2, {alpha:0}, 1, {ease:FlxEase.expoOut});
        FlxTween.tween(_txtRank2.scale, {x:4, y:4}, 1, {ease:FlxEase.expoOut});
    }

    private function _cbShake(timer:FlxTimer):Void {
//        FlxG.camera.shake(0.02, 0.3);
        _bEnd = true;
    }

    public function isEnd():Bool {
        return _bEnd;
    }

    /**
     * 最大レベルを更新したかどうか
     **/
    public function isNewLevel():Bool {
        return _bNewLevel;
    }
}
