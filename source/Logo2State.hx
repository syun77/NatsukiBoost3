package ;
import OpenningState;
import flixel.FlxG;
import flixel.FlxState;
import ss.FlxSSPlayerMgr;
import ss.SSTexturePackerDataMgr;

/**
 * SpriteStudioロゴ表示
 **/
class Logo2State extends FlxState {
    private var _texs:SSTexturePackerDataMgr;
    private var _sprites:FlxSSPlayerMgr;
    override public function create() {
        super.create();

        var ss  = "assets/ss/logo2/ss_logo_anime_1_root.json";
        var dir = "assets/ss/logo2";
        _texs = new SSTexturePackerDataMgr(ss, dir);
        _sprites = new FlxSSPlayerMgr();
        for(i in 0..._texs.animationMax) {
            _sprites.addSSPlayer(FlxG.width/2, FlxG.height/2, ss, _texs, i);
        }
        this.add(_sprites);
        _sprites.play(1);
    }

    override public function update():Void {
        super.update();
        if(_sprites.isStop()) {
//            FlxG.switchState(new Logo2State());
            FlxG.switchState(new OpenningState());
        }
    }
}
