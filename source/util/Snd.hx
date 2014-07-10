package util;
import flixel.system.FlxSound;
import flixel.FlxG;

/**
 * サウンド管理
 **/
class Snd {

    // BGM無効フラグ
    private static var _bBgmDisable = true;

    // SEワンショット再生用テーブル
    private static var _oneShotTable = new Map<String, SoundInfo>();

    /**
     * キャッシュする
     **/
    public static function cache():Void {

        FlxG.sound.volume = 1;

        FlxG.sound.cache("title");
        FlxG.sound.cache("001");
        FlxG.sound.cache("002");
        FlxG.sound.cache("003");
        FlxG.sound.cache("gameover");
    }

    public static function playSe(key:String, bOneShot:Bool=false, tWait:Float=0.1):FlxSound {

        if(bOneShot) {

            var info:SoundInfo = null;

            if(_oneShotTable.exists(key)) {
                info = _oneShotTable[key];
                var diff = Sys.time() - info.time;

                if(diff < tWait) {
                    // ちょっと待ってから再生する
                    return info.data;
                }

                info.data.kill();
                info.time = 0;
            }
            else {
                info = new SoundInfo();
            }

            var data:FlxSound = FlxG.sound.play(key);
            info.data = data;
            info.time = Sys.time();
            _oneShotTable[key] = info;

            return info.data;
        }
        else {
            return FlxG.sound.play(key);
        }

    }

    public static function playMusic(name:String, bLoop:Bool=true):Void {

        if(_bBgmDisable) {
            // BGM無効
            return;
        }

        var sound = FlxG.sound.cache(name);
        if(sound != null) {
            // キャッシュがあればキャッシュから再生
            FlxG.sound.playMusic(sound, 1, bLoop);
        }
        else {
            FlxG.sound.playMusic(name, 1, bLoop);
        }
    }
}

class SoundInfo {
    public var data:FlxSound = null;
    public var time:Float = 0;
}
