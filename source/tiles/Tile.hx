package tiles;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;

/**
 * ...
 * @author Egar Almeida
 */

 typedef TileStructure = {
	var health:Int;
	var regenRate:Int;
	var regenDelay:Float;
	var maxHealth:Int;
}
 
class Tile extends FlxSprite
{

	private var _tile:TileStructure = { health: 100, maxHealth: 100, regenRate: 10, regenDelay: 0.5 };

	private var _health:Float;
	private var _regenTimer:Float;

	public var index:Int;
	
	public function new(X:Float = 0, Y:Float = 0, Index:Int, Tilemap:FlxTilemap) 
	{
		super(X, Y);
		//trace("Tile created. Index is " + Index);
		// Graphic
		loadGraphic(Reg.TILE_CRACKS, true, 32, 32, true);
		
		index = Index;
		
		_regenTimer = 0;
		_health = _tile.maxHealth;
		
		// Animations
		animation.add("1", [0], 0, false);
		animation.add("2", [1], 0, false);
		animation.add("3", [2], 0, false);
		animation.add("4", [3], 0, false);
	}
	
	/**
	 * Adds damage to the tile
	 * 
	 * @param	damage
	 * @return	true if the tile was killed
	 */
	public function addDamage(damage:Float):Bool
	{
		_regenTimer = 0;
		
		_health = _health - damage;

		if (_health <= 0)
		{
			FlxG.sound.play(AssetPaths.tile_destroyed__wav);
			kill();
			return true;
		} else
		{
			return false;
		}
	}
	
	/**
	 * Changes the graphic according to the current amount of health
	 */
	private function animate():Void
	{
		if (_health < _tile.maxHealth)
		{
			if (_health >= Utils.percentOf(66, _tile.maxHealth))
			{
				animation.play("2");
			} else if (_health >= Utils.percentOf(33, _tile.maxHealth) && _health < Utils.percentOf(66, _tile.maxHealth)) {
				animation.play("3");
			} else {
				animation.play("4");
			}
		} else {
			animation.play("1");
		}
	}
	
	override public function update():Void
	{
		// If health is not full, regenerate over time
		if (_health < _tile.maxHealth) 
		{
			_regenTimer += FlxG.elapsed;
			if (_regenTimer >= _tile.regenDelay)
			{
				_regenTimer -= _tile.regenDelay;
				_health += _tile.regenRate;
				
				// If health is full, then there's no reason to exist anymore. This is the emo condition.
				if (_health >= _tile.maxHealth)
				{
					kill(); 
				}
			}
			
			animate();
		}
		
		super.update();
	}
	
	override public function revive():Void
	{
		super.revive();
		_regenTimer = 0;
		_health = _tile.maxHealth;
		animate();
		//trace("Tile revived. Index is " + index);
	}
	
	override public function destroy():Void
	{
		
		super.destroy();
	}
	
}