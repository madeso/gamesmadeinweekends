package
{
	import org.flixel.*;

	public class Monkey extends FlxSprite
	{
		[Embed(source="barrel.png")] private var ImgMonkey:Class;
		[Embed(source="explosion.mp3")] private var SndHit:Class;
		
		public function Monkey(ax:Number, ay:Number)
		{
			super(ax,ay);
			loadGraphic(ImgMonkey,true, false, 64);
			width = 54;
			height = 62;
			offset.x = 5;
			offset.y = 2;

			addAnimation("idle",[0]);
			addAnimation("die",[1,2,3,4,5,6,7,8,9], 10, false);
		}

		override public function update():void
		{
			if(dead && finished) exists = false;
			else super.update();
		}

		override public function render():void
		{
			super.render();
		}

		override public function kill():void
		{
			if(dead) return;
			velocity.x = 0;
			velocity.y = 0;
			if (onScreen())
			{
				FlxG.play(SndHit);
				FlxG.quake.start(0.05, 0.3);
			}
			dead = true;
			solid = false;
			play("die");
		}
	}
}