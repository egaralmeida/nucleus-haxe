package;

import flixel.group.FlxGroup;
import Loot;

/**
 * Loot Manager
 * @author Egar Almeida
 */

class LootManager
{
	
	private var _lootGroup:FlxTypedGroup<Loot>;
	private var _hudGroup:FlxGroup;
	
	public function new(LootGroup:FlxTypedGroup<Loot>, HudGroup:FlxGroup) 
	{
		_lootGroup = LootGroup;
		_hudGroup = HudGroup;
	}
	
	public function dropLoot(X:Float, Y:Float, LootType:LootEnum, LootAmount:Int = 1):Void
	{
		var loot:Loot = _lootGroup.recycle(Loot, [ _hudGroup ], false, false);
		loot.reset(X, Y);
		loot.start(X, Y, PlayState.instance.playerX, PlayState.instance.playerY, LootType, LootAmount);
	}
	
}