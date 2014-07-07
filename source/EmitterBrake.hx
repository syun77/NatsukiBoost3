package ;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

/**
 * ブレーキエフェクト
 **/
class EmitterBrake extends FlxEmitter {

    private static inline var SPEED:Int = 20;
    private static inline var SIZE:Int = 32;

    public function new() {
        super(0, 0, SIZE);

        this.setXSpeed(-SPEED, SPEED);
        this.setYSpeed(-SPEED, SPEED);
        this.gravity = 50;

        // パーティクル生成
        for(i in 0...SIZE) {
            this.add(new ParticleBrake());
        }
    }

    public function explode(px:Float, py:Float):Void {
        this.x = px;
        this.y = py;
        this.start(true, 1, 0, 1, 1);
        super.update();
    }
}

class ParticleBrake extends FlxParticle {
    private var _timer:Int = 0;
    public function new() {
        super();
        loadGraphic("assets/images/brake.png");
    }

    override public function update():Void {
        _timer++;
        visible = if(_timer%4 < 2) true else false;
        velocity.x *= 0.97;
        velocity.y *= 0.97;
        super.update();
    }
}
