package token;

import jp_2dgames.TmxLoader;
import jp_2dgames.TextUtil;
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

    private var _width:Int = 0;
    private var _height:Int = 0;
    private var _tmx:TmxLoader;
    private var _layer:Layer2D;

    /**
     * 固定マップをロード
     **/
    public function new() {

        switch(Reg.mode) {
            case GameMode.Fix:
                // 固定マップをロード
                _tmx = new TmxLoader();
                var fTmx = "assets/levels/" + Reg.getLevelString() + ".tmx";
                _tmx.load(fTmx);
                _width = _tmx.width;
                _height = _tmx.height;

            case GameMode.Random:
                _width = 0;
                var layers = new Array<Layer2D>();
                for(i in 1...4) {
                    var fTmx = "assets/levels/random/" + TextUtil.fillZero(i, 3) + ".tmx";
                    var tmx = new TmxLoader();
                    tmx.load(fTmx);
                    _width += tmx.width;
                    _height = tmx.height;
                    layers.push(tmx.getLayer(0));
                }
                _layer = new Layer2D(_width, _height);
                var x:Int = 0;
                for(layer in layers) {
                    _layer.copyRectDestination(layer, x, 0);
                    x += layer.width;
                }
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
        switch(Reg.mode) {
            case GameMode.Fix:
                // 最初にロードしたマップをそのまま返す
                return _tmx.getLayer(idx);
            case GameMode.Random:
                return _layer;
            case GameMode.Endless:
                return null;
        }
    }

    private function get_width():Int { return _width; }
    private function get_height():Int { return _height; }
    private function get_tileWidth():Int { return _tileWidth; }
    private function get_tileHeight():Int { return _tileHeight; }
}
