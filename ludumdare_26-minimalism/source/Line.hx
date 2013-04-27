package ;
import org.flixel.FlxSprite;
import org.flixel.FlxG;
import org.flixel.FlxObject;

/**
 * ...
 * @author sirGustav
 */

class Line extends FlxSprite
{
	private static var SCALE : Float = 16;
	private static var BASE : Float = 300;
	
	public function new(Pos:Float, Hor:Bool)
	{
		super(0,0);
		
		if ( !Hor )
		{
			x = Pos;
			y = BASE;
			scale.y = SCALE;
		}
		else
		{
			x = BASE;
			y = Pos;
			scale.x = SCALE;
		}
		
		loadGraphic("assets/items.png", true, true, 40, 40);
		if ( Hor )
		{
			addAnimation("idle", [4]);
		}
		else
		{
			addAnimation("idle", [5]);
		}
		play("idle");
	}
}