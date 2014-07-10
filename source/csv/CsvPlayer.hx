package csv;

import jp_2dgames.CsvLoader;

/**
 * プレイヤーパラメータ
 **/
class CsvPlayer {

    public var speed_start:Float;        // 開始速度
    public var speed_top:Float;          // 開始時のトップスピード

    public var accel_ratio:Float;        // 加速割合
    public var deceleration_ratio:Float; // 減速割合
    public var brake_ratio:Float;        // ダメージ時の減速割合

    public var damage_timer:Int;         // ダメージ時の加速できない時間

    public var eat_se_timer:Float;       // "eat"SEのウェイト時間

    public function new() {
        var csv:CsvLoader = new CsvLoader("assets/params/player.csv");

        speed_start = csv.searchItemFloat("key", "speed_start", "value");
        speed_top = csv.searchItemFloat("key", "speedtop_start", "value");

        accel_ratio = csv.searchItemFloat("key", "speedtop_accel", "value");
        deceleration_ratio = csv.searchItemFloat("key", "speedtop_decceleration", "value");
        brake_ratio = csv.searchItemFloat("key", "brake_ratio", "value");

        damage_timer = csv.searchItemInt("key", "damage_timer", "value");

        eat_se_timer = csv.searchItemFloat("key", "eat_se_timer", "value");

    }
}
