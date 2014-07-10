package csv;

import jp_2dgames.CsvLoader;

/**
 * プレイヤーパラメータ
 **/
class CsvPlayer {

    public var speed_start:Float;
    public var speed_top:Float;
    public var accel_ratio:Float;
    public var deceleration_ratio:Float;
    public var brake_ratio:Float;

    public function new() {
        var csv:CsvLoader = new CsvLoader("assets/params/player.csv");

        speed_start = csv.searchItemFloat("key", "speed_start", "value");
        speed_top = csv.searchItemFloat("key", "speedtop_start", "value");
        accel_ratio = csv.searchItemFloat("key", "speedtop_accel", "value");
        deceleration_ratio = csv.searchItemFloat("key", "speedtop_decceleration", "value");
        brake_ratio = csv.searchItemFloat("key", "brake_ratio", "value");
    }
}
