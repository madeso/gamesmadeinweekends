package ;
import org.flixel.FlxPoint;

/**
 * ...
 * @author sirGustav
 */

class Vec 
{
	public var x : Float;
	public var y : Float;
	
	public function new(?X: Float, ?Y:Float)
	{
		x = (X==null)?0:X;
		y = (Y==null)?x:Y;
	}
	
	public function flx() : FlxPoint
	{
		return new FlxPoint(x, y);
	}
	
	public function sub(o: Vec) : Vec
	{
		return new Vec(x - o.x, y - o.y);
	}
	public static function Sub(lhs : Vec, rhs: Vec) : Vec
	{
		return lhs.sub(rhs);
	}
	
	public function point() : FlxPoint
	{
		return new FlxPoint(x, y);
	}
	
	public function len() : Float
	{
		return Math.sqrt(lenSq());
	}
	
	public function lenSq() : Float
	{
		return x * x + y * y;
	}
	
	public function scaled(s : Float) : Vec
	{
		return new Vec(x * s, y * s);
	}
	
	public function nor() : Vec
	{
		return scaled(1 / len());
	}
	
	public function dot(v:Vec) : Float
	{
		return x * v.x + y * v.y;
	}
	public static function Dot(lhs:Vec, rhs:Vec) : Float
	{
		return lhs.dot(rhs);
	}
}