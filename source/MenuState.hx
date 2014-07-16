package;

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

    /**
	 * 生成
	 */
    override public function create():Void {
        super.create();

        _natsuki = new FlxSprite(FlxG.width, 0);
        _natsuki.loadGraphic("assets/images/natsuki01.png");
        this.add(_natsuki);
        this.add(new FlxTrail(_natsuki));
        FlxTween.tween(_natsuki, {x:0}, 1, {ease:FlxEase.expoOut});

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
        _txtCopy.text = "(c)2014 Alpha Secret Base / 2dgames.jp";
        _txtCopy.alignment = "center";

        this.add(_txtTitle);
        this.add(_txtPress);
        this.add(_txtCopy);

        // ボタン
        _btnList = new Array<FlxButton>();

//        var x = FlxG.width/2-40;
        var x = FlxG.width/2-80;
        var y = FlxG.height/2+24;
        var dy = 24;
        var _btn1 = new FlxButton( x, y, "EASY", _btnEasy);
        y += dy;
        var _btn2 = new FlxButton( x, y, "NORMAL", _btnNormal);
        y += dy;
        var _btn3 = new FlxButton( x, y, "HARD", _btnHard);
        _btnList.push(_btn1);
        _btnList.push(_btn2);
        _btnList.push(_btn3);

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
            this.add(txt);
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
                        if(i <= Reg.getLevelMax()) {
                            // クリアしたステージ+1のみ選択可能
                            btn.visible = true;
                        }
                        i++;
                    }
                    i = 0;
                    for(txt in _texts) {
                        if(i <= Reg.getLevelMax()) {
                            // クリアしたステージ+1のみ選択可能
                            txt.visible = true;
                        }
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
        _bDecide = true;
    }
    private function _btnNormal():Void {
        Reg.setLevel(2);
        _bDecide = true;
    }
    private function _btnHard():Void {
        Reg.setLevel(3);
        _bDecide = true;
    }
}