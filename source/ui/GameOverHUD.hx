package ui;
import flixel.util.loaders.TexturePackerData;
import flixel.group.FlxGroup;
import flixel.util.FlxRandom;
import token.Player;
import flixel.FlxSprite;

/**
 * ゲームオーバー
 **/
class GameOverHUD extends FlxGroup {

    // ゲームオブジェクト
    private var _player:FlxSprite; // プレイヤー
    private var _munen:FlxSprite; // 無念
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

        _player.velocity.set(FlxRandom.floatRanged(-100, 100), -200);
        _player.acceleration.y = 400;
        _player.angularVelocity = FlxRandom.floatRanged(-90, 90);
        this.add(_player);
    }

    public function isEnd():Bool {
        return true;
    }

    /**
     * 更新
     **/
    override public function update():Void {
        super.update();
    }
}
