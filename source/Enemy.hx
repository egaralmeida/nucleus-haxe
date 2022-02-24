package;

import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.math.FlxAngle;
import flixel.math.FlxVelocity;

/**
 * Test Enemy base class
 * @author Egar Almeida
 */

 typedef EnemyStructure = {
	var speed:Float;
	var maxSpeed:Float;
	var acceleration:Float;
	var drag:Float;
}

class Enemy extends FlxSprite
{

	private var _enemyData:EnemyStructure;
	
	private var _speed:Float;
	private var _accelerationFactor:Float;
	private var _fireTimer:Float = 0;
	private var _shooting:Bool = false;

	private var _tilemap:FlxTilemap;
	private var _enemyObject:FlxSprite;
	
	public function new(X, Y, TileMap:FlxTilemap, EnemyObject:FlxSprite) 
	{
		super(X, Y);
		
		_tilemap = TileMap;
		_enemyObject = EnemyObject;
		
		_enemyData = Core.getJson("assets/data/enemies/enemy.json");
		
		// Graphic
		loadGraphic(Reg.ENEMY_SHIP, true, 52, 52, true);

		// Shrink bounding box
		width = 20;
		height = 20;

		// Adjust offset of bounding box
		offset.x = 16;
		offset.y = 16;
		
		// Movement Variables
		_speed = _enemyData.speed;
		_accelerationFactor = _enemyData.acceleration;
		drag.x = drag.y = 100; //_enemyData.drag;
		maxVelocity.x =	maxVelocity.y = _enemyData.maxSpeed;
		//maxAngular = 120;
		//angularDrag = 0; //800;
		
		// Animations
		animation.add("Idle", [0]);
		animation.add("Shooting", [1, 2, 3], 12);
		animation.add("Moving", [6, 7, 8], 12);
		animation.add("MovingShooting", [9, 10, 11], 12);
		
	}
	
	
	override public function update():Void
	{
		//angle = FlxAngle.angleBetween(this, _enemyObject, true);
		
		// Animate
		if (Math.abs(velocity.x) > 0 || Math.abs(velocity.y) > 0)
			if (_shooting)
				animation.play("MovingShooting");
			else
				animation.play("Moving");
		else
			if(_shooting)
				animation.play("Shooting");
			else
				animation.play("Idle");

		FlxVelocity.accelerateTowardsObject(this, _enemyObject, 1000, 10000, 10000);
		
		super.update();
	}
	
}