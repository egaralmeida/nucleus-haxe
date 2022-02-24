package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	private var title:FlxText;
	private var subtitle:FlxText;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		title = new FlxText(0, 0, 0, "Press Space to Start!", 32);
		title.setFormat(null, 32, 0x666D73, "center", FlxText.BORDER_OUTLINE, 0xFFFFFF, true);
		title.setPosition(FlxG.width / 2 - title.width / 2, FlxG.height / 2 - title.height / 2);
		
		subtitle = new FlxText(0, 0, 0, "(Will take a long time to load)", 16);
		subtitle.setFormat(null, 16, 0x666D73, "center", FlxText.BORDER_NONE, 0xFFFFFF, true);
		subtitle.setPosition(FlxG.width / 2 - subtitle.width / 2, FlxG.height / 2 - subtitle.height / 2 + title.height);
		
		add(title);
		add(subtitle);
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		title.destroy();
		subtitle.destroy();
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		if (FlxG.keys.justPressed.SPACE)
		{
			FlxG.switchState(new PlayState());
		}
		
		super.update();
	}	
}