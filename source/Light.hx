package;

import flash.display.BlendMode;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

/**
 * "Light"
 * @author Egar Almeida
 */
class Light extends FlxSprite
{
	
	private var _darkness:FlxSprite;
	private var _followObject:FlxSprite;
	
	public function new(X:Float, Y:Float, Darkness:FlxSprite, ?FollowObject:FlxSprite) 
	{
		// Graphic
		super(X, Y, Reg.LIGHT);
		
		_darkness = Darkness;
		_followObject = FollowObject;
		
		//blend = BlendMode.SCREEN;
		
	}
	
	override public function update():Void
	{
		var followObjectXY:FlxPoint = _followObject.getMidpoint();
		x = followObjectXY.x;
		y = followObjectXY.y; 
		
		super.update();
	}
	
	override public function draw():Void
	{
		var screenXY:FlxPoint = getScreenXY();
		_darkness.stamp(this, Std.int(screenXY.x - width / 2), Std.int(screenXY.y - height / 2));
	}
}