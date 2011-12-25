package
{
	import org.flixel.*;

	public class Powerup extends FlxSprite
	{
		[Embed(source="powerup.png")] private var ImgBullet:Class;
		
		public function Powerup(ax:Number, ay:Number)
		{
			super(ax,ay);
			loadGraphic(ImgBullet,true, false, 64);
			width = 5;
			height = 5;
			offset.x = 25;
			offset.y = 22;

			addAnimation("idle",[0]);
		}
	}
}