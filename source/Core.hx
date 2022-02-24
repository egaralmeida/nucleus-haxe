package;

/**
 * System access functions
 * @author Egar Almeida
 */

 import haxe.Json;
 import openfl.Assets;
 
 #if (cpp || neko)
	import sys.io.File;
 #end
 
 class Core
{
	public static function getJson(path:String):Dynamic
	{
		try
		{
			trace("Parsing " + path);
			var incomingJson:String = Assets.getText(path);
			trace(incomingJson);
			return Json.parse(incomingJson);
			
		} catch (msg:String) {
			trace("Error while loading or parsing Json file " + path + ": " + msg);
			return 0;
		}
	}

#if (cpp || neko)
	public static function saveJson(path:String, structure:Dynamic):Void
	{
		var resultJson:String = Json.stringify(structure, null,"\t"); 
		trace(resultJson);

		try
		{
			File.saveContent(path, resultJson); 

		} catch (msg:String) {
			trace("Error while saving Json file " + path + ": " + msg);
		}	
	}
#end

}