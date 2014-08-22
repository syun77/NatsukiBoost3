package ss;

import flixel.system.layer.Region;
import flixel.util.loaders.CachedGraphics;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.util.FlxAngle;
import haxe.Json;
import flixel.FlxSprite;
import openfl.Assets;

class SSAnimation {
    private static inline var IDX_PART_NO = 0; // パーツ番号
    private static inline var IDX_IMAGE_NO = 1; // テクスチャ番号
    private static inline var IDX_SOURCE_X = 2; // 切り取り座標(X)
    private static inline var IDX_SOURCE_Y = 3; // 切り取り座標(Y)
    private static inline var IDX_SOURCE_W = 4; // 切り取る幅
    private static inline var IDX_SOURCE_H = 5; // 切り取る高さ
    private static inline var IDX_DST_X = 6; // 描画座標(X)
    private static inline var IDX_DST_Y = 7; // 描画座標(Y)
    private static inline var IDX_DST_ANGLE = 8; // 回転(ラジアン)
    private static inline var IDX_DST_SCALE_X = 9; // スケール値(X)
    private static inline var IDX_DST_SCALE_Y = 10; // スケール値(Y)
    private static inline var IDX_ORIGIN_X = 11; // 原点(X)
    private static inline var IDX_ORIGIN_Y = 12; // 原点(Y)
    private static inline var IDX_FLIP_H = 13; // 左右反転フラグ
    private static inline var IDX_FLIP_V = 14; // 上下反転フラグ
    private static inline var IDX_ALPHA = 15; // 透明度
    private static inline var IDX_V0_X = 16; // ?X
    private static inline var IDX_V0_Y = 17; // ?Y

    public var imageNo(get, null):Int;
    public var sourceX(get, null):Int;
    public var sourceY(get, null):Int;
    public var sourceW(get, null):Int;
    public var sourceH(get, null):Int;
    public var x(get, null):Float;
    public var y(get, null):Float;
    public var angle(get, null):Float;
    public var scaleX(get, null):Float;
    public var scaleY(get, null):Float;
    public var originX(get, null):Float;
    public var originY(get, null):Float;
    public var flipH(get, null):Bool;
    public var flipV(get, null):Bool;
    public var alpha(get, null):Float;

    private var _data:Dynamic;
    private var _now:Int = 0;
    private var _no:Int = 0;
    public function new(data:Dynamic) {
        _data = data;
    }
    public function frameMax():Int {
        return _data.length;
    }
    public function setNo(no:Int):Void {
        _no = no;
    }
    public function setNow(frame:Int):Void {
        _now = frame;
    }
    public function getData(frame:Int=-1):Dynamic {
        if(frame < 0) {
            frame = _now;
        }
        return _data[frame][_no];
    }
    public function getDataValue(frame:Int=-1, idx:Int) {
        var data = getData(frame);

        if(data == null || idx >= cast(data).length) {
            // データが存在しない
            return 0.0;
        }
        return data[idx];
    }
    public function hasDataValue(frame:Int=-1, idx:Int):Bool {
        var data = getData(frame);

        if(data == null || idx >= cast(data).length) {
            // データが存在しない
            return false;
        }

        return true;
    }

    private function get_imageNo():Int {
        if(hasDataValue(-1, IDX_IMAGE_NO)) {
            return cast getDataValue(-1, IDX_IMAGE_NO);
        }
        return -1;
    }
    private function get_sourceX():Int {
        return cast getDataValue(-1, IDX_SOURCE_X);
    }
    private function get_sourceY():Int {
        return cast getDataValue(-1, IDX_SOURCE_Y);
    }
    private function get_sourceW():Int {
        return cast getDataValue(-1, IDX_SOURCE_W);
    }
    private function get_sourceH():Int {
        return cast getDataValue(-1, IDX_SOURCE_H);
    }
    private function get_x():Float {
        return cast getDataValue(-1, IDX_DST_X);
    }
    private function get_y():Float {
        return cast getDataValue(-1, IDX_DST_Y);
    }
    private function get_angle():Float {
        return cast getDataValue(-1, IDX_DST_ANGLE);
    }
    private function get_scaleX():Float {
        return cast getDataValue(-1, IDX_DST_SCALE_X);
    }
    private function get_scaleY():Float {
        return cast getDataValue(-1, IDX_DST_SCALE_Y);
    }
    private function get_originX():Float {
        return cast getDataValue(-1, IDX_ORIGIN_X);
    }
    private function get_originY():Float {
        return cast getDataValue(-1, IDX_ORIGIN_Y);
    }
    private function get_flipH():Bool {
        if(cast getDataValue(-1, IDX_FLIP_H)) {
            return true;
        }
        else {
            return false;
        }
    }
    private function get_flipV():Bool {
        if(cast getDataValue(-1, IDX_FLIP_V)) {
            return true;
        }
        else {
            return false;
        }
    }
    private function get_alpha():Float {
        if(hasDataValue(-1, IDX_ALPHA) == false) {
            // データなし
            return 1;
        }
        return getDataValue(-1, IDX_ALPHA);
    }
}

class FlxSSPlayer extends FlxSprite {

    // オフセット用パラメータ
    private var _ofsX:Float;
    private var _ofsY:Float;
    private var _ofsAlpha:Float = 1;

    private var _texs:SSTexturePackerDataMgr;
    private var _animation:SSAnimation = null;
    private var _frame:Int = 0;
    private var _frameMax:Int = 0;

    private var _bPlaying:Bool = false;
    private var _nPlay:Int = 0;
    private var _nPlayMax:Int = 0;

    private var _fps:Float = 0;
    private var _timer:FlxTimer = null;
    private var _prevAnimationTexName = "";

    public function new(X:Float, Y:Float, Description:String, Textures:SSTexturePackerDataMgr, FrameNo:Int) {
        super();

        _texs = Textures;

        // アニメーション読み込み
        loadAnimation(Description, FrameNo);

        var imageNo = _animation.imageNo;
        var name = _getAnimationTexName();
        // テクスチャを適用
        if(name == null) {
            // 何も表示しない
            visible = false;
        }
        else {
            _loadTexture(imageNo, false, name);
        }
        _prevAnimationTexName = name;

        // 描画オフセット設定
        setDrawOffset(X, Y);

        _timer = new FlxTimer(1.0/_fps, _updateAnimation, 0);

//        FlxG.watch.add(this, "_prevAnimationTexName");
    }

    private function _loadTexture(Index:Int = 0, Unique:Bool = false, ?FrameName:String):FlxSSPlayer {

        if(Index < 0) {
            return null;
        }

        var Data = _texs.getTexture(Index);

        if(Data.assetName == null) {
            return null;
        }
        // 焼きこみ回転アニメを初期化
        bakedRotationAngle = 0;

        if (Std.is(Data, CachedGraphics))
        {
            cachedGraphics = cast Data;
            if (cachedGraphics.data == null)
            {
                // テクスチャが破棄されている場合は何も表示しない
                visible = false;
                return null;
            }
        }
        else if (Std.is(Data, SSTexturePackerData))
        {
            cachedGraphics = FlxG.bitmap.add(Data.assetName, Unique);
            cachedGraphics.data = cast Data;
        }
        else
        {
            return null;
        }

        region = new Region();
        region.width = cachedGraphics.bitmap.width;
        region.height = cachedGraphics.bitmap.height;

        animation.destroyAnimations();
        updateFrameData();
        resetHelpers();

        if (FrameName != null) {
            animation.frameName = FrameName;
        }

        resetSizeFromFrame();
        centerOrigin();
        return this;
    }

    private function _getAnimationTexName():String {

        var imageNo = _animation.imageNo;

        if(imageNo < 0) {
            return null;
        }
        return "" + imageNo
            + ":" + _animation.sourceX
            + "," + _animation.sourceY
            + "," + _animation.sourceW
            + "," + _animation.sourceH;
    }

    override public function destroy():Void {
//        FlxG.watch.remove(this, "_prevAnimationTexName");
        super.destroy();
        _timer.destroy();
        _timer = null;
        _texs = null;
    }

    private function _updateAnimation(?timer:FlxTimer):Void {
        if(_bPlaying == false) {
            // 停止中
            return;
        }

        _animation.setNow(_frame);

        var name = _getAnimationTexName();
        if(name == null) {
            visible = false;
            _prevAnimationTexName = name;
        }
        if(name != _prevAnimationTexName) {
            var imageNo = _animation.imageNo;
            _loadTexture(imageNo, false, name);
            _prevAnimationTexName = name;
            visible = true;
        }

        // アニメーションパラメータ反映
        x = _ofsX + _animation.x;
        y = _ofsY + _animation.y;
        angle = -_animation.angle * FlxAngle.TO_DEG;
        scale.set(_animation.scaleX, _animation.scaleY);
        flipX = _animation.flipH;
        flipY = _animation.flipV;
        alpha = _animation.alpha * _ofsAlpha;
        offset.set(_animation.originX, _animation.originY);

        _frame++;
        if(_frame >= _frameMax) {
            _frame = 0;
            _nPlay++;
            if(_nPlayMax <= 0) {
                // 無限ループ
            }
            else if(_nPlay >= _nPlayMax) {
                // 再生終了
                _bPlaying = false;
            }
        }
    }

    public function setDrawOffset(X:Float, Y:Float):Void {
        _ofsX = X;
        _ofsY = Y;

        // 座標更新
        x = _ofsX + _animation.x;
        y = _ofsY + _animation.y;
    }

    public function setOffsetAlpha(Alpha:Float) {
        _ofsAlpha = Alpha;
    }

    public function loadAnimation(Animation:String, FrameNo:Int):Void {
        var data = Json.parse(openfl.Assets.getText(Animation));

        var anim = data[0].animation;
        var ssa = anim.ssa;

        // フレームレート
        _fps = anim.fps;

        // アニメーション番号を格納
        _animation = new SSAnimation(ssa);
        _animation.setNo(FrameNo);

        _frame = 0;
        _frameMax = _animation.frameMax();
    }

    public function play(cnt:Int=0):Void {
        _bPlaying = true;
        _nPlay = 0;
        _nPlayMax = cnt;
    }

    public function pause():Void {
        _bPlaying = false;
    }

    public function resume():Void {
        if(_nPlay < _nPlayMax) {
            _bPlaying = true;
        }
    }

    public function isPause():Bool {
        return _bPlaying == false;
    }

    public function isStop():Bool {
        if(isPause() && _nPlay >= _nPlayMax) {
            return true;
        }

        return false;
    }

    public function toggle():Void {
        if(isPause()) {
            pause();
        }
        else {
            resume();
        }
    }

    /**
     * 初期位置に戻す
     **/
    public function resetAnimation():Void {
        _frame = 0;
        _nPlay = 0;
        _nPlayMax = 0;

        // カラ回しする
        _bPlaying = true;
        update();
        _bPlaying = false;
        _frame = 0;
    }

    override public function update():Void {
        super.update();
//        _updateAnimation();
    }
}

