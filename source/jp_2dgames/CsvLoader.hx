package jp_2dgames;

import flixel.FlxG;
import openfl.Assets;

/**
 * CSV読み込みクラス
 **/
class CsvLoader {

    private var _filepath:String = "";
    private var _header: Array<String>;
    private var _types: Array<String>;
    private var _datas: Map<Int, Map<String, String>>;

    public function new() {
    }

    /**
     * CSVを読み込む
     * @param filepath CSVのファイルパス
     **/
    public function load(filepath:String):Void {
        _datas = new Map<Int, Map<String, String>>();
        var text:String = Assets.getText(filepath);
        if(text == null) {
            FlxG.log.warn("CsvLoader.load() text is null. file:'" + filepath + "''");
            return;
        }
        _filepath = filepath;
        var row = 0;
        for(line in text.split("\n")) {
            if(line == "") { continue; }

            var arr:Array<String> = line.split(",");
            switch(row) {
            case 0:
                _header = line.split(",");
            case 1:
                _types = line.split(",");
            default:
                var nId = 0;
                var col = 0;
                var data:Map<String, String> = new Map<String, String>();
                for(k in _header) {
                    var v:String = arr[col];
                    if(k == "id") {
                        nId = Std.parseInt(v);
                    }
                    data.set(k, v);
                    col++;
                }
                _datas.set(nId, data);
            }
            row++;
        }
    }

    /**
     * データ数を取得する
     * @return データ数
     **/
    public function size():Int {
        var cnt:Int = 0;
        for(k in _datas.keys()) {
            cnt++;
        }
        return cnt;
    }

    /**
     * 指定のIDが存在するかどうかチェックする
     * @param id id
     * @return 存在すればtrue
     **/
    public function hasId(id:Int):Bool {
        return _datas.exists(id);
    }

    /**
     * id配列を取得する
     **/
    public function keys():Iterator<Int> {
        return _datas.keys();
    }

    /**
     * 値を文字列として取得する
     * @param id id
     * @param key キー文字列
     * @return 値
     **/
    public function getString(id:Int, key:String):String {
        if(_datas.exists(id) == false) {
            throw "Error: Not found id = " + id;
        }
        var data:Map<String, String> = _datas.get(id);
        if(data.exists(key) == false) {
            throw "Error: Not found key = " + key;
        }
        return data.get(key);
    }

    /**
     * 値を数値として取得する
     * @param id id
     * @param key キー文字列
     * @return 値
     **/
    public function getInt(id:Int, key:String):Int {
        return Std.parseInt(getString(id, key));
    }
    public function dump():Void {
        trace("<CSVLoader> file='"+_filepath + "'");
        var str = "";
        for(s in _header) {
            str += s + ",";
        }
        trace(str);

        str = "";
        for(s in _types) {
            str += s + ",";
        }
        trace(str);
        for(k in _datas.keys()) {
            var data = _datas.get(k);
            str = "";
            for(d in data) {
                str += d + ",";
            }
            trace(str);
        }
    }
}
