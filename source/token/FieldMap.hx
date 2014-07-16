package token;

import Reg.GameMode;
import jp_2dgames.Layer2D;
import jp_2dgames.TmxLoader;
/**
 * ステージマップ管理
 **/
class FieldMap {

    // チップの幅
    public static inline var _tileWidth:Int = 8;
    // チップの高さ
    public static inline var _tileHeight:Int = 8;

    public var width(get, null):Int;
    public var height(get, null):Int;
    public var tileWidth(get, null):Int;
    public var tileHeight(get, null):Int;

    private var _tmx:TmxLoader;

    public function new() {
        _tmx = new TmxLoader();
        var fTmx = "assets/levels/" + Reg.getLevelString() + ".tmx";
        _tmx.load(fTmx);

        var mode = Reg.mode;
        switch(mode) {
            case GameMode.Fix:
            case GameMode.Random:
            case GameMode.Endless:
        }

    }

    public function getRealWidth():Int { return width * tileWidth; }
    public function getRealHeight():Int { return height * tileHeight; }
    public function toRealX(i:Float, ofsW:Int=0):Float {
        if(ofsW == 0) {
            // オフセットなし
            return i * tileWidth;
        }

        return i * tileWidth - (ofsW/2) - tileWidth/2;
    }
    public function toRealY(j:Float, ofsH:Int=0):Float {
        if(ofsH == 0) {
            // オフセットなし
            return j * tileHeight;
        }

        return j * tileHeight - (ofsH/2) - tileHeight/2;
    }
    public function getLayer(idx:Int):Layer2D {
        return _tmx.getLayer(idx);
    }

    private function get_width():Int { return _tmx.width; }
    private function get_height():Int { return _tmx.height; }
    private function get_tileWidth():Int { return _tileWidth; }
    private function get_tileHeight():Int { return _tileHeight; }
}
