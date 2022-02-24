package;

import flixel.util.FlxSave;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	/**
	 *  Assets
	 */
	public static inline var PLAYER_SHIP:String = "assets/images/ship.png";
	public static inline var ENEMY_SHIP:String = "assets/images/enemy.png";
	
	public static inline var TILES:String = "assets/images/tilemap_rock.png";
	public static inline var TILE_CRACKS:String = "assets/images/tile_cracks.png";
	public static inline var TILE_PARTICLES:String = "assets/images/tile_particles.png";
	
	public static inline var BACKDROP:String = "assets/images/backdrop.png";
	public static inline var LIGHT:String = "assets/images/light_300.png";		

	public static inline var LOOT_TILE_DIRT:String = "assets/images/tileDirtLoot.png";
	
	public static inline var GREEN_CROSS:String = "assets/images/greenCross.png";  // TODO: Remove, used for debug.
	public static inline var RED_CROSS:String = "assets/images/redCross.png";	   // TODO: Remove, used for debug.
	
	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	public static var levels:Array<Dynamic> = [];
	/**
	 * Generic level variable that can be used for cross-state stuff.
	 * Example usage: Storing the current level number.
	 */
	public static var level:Int = 0;
	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	public static var scores:Array<Dynamic> = [];
	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
	public static var score:Int = 0;
	/**
	 * Generic bucket for storing different FlxSaves.
	 * Especially useful for setting up multiple save slots.
	 */
	public static var saves:Array<FlxSave> = [];
}