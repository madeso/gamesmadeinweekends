package
{
	import org.flixel.*;

	public class TitleSprite extends FlxSprite
	{
		[Embed(source="title.png")] private var ImgHeart:Class;
		
		public function TitleSprite()
		{
			super(0,0);
			loadGraphic(ImgHeart,false, false, 640);
			width = 640;
			height = 480;
			offset.x = 0;
			offset.y = 0;

			addAnimation("idle", [0]);
			play("idle")
		}

		override public function update():void
		{
			super.update();
		}

		override public function render():void
		{
			super.render();
		}
	}
}