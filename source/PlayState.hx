package;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxObject;
import tiles.*;
import flash.display.BlendMode;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.tile.FlxCaveGenerator;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import haxe.Timer;
import openfl.Assets;
import haxe.Json;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.effects.particles.FlxEmitter;

#if (cpp || neko)
import sys.io.File;
#end

/**
 * Game State
 * @author Egar Almeida
 */
class PlayState extends FlxState
{
	public static inline var TILE_WIDTH:Int = 32;
	public static inline var TILE_HEIGHT:Int = 32;
	public static inline var MAP_WIDTH_IN_TILES:Int = 150;
	public static inline var MAP_HEIGHT_IN_TILES:Int = 150;
	public static var instance:PlayState;
	
	public var playerX:Float;
	public var playerY:Float;
	
	private var _hud:Hud;
	private var _player:Player;
	private var _tilemap:FlxTilemap;
	private var _bgTilemap:FlxTilemap;
	private var _backDrop:FlxBackdrop;
	private var _tileManager:TileManager;
	private var _lootManager:LootManager;
	private var _particleManager:ParticleManager;
	private var _darkness:FlxSprite;
	private var _canvas:FlxSprite;
	private var _enemy:Enemy;
	
	private var _stageObjects:FlxGroup;
	private var _hudGroup:FlxGroup;
	private var _tileGroup:FlxTypedGroup<Tile>;
	private var _particleGroup:FlxTypedGroup<FlxEmitter>;
	private var _lootGroup:FlxTypedGroup<Loot>;
	
	private var _canvasCleared:Bool = false;
	
	override public function create():Void
	{
		// This state
		instance = this;
		
		// Hud
		_hudGroup = new FlxGroup();
		_hud = new Hud(_hudGroup);
		
		// Create stage and its objects
		generateTilemap(false);
		
		// Create a canvas for primitives drawing
		_canvas = new FlxSprite();
		_canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, false);
		_canvas.scrollFactor.x = 0;
		_canvas.scrollFactor.y = 0;
		
		_particleGroup = new FlxTypedGroup();
		_particleManager = new ParticleManager(_particleGroup);
		
		_lootGroup = new FlxTypedGroup();
		_lootManager = new LootManager(_lootGroup, _hudGroup);
		
		_tileGroup = new FlxTypedGroup();
		_tileManager = new TileManager(_tilemap, _tileGroup, _particleManager, _lootManager);
		
		_player = new Player(_tileManager, _tilemap, _hud, _canvas);
		
		// Position the player in the center of the map, where there is a hole for the ship.
		_player.setPosition(MAP_WIDTH_IN_TILES * TILE_HEIGHT / 2, MAP_HEIGHT_IN_TILES * TILE_HEIGHT / 2);
		
		// Make some enemies
		_enemy = new Enemy(680, 2400, _tilemap, _player);
		
		// Group stage objects for faster collision detection. We don't add these groups to the stage.
		_stageObjects = new FlxGroup();
		_stageObjects.add(_player);
		_stageObjects.add(_lootGroup);
		_stageObjects.add(_enemy);
		
		// Create darkness
		_darkness = new FlxSprite(0,0);
		_darkness.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
		_darkness.scrollFactor.x = 0;
		_darkness.scrollFactor.y = 0;
		_darkness.blend = BlendMode.MULTIPLY;
		_darkness.alpha = 0.9;
		
		// Create light
		var light:Light = new Light(_player.getMidpoint().x, _player.getMidpoint().y, _darkness, _player);
		
		// Add everything to stage in rendering order
		add(_backDrop);
		add(_tilemap);
		add(_tileGroup);
		add(_lootGroup);
		add(_particleGroup);
		add(_canvas);
		add(_enemy);
		add(_player);
		add(light);
		add(_darkness);
		add(_hudGroup);
		add(_hud);
		
		// Setup Camera 
		FlxG.camera.setBounds(0, 0, MAP_WIDTH_IN_TILES * TILE_HEIGHT, MAP_HEIGHT_IN_TILES * TILE_HEIGHT, true);
		FlxG.camera.follow(_enemy, FlxCamera.STYLE_NO_DEAD_ZONE);

		super.create();
	}
	
	/**
	 * Generates the tilemap
	 */
	private function generateTilemap(loadFromFile:Bool = true, ?saveNewMap:Bool = false):Void
	{
		// We first load the backdrop
		_backDrop = new FlxBackdrop(Reg.BACKDROP, 0.15, 0.15, true, true);
		
		// Then we load or generate the tilemap
		var caveData:String = "";

		if (loadFromFile)
		{
			// Load a pre-generated map
			try
			{
				trace("Loading pre-generated cave...");
				caveData = fileStringToMapData(Assets.getText("assets/data/test.txt"));
			} 
			catch (msg:String)
			{
				trace("Nope. " + msg);
			}
		}
		else
		{
			// The cave generator creates the array
			trace("Generating random cave...");
			caveData = FlxCaveGenerator.generateCaveString(MAP_WIDTH_IN_TILES, MAP_HEIGHT_IN_TILES, 13, 0.6); // 10, 0.5
		}

		// We pass the array to FlxTilemap
		_tilemap = new FlxTilemap();
		_tilemap.widthInTiles = MAP_WIDTH_IN_TILES;
		_tilemap.heightInTiles = MAP_HEIGHT_IN_TILES;
		_tilemap.setCustomTileMappings([], [12, 15, 16], [[12, 28], [15, 31], [16, 32]]);
		trace("Loading generated cave...");
		_tilemap.loadMap(caveData, Reg.TILES, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
		
		if (!loadFromFile)
		{
			// We make a hole in the center of the map for the player to spawn.
			trace("Making player hole...");
			makeHole(MAP_WIDTH_IN_TILES * TILE_WIDTH / 2, MAP_HEIGHT_IN_TILES * TILE_HEIGHT / 2, 6);
			
			// Make the orbital caves
			trace("Making orbital caves...");
			var initialTime:Float = Timer.stamp();
			makeOrbitalCave(MAP_WIDTH_IN_TILES * TILE_WIDTH / 2, MAP_HEIGHT_IN_TILES * TILE_HEIGHT / 2, 50, 60, 5);
			//makeOrbitalCave(MAP_WIDTH_IN_TILES * TILE_WIDTH / 2, MAP_HEIGHT_IN_TILES * TILE_HEIGHT / 2, 150, 160, 7);
			//makeOrbitalCave(MAP_WIDTH_IN_TILES * TILE_WIDTH / 2, MAP_HEIGHT_IN_TILES * TILE_HEIGHT / 2, 260, 270, 9);
			var totalTime:Float = Timer.stamp() - initialTime;
			trace ("It took " + totalTime + " seconds to complete the action.");
			
		}
		
		// We deactivate auto tiling after the cave has been created
		//_tilemap.auto = FlxTilemap.OFF;
		
#if (cpp || neko)
		if (!loadFromFile && saveNewMap)
		{
			try
			{
				File.saveContent("test2.txt", Std.string(_tilemap.getData(true)));
			} 
			catch (msg:String)
			{
				trace("Nope. " + msg);
			}
		}
#end
	}
	
	private function fileStringToMapData(fileString:String):String
	{

		// We eliminate the [ ] from the string
		fileString = fileString.substr(1, fileString.length - 2);
		
		// Then we find the place where the newline should be inserted by counting commas
		var newString:String = "";
		var i:Int = 0;
		var j:Int = 0;
		for (i in 0...fileString.length)
		{
			newString = newString + fileString.charAt(i);
			
			if (fileString.charAt(i) == ",")
			{
				j++;
				if (j == MAP_WIDTH_IN_TILES + 1)
				{
					j = 0;
					newString = newString + "\n";
				}
			}
		}
		
		return newString;
	}
	
	private function makeHole(x:Float = 0, y:Float = 0, radius:Int = 10):Void
	{
		var i:Int = 0;
		var ir:Int = 0;
		for (i in 1...360)
		{
			for (ir in 0...radius)
			{
				var ix:Float = x + Math.cos(i * Math.PI / 180) * (ir * TILE_WIDTH);
				var iy:Float = y - Math.sin(i * Math.PI / 180) * (ir * TILE_HEIGHT);
				
				_tilemap.setTile(Math.floor(ix / TILE_WIDTH), Math.floor(iy / TILE_HEIGHT), 0);
			}
		}
	}
	
	private function makeOrbitalCave(x:Float, y:Float, distanceMin:Int, distanceMax:Int, radius:Int)
	{
		var j:Float = 0;
		while (j < 2 * Math.PI)
		{
			var jx:Float = x + Math.cos(j) * (Utils.rnd(distanceMin, distanceMax) * TILE_WIDTH);
			var jy:Float = y - Math.sin(j) * (Utils.rnd(distanceMin, distanceMax) * TILE_HEIGHT);
			
			j += 0.01745;
			
			makeHole(jx, jy, radius);
		}
	}
	
	override public function draw():Void
	{
		//FlxSpriteUtil.fill(_darkness, 0xff000000);
		super.draw();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		_hud.destroy();
		_player.destroy();
		_stageObjects.destroy();
		_tilemap.destroy();
		_tileManager.destroy();
		_tileGroup.destroy();
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		// Clear canvas every other frame
		if (_canvasCleared)
		{
			_canvasCleared = false;
		}
		else
		{
			FlxSpriteUtil.fill(_canvas, FlxColor.TRANSPARENT);
			FlxSpriteUtil.fill(_darkness, 0xff000000);
			_canvasCleared = true;
		}
		
		// Clear darkness
		//FlxSpriteUtil.fill(_darkness, 0xff000000);
		
		// Collide the stage objects with the walls
		FlxG.collide(_tilemap, _stageObjects);
		
		FlxG.overlap(_lootGroup, _lootGroup, lootOverlap);
		FlxG.overlap(_stageObjects, _lootGroup, playerLootOVerlap);
		
		// Store the player's coordinate for easier access between objects
		playerX = _player.x;
		playerY = _player.y;
		
		
		// Debug tracing of things and stuff!
		if (FlxG.keys.justPressed.P)
		{
			//trace(FlxG.camera.scroll.x + ", " + FlxG.camera.scroll.y);
			trace("Player is at (" + _player.x + ", " + _player.y + ")");
		}
		
		if (FlxG.keys.justPressed.K)
			_lootGroup.getFirstAlive().kill();
		
		super.update();
	}	
	
	private function lootOverlap(Object1:FlxObject, Object2:FlxObject):Void
	{
		if (Std.is(Object1, Loot) && Std.is(Object2, Loot))
		{
			cast(Object1, Loot).lootAmount += cast(Object2, Loot).lootAmount;
			Object2.kill();
		}
	}
	
	private function playerLootOVerlap(PlayerObject:FlxObject, LootObject:FlxObject):Void
	{
		// TODO Get the actual loot.
		if (Std.is(PlayerObject, Player) && Std.is(LootObject, Loot))
		{
			//PlayerObject.lootAmount += LootObject.lootAmount;
			LootObject.kill();
		}

	}
	
}