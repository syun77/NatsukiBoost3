package csv;

import jp_2dgames.CsvLoader;

/**
 * プレイヤーパラメータ
 **/
class CsvPlayer {

    public var speed_start:Float;         // 開始速度
    public var speed_top:Float;           // 開始時のトップスピード

    public var accel_ratio:Float;         // 加速割合
    public var deceleration_ratio:Float;  // 減速割合
    public var brake_ratio:Float;         // ブレーキボタンによる減速割合

    public var speed_over_deceleration:Float; // トップスピードを超えていた際の減速度

    public var damage_timer:Int;          // ダメージ時の加速できない時間
    public var damagetop_base:Float;      // トップスピードのダメージ初期値
    public var damagetop_inc:Float;       // トップスピードのダメージ累積値
    public var speedtop_max:Float;        // トップスピードの限界速度

    public var speedtop_deadline:Float;   // ゲームオーバーとなる速度
    public var eat_se_timer:Float;        // "eat"SEのウェイト時間

    public var item_big_size:Float;       // 拡大アイテムによるサイズの倍率
    public var item_big_timer:Float;      // 拡大アイテムが有効な時間（秒）
    public var item_small_size:Float;     // 縮小アイテムによるサイズの倍率
    public var item_small_timer:Float;    // 縮小アイテムが有効な時間（秒）
    public var item_star_timer:Float;     // 無敵アイテムが有効な時間（秒）
    public var item_dash_addspeed:Float;  // 加速アイテムにより加算される速度
    public var item_dash_timer:Float;     // 加速アイテムが有効な時間（秒）
    public var item_damage_val:Float;     // ダメージアイテムによるトップスピードの減少量
    public var item_shield_count:Int;     // シールドアイテムで防ぐことができるダメージの回数
    public var item_gravity_length:Float; // 重力アイテムが有効な距離
    public var item_gravity_power:Float;  // 重力アイテムにより引っ張られる力
    public var combo_timer:Float;         // コンボが有効な時間（秒）


    public function new() {
        var csv:CsvLoader = new CsvLoader("assets/params/player.csv");

        speed_start = csv.searchItemFloat("key", "speed_start", "value");
        speed_top = csv.searchItemFloat("key", "speedtop_start", "value");

        accel_ratio = csv.searchItemFloat("key", "speedtop_accel", "value");
        deceleration_ratio = csv.searchItemFloat("key", "speedtop_deceleration", "value");
        brake_ratio = csv.searchItemFloat("key", "brake_ratio", "value");

        speed_over_deceleration = csv.searchItemFloat("key", "speed_over_deceleration", "value");

        damage_timer = csv.searchItemInt("key", "damage_timer", "value");
        damagetop_base = csv.searchItemFloat("key", "damagetop_base", "value");
        damagetop_inc = csv.searchItemFloat("key", "damagetop_inc", "value");

        speedtop_deadline = csv.searchItemFloat("key", "speedtop_deadline", "value");
        speedtop_max = csv.searchItemFloat("key", "speedtop_max", "value");

        eat_se_timer = csv.searchItemFloat("key", "eat_se_timer", "value");

        item_big_size = csv.searchItemFloat("key", "item_big_size", "value");
        item_big_timer = csv.searchItemFloat("key", "item_big_timer", "value");
        item_small_size = csv.searchItemFloat("key", "item_small_size", "value");
        item_small_timer = csv.searchItemFloat("key", "item_small_timer", "value");
        item_star_timer = csv.searchItemFloat("key", "item_star_timer", "value");
        item_dash_addspeed = csv.searchItemFloat("key", "item_dash_addspeed", "value");
        item_dash_timer = csv.searchItemFloat("key", "item_dash_timer", "value");
        item_damage_val = csv.searchItemFloat("key", "item_damage_val", "value");
        item_shield_count = csv.searchItemInt("key", "item_shield_count", "value");
        item_gravity_length = csv.searchItemFloat("key", "item_gravity_length", "value");
        item_gravity_power = csv.searchItemFloat("key", "item_gravity_power", "value");

        combo_timer = csv.searchItemFloat("key", "combo_timer", "value");
    }
}
