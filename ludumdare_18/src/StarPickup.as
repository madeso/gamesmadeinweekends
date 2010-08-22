package
{
	import org.flixel.*;

	public class StarPickup extends FlxSprite
	{
		[Embed(source="powerup.png")] private var ImgBullet:Class;
		
		public function StarPickup(ax:Number, ay:Number)
		{
			super(ax,ay);
			loadGraphic(ImgBullet,true, false, 64);
			width = 5;
			height = 5;
			offset.x = 25;
			offset.y = 22;

			addAnimation("idle", [0, 1], 3);
			play("idle");
		}
	}
}