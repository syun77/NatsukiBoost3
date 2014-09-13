package jp.seconddgames.natsukiboost3;

import jp.seconddgames.natsukiboost3.util.Snd;
import jp.seconddgames.natsukiboost3.ss.SSTexturePackerDataMgr;
import jp.seconddgames.natsukiboost3.ss.FlxSSPlayerMgr;
import flixel.FlxG;
import flixel.FlxState;

/**
 * A FlxState which can be used for the game's menu.
 */
class OpenningState extends FlxState {
    /**
	 * Function that is called up when to state is created to set it up. 
	 */

    private var _texs:SSTexturePackerDataMgr = null;
    private var _sprites:FlxSSPlayerMgr = null;

    private var _step:Int = 1;

    override public function create():Void {
        super.create();

        // BGM再生
        Snd.playMusic("001");

    }

    /**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
    override public function destroy():Void {
        super.destroy();
    }

    /**
	 * Function that is called once every frame.
	 */
    override public function update():Void {
        super.update();

        if(FlxG.mouse.pressed) {
            // スキップ
            FlxG.switchState(new MenuState());
            return;
        }

        if(_sprites == null || _sprites.isStop()) {

            if(_sprites != null) {
                _sprites.destroy();
            }
            if(_texs != null) {
                _texs.destroy();
            }

            if(_step == 4) {
                // フェードアウト
                FlxG.sound.music.fadeOut(7);
            }
            if(_step > 4) {
                FlxG.switchState(new MenuState());
                return;
            }

            var ss = "assets/ss/openning/scene" + _step + "_anime_1.json";
            var dir = "assets/ss/openning";
            _texs = new SSTexturePackerDataMgr(ss, dir);
            _sprites = new FlxSSPlayerMgr();
            for(i in 0..._texs.animationMax) {
                _sprites.addSSPlayer(FlxG.width/2, FlxG.height/2, ss, _texs, i);
            }
            this.add(_sprites);

            _sprites.play(1);

            _step++;
        }

    }
}