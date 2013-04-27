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
	private static var CROSS : Int = 11;
	
	private var items : FlxGroup;
	private var board : Board;
	private var cross : DarkBox;
	private var selectionbox : DarkBox;
	private var topbox : DarkBox;
	private var placehere : Box;
	private var selectionVisible : Bool = false;
	private var targetindex : Int = -1;
	
	private var buttonRedBig : Box;
	private var buttonBlueBig : Box;
	private var buttonYellowBig : Box;
	
	private var lastColor : Color;
	
	private static var CROSSOUT : Int = 500;
	
	private var bombindex : Int = -1;
	private var bombdir : Int = 0;
	private var bombtimer : Float = 0;
	private static var BOMBTIME : Float = 0.10;
	
	private var storedBombs : Array<BombDir>;
	
	override public function create():Void
	{
		// Game.music("andsoitbegins");
		
		lastColor = Color.None;
		items = new FlxGroup();
		board = new Board();
		selectionbox = new DarkBox(300, 300, 0, 16, 16, BLACK);
		topbox = new DarkBox(300, -60, 0.5, 16, 2, BLACK);
		cross = new DarkBox(570, CROSSOUT, 1, 1, 1, CROSS);
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
		add(cross);
		
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
	
	public static function Right(dir:Int) : Int
	{
		if ( dir == 4 ) return 8;
		if ( dir == 6 ) return 2;
		if ( dir == 8 ) return 6;
		if ( dir == 2 ) return 4;
		return -1;
	}
	
	public static function Left(dir:Int) : Int
	{
		if ( dir == 4 ) return 2;
		if ( dir == 6 ) return 8;
		if ( dir == 8 ) return 4;
		if ( dir == 2 ) return 6;
		return -1;
	}
	

	override public function update():Void
	{
		super.update();
		
		if ( bombindex == -1 )
		{		
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
		else
		{
			bombtimer += FlxG.elapsed;
			if ( bombtimer > BOMBTIME )
			{
				bombtimer -= BOMBTIME;
				Game.sfx("score");
				// trace("bomb");
				
				var p : Bool = false;
				board.setColor(bombindex, Color.None);
				var nextindex : Int = board.getIndexFromDir(bombindex, bombdir);
				var c : Color = board.getColor( nextindex );
				// trace("investigating " + Std.string(bombdir) + " / " + Std.string(c));
				if ( Rules.IsValidBombColor(c) )
				{
					bombindex = nextindex;
					// trace("nextindex");
				}
				else
				{
					var goright : Bool = Rules.IsValidBombColor( board.getColor( board.getIndexFromDir(bombindex, Right(bombdir))));
					var goleft : Bool = Rules.IsValidBombColor( board.getColor( board.getIndexFromDir(bombindex, Left(bombdir))));
					if ( goright && goleft )
					{
						if ( Game.brnd() ) goright = false;
						else goleft = false;
						
						if ( goleft )
						{
							storedBombs.push(new BombDir(bombindex, board.getIndexFromDir(bombindex, Right(bombdir)), Right(bombdir)));
						}
						else
						{
							storedBombs.push(new BombDir(bombindex, board.getIndexFromDir(bombindex, Left(bombdir)), Left(bombdir)));
						}
					}
					
					if ( goright )
					{
						// trace("right");
						bombdir = Right(bombdir);
						bombindex = board.getIndexFromDir(bombindex, bombdir);
					}
					else if ( goleft )
					{
						// trace("left");
						bombdir = Left(bombdir);
						bombindex = board.getIndexFromDir(bombindex, bombdir);
					}
					else
					{
						// trace("starting again");
						if ( storedBombs.length != 0 )
						{
							startBombing();
						}
						else
						{
							// stop bombing
							bombindex = -1;
						}
					}
				}
			}
		}
	}
	
	private function canBomb() : Bool
	{
		storedBombs = board.listBombDirs();
		return storedBombs.length != 0;
	}
	
	private function startBombing() : Void
	{
		if ( storedBombs.length == 0 ) return;
		var index : Int = Std.random(storedBombs.length);
		board.setColor(storedBombs[index].bombindex, Color.None);
		bombindex = storedBombs[index].index;
		bombdir = storedBombs[index].dir;
		bombtimer = 0;
		storedBombs.remove(storedBombs[index]);
		// trace("boms left " + Std.string(storedBombs.length));
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
			Actuate.tween(cross, 1, { y: 425 } ).ease(Quint.easeOut);
		}
		else
		{
			Actuate.tween (selectionbox, 1, { alpha: 0.0 } );
			Actuate.tween (topbox, 0.75, { y: -60 } ).ease(Quint.easeInOut);
			
			Actuate.tween(buttonRedBig, 1, { y: -43 } ).ease(Quint.easeOut).delay(randomDelay());
			Actuate.tween(buttonBlueBig, 1, { y: -43 } ).ease(Quint.easeOut).delay(randomDelay());
			Actuate.tween(buttonYellowBig, 1, { y: -43 } ).ease(Quint.easeOut).delay(randomDelay());
			
			Actuate.tween(cross, 1, { y: CROSSOUT } ).ease(Quint.easeOut);
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
				else if ( cross.overlapsPoint(p) )
				{
					close = true;
					Game.sfx("abort");
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
						
						if ( canBomb() )
						{
							startBombing();
						}
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
