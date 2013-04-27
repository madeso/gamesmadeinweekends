package;

import nme.Assets;
import nme.geom.Rectangle;
import nme.net.SharedObject;
import org.flixel.FlxButton;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxPath;
import org.flixel.FlxPoint;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;
import org.flixel.FlxU;
import org.flixel.tmx.TmxObject;
import org.flixel.tmx.TmxObjectGroup;

import org.flixel.tmx.TmxMap;

/**
 * ...
 * @author sirGustav
 */

class GameState  extends FlxState
{	
	private var items : FlxGroup;
	private var board : Board;
		
	override public function create():Void
	{
		// Game.music("andsoitbegins");
		
		items = new FlxGroup();
		board = new Board(this);
		
		add(board);
		add(items);
		
		FlxG.bgColor = 0xfffdfdfd;
		
		#if flash
		FlxG.mouse.show();
		#end
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		
		if ( FlxG.mouse.justReleased() )
		{
			//var fp : FlxPoint = FlxG.mouse.getWorldPosition();
			var p : Vec = new Vec(FlxG.mouse.screenX, FlxG.mouse.screenY);//new Vec(fp.x, fp.y);
			onClick(p);
		}
		
		for (touch in FlxG.touchManager.touches)
		{
			if ( touch.justReleased() )
			{
				var p : Vec = new Vec(touch.screenX, touch.screenY);
				onClick(p);
			}
		}
	}
	
	private function onClick(point:Vec): Void
	{
		point.x = Math.floor(point.x / 42) * 42;
		point.y = Math.floor(point.y / 42) * 42;
		//items.add(new Box(point.x, point.y, BoxSize.Normal, Game.irnd(0,3), this));
	}
}