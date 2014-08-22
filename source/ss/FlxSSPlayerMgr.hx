package ss;

import flixel.group.FlxGroup;
/**
 * FlxSSPlayer管理
 **/
class FlxSSPlayerMgr extends FlxGroup {

    private var _pool:Array<FlxSSPlayer>;

    public function new() {
        super();
        _pool = new Array<FlxSSPlayer>();
    }

    public function addSSPlayer(X:Float, Y:Float, SSJson:String, Textures:SSTexturePackerDataMgr, AnimationID:Int):FlxSSPlayer {
        var spr = new FlxSSPlayer(X, Y, SSJson, Textures, AnimationID);
        _pool.push(spr);
        this.add(spr);
        return spr;
    }

    public function play(nPlay:Int=0):Void {
        for(spr in _pool) {
            spr.play(nPlay);
        }
    }

    public function isStop():Bool {
        for(spr in _pool) {
            if(spr.isStop() == false) {
                return false;
            }
        }

        return true;
    }

    override public function destroy():Void {

        if(_pool != null) {
            for(spr in _pool) {
                this.remove(spr);
                spr.destroy();
            }
            _pool = null;
        }
        super.destroy();
    }
}
