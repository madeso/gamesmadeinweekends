package ;
import org.flixel.FlxSprite;
import org.flixel.FlxG;
import org.flixel.FlxObject;

/**
 * ...
 * @author sirGustav
 */

class Img extends FlxSprite
{
	public function new(path : String)
	{
		super(0, 0);
		
		loadGraphic(path);
		addAnimation("idle", [0]);
		
		play("idle");
	}
}