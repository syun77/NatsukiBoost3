package ss;

import flixel.FlxG;
import flixel.interfaces.IFlxDestroyable;
import haxe.Json;
import openfl.Assets;
/**
 * SS用テクスチャ管理
 **/
class SSTexturePackerDataMgr implements IFlxDestroyable {
    private var _pool:Array<SSTexturePackerData>;
    private var _animationMax:Int = 0;

    public var animationMax(get, null):Int;

    public function new(SSJson:String, ImageDir:String) {

        // JSON読み込み
        var data:Dynamic = Json.parse(Assets.getText(SSJson));

        // 画像生成
        _pool = new Array<SSTexturePackerData>();
        var images = data[0].images;
        for(image in Lambda.array(images)) {
            // 画像ファイルのパスを作成
            var assetName = ImageDir + "/" + image;
            var tex = new SSTexturePackerData(SSJson, assetName);
            _pool.push(tex);
        }

        // アニメーションの数を数える
        var animation = data[0].animation;
        var ssa = animation.ssa;
        for (allframe in Lambda.array(ssa)) {
            // 1フレーム内の最大アニメを数える
            var cntAnim = Lambda.array(allframe).length;
            if(cntAnim > _animationMax) {
                // アニメーション最大数更新
                _animationMax = cntAnim;
            }
        }

    }

    public function getTexture(Index:Int):SSTexturePackerData {
        return _pool[Index];
    }

    public function get_animationMax():Int {
        return _animationMax;
    }

    public function destroy():Void {
        for(tex in _pool) {
            tex.destroyForce();
        }
        _pool = null;
    }
}
