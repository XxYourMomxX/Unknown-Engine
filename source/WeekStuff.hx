package;

import flixel.FlxG;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;
import haxe.format.JsonParser;
#if desktop
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef WeekData
{
	// VERY COOL JSON STUFF :)))))
	var songs:Array<Dynamic>;
	var characters:Array<String>;
	var storyPngFile:String;
	var weekTitle:String;
	var isUnlocked:Bool;
}

class WeekStuff
{
	public var daFolder:String = '';

	var songs:Array<Dynamic>;
	var characters:Array<String>;
	var storyPngFile:String;
	var weekTitle:String;
	var isUnlocked:Bool;

	public function new(weekData:WeekData)
	{
		songs = weekData.songs;
		characters = weekData.characters;
		storyPngFile = weekData.storyPngFile
		weekTitle = weekData.weekTitle
		isUnlocked = weekData.isUnlocked
	}
}