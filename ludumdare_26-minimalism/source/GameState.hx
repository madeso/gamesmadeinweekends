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
	private static var BLACK : Int = 3;
	
	private var items : FlxGroup;
	private var board : Board;
	private var selectionbox : DarkBox;
	private var topbox : DarkBox;
	private var placehere : Box;
	private var selectionVisible : Bool = false;
	private var targetindex : Int = -1;
	
	private var buttonRedBig : Box;
	private var buttonBlueBig : Box;
	private var buttonYellowBig : Box;
	
	private var lastColor : Color;
	
	override public function create():Void
	{
		// Game.music("andsoitbegins");
		
		lastColor = Color.None;
		items = new FlxGroup();
		board = new Board();
		selectionbox = new DarkBox(300, 300, 0, 16, 16, BLACK);
		topbox = new DarkBox(300, -60, 0.5, 16, 2, BLACK);
		placehere = new Box(0, 0, BoxSize.Normal, Color.None, false);
		placehere.visible = false;
		
		var buttonheight : Int = -40;
		
		var BASE : Int = 80;
		var RED : Int = BASE + 20;
		var BLUE : Int = BASE + 40 * 5;
		var YELLOW : Int = BASE + 40 * 10;
		
		var SPACE : Int = 10;
		
		buttonRedBig = new Box(RED + 0, buttonheight, BoxSize.Normal, Color.Red, true);
		buttonBlueBig = new Box(BLUE + 0, buttonheight, BoxSize.Normal, Color.Blue, true);
		buttonYellowBig = new Box(YELLOW + 0, buttonheight, BoxSize.Normal, Color.Yellow, true);
		
		
		add(board);
		add(items);
		add(selectionbox);
		add(topbox);
		add(placehere);
		
		add(buttonRedBig);
		add(buttonBlueBig);
		add(buttonYellowBig);
		
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
			
			Actuate.tween(buttonRedBig, 1, { y: 10 } ).ease(Quint.easeOut).delay(randomDelay());
			Actuate.tween(buttonBlueBig, 1, { y: 10 } ).ease(Quint.easeOut).delay(randomDelay());
			Actuate.tween(buttonYellowBig, 1, { y: 10 } ).ease(Quint.easeOut).delay(randomDelay());
		}
		else
		{
			Actuate.tween (selectionbox, 1, { alpha: 0.0 } );
			Actuate.tween (topbox, 0.75, { y: -60 } ).ease(Quint.easeInOut);
			
			Actuate.tween(buttonRedBig, 1, { y: -43 } ).ease(Quint.easeOut).delay(randomDelay());
			Actuate.tween(buttonBlueBig, 1, { y: -43 } ).ease(Quint.easeOut).delay(randomDelay());
			Actuate.tween(buttonYellowBig, 1, { y: -43 } ).ease(Quint.easeOut).delay(randomDelay());
		}
	}
	
	private function randomDelay() : Float
	{
		return Game.rnd(0, 0.25);
	}
	
	private function onClick(point:Vec): Void
	{
		if ( selectionVisible )
		{
			var close : Bool = true;
			
			if ( targetindex >= 0 )
			{
				close = false;
				var c : Color = Color.None;
				var p : FlxPoint = point.flx();
				if ( buttonRedBig.overlapsPoint(p) )
				{
					c = Color.Red;
				}
				else if ( buttonBlueBig.overlapsPoint(p) )
				{
					c = Color.Blue;
				}
				else if ( buttonYellowBig.overlapsPoint(p) )
				{
					c = Color.Yellow;
				}
				else if ( lastColor != Color.None )
				{
					var index : Int = board.getClosestMatch(point);
					if ( index == targetindex )
					{
						c = lastColor;
					}
				}
				
				if ( c != Color.None )
				{
					if ( Rules.CanPlace(board, targetindex, c) == true )
					{
						board.setColor(targetindex, c);
						lastColor = c;
						Game.sfx("enter");
						close = true;
					}
					else
					{
						Game.sfx("bad3");
					}
				}
			}
			
			if ( close )
			{
				setSelectionVisible(false);
			}
		}
		else
		{
			var index : Int = board.getClosestMatch(point);
			if ( index == -1 ) return;
			if ( Rules.CanPlace(board, index, Color.None) == true )
			{
				var p : Vec = board.getPosition(index);
				Game.sfx("select");
				placehere.x = p.x;
				placehere.y = p.y;
				placehere.setSize(board.getSize(index));
				targetindex = index;
				setSelectionVisible(true);
			}
			else
			{
				Game.sfx("bad3");
			}
		}
	}
}
