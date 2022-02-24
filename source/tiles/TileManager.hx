package tiles;

import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.math.FlxPoint;
import Loot;

/**
 * ...
 * @author Egar Almeida
 */

class TileManager extends FlxBasic
{

	private var _tileIndex:Array<Int>;
	private var _tiles:Array<Tile>;
	private var _tilemap:FlxTilemap;
	private var _tileGroup:FlxTypedGroup<Tile>;
	
	private var _particleManager:ParticleManager;
	private var _lootManager:LootManager;
	
	public function new(Tilemap:FlxTilemap, TileGroup:FlxTypedGroup<Tile>, ParticleMgr:ParticleManager, LootMgr:LootManager) 
	{
		//_tileIndex = new Array();
		_tiles = new Array();
		
		_tilemap = Tilemap;
		_tileGroup = TileGroup;
		
		_particleManager = ParticleMgr;
		_lootManager = LootMgr;
		
		super();
	}
	
	/**
	 * Drills a tile with the indicated tool, if it's drillable.
	 * 
	 * @param	X	x position in world coordinates
	 * @param	Y	y position in world coordinates
	 * @param	damage	the amount of damage to deal
	 */
	public function drillTile(X:Float, Y:Float, damage:Float):Void
	{
		// TODO: Add a parameter to set the tool with which we are drilling
		
		// Calculate index of the tile in the array
		var index:Int = _tilemap.getTileIndexByCoords(FlxPoint.get(X, Y));
		
		// Only do anything if the tile is not empty
		if (_tilemap.getTileByIndex(index) != 0)
		{
			// We find if the tile already exists by iterating the group
			var tile:Tile = findTile(index);
			
			if (tile == null)
			{
				// We didn't find the tile, let's recycle one from the group.
				tile = _tileGroup.recycle(Tile, [_tilemap.getTileCoordsByIndex(index, false).x, _tilemap.getTileCoordsByIndex(index, false).y, index, _tilemap], false, false);
				
				if (!tile.exists)
				{
					tile.index = index;
					tile.x = _tilemap.getTileCoordsByIndex(index, false).x;
					tile.y = _tilemap.getTileCoordsByIndex(index, false).y;
					tile.revive();
				}
			}
			
			// With our tile retrieved, we add damage
			if (tile.addDamage(damage))
			{
				// The tile is dead. Long live the tile. Well, no. Remove it.
				_particleManager.explodeTile(tile);
				_tilemap.setTileByIndex(index, 0);
				
				// Let's get some loot.
				_lootManager.dropLoot(tile.x, tile.y, TileDirt, 1);
				
			}
		}
	}
	
	private function findTile(index:Int):Tile
	{
		var it:Tile;
		for (it in _tileGroup) 
		{
			if (it.index == index)
			{
				// We found the tile
				return it;
			}
		}
		// We didn't find the tile
		return null;
	}
	
	/**
	 * Returns the index of the tile from its world coordinates
	 * @param	X
	 * @param	Y
	 * @return	the index of the tile
	 */
	public function getTileIndexByCoords(X:Float, Y:Float):Int
	{
		return Std.int(Y / PlayState.TILE_HEIGHT) * _tilemap.widthInTiles + Std.int(X / PlayState.TILE_WIDTH) ;
	}
	
	/**
	 * Returns the world coordinates at the upper-left corner of the tile
	 * @param	index	the index of the tile
	 * @return	a FlxPoint with the world coordinates of the tile
	 */
	public function getTileCoordsByIndex(index:Int):FlxPoint
	{
		return FlxPoint.get((index % _tilemap.widthInTiles) * PlayState.TILE_WIDTH, Std.int(index / _tilemap.widthInTiles) * PlayState.TILE_HEIGHT); 
	}
	
	override public function update():Void
	{
		super.update();
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}
	
}