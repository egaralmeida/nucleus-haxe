package;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;

/**
 * Particle Manager
 * @author Egar Almeida
 */
class ParticleManager extends FlxBasic
{
	
	private var _tileParticles:FlxEmitter;
	private var _particleGroup:FlxTypedGroup<FlxEmitter>;
	
	public function new(ParticleGroup:FlxTypedGroup<FlxEmitter>) 
	{
		_particleGroup = ParticleGroup;
		_particleGroup.maxSize = 5;
		
		super();
	}
	
	public function explodeTile(Object:FlxObject):Void
	{
		_tileParticles = _particleGroup.recycle(FlxEmitter, [0, 0], false, false);
		_tileParticles.setXSpeed(-200, 200);
		_tileParticles.setYSpeed(-200, 200);
		_tileParticles.setRotation(-720, -720);
		_tileParticles.bounce = 0.5;
		_tileParticles.makeParticles(Reg.TILE_PARTICLES, 10, 10, true, 0.5);
		_tileParticles.at(Object);
		_tileParticles.start(true, 1, 0, 40);
		
		var i:FlxEmitter;
		var count:Int = 0;
		for (i in _particleGroup) 
		{
			if (i.on)
				count++;
		}
		//trace("emitters: " + _particleGroup.length + ", emitters on: " + count);
		
	}
}