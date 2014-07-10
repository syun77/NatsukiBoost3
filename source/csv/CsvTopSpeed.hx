package csv;
import jp_2dgames.CsvLoader;

/**
 * トップスピード上昇CSV
 **/
class CsvTopSpeed {

    private var _csv:CsvLoader;
    private var _count:Int = 9999999; // トップスピード上昇に必要な同属性ブロック数
    private var _value:Int = 2; // 上昇するトップスピード

    public function new() {
        _csv = new CsvLoader("assets/params/topspeed.csv");
    }

    public function getCount():Int { return _count; }
    public function getValue():Int { return _value; }

    /**
     * 必要なパラメータを更新
     **/
    public function update(topSpeed:Float):Void {

        // トップスピード上昇判定
        _count = 9999999;
        _value = 2;
        var search = function(data:Map<String,String>) {
            if(topSpeed < Std.parseFloat(data["speed"])) {
                _count = Std.parseInt(data["count"]);
                _value = Std.parseInt(data["value"]);
                return true;
            }
            return false;
        }
        _csv.foreachSearchID(search);
    }
}
