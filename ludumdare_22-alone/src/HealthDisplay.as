package
{
	import org.flixel.*;

	public class HealthDisplay extends FlxSprite
	{
		[Embed(source="hearts.png")] private var ImgHearts:Class;
		
		public function HealthDisplay()
		{
			super();
			loadGraphic(ImgHearts,true, false, 64);

			addAnimation("0", [0]);
			addAnimation("1", [1]);
			addAnimation("2", [2]);
			addAnimation("3", [3]);
			addAnimation("4", [4]);
			setHealth(4);
		}
		
		public function setHealth(h:uint) : void
		{
			play(h.toString());
		}
	}
}