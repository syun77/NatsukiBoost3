package;

import Reg.GameMode;
import util.Snd;
import flixel.FlxSprite;
import flixel.util.FlxStringUtil;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

private enum State {
    Main; // メイン
    Select; // ボタン選択中
    Decide; // ボタンを選択した
}
/**
 * タイトル画面
 */
class MenuState extends FlxState {

    private static inline var TIMER_TO_LOGO = 15; // 15秒間放置でロゴ画面へ戻る

    private var _timer:Int = 0;
    private var _state:State = State.Main;
    private var _bDecide:Bool = false;
    private var _idxDecide:Int = -1;
    private var _btnList:Array<FlxButton>;

    private var _texts:Array<FlxText>;
    private var _natsuki:FlxSprite;

    private var _bg:FlxSprite;
    private var _charctor:FlxSprite;
    private var _logo:FlxSprite;
    private var _wafers:Array<FlxSprite>;

    private var _tPast:Float = 0; // 経過時間
    private var _mouseX:Float = 0;
    private var _mouseY:Float = 0;

    /**
	 * 生成
	 */
    override public function create():Void {
        super.create();

        _bg = new FlxSprite();
        _bg.loadGraphic("assets/images/title/bg.png");
        _bg.x = -FlxG.width*2/3;
        FlxTween.tween(_bg, {x:0}, 15, {ease:FlxEase.sineOut});
        _bg.alpha = 0.25;
        FlxTween.tween(_bg, {alpha:1}, 3, {ease:FlxEase.sineOut, startDelay:2});
        this.add(_bg);

        _charctor = new FlxSprite();
        _charctor.loadGraphic("assets/images/title/charctor.png");
        _charctor.alpha = 0;
        FlxTween.tween(_charctor, {alpha:1}, 2, {ease:FlxEase.expoOut, startDelay:0.25});
        this.add(_charctor);

        // ロゴ
        _logo = new FlxSprite();
        _logo.loadGraphic("assets/images/title/logo.png");
        _logo.x = FlxG.width/2 - _logo.width/2;
        _logo.y = 8;
        _logo.scale.set(5, 0);
        var delay = 0;
        FlxTween.tween(_logo.scale, {x:1, y:1}, 1, {ease:FlxEase.expoOut, startDelay:delay});
        this.add(_logo);

        // ウエハース
        _wafers = new Array<FlxSprite>();
        for(i in 1...6) {
            var index = 6 - i;
            var wafer = new Wafer(index);
            this.add(wafer);
        }

        // テキスト
        var _txtCopy = new FlxText(0, FlxG.height-16, FlxG.width);
        _txtCopy.text = "(c)2014 Alpha Secret Base";
        _txtCopy.alignment = "center";
        this.add(_txtCopy);

        // ボタン
        _btnList = new Array<FlxButton>();

//        var x = FlxG.width/2-40;
        var x = FlxG.width/2-80;
        var x2 = x + 80;
        var y = FlxG.height/2+24;
        var dy = 24;
        var _btn1 = new FlxButton( x, y, "EASY", _btnEasy);
        var _btn4 = new FlxButton( x2, y, "EASY", _btnEasyRandom);
        y += dy;
        var _btn2 = new FlxButton( x, y, "NORMAL", _btnNormal);
        var _btn5 = new FlxButton( x2, y, "NORMAL", _btnNormalRandom);
        y += dy;
        var _btn3 = new FlxButton( x, y, "HARD", _btnHard);
        var _btn6 = new FlxButton( x2, y, "HARD", _btnHardRandom);

        // チュートリアルボタン
        var _btn99 = new FlxButton( FlxG.width-80, FlxG.height-24, "TUTORIAL", _btnTutorial);
        _btnList.push(_btn1);
        _btnList.push(_btn2);
        _btnList.push(_btn3);
        _btnList.push(_btn4);
        _btnList.push(_btn5);
        _btnList.push(_btn6);
        _btnList.push(_btn99);

        var i = 0;
        for(btn in _btnList) {
            btn.color = FlxColor.AZURE;
            btn.label.color = FlxColor.AQUAMARINE;

            this.add(btn);
            var px = btn.x;
            btn.x = -btn.width;
            var delay2 = i * 0.125;
            FlxTween.tween(btn, {x:px}, 1, {ease:FlxEase.expoOut, startDelay:delay2});
            i++;
        }

        // ハイスコア表示
        x += 80 + 4;
        y = FlxG.height/2+24+4;
        _texts = new Array<FlxText>();
        for(i in 1...4) {
            var hiscore = Reg.getHiScore(i);
            var hitime = Reg.getTime(i);
            var rank = Reg.getRank(i);

            var txt:FlxText = new FlxText(x, y, FlxG.width);
            txt.text = "(" + rank + ") " + hiscore + " - TIME: " + FlxStringUtil.formatTime(hitime/1000, true);
            txt.color = FlxColor.SILVER;
            y += dy;

            txt.visible = false;
//            this.add(txt);
            _texts.push(txt);
        }

        // タイトル画面BGM再生
        Snd.playMusic("title");

    }

    /**
	 * 破棄
	 */
    override public function destroy():Void {
        super.destroy();
    }

    private function _updateElapsed():Void {
        _tPast += FlxG.elapsed;
        if(FlxG.mouse.x != _mouseX || FlxG.mouse.y != _mouseY) {
            // 何らかの入力があるので経過時間をリセット
            _tPast = 0;
        }
        _mouseX = FlxG.mouse.x;
        _mouseY = FlxG.mouse.y;
    }
    /**
	 * 更新
	 */
    override public function update():Void {
        super.update();

        // 経過時間を計算する
        _updateElapsed();
        if(_tPast > TIMER_TO_LOGO) {
            // 一定時間放置したのでロゴへ戻る
            FlxG.switchState(new LogoState());
            return;
        }

        switch(_state) {
            case State.Main:
                _timer++;
                _state = State.Select;

            case State.Select:
                // 決定待ち
                _timer++;
                if(_bDecide) {
                    _state = State.Decide;
                    _timer = 0;
                    Snd.playSe("push");
                    if(FlxG.sound.music != null) {
                        FlxG.sound.music.stop();
                    }
                    var i = 0;
                    for(btn in _btnList) {
                        if(i != _idxDecide) {
                            btn.visible = false;
                        }
                        i++;
                    }
                }

            case State.Decide:
                _timer++;
                if(_timer > 30) {
                    FlxG.switchState(new PlayState());
                }
        }

        // やり直し
//        if(FlxG.keys.justPressed.R) {
//            FlxG.resetState();
//        }
    }

    // ボタンを押した
    private function _btnEasy():Void {
        Reg.setLevel(1);
        Reg.setMode(GameMode.Fix);
        _bDecide = true;
        _idxDecide = 0;
    }
    private function _btnNormal():Void {
        Reg.setLevel(2);
        Reg.setMode(GameMode.Fix);
        _bDecide = true;
        _idxDecide = 1;
    }
    private function _btnHard():Void {
        Reg.setLevel(3);
        Reg.setMode(GameMode.Fix);
        _bDecide = true;
        _idxDecide = 2;
    }
    private function _btnEasyRandom():Void {
        Reg.setLevel(1);
        Reg.setMode(GameMode.Random);
        _bDecide = true;
        _idxDecide = 3;
    }
    private function _btnNormalRandom():Void {
        Reg.setLevel(2);
        Reg.setMode(GameMode.Random);
        _bDecide = true;
        _idxDecide = 4;
    }
    private function _btnHardRandom():Void {
        Reg.setLevel(3);
        Reg.setMode(GameMode.Random);
        _bDecide = true;
        _idxDecide = 5;
    }
    private function _btnTutorial():Void {
        // チュートリアル画面呼び出し
        FlxG.switchState(new TutorialState());
    }
}

class Wafer extends FlxSprite {
    private var _timer:Float;
    public function new(index:Int) {
        super();
        loadGraphic('assets/images/title/wafer${index}.png');
        alpha = 0;
        var delay = 1 + (5 - index) * 0.25;
        FlxTween.tween(this, {alpha:1}, 1, {ease:FlxEase.expoOut, startDelay:delay});
        var dy = 20 - index * 3;
        _timer = 1 + 0.25 * index;
        FlxTween.tween(velocity, {y:dy}, _timer, {ease:FlxEase.expoOut, complete:_cbEnd});
    }

    private function _cbEnd(tween:FlxTween):Void {
        var dy = velocity.y * -1;
        velocity.y = 0;
        FlxTween.tween(velocity, {y:dy}, _timer, {ease:FlxEase.expoOut, complete:_cbEnd});
    }

}