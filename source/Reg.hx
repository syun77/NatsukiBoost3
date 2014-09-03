package;

import Reg.GameMode;
import flash.Lib;
import jp_2dgames.TextUtil;
import flixel.util.FlxSave;

enum GameMode {
    Fix; // 固定ステージ
    Random; // ランダムマップ
    Endless; // エンドレス
}
/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg {

    // 初期タイム
    public static var TIME_INIT:Int = (59 * 60 * 1000) + (59 * 1000) + 999;
    // セーブデータのバージョン番号
    private static var SAVE_VERSION:Int = 106;

    // ゲームモード
//    private static var _mode:GameMode = GameMode.Fix;
    private static var _mode:GameMode = GameMode.Random;
//    private static var _mode:GameMode = GameMode.Endless;
    public static var mode(get, null):GameMode;

    // レベルの最大
    public static var LEVEL_MAX = 4;

    // レベル
    private static var _level:Int = 1;
	public static var level(get, null):Int;

    // スコア
	public static var score:Int = 0;

    // セーブデータ
    private static var _save:FlxSave = null;

    private static function _getSave():FlxSave {
        if(_save == null) {
            _save = new FlxSave();
            _save.bind("SAVEDATA");
        }
        if(_save.data.version == null || _save.data.version != SAVE_VERSION) {
            // バージョンが違っていれば初期化
            clear(_save);
        }

        return _save;
    }

    /**
     * セーブデータを初期化
     **/
    public static function clear(s:FlxSave=null):Void {
        if(s == null) {
            if(_save == null) {
                s = _getSave();
            }
            else {
                s = _save;
            }
        }

        s.data.version = SAVE_VERSION;
        s.data.scores = new Array<Int>();
        s.data.times = new Array<Int>();
        s.data.ranks = new Array<Int>();
        for(i in 0...7) {
            s.data.scores.push(0);
            s.data.times.push(TIME_INIT);
            s.data.ranks.push(0);
        }

        s.flush();
    }

    /**
     * ハイスコアを取得
     * @param lv レベル。指定がなければ現在のレベルで取得する
     * @return ハイスコア
     **/
    public static function getHiScore(?m:GameMode, lv:Int = -1):Int {
        var s = _getSave();
        if(m == null) {
            m = mode;
        }
        if(lv < 0) {
            lv = _level;
        }

        var key = getModeLevelInt(m, lv);

        return s.data.scores[key];
    }

    /**
     * 最短タイムを取得
     * @param lv レベル。指定がなければ現在のレベルで取得する
     * @return 最短タイム
     **/
    public static function getTime(?m:GameMode, lv:Int = -1):Int {
        var s = _getSave();
        if(m == null) {
            m = mode;
        }
        if(lv < 0) {
            lv = _level;
        }

        var key = getModeLevelInt(m, lv);

        return s.data.times[key];
    }

    /**
     * ランクを取得
     * @param lv レベル。指定がなければ現在のレベルで取得する
     * @return ランク
     **/
    public static function getRank(?m:GameMode, lv:Int = -1):Int {
        var s = _getSave();
        if(m == null) {
            m = mode;
        }
        if(lv < 0) {
            lv = _level;
        }

        var key = getModeLevelInt(m, lv);

        return s.data.ranks[key];
    }

    /**
     * スコア更新
     * @param score  スコア
     * @param time   経過時間
     * @param rank   ランク
     * @param bClear クリアしたかどうか
     * @return レベル更新したらtrue
     **/
    public static function save(score:Int, time:Int, rank:Int, bClear:Bool):Bool {

        var s = _getSave();

        var hiscore = getHiScore();
        var hitime = getTime();
        var hirank = getRank();

        var key = getModeLevelInt(mode, level);

        if(score > hiscore) {
            // ハイスコア更新
            s.data.scores[key] = score;
        }
        if(time < hitime) {
            // 最短タイム更新
            s.data.times[key] = time;
        }

        if(rank > hirank) {
            // ランク更新
            s.data.ranks[key] = rank;
        }

        var ret:Bool = false; // 新しいレベルをクリアしたかどうか

        s.flush();

        return ret;
    }

    /**
     * スコアのみ保存する
     **/
    public static function saveScore(score:Int):Void {
        var s = _getSave();
        var hiscore = getHiScore();
        var key = getModeLevelInt(mode, level);
        if(score > hiscore) {
            // ハイスコア更新
            s.data.scores[key] = score;
        }

        s.flush();
    }

    /**
     * 指定のゲームモードとレベルを組み合わせて数字を返す
     * @note セーブデータのキーとして使用する
     **/
    public static function getModeLevelInt(m:GameMode, lv:Int):Int {
        switch(m) {
            case GameMode.Fix:
                return 0 + lv - 1;
            case GameMode.Random:
                return 3 + lv - 1;
            case GameMode.Endless:
                return 6;
        }
    }

    /**
     * ランク数値を文字列に変換する
     **/
    public static function getRankToString(rank:Int):String {
        switch(rank) {
            case 5: return "S";
            case 4: return "A";
            case 3: return "B";
            case 2: return "C";
            case 1: return "D";
            case 0: return "E";
            default: return "E";
        }
    }

    /**
     * ランク文字列を数値に変換する
     **/
    public static function getRankToInt(rank:String):Int {
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

    /**
     * 難易度に対応する名前を取得する
     **/
    public static function getLevelName(lv:Int=-1):String {

        if(lv == -1) {
            lv = _level;
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
        return TextUtil.fillZero(_level, 3);
    }

    /**
     * ゲームモードを文字列として取得する
     **/
    public static function getModeString():String {
        switch(mode) {
        case GameMode.Fix: return "Fix";
        case GameMode.Random: return "Random";
        case GameMode.Endless: return "Endless";
        }
    }

    /**
     * ランク判定用CSVのファイル名を取得する
     **/
    public static function getRankCsvName():String {
        var modeName = getModeString();
        var levelName = getLevelString();

        return 'assets/levels/rank_${modeName}_${levelName}.csv';
    }

    /**
     * ゲームモードを設定
     **/
    public static function setMode(m:GameMode):Void {
        _mode = m;
    }

    /**
     * ゲームモードを取得
     **/
    private static function get_mode():GameMode {
        return _mode;
    }

    /**
     * レベルを設定
     **/
    public static function setLevel(v:Int):Void {
        _level = v;
    }

    /**
     * レベルを取得
     **/
    private static function get_level():Int {
        return _level;
    }

    /**
     * ゲームを起動しての経過時間を取得する
     **/
    public static function getPasttime():Float {
        return flash.Lib.getTimer() * 0.001;
    }
}

