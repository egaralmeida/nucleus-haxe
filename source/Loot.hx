package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxVelocity;

/**
 * Loot
 * @author Egar Almeida
 */

enum LootEnum 
{
	TileDirt;
	TileXiridium;
}
 
class Loot extends FlxSprite
{
	
	public var lootAmount:Int = 0;
	
	private var _maxCapacity:Float = 100;
	private var _lootType:LootEnum;
	private var _targetX:Float;
	private var _targetY:Float;
	
	private var _indicator:FlxText;
	private var _hudGroup:FlxGroup;
	
	public function new(HudGroup:FlxGroup)
	{
		super();
		trace("New called " + x + ", " + y);
		_hudGroup = HudGroup;
		
		_indicator = new FlxText();
		_indicator.setFormat(null, 8, 0x008000, "center", FlxText.BORDER_NONE, 0x000000, true);
		_hudGroup.add(_indicator);
	}
	
	public function start(X:Float = 0, Y:Float = 0, TargetX:Float = 0, TargetY:Float = 0, LootType:LootEnum, LootAmount:Int = 1):Void
	{
		//trace("Start called. XY: " + X + ", " + Y + " TargetXY: " + TargetX + ", " + TargetY + " LootType: " + LootType + " LootAmount: " + LootAmount);
		lootAmount = LootAmount;
		x = X;
		y = Y;
		_targetX = TargetX;
		_targetY = TargetY;
		
		// We only load the graphic if it's different than the one we loaded before recycling
		if (LootType != _lootType)
		{
			_lootType = LootType;

			switch (_lootType)
			{
				case TileDirt:
					loadRotatedGraphic(Reg.LOOT_TILE_DIRT, 36, -1, false, true);
				
				case TileXiridium:
					trace("I'm some TileXiridium loot!");
			}
		}
	
		angularVelocity = 90;
		elasticity = 1;
		acceleration.x = acceleration.y = 0;
		
		var minDrag:Int = 50;
		var maxDrag:Int = 200;
		var minSpeed:Int = 100;
		var maxSpeed:Int = 200;
		var dispersion:Int = 50;
		
		FlxVelocity.moveTowardsPoint(this, FlxPoint.get(_targetX + FlxRandom.intRanged( -dispersion, dispersion), _targetY + FlxRandom.intRanged( -dispersion, dispersion)), FlxRandom.intRanged(minSpeed, maxSpeed), 0);
		drag.x = drag.y = FlxRandom.intRanged(minDrag, maxDrag);
	}
	
	
	override public function update():Void
	{
		if (lootAmount > 1)
		{
			_indicator.text = Std.string(lootAmount);
			_indicator.setPosition(x + width - _indicator.get_width() / 2, y + height - _indicator.get_height() / 2);
		}
		
		super.update();
	}
	
	override public function kill():Void
	{
		_indicator.text = "";
		super.kill();
	}
	
	override public function destroy():Void
	{
		//_indicator.destroy();
		
		super.destroy();
	}
}