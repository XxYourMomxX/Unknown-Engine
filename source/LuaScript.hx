package;

import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
import openfl.display3D.textures.VideoTexture;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.atlas.FlxAtlas;
import flixel.tweens.FlxEase;
import openfl.filters.ShaderFilter;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import lime.app.Application;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.FlxGame;
import PlayState;

using StringTools;

class LuaScript
{
	public var lua:State = null;

	function call(daFunction:String, args:Array<Dynamic>, ?type : String):Dynamic
	{
		var result:Any = null;

		Lua.getglobal(lua, daFunction);

		for (arg in args)
		{
			Convert.toLua(lua, arg);
		}

		result = Lua.pcall(lua, args.length, 1, 0);
		var ripError:String = Lua.tostring(lua, -1);

		Lua.tostring(lua, result);

		if (ripError != null)
		{
			if (ripError != "attempt to call a nil value")
			{
		return null;
			}
		}
		if (result == null)
		{
			trace("RIP");
			return null;
		}
		else 
		{
			return convert(result, type);
		}
	}

	private function convert(v : Any, type : String) : Dynamic {
		if( Std.is(v, String) && type != null ) {
		var v : String = v;
		if( type.substr(0, 4) == 'array' ) {
			if( type.substr(4) == 'float' ) {
			var array : Array<String> = v.split(',');
			var array2 : Array<Float> = new Array();

			for( vars in array ) {
		array2.push(Std.parseFloat(vars));
			}

			return array2;
			} else if( type.substr(4) == 'int' ) {
			var array : Array<String> = v.split(',');
			var array2 : Array<Int> = new Array();

			for( vars in array ) {
		array2.push(Std.parseInt(vars));
			}

			return array2;
			} else {
			var array : Array<String> = v.split(',');
			return array;
			}
		} else if( type == 'float' ) {
			return Std.parseFloat(v);
		} else if( type == 'int' ) {
			return Std.parseInt(v);
		} else if( type == 'bool' ) {
			if( v == 'true' ) {
			return true;
			} else {
			return false;
			}
		} else {
			return v;
		}
		} else {
		return v;
		}
	}

	public function setVariable(variable:String, object:Dynamic)
	{
		Lua.pushnumber(lua, object);
		Lua.setglobal(lua, variable);
	}

	function getActorByName(name:String):Dynamic
	{
		switch(name)
		{
			case 'boyfriend':
		return PlayState.boyfriend;
			case 'girlfriend':
		return PlayState.gf;
			case 'dad':
		return PlayState.dad;
			case 'strumLineNotes':
			return PlayState.strumLineNotes;
		}
		return luaSprites.get(name);
	}

	public static var luaSprites:Map<String,FlxSprite> = [];

	function changePlayerChar(newChar:String)
	{
		var boyfriendX = PlayState.boyfriend.x;
		var boyfriendY = PlayState.boyfriend.y;
		PlayState.instance.removeLuaObject(PlayState.boyfriend);
		PlayState.boyfriend = new Boyfriend(boyfriendX, boyfriendY, newChar);
		PlayState.instance.addLuaObject(PlayState.boyfriend);
		//Icon Change Will be Here next update
	}

	function changeOpponentChar(newChar:String)
	{
		var dadX = PlayState.dad.x;
		var dadY = PlayState.dad.y;
		PlayState.instance.removeLuaObject(PlayState.dad);
		PlayState.dad = new Character(dadX, dadY, newChar);
		PlayState.instance.addLuaObject(PlayState.dad);
		//Icon Change Will be Here next update
	}

	function changeGfChar(newChar:String)
	{
		var gfX = PlayState.gf.x;
		var gfY = PlayState.gf.y;
		PlayState.instance.removeLuaObject(PlayState.gf);
		PlayState.gf = new Character(gfX, gfY, newChar);
		PlayState.instance.addLuaObject(PlayState.gf);
		//Icon Change Will be Here next update
	}

	public function getVariable(Variable:String, type:String) : Dynamic {
		Lua.getglobal(lua, Variable);
		var result = Convert.fromLua(lua,-1);
		Lua.pop(lua,1);

		if( result == null )
		{
			return null;
		}
		else 
		{
			var result = convert(result, type);
			return result;
		}
	}

	public function new(LuaScript:String)
	{
		trace('trying to open a new lua state');
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);
		
		var result = LuaL.dofile(lua, LuaScript); // execute le file
	
		if (result != 0)
		{
			Application.current.window.alert("Rip Error on Script");
			lua = null;
			LoadingState.loadAndSwitchState(new MainMenuState());
		}

		setVariable('playerX', PlayState.boyfriend.x);
		setVariable('playerY', PlayState.boyfriend.y);
		setVariable('opponentX', PlayState.dad.x);
		setVariable('opponentY', PlayState.dad.y);
		setVariable('GfX', PlayState.gf.x);
		setVariable('GfY', PlayState.gf.y);
	
		setVariable("difficulty", PlayState.storyDifficulty);
		setVariable("bpm", Conductor.bpm);
		setVariable("scrollspeed", FlxG.save.data.scrollSpeed != 1 ? FlxG.save.data.scrollSpeed : PlayState.SONG.speed);
		setVariable("fpsCap", FlxG.save.data.fpsCap);
		setVariable("downscroll", FlxG.save.data.downscroll);
	
		setVariable("curStep", 0);
		setVariable("curBeat", 0);
		setVariable("crochet", Conductor.stepCrochet);
		setVariable("safeZoneOffset", Conductor.safeZoneOffset);
	
		setVariable("cameraZoom", FlxG.camera.zoom);
	
		setVariable("cameraAngle", FlxG.camera.angle);

		//setVariable("onlyShowNotes", 'bool');
		setVariable('scoreTextInvisible', 'bool');
	
		setVariable("screenWidth",FlxG.width);
		setVariable("screenHeight",FlxG.height);
		setVariable("windowWidth",FlxG.width);
		setVariable("windowHeight",FlxG.height);
	
		setVariable("mustHit", false);

		setVariable("strumLineY", PlayState.strumLine.y);
		
		// callbacks
	
		// sprites
			
		Lua_helper.add_callback(lua," changeOpponentChar", function(newChar:String) {
			changeOpponentChar(newChar);
		});

		Lua_helper.add_callback(lua,"changePlayerChar", function(newChar:String){
			changePlayerChar(newChar);
		});

		Lua_helper.add_callback(lua,"changeGfChar", function(newChar:String){
			changeGfChar(newChar);
		});
		
		// hud/camera
	
		Lua_helper.add_callback(lua,"setHudAngle", function (x:Float) {
			PlayState.instance.camHUD.angle = x;
		});
		
		Lua_helper.add_callback(lua,"setHealth", function (newHealth:Float) {
			PlayState.instance.health = newHealth;
		});

		Lua_helper.add_callback(lua,"setHudPosition", function (x:Int, y:Int) {
			PlayState.instance.camHUD.x = x;
			PlayState.instance.camHUD.y = y;
		});
	
		Lua_helper.add_callback(lua,"getHudX", function () {
			return PlayState.instance.camHUD.x;
		});
	
		Lua_helper.add_callback(lua,"getHudY", function () {
			return PlayState.instance.camHUD.y;
		});
		
		Lua_helper.add_callback(lua,"setCamPosition", function (x:Int, y:Int) {
			FlxG.camera.x = x;
			FlxG.camera.y = y;
		});
	
		Lua_helper.add_callback(lua,"getCameraX", function () {
			return FlxG.camera.x;
		});
	
		Lua_helper.add_callback(lua,"getCameraY", function () {
			return FlxG.camera.y;
		});
	
		Lua_helper.add_callback(lua,"setCamZoom", function(zoomAmount:Float) {
			FlxG.camera.zoom = zoomAmount;
		});
	
		Lua_helper.add_callback(lua,"setHudZoom", function(zoomAmount:Float) {
			PlayState.instance.camHUD.zoom = zoomAmount;
		});
	
		// strumline

		Lua_helper.add_callback(lua, "setStrumlineY", function(y:Float)
		{
			PlayState.strumLine.y = y;
		});
	
		// actors
		
		Lua_helper.add_callback(lua,"getRenderedNotes", function() {
			return PlayState.instance.notes.length;
		});
	
		Lua_helper.add_callback(lua,"getRenderedNoteX", function(id:Int) {
			return PlayState.instance.notes.members[id].x;
		});
	
		Lua_helper.add_callback(lua,"getRenderedNoteY", function(id:Int) {
			return PlayState.instance.notes.members[id].y;
		});

		Lua_helper.add_callback(lua,"getRenderedNoteType", function(id:Int) {
			return PlayState.instance.notes.members[id].noteData;
		});

		Lua_helper.add_callback(lua,"isSustain", function(id:Int) {
			return PlayState.instance.notes.members[id].isSustainNote;
		});

		Lua_helper.add_callback(lua,"isParentSustain", function(id:Int) {
			return PlayState.instance.notes.members[id].prevNote.isSustainNote;
		});

		
		Lua_helper.add_callback(lua,"getRenderedNoteParentX", function(id:Int) {
			return PlayState.instance.notes.members[id].prevNote.x;
		});

		Lua_helper.add_callback(lua,"getRenderedNoteParentY", function(id:Int) {
			return PlayState.instance.notes.members[id].prevNote.y;
		});

		Lua_helper.add_callback(lua,"getRenderedNoteHit", function(id:Int) {
			return PlayState.instance.notes.members[id].mustPress;
		});

		Lua_helper.add_callback(lua,"getRenderedNoteCalcX", function(id:Int) {
			if (PlayState.instance.notes.members[id].mustPress)
				return PlayState.playerStrums.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;
			return PlayState.strumLineNotes.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;
		});

		Lua_helper.add_callback(lua,"anyNotes", function() {
			return PlayState.instance.notes.members.length != 0;
		});

		Lua_helper.add_callback(lua,"getRenderedNoteStrumtime", function(id:Int) {
			return PlayState.instance.notes.members[id].strumTime;
		});
	
		Lua_helper.add_callback(lua,"getRenderedNoteScaleX", function(id:Int) {
			return PlayState.instance.notes.members[id].scale.x;
		});
	
		Lua_helper.add_callback(lua,"setRenderedNotePos", function(x:Float,y:Float, id:Int) {
			if (PlayState.instance.notes.members[id] == null)
				throw('error! you cannot set a rendered notes position when it doesnt exist! ID: ' + id);
			else
			{
				PlayState.instance.notes.members[id].noteismodifiedByLua = true;
				PlayState.instance.notes.members[id].x = x;
				PlayState.instance.notes.members[id].y = y;
			}
		});
	
		Lua_helper.add_callback(lua,"setRenderedNoteAlpha", function(alpha:Float, id:Int) {
			PlayState.instance.notes.members[id].noteismodifiedByLua = true;
			PlayState.instance.notes.members[id].alpha = alpha;
		});
	
		Lua_helper.add_callback(lua,"setRenderedNoteScale", function(scale:Float, id:Int) {
			PlayState.instance.notes.members[id].noteismodifiedByLua = true;
			PlayState.instance.notes.members[id].setGraphicSize(Std.int(PlayState.instance.notes.members[id].width * scale));
		});

		Lua_helper.add_callback(lua,"setRenderedNoteScale", function(scaleX:Int, scaleY:Int, id:Int) {
			PlayState.instance.notes.members[id].noteismodifiedByLua = true;
			PlayState.instance.notes.members[id].setGraphicSize(scaleX,scaleY);
		});

		Lua_helper.add_callback(lua,"getRenderedNoteWidth", function(id:Int) {
			return PlayState.instance.notes.members[id].width;
		});


		Lua_helper.add_callback(lua,"setRenderedNoteAngle", function(angle:Float, id:Int) {
			PlayState.instance.notes.members[id].noteismodifiedByLua = true;
			PlayState.instance.notes.members[id].angle = angle;
		});
	
		Lua_helper.add_callback(lua,"setActorX", function(x:Int,id:String) {
			getActorByName(id).x = x;
		});
		
		Lua_helper.add_callback(lua,"playActorAnimation", function(id:String,anim:String,force:Bool = false,reverse:Bool = false) {
			getActorByName(id).playAnim(anim, force, reverse);
		});
	
		Lua_helper.add_callback(lua,"setActorAlpha", function(alpha:Float,id:String) {
			getActorByName(id).alpha = alpha;
		});
	
		Lua_helper.add_callback(lua,"setActorY", function(y:Int,id:String) {
			getActorByName(id).y = y;
		});
					
		Lua_helper.add_callback(lua,"setActorAngle", function(angle:Int,id:String) {
			getActorByName(id).angle = angle;
		});
	
		Lua_helper.add_callback(lua,"setActorScale", function(scale:Float,id:String) {
			getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scale));
		});
		
		Lua_helper.add_callback(lua, "setActorScaleXY", function(scaleX:Float, scaleY:Float, id:String)
		{
			getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scaleX), Std.int(getActorByName(id).height * scaleY));
		});
	
		Lua_helper.add_callback(lua, "setActorFlipX", function(flip:Bool, id:String)
		{
			getActorByName(id).flipX = flip;
		});

		Lua_helper.add_callback(lua, "setActorFlipY", function(flip:Bool, id:String)
		{
			getActorByName(id).flipY = flip;
		});
	
		Lua_helper.add_callback(lua,"getActorWidth", function (id:String) {
			return getActorByName(id).width;
		});
	
		Lua_helper.add_callback(lua,"getActorHeight", function (id:String) {
			return getActorByName(id).height;
		});
	
		Lua_helper.add_callback(lua,"getActorAlpha", function(id:String) {
			return getActorByName(id).alpha;
		});
	
		Lua_helper.add_callback(lua,"getActorAngle", function(id:String) {
			return getActorByName(id).angle;
		});
	
		Lua_helper.add_callback(lua,"getActorX", function (id:String) {
			return getActorByName(id).x;
		});
	
		Lua_helper.add_callback(lua,"getActorY", function (id:String) {
			return getActorByName(id).y;
		});

		Lua_helper.add_callback(lua,"setWindowPos",function(x:Int,y:Int) {
			Application.current.window.x = x;
			Application.current.window.y = y;
		});

		Lua_helper.add_callback(lua,"getWindowX",function() {
			return Application.current.window.x;
		});

		Lua_helper.add_callback(lua,"getWindowY",function() {
			return Application.current.window.y;
		});

		Lua_helper.add_callback(lua,"resizeWindow",function(Width:Int,Height:Int) {
			Application.current.window.resize(Width,Height);
		});
		
		Lua_helper.add_callback(lua,"getScreenWidth",function() {
			return Application.current.window.display.currentMode.width;
		});

		Lua_helper.add_callback(lua,"getScreenHeight",function() {
			return Application.current.window.display.currentMode.height;
		});

		Lua_helper.add_callback(lua,"getWindowWidth",function() {
			return Application.current.window.width;
		});

		Lua_helper.add_callback(lua,"getWindowHeight",function() {
			return Application.current.window.height;
		});

	
		// tweens
		
		Lua_helper.add_callback(lua,"tweenCameraPos", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenCameraAngle", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenCameraZoom", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudPos", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenHudAngle", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudZoom", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {zoom:toZoom}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenPos", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosXAngle", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosYAngle", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenAngle", function(id:String, toAngle:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});

		Lua_helper.add_callback(lua,"tweenCameraPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenCameraAngleOut", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenCameraZoomOut", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenHudAngleOut", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudZoomOut", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {zoom:toZoom}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenPosOut", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosXAngleOut", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosYAngleOut", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenAngleOut", function(id:String, toAngle:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});

		Lua_helper.add_callback(lua,"tweenCameraPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenCameraAngleIn", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenCameraZoomIn", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenHudAngleIn", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudZoomIn", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {zoom:toZoom}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenPosIn", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosXAngleIn", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosYAngleIn", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenAngleIn", function(id:String, toAngle:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenFadeIn", function(id:String, toAlpha:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenFadeOut", function(id:String, toAlpha:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});

		//forgot and accidentally commit to master branch
		// shader
		
		/*Lua_helper.add_callback(lua,"createShader", function(frag:String,vert:String) {
			var shader:LuaShader = new LuaShader(frag,vert);

			trace(shader.glFragmentSource);

			shaders.push(shader);
			// if theres 1 shader we want to say theres 0 since 0 index and length returns a 1 index.
			return shaders.length == 1 ? 0 : shaders.length;
		});

		
		Lua_helper.add_callback(lua,"setFilterHud", function(shaderIndex:Int) {
			PlayState.instance.camHUD.setFilters([new ShaderFilter(shaders[shaderIndex])]);
		});

		Lua_helper.add_callback(lua,"setFilterCam", function(shaderIndex:Int) {
			FlxG.camera.setFilters([new ShaderFilter(shaders[shaderIndex])]);
		});*/

		// default strums

		for (i in 0...PlayState.strumLineNotes.length) {
			var member = PlayState.strumLineNotes.members[i];
			setVariable("defaultStrum" + i + "X", Math.floor(member.x));
			setVariable("defaultStrum" + i + "Y", Math.floor(member.y));
			setVariable("defaultStrum" + i + "Angle", Math.floor(member.angle));
			trace("Adding strum" + i);
		}
	}

	public function die()
	{
		trace('killed the boi');
		Lua.close(lua);
		lua = null;
	}

	public static function startLuaScript(path:String)
	{
		return new LuaScript(path);
	}
}