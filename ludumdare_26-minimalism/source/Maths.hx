package ;
import org.flixel.FlxPoint;

/**
 * ...
 * @author sirGustav
 */

class Maths 
{
	private static var X : Float = 1.0 / Math.sqrt(2.0);

	public static function Classify(a:Vec) : Int
	{
		// TODO add more directions
		var d : Vec = a.nor();
		
		var r : Int = 6;
		var temp : Float = Acos(new Vec(1,0).dot(d));
		var current : Float = temp;
		
		temp = Acos(new Vec(-1,0).dot(d));
		if( temp < current )
		{
			r = 4;
			current = temp;
		}
		
		temp = Acos(new Vec(0,1).dot(d));
		if( temp < current )
		{
			r = 8;
			current = temp;
		}
		
		temp = Acos(new Vec(0,-1).dot(d));
		if( temp < current )
		{
			r = 2;
			current = temp;
		}
		
		temp = Acos(new Vec(X,X).dot(d));
		if( temp < current )
		{
			r = 9;
			current = temp;
		}
		
		temp = Acos(new Vec(-X,X).dot(d));
		if( temp < current )
		{
			r = 7;
			current = temp;
		}
		
		temp = Acos(new Vec(X,-X).dot(d));
		if( temp < current )
		{
			r = 3;
			current = temp;
		}
		
		temp = Acos(new Vec(-X,-X).dot(d));
		if( temp < current )
		{
			r = 1;
			current = temp;
		}
		
		return r;
	}

	private static function Acos(dot:Float) : Float
	{
		return Math.acos(dot);
	}
}