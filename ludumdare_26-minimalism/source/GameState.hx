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
import com.eclecticdesignstudio.motion.easing.Sine;
import com.eclecticdesignstudio.motion.easing.Bounce;

/**
 * ...
 * @author sirGustav
 */

class GameState  extends FlxState
{	
	private static var BLACK : Int = 3;
	private static var CROSS : Int = 11;
	private static var BOMB : Int = 17;
	
	private var items : FlxGroup;
	private var board : Board;
	private var cross : DarkBox;
	private var bombButton : DarkBox;
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
	private static var BOMBTIME : Float = 0.30;
	
	private var storedBombs : Array<BombDir>;
	
	private var scoreMulti : Int = 1;
	private var scoreDisplay : FlxText;
	
	private var lastColors : Array<Color>;
	
	var continuetext : FlxText;
	
	override public function create():Void
	{
		// Game.music("andsoitbegins");
		
		storedBombs = new Array<BombDir>();
		
		lastColors = new Array<Color>();
		
		lastColor = Color.None;
		items = new FlxGroup();
		board = new Board();
		selectionbox = new DarkBox(300, 300, 0, 16, 16, 0);
		topbox = new DarkBox(300, -60, 0.5, 16, 2, BLACK);
		cross = new DarkBox(570, CROSSOUT, 1, 1, 1, CROSS);
		bombButton = new DarkBox(-40, 420, 1, 1, 1, BOMB);
		placehere = new Box(0, 0, BoxSize.Normal, Color.None, false);
		placehere.visible = false;
		
		continuetext = new FlxText(0, 360, Game.Width,
		#if android
		"Touch to continue"
		#else
		"Hit space to continue"
		#end
		, true);
		continuetext.font = "assets/fonts/La-chata-normal.ttf";
		
		continuetext.alignment = "center";
		continuetext.color = 0xff000000;
		continuetext.size = 25;
		continuetext.visible = false;
		Actuate.tween(continuetext, 0.5, { size: 30 } ).repeat().reflect().ease(Quint.easeInOut);
		
		var buttonheight : Int = -40;
		
		var BASE : Int = 80;
		var RED : Int = BASE + 20;
		var BLUE : Int = BASE + 40 * 5;
		var YELLOW : Int = BASE + 40 * 10;
		
		var SPACE : Int = 10;
		
		buttonRedBig = new Box(RED + 0, buttonheight, BoxSize.Normal, Color.Red, true);
		buttonBlueBig = new Box(BLUE + 0, buttonheight, BoxSize.Normal, Color.Blue, true);
		buttonYellowBig = new Box(YELLOW + 0, buttonheight, BoxSize.Normal, Color.Yellow, true);
		
		bombButton.scale.x = 0.9;
		bombButton.scale.y = 0.9;
		
		scoreDisplay = new FlxText(10, 10, Game.Width-20, "[score]", 25);
		scoreDisplay.font = "assets/fonts/La-chata-normal.ttf";
		scoreDisplay.alignment = "right";
		scoreDisplay.color = 0xff000000;
		
		updateScoreDisplay();
		
		add(board);
		add(items);
		add(scoreDisplay);
		add(selectionbox);
		add(topbox);
		add(placehere);
		add(cross);
		add(bombButton);
		
		add(buttonRedBig);
		add(buttonBlueBig);
		add(buttonYellowBig);
		
		add(continuetext);
		
		FlxG.bgColor = 0xfffdfdfd;
		
		#if flash
		FlxG.mouse.show();
		#end
		
		updateTintOnLastSelection();
	}
	
	private function updateTintOnLastSelection()
	{
		selectionbox.color = 0xff000000;
		if ( lastColor == Color.Red ) selectionbox.color = 0xff400000;
		if ( lastColor == Color.Blue ) selectionbox.color = 0xff000040;
		if ( lastColor == Color.Yellow ) selectionbox.color = 0xff404000;
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
	
	private function updateScore(id:Int):Void
	{
		var c : Color = board.getColor(id);
		if ( c != Color.None && c!=Color.Black )
		{
			lastColors.push(c);
		}
		while (lastColors.length > 4)
		{
			lastColors.shift();
		}
		
		var sb : Int = getScoreBase();
		
		Game.Score += scoreMulti * sb;
		addScoreToWorld(id, scoreMulti*sb, sb>1?"x4":"");
		
		updateScoreDisplay();
		Actuate.tween(scoreDisplay, 0.10, { size: 50 } ).repeat(1).reflect().ease(Quint.easeInOut);
		FlxG.shake(0.02, 0.1);
	}
	
	private function getScoreBase() : Int
	{
		var red : Bool = false;
		var blue : Bool = false;
		var yellow : Bool = false;
		
		for (c in lastColors)
		{
			if ( c == Color.Red ) red = true;
			if ( c == Color.Blue ) blue = true;
			if ( c == Color.Yellow ) yellow = true;
		}
		
		var base : Int = 0;
		if ( red )
		{
			++base;
		}
		if ( blue )
		{
			++base;
		}
		if ( yellow )
		{
			++base;
		}
		
		if ( base <= 2 ) return 1;
		else
		{
			return 4;
		}
	}
	
	private function addScoreToWorld(id:Int, score:Int, x:String):Void
	{
		var pos : Vec = board.getCenter(id);
		
		var c : Color = board.getColor(id);
		if ( c != Color.None )
		{
			var bang : DarkBox = new DarkBox(pos.x, pos.y, 1.0, 1.0, 1.0, 1);
			items.add(bang);
			bang.color = Game.CalcColor(c);
			
			var TIMEFX : Float = 0.5;
			var SCALE : Float = 8;
			
			Actuate.tween(bang.scale, TIMEFX, { x: SCALE } ).ease(Quint.easeOut);
			Actuate.tween(bang.scale, TIMEFX, { y: SCALE } ).ease(Quint.easeOut);
			Actuate.tween(bang, TIMEFX, { alpha: 0 } ).ease(Quint.easeOut);
		}
		
		var t : FlxText = new FlxText(pos.x - 50, pos.y, 100, Std.string(score)+"00"+x, 20);
		t.alignment = "center";
		t.font = "assets/fonts/La-chata-normal.ttf";
		t.color = 0xff000000;
		t.size = 25;
		var TIME : Float = 1.5;
		Actuate.tween(t, TIME, { size: 40 } ).ease(Quint.easeOut);
		Actuate.tween(t, TIME, { y: t.y - 80 } ).ease(Quint.easeOut);
		Actuate.tween(t, TIME, { alpha: 0 } ).ease(Quint.easeOut);
		items.add(t);
	}
	
	private function updateScoreDisplay() : Void
	{
		if ( Game.Score > 0 )
		{
			scoreDisplay.text = Std.string(Game.Score) + "00";
		}
		else
		{
			scoreDisplay.text = "0";
		}
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
				onClick(p, Command.None);
			}
			
			for (touch in FlxG.touchManager.touches)
			{
				if ( touch.justReleased() )
				{
					var p : Vec = new Vec(touch.screenX, touch.screenY);
					onClick(p, Command.None);
				}
			}
			
			var away: Vec = new Vec( -100, -100);
			
			if ( FlxG.keys.justReleased("ENTER") ) onClick(away, Command.StartBombing);
			
			if ( FlxG.keys.justReleased("R") ) onClick(away, Command.Red);
			if ( FlxG.keys.justReleased("Y") ) onClick(away, Command.Blue);
			if ( FlxG.keys.justReleased("B") ) onClick(away, Command.Yellow);
			
			if ( FlxG.keys.justReleased("A") ) onClick(away, Command.Red);
			if ( FlxG.keys.justReleased("S") ) onClick(away, Command.Blue);
			if ( FlxG.keys.justReleased("W") ) onClick(away, Command.Blue);
			if ( FlxG.keys.justReleased("D") ) onClick(away, Command.Yellow);
			
			if ( FlxG.keys.justReleased("ONE") ) onClick(away, Command.Red);
			if ( FlxG.keys.justReleased("TWO") ) onClick(away, Command.Blue);
			if ( FlxG.keys.justReleased("THREE") ) onClick(away, Command.Yellow);
			
			if ( FlxG.keys.justReleased("ESCAPE") ) onClick(away, Command.Close);
			
			if ( FlxG.keys.justReleased("SPACE") ) onClick(away, Command.Keep);
		}
		else
		{
			bombtimer += FlxG.elapsed;
			if ( bombtimer > BOMBTIME )
			{
				bombtimer -= BOMBTIME;
				Game.sfx("bang");
				updateScore(bombindex);
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
						++scoreMulti;
					}
					
					if ( goright )
					{
						++scoreMulti;
						Game.sfx("score");
						// trace("right");
						bombdir = Right(bombdir);
						bombindex = board.getIndexFromDir(bombindex, bombdir);
					}
					else if ( goleft )
					{
						++scoreMulti;
						Game.sfx("score");
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
							
							continuetext.visible = true;
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
			Actuate.tween (selectionbox, 1, { alpha: 0.5 } ).ease(Sine.easeInOut);
			Actuate.tween (topbox, 1, { y: 0 } ).ease(Quint.easeOut);
			
			Actuate.tween(buttonRedBig, 1, { y: 10 } ).ease(Bounce.easeOut).delay(randomDelay());
			Actuate.tween(buttonBlueBig, 1, { y: 10 } ).ease(Bounce.easeOut).delay(randomDelay());
			Actuate.tween(buttonYellowBig, 1, { y: 10 } ).ease(Bounce.easeOut).delay(randomDelay());
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
	
	private function hideBombButton() : Void
	{
		Actuate.tween(bombButton, 1, { x: -40 } ).ease(Quint.easeOut);
	}
	
	private function onClick(apoint:Vec, cmd:Command): Void
	{
		if ( continuetext.visible )
		{
			if ( board.hasBoxes() )
			{
				FlxG.switchState(new LostState() );
			}
			else
			{
				FlxG.switchState(new WinState() );
			}
		}
		else
		{
			var fp : FlxPoint = apoint.flx();
			
			if ( cmd == Command.StartBombing || bombButton.overlapsPoint(fp) )
			{
				if ( storedBombs.length > 0 )
				{
					Game.sfx("enter");
					startBombing();
					
					if ( selectionVisible )
					{
						setSelectionVisible(false);
					}
					hideBombButton();
				}
			}
			
			if ( selectionVisible )
			{
				var close : Bool = true;
				
				if ( targetindex >= 0 )
				{
					close = false;
					var c : Color = Color.None;
					if ( cmd == Command.Red || buttonRedBig.overlapsPoint(fp) )
					{
						c = Color.Red;
					}
					else if ( cmd == Command.Blue || buttonBlueBig.overlapsPoint(fp) )
					{
						c = Color.Blue;
					}
					else if ( cmd == Command.Yellow || buttonYellowBig.overlapsPoint(fp) )
					{
						c = Color.Yellow;
					}
					else if ( cmd == Command.Close || cross.overlapsPoint(fp) )
					{
						close = true;
						Game.sfx("abort");
					}
					else if ( lastColor != Color.None )
					{
						var index : Int = board.getClosestMatch(apoint);
						if ( cmd == Command.Keep || index == targetindex )
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
							updateTintOnLastSelection();
							Game.sfx("enter");
							close = true;
							
							var osl : Int = storedBombs.length;
							
							if ( canBomb() )
							{
								if ( storedBombs.length > 0 )
								{
									if ( osl == 0 ) // adding a sine multiple times on the same object causes flash to crash
									{
										Actuate.tween(bombButton, 1, { x: 10 } ).ease(Quint.easeOut);
										Actuate.tween(bombButton.scale, 0.5, { x: 1.1 } ).repeat().reflect().ease(Sine.easeInOut).delay(randomDelay());
										Actuate.tween(bombButton.scale, 0.5, { y: 1.1 } ).repeat().reflect().ease(Sine.easeInOut).delay(randomDelay());
									}
								}
								
								if ( storedBombs.length == osl )
								{
									startBombing();
									hideBombButton();
								}
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
				var index : Int = board.getClosestMatch(apoint);
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
}
