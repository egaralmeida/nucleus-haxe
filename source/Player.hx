package;

/**
 * Player Class
 * @author Egar Almeida
 */

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxAngle;
import flixel.util.FlxSpriteUtil;

import tiles.*;

typedef WeaponStructure = {
	var damage:Float;
	var fireDelay:Float;
}

typedef PlayerStructure = {
	var speed:Float;
	var maxSpeed:Float;
	var acceleration:Float;
	var drag:Float;
	var keyUp:String;
	var keyDown:String;
	var keyLeft:String;
	var keyRight:String;
}

class Player extends FlxSprite
{

	private var _pickaxe:WeaponStructure = { damage: 50, fireDelay: 0.1 }
	private var _buildRay:WeaponStructure = { damage: 0, fireDelay: 0.1 }
	private var _playerData:PlayerStructure;
	private var _currentWeapon:WeaponStructure;
	
	private var _speed:Float;
	private var _accelerationFactor:Float;
	private var _fireTimer:Float = 0;
	private var _laserLineStyle:LineStyle = { color: FlxColor.RED, thickness: 3 };
		
	private var _tileManager:TileManager;
	private var _tilemap:FlxTilemap;
	private var _hud:Hud;
	private var _canvas:FlxSprite;
	
	private var _shooting:Bool;
	private var _buildingMode:Bool;
	
	public function new(TileMgr:TileManager, Tilemap:FlxTilemap, MyHud:Hud, Canvas:FlxSprite) 
	{
		super();
		
		// Establish our objects
		_tileManager = TileMgr;
		_tilemap = Tilemap;
		_hud = MyHud;
		_canvas = Canvas;

		// Get configuration parameters
		_playerData = Core.getJson("assets/data/players/player.json");
		_currentWeapon = _pickaxe;
		
		// Graphic
		loadGraphic(Reg.PLAYER_SHIP, true, 52, 52, true);

		// Shrink bounding box
		width = 20;
		height = 20;

		// Adjust offset of bounding box
		offset.x = 16;
		offset.y = 16;
		
		// Movement Variables
		_speed = _playerData.speed;
		_accelerationFactor = _playerData.acceleration;
		drag.x = _playerData.drag;
		drag.y = _playerData.drag;
		maxVelocity.x = _playerData.maxSpeed;
		maxVelocity.y = _playerData.maxSpeed;
		maxAngular = 120;
		angularDrag = 800;
		
		// Animations
		animation.add("Idle", [0]);
		animation.add("Shooting", [1, 2, 3], 12);
		animation.add("Moving", [6, 7, 8], 12);
		animation.add("MovingShooting", [9, 10, 11], 12);
	}
	
	override public function update():Void
	{
		// Reset accelerations
		//angularAcceleration = 0;
		acceleration.x = 0;
		acceleration.y = 0;
		
		// Reset flags
		_shooting = false;
		
		// Calculate angle to mouse pointer
		angle = Utils.getAngle(getMidpoint().x, getMidpoint().y, FlxG.mouse.x, FlxG.mouse.y);

		// Get and act to input
		// Strafe Left
		if (FlxG.keys.checkStatus(FlxG.keys.getKeyCode(_playerData.keyLeft), FlxKey.PRESSED))
			acceleration.x = -_speed * _accelerationFactor;
		
		// Strafe Right
		if (FlxG.keys.checkStatus(FlxG.keys.getKeyCode(_playerData.keyRight), FlxKey.PRESSED))
			acceleration.x = _speed * _accelerationFactor;
		
		// Advance
		if (FlxG.keys.checkStatus(FlxG.keys.getKeyCode(_playerData.keyUp), FlxKey.PRESSED))
			acceleration.y = -_speed * _accelerationFactor;
		
		// Retract
		if (FlxG.keys.checkStatus(FlxG.keys.getKeyCode(_playerData.keyDown), FlxKey.PRESSED))
			acceleration.y = _speed * _accelerationFactor;
			
		// Action
		if (FlxG.mouse.pressed)
		{
			_fireTimer += FlxG.elapsed;
			if (_fireTimer >= _currentWeapon.fireDelay)
			{
				_fireTimer -= _currentWeapon.fireDelay;
				
				if (_buildingMode) 
				{
					var tileIndexAtMouse:Int = _tilemap.getTileIndexByCoords(FlxG.mouse.getWorldPosition());
					if (_tilemap.getTileByIndex(tileIndexAtMouse) == 0)
					{
						_tilemap.setTileByIndex(tileIndexAtMouse, 16);
					}
				} 
				else 
				{
					var playerPoint:FlxPoint = getMidpoint();
					var mousePoint:FlxPoint = FlxG.mouse.getWorldPosition();
					var resultPoint:FlxPoint = FlxPoint.get();
					
					var tileIndexAtMouse:Int = _tilemap.getTileIndexByCoords(mousePoint);
					if (tileIndexAtMouse != 0 && !_tilemap.ray(playerPoint, mousePoint, resultPoint, 4))
					{
						// For any left or bottom wall hits, ray() returns an incorrect resulting coordinate (apparently). 
						// This is here to fix this problem. 
						// TODO: Check if it was fixed when upgrading to the latest flixel version, if that ever happens.
						if (playerPoint.x > mousePoint.x)
							resultPoint.x -= 1;
						
						if (playerPoint.y > mousePoint.y)
							resultPoint.y -= 1;
						
						var tileIndexByRay:Int = _tilemap.getTileIndexByCoords(resultPoint);
						if (tileIndexByRay == tileIndexAtMouse)
						{
							_shooting = true;
							
							FlxSpriteUtil.drawLine(_canvas, getMidpoint().x - FlxG.camera.scroll.x, getMidpoint().y - FlxG.camera.scroll.y, FlxG.mouse.x - FlxG.camera.scroll.x, FlxG.mouse.y - FlxG.camera.scroll.y, _laserLineStyle);
							
							_tileManager.drillTile(mousePoint.x, mousePoint.y, _currentWeapon.damage);
							
							if (Utils.rnd(0, 100) <= 50)
								FlxG.sound.play(AssetPaths.drill1__wav, 1);
							else
								FlxG.sound.play(AssetPaths.drill2__wav, 1);
						}
					}	
				}
			} 
		}
		
		if (FlxG.keys.justPressed.ONE)
		{
			_buildingMode = !_buildingMode;
			
			if (_buildingMode) 
			{
				_hud.write("Building mode: ON", 2);
				_currentWeapon = _buildRay;
				_fireTimer = 0;
			} 
			else
			{
				_hud.write("Building mode: OFF", 2);
				_currentWeapon = _pickaxe;
				_fireTimer = 0;
			}
		}
		
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
		
		super.update();
	}
	
}