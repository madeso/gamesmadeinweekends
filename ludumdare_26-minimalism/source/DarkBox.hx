package ;
import org.flixel.FlxSprite;
import org.flixel.FlxG;
import org.flixel.FlxObject;

/**
 * ...
 * @author sirGustav
 */

class DarkBox extends FlxSprite
{
	public function new(X:Float, Y:Float, f:Float, sx:Float, sy:Float)
	{
		super(X, Y);
		loadGraphic("assets/items.png", true, true, 40, 40);
		addAnimation("idle", [3 * 6 + 3]);
		play("idle");
		alpha = f;
		scale.x = sx;
		scale.y = sy;
	}
}