package;

import flixel.addons.display.FlxSpriteAniRot;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

/**
 * Hud
 * @author Egar Almeida
 */
class Hud extends FlxBasic
{
	
	private var _hudText:FlxText;
	private var _hudGroup:FlxGroup;
	
	private var _textDuration:Float = 1;
	private var _textTimer:Float = 0;
	
	public function new(HudGroup:FlxGroup) 
	{
		super();
		
		_hudGroup = HudGroup;
		
		_hudText = new FlxText(10, FlxG.height - 26, 0, "", 16);
		_hudText.setFormat(null, 16, 0xd8eba2, "left", FlxText.BORDER_OUTLINE_FAST, 0x131c1b);
		_hudText.scrollFactor.x = 0;
		_hudText.scrollFactor.y = 0;
		
		_hudGroup.add(_hudText);
	}
	
	public function write(Text:String, Duration:Float = 1):Void
	{
		_hudText.text = Text;
		_textDuration = Duration;
		_textTimer = 0;
		
	}
	
	override public function update()
	{
		_textTimer += FlxG.elapsed;
		if (_textTimer >= _textDuration)
		{
			_textTimer -= _textDuration;
			_hudText.text = "";
		}
	}
	
}