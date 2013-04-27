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

/**
 * ...
 * @author sirGustav
 */

class GameState  extends FlxState
{	
	private var items : FlxGroup;
	private var board : Board;
	private var selectionbox : DarkBox;
	private var targetindex : Int = -1;
		
	override public function create():Void
	{
		// Game.music("andsoitbegins");
		
		items = new FlxGroup();
		board = new Board(this);
		selectionbox = new DarkBox(620, 500, 0.5, 33);
		selectionbox.visible = false;
		
		add(board);
		add(items);
		add(selectionbox);
		
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
		if ( selectionbox.visible )
		{
			if ( targetindex > 0 )
			{
				board.setColor(targetindex, Color.Red);
			}
			
			selectionbox.visible = false;
		}
		else
		{
			var index : Int = board.getClosestMatch(point);
			if ( index == -1 ) return;
			targetindex = index;
			selectionbox.visible = true;
		}
	}
}