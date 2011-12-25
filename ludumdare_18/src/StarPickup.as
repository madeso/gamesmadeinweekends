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
			width = 30;
			height = 30;
			offset.x = 11;
			offset.y = 5;

			addAnimation("idle", [0, 1], 3);
			play("idle");
		}
	}
}