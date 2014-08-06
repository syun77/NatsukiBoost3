package;

import Reg.GameMode;
import util.Snd;
import flixel.addons.effects.FlxTrail;
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

    private var _txtPress:FlxText;
    private var _timer:Int = 0;
    private var _state:State = State.Main;
    private var _bDecide:Bool = false;
    private var _btnList:Array<FlxButton>;

    private var _texts:Array<FlxText>;
    private var _natsuki:FlxSprite;

    private var _bg:FlxSprite;
    private var _charctor:FlxSprite;
    private var _logo:FlxSprite;
    private var _wafers:Array<FlxSprite>;

    /**
	 * 生成
	 */
    override public function create():Void {
        super.create();

        _bg = new FlxSprite();
        _bg.loadGraphic("assets/images/title/bg.png");
        this.add(_bg);
        _charctor = new FlxSprite();
        _charctor.loadGraphic("assets/images/title/charctor.png");
        this.add(_charctor);
        _logo = new FlxSprite();
        _logo.loadGraphic("assets/images/title/logo.png");
        this.add(_logo);
        _wafers = new Array<FlxSprite>();
        for(i in 1...6) {
            var wafer = new FlxSprite();
            wafer.loadGraphic('assets/images/title/wafer${i}.png');
            _wafers.push(wafer);
            this.add(wafer);
        }

        // テキスト
        var _txtTitle = new FlxText(0, 64, FlxG.width);
        _txtTitle.size = 24;
        _txtTitle.alignment = "center";
        _txtTitle.text = "Natsuki Boost3";
        _txtTitle.borderStyle = FlxText.BORDER_OUTLINE_FAST;
        _txtPress = new FlxText(0, FlxG.height/2+36, FlxG.width);
        _txtPress.size = 16;
        _txtPress.alignment = "center";
#if MOBILE
        _txtPress.text = "tap to start";
#else
        _txtPress.text = "click to start";
#end
        var _txtCopy = new FlxText(0, FlxG.height-16, FlxG.width);
        _txtCopy.text = "(c)2014 Alpha Secret Base";
        _txtCopy.alignment = "center";

        this.add(_txtTitle);
        this.add(_txtPress);
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
        _btnList.push(_btn1);
        _btnList.push(_btn2);
        _btnList.push(_btn3);
        _btnList.push(_btn4);
        _btnList.push(_btn5);
        _btnList.push(_btn6);

        for(btn in _btnList) {
            btn.color = FlxColor.AZURE;
            btn.label.color = FlxColor.AQUAMARINE;

            this.add(btn);
            btn.visible = false;
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

    /**
	 * 更新
	 */
    override public function update():Void {
        super.update();

        switch(_state) {
            case State.Main:
                _timer++;
                _txtPress.visible = _timer%64 < 48;
                if(FlxG.mouse.justReleased) {

                    if(Reg.getLevelMax() == 0) {
                        // ステージ1のみの場合は、ステージ選択なしで開始
                        _state = State.Decide;
                        _timer = 0;
                        Snd.playSe("push");
                        if(FlxG.sound.music != null) {
                            FlxG.sound.music.stop();
                        }
                        return;
                    }

                    // ステージ選択へ
                    _txtPress.text = "Please select level.";
                    FlxTween.tween(_txtPress, {y:FlxG.height/2}, 1, {ease:FlxEase.expoOut});
                    var i = 0;
                    for(btn in _btnList) {
//                        if(i <= Reg.getLevelMax()) {
                            // クリアしたステージ+1のみ選択可能
                            btn.visible = true;
//                        }
                        i++;
                    }
                    i = 0;
                    for(txt in _texts) {
//                        if(i <= Reg.getLevelMax()) {
                            // クリアしたステージ+1のみ選択可能
                            txt.visible = true;
//                        }
                        i++;
                    }
                    _state = State.Select;
                }

            case State.Select:
                // 決定待ち
                _timer++;
                _txtPress.visible = _timer%64 < 48;
                if(_bDecide) {
                    _state = State.Decide;
                    _timer = 0;
                    Snd.playSe("push");
                    if(FlxG.sound.music != null) {
                        FlxG.sound.music.stop();
                    }
                    var i = 0;
                    for(btn in _btnList) {
                        if(i + 1 != Reg.level) {
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

//        if(FlxG.keys.justPressed.R) {
//            FlxG.resetState();
//        }
    }

    // ボタンを押した
    private function _btnEasy():Void {
        Reg.setLevel(1);
        Reg.setMode(GameMode.Fix);
        _bDecide = true;
    }
    private function _btnNormal():Void {
        Reg.setLevel(2);
        Reg.setMode(GameMode.Fix);
        _bDecide = true;
    }
    private function _btnHard():Void {
        Reg.setLevel(3);
        Reg.setMode(GameMode.Fix);
        _bDecide = true;
    }
    private function _btnEasyRandom():Void {
        Reg.setLevel(1);
        Reg.setMode(GameMode.Random);
        _bDecide = true;
    }
    private function _btnNormalRandom():Void {
        Reg.setLevel(2);
        Reg.setMode(GameMode.Random);
        _bDecide = true;
    }
    private function _btnHardRandom():Void {
        Reg.setLevel(3);
        Reg.setMode(GameMode.Random);
        _bDecide = true;
    }
}