package jp.seconddgames.natsukiboost3.csv;

import jp.seconddgames.natsukiboost3.jp_2dgames.CsvLoader;

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
        var c:CsvLoader = new CsvLoader("assets/params/player.csv");

        speed_start = c.searchItemFloat("key", "speed_start", "value");
        speed_top = c.searchItemFloat("key", "speedtop_start", "value");

        accel_ratio = c.searchItemFloat("key", "speedtop_accel", "value");
        deceleration_ratio = c.searchItemFloat("key", "speedtop_deceleration", "value");
        brake_ratio = c.searchItemFloat("key", "brake_ratio", "value");

        speed_over_deceleration = c.searchItemFloat("key", "speed_over_deceleration", "value");

        damage_timer = c.searchItemInt("key", "damage_timer", "value");
        damagetop_base = c.searchItemFloat("key", "damagetop_base", "value");
        damagetop_inc = c.searchItemFloat("key", "damagetop_inc", "value");

        speedtop_deadline = c.searchItemFloat("key", "speedtop_deadline", "value");
        speedtop_max = c.searchItemFloat("key", "speedtop_max", "value");

        eat_se_timer = c.searchItemFloat("key", "eat_se_timer", "value");

        item_big_size = c.searchItemFloat("key", "item_big_size", "value");
        item_big_timer = c.searchItemFloat("key", "item_big_timer", "value");
        item_small_size = c.searchItemFloat("key", "item_small_size", "value");
        item_small_timer = c.searchItemFloat("key", "item_small_timer", "value");
        item_star_timer = c.searchItemFloat("key", "item_star_timer", "value");
        item_dash_addspeed = c.searchItemFloat("key", "item_dash_addspeed", "value");
        item_dash_timer = c.searchItemFloat("key", "item_dash_timer", "value");
        item_damage_val = c.searchItemFloat("key", "item_damage_val", "value");
        item_shield_count = c.searchItemInt("key", "item_shield_count", "value");
        item_gravity_length = c.searchItemFloat("key", "item_gravity_length", "value");
        item_gravity_power = c.searchItemFloat("key", "item_gravity_power", "value");

        combo_timer = c.searchItemFloat("key", "combo_timer", "value");

    }
}
