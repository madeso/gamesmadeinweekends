package;

import nme.Lib;
import org.flixel.FlxGame;
import org.flixel.FlxG;

class ProjectClass extends FlxGame
{	
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		var ratioX:Float = stageWidth / Game.Width;
		var ratioY:Float = stageHeight / Game.Height;
		var ratio:Float = Math.min(ratioX, ratioY);
		super(Math.floor(stageWidth / ratio), Math.floor(stageHeight / ratio), MenuState);
		//forceDebugger = true;
		mouseEnabled = true;
	}
}
