package ui;
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

    private var _score:Int;
    private var _scores:Array<FlxSprite>;

    /**
     * コンストラクタ
     **/
    public function new(score:Int) {
        super();
        _score = score;

        _objs = new Array<FlxObject>();

        // スコアパネルの生成
        _panel = new FlxSprite(FlxG.width/2, FlxG.height/2+40);
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
     * 終了したかどうか
     **/
    public function isEnd():Bool {
        return true;
    }
}
