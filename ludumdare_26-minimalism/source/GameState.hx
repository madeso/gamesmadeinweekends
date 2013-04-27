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

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Quint;

/**
 * ...
 * @author sirGustav
 */

class GameState  extends FlxState
{	
	private static var RED : Int = 0;
	private static var BLUE : Int = 1;
	private static var YELLOW : Int = 2;
	private static var BLACK : Int = 3;
	private static var WHITE : Int = 16;
	
	private var items : FlxGroup;
	private var board : Board;
	private var selectionbox : DarkBox;
	private var topbox : DarkBox;
	private var placehere : Box;
	private var selectionVisible : Bool = false;
	private var targetindex : Int = -1;
	
	override public function create():Void
	{
		// Game.music("andsoitbegins");
		
		items = new FlxGroup();
		board = new Board();
		selectionbox = new DarkBox(300, 300, 0, 16, 16, BLACK);
		topbox = new DarkBox(300, -60, 0.5, 16, 2, BLACK);
		placehere = new Box(0, 0, BoxSize.Normal, Color.None, false);
		placehere.visible = false;
		
		add(board);
		add(items);
		add(selectionbox);
		add(topbox);
		add(placehere);
		
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
	
	private function setSelectionVisible(v : Bool) : Void
	{
		selectionVisible = v;
		
		placehere.visible = v;
		
		if ( v )
		{
			Actuate.tween (selectionbox, 1, { alpha: 0.5 } );
			Actuate.tween (topbox, 1, { y: 0 } ).ease(Quint.easeOut);
		}
		else
		{
			Actuate.tween (selectionbox, 1, { alpha: 0.0 } );
			Actuate.tween (topbox, 1, { y: -60 } );
		}
	}
	
	private function onClick(point:Vec): Void
	{
		if ( selectionVisible )
		{
			if ( targetindex > 0 )
			{
				board.setColor(targetindex, Color.Red);
			}
			
			setSelectionVisible(false);
		}
		else
		{
			var index : Int = board.getClosestMatch(point);
			if ( index == -1 ) return;
			var p : Vec = board.getPosition(index);
			placehere.x = p.x;
			placehere.y = p.y;
			placehere.setSize(board.getSize(index));
			targetindex = index;
			setSelectionVisible(true);
		}
	}
}
