package jp.seconddgames.natsukiboost3.ui;
import jp.seconddgames.natsukiboost3.token.Player;
import jp.seconddgames.natsukiboost3.util.Snd;
import jp.seconddgames.natsukiboost3.Attribute;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.loaders.TexturePackerData;
import flixel.group.FlxGroup;
import flixel.util.FlxRandom;
import flixel.FlxSprite;

/**
 * ゲームオーバー
 **/
class GameOverHUD extends FlxGroup {

    // ゲームオブジェクト
    private var _player:FlxSprite; // プレイヤー
    private var _munen:FlxSprite; // 無念

    // 変数
    private var _bMunen:Bool = false;

    public function new(player:Player) {
        super();

        // プレイヤー生成
        var tex = new TexturePackerData("assets/images/player.json", "assets/images/player.png");
        _player = new FlxSprite(player.x, player.y);
        _player.loadGraphicFromTexture(tex);

        _player.animation.add("blue", [0]);
        _player.animation.add("red", [1]);

        if(player.getAttribute() == Attribute.Blue) {
            _player.animation.play("blue");
        }
        else {
            _player.animation.play("red");
        }

        _player.velocity.set(FlxRandom.float()*100, -200);
        _player.acceleration.y = 400;
        _player.angularVelocity = 480;
        if(FlxRandom.chanceRoll()) { _player.angularVelocity *= -1; }
        _player.angularDrag = 360;
        this.add(_player);

        // 吹き出し
        _munen = new FlxSprite();
        _munen.loadGraphic("assets/images/munen.png");
        _munen.visible = false;
        this.add(_munen);
    }

    public function isEnd():Bool {
        return _player.y > FlxG.height;
    }

    /**
     * 更新
     **/
    override public function update():Void {
        super.update();

        if(_bMunen == false) {
            if(_player.y > FlxG.height) {
                // 無念画像の表示
                Snd.playSe("dead");
                // 画面を1秒間、白フラッシュします
                FlxG.camera.flash(0xffFFFFFF, 1);
                // 画面を5%の揺れ幅で0.35秒間、揺らします
                FlxG.camera.shake(0.05, 0.35);
                _munen.x = _player.x;
                var py = FlxG.height - _munen.height - 16;
                _munen.y = FlxG.height;
                FlxTween.tween(_munen, {y:py}, 1, {ease:FlxEase.expoOut});
                _munen.visible = true;
                _bMunen = true;
            }
        }
    }
}
