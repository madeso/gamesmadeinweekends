package ;

import org.flixel.FlxG;
import org.flixel.FlxGroup;

/**
 * ...
 * @author sirGustav
 */

class Board extends FlxGroup
{
	private static var BOARDSIZE : Int = 6;
	
	private static var STARTX : Int = 80;
	private static var ENDX : Int = STARTX + 11 * 40;
	
	private static var STARTY : Int = 90;
	private static var ENDY : Int = STARTY + 7 * 40;
	
	public var Width : Int = 0;
	public var Height : Int = 0;
	
	private var boxes : Array<Box>;
	
	public function new() 
	{
		super();
		
		trace("creating board");
		
		boxes = new Array<Box>();
		
		var xsize : Array<Bool> = new Array<Bool>();
		var ysize : Array<Bool> = new Array<Bool>();
		
		var x : Int = STARTX;
		var y : Int = STARTY;
		
		var big : Bool = false;
		
		// add vertical lines
		while(x < ENDX)
		{
			add(new Line(x, false));
			big = Game.brnd();
			xsize.push(big);
			x += step(big);
			Width++;
		}
		add(new Line(x, false));
		
		// add horizontal lines
		while (y < ENDY)
		{
			add(new Line(y, true));
			big = Game.brnd();
			ysize.push(big);
			y += step(big);
			Height++;
		}
		add(new Line(y, true));
		
		// setup board data
		var ybase : Int = 0;
		y = 0;
		while (y < Height)
		{
			var xbase : Int = 0;
			var ybig : Bool = ysize[y];
			x = 0;
			while (x < Width)
			{
				var xbig : Bool = xsize[x];
				var size : BoxSize = GetSize(xbig, ybig);
				var color : Color = Game.RandomColor();
				//trace("Adding: " + Std.string(xbig) + " & " +  Std.string(ybig) +"->"+ Std.string(size));
		
				var b : Box = new Box(STARTX + xbase + 2, STARTY + ybase + 2, size, color, true);
				boxes.push(b);
				add(b);
				
				xbase += step(xbig);
				
				++x;
			}
			ybase += step(ybig);
			++y;
		}
	}
	
	private function GetSize(xbig:Bool, ybig:Bool):BoxSize
	{
		if ( xbig && ybig ) return BoxSize.Normal;
		if ( !xbig && !ybig ) return BoxSize.Small;
		if ( xbig ) return BoxSize.Half;
		return return BoxSize.RotatedHalf;
	}
	
	public function getClosestMatch(p:Vec) : Int
	{
		var best : Int = -1;
		var dist : Float = 0;
		
		var y : Int = 0;
		while (y < Height)
		{
			var x : Int = 0;
			while (x < Width)
			{
				var i : Int = index(x, y);
				var b : Vec = boxes[i].getCenter();
				var l : Float = Vec.Sub(p, b).lenSq();
				if ( best == -1 || dist > l )
				{
					best = i;
					dist = l;
				}
				
				++x;
			}
			++y;
		}
		
		return best;
	}
	
	public function getPosition(i:Int) : Vec
	{
		if ( i < 0 ) return new Vec(0, 0);
		else return new Vec(boxes[i].x, boxes[i].y);
	}
	
	public function getSize(i:Int) : BoxSize
	{
		if ( i < 0 ) return BoxSize.Normal;
		else return boxes[i].getSize();
	}
	
	public function setColor(pos:Int, c: Color)
	{
		boxes[pos].setColor(c);
	}
	
	public function index(x:Int, y:Int):Int
	{
		if ( x < 0 ) return -1;
		if ( x >= Width) return -1;
		if ( y < 0 ) return -1;
		if ( y >= Height ) return -1;
		return Width * y + x;
	}
	
	private function step(big:Bool) : Int
	{
		if ( big ) return 42;
		else return 22;
	}
}