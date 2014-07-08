package;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
import jp_2dgames.TextUtil;
import flixel.util.FlxSave;
import flixel.FlxG;
class Reg {

    // 初期タイム
    public static var TIME_INIT = (59 * 60 * 1000) + (59 * 1000) + 999;

    // レベルの最大
    public static var LEVEL_MAX = 4;

    // BGM無効フラグ
    private static var _bBgmDisable = true;
//    private static var _bBgmDisable = false;

    // レベル
	public static var level:Int = 1;
    // スコア
	public static var score:Int = 0;

    // セーブデータ
    private static var _save:FlxSave = null;

    private static function _getSave():FlxSave {
        if(_save == null) {
            _save = new FlxSave();
            _save.bind("SAVEDATA");
        }
        if(_save.data == null || _save.data.scores == null || _save.data.levelMax == null) {
            // データがなければ初期化
            clear(_save);
        }

        return _save;
    }

    /**
     * セーブデータを初期化
     **/
    public static function clear(s:FlxSave=null):Void {
        if(s == null) {
            s = _save;
        }

        s.data.scores = new Array<Int>();
        s.data.times = new Array<Int>();
        s.data.ranks = new Array<String>();
        for(i in 0...LEVEL_MAX) {
            s.data.scores.push(0);
            s.data.times.push(TIME_INIT);
            s.data.ranks.push("E");
        }
        _save.data.levelMax = 0;
        s.flush();
    }

    /**
     * 最大レベルクリア数を取得する
     * @return 最大レベルクリア数
     **/
    public static function getLevelMax():Int {
        return _save.data.levelMax;
    }

    /**
     * ハイスコアを取得
     * @param lv レベル。指定がなければ現在のレベルで取得する
     * @return ハイスコア
     **/
    public static function getHiScore(lv:Int = -1):Int {
        var s = _getSave();
        if(lv < 0) {
            lv = level;
        }

        return s.data.scores[lv];
    }

    /**
     * 最短タイムを取得
     * @param lv レベル。指定がなければ現在のレベルで取得する
     * @return 最短タイム
     **/
    public static function getTime(lv:Int = -1):Int {
        var s = _getSave();
        if(lv < 0) {
            lv = level;
        }

        return s.data.times[lv];
    }

    /**
     * ランクを取得
     * @param lv レベル。指定がなければ現在のレベルで取得する
     * @return ランク
     **/
    public static function getRank(lv:Int = -1):String {
        var s = _getSave();
        if(lv < 0) {
            lv = level;
        }

        return s.data.ranks[lv];
    }

    /**
     * スコア更新
     * @param score  スコア
     * @param time   経過時間
     * @param rank   ランク
     * @param bClear クリアしたかどうか
     * @return レベル更新したらtrue
     **/
    public static function save(score:Int, time:Int, rank:String, bClear:Bool):Bool {

        var s = _getSave();

        var hiscore = getHiScore();
        var hitime = getTime();
        var hirank = getRank();

        if(score > hiscore) {
            // ハイスコア更新
            s.data.scores[level] = score;
        }
        if(time < hitime) {
            // 最短タイム更新
            s.data.times[level] = time;
        }

        // ランクを数値に変換
        var rankToInt = function(rank:String) {
            switch(rank) {
                case "S": return 5;
                case "A": return 4;
                case "B": return 3;
                case "C": return 2;
                case "D": return 1;
                case "E": return 0;
                default: return 0;
            }
        }
        var rankA = rankToInt(rank);
        var rankB = rankToInt(hirank);
        if(rankA > rankB) {
            // ランク更新
            s.data.ranks[level] = rank;
        }

        var ret:Bool = false; // 新しいレベルをクリアしたかどうか

        if(bClear) {
            // クリアしていたら最大レベルチェック
            if(level > getLevelMax()) {
                // クリアしたレベルを更新
                s.data.levelMax = level;

                if(level < LEVEL_MAX - 1) {
                    // アンロック・ウィンドウ表示
                    ret = true;
                }
            }
        }

        s.flush();

        return ret;
    }

    /**
     * 難易度に対応する名前を取得する
     **/
    public static function getLevelName(lv:Int=-1):String {

        if(lv == -1) {
            lv = level;
        }

        switch(lv) {
            case 1: return "Easy";
            case 2: return "Normal";
            case 3: return "Hard";
            default: return "None";
        }
    }

    /**
     * レベル数値を文字列に変換する
     **/
    public static function getLevelString():String {

        // 3桁の0埋めの数値
        return TextUtil.fillZero(level, 3);
    }

    /**
     * キャッシュする
     **/
    public static function cacheMusic():Void {
        FlxG.sound.volume = 1;

        FlxG.sound.cache("title");
        FlxG.sound.cache("001");
        FlxG.sound.cache("002");
        FlxG.sound.cache("003");
        FlxG.sound.cache("gameover");
    }

    public static function playMusic(name:String, bLoop:Bool=true):Void {

        if(_bBgmDisable) {
            // BGM無効
            return;
        }

        var sound = FlxG.sound.cache(name);
        if(sound != null) {
            // キャッシュがあればキャッシュから再生
            FlxG.sound.playMusic(sound, 1, bLoop);
        }
        else {
            FlxG.sound.playMusic(name, 1, bLoop);
        }
    }
}