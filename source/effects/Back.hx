package effects;
import flixel.FlxG;
import token.Meteor;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

/**
 * 背景管理
 **/
class Back extends FlxGroup {

    private var _back:FlxSprite;
    private var _meteors:FlxTypedGroup<Meteor>;
    private var _timer:Int = 0;

    public function new() {
        super();
        _back = new FlxSprite(0, 0, "assets/images/bg.png");
        _back.scrollFactor.set(0, 0);
        this.add(_back);

        _meteors = new FlxTypedGroup<Meteor>(128);
        for(i in 0..._meteors.maxSize) {
            _meteors.add(new Meteor());
        }
        this.add(_meteors);
    }

    override public function update():Void {
        super.update();

        _timer++;
        if(_timer%30 == 0) {
            var meteor:Meteor = _meteors.recycle();
            meteor.init(0, FlxG.height);
        }
    }

    public function setDanger(b:Bool):Void {

        // ピンチチェック
        if(_back.color != FlxColor.WHITE) {
            _back.color = FlxColor.WHITE;
        }
        if(b) {
            // 背景を赤くする
            _back.color = FlxColor.RED;
        }
    }
}
