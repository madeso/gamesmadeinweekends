package
{
	import org.flixel.*;

	public class Barrel extends FlxSprite
	{
		[Embed(source="barrel.png")] private var ImgBullet:Class;
		[Embed(source="explosion.mp3")] private var SndHit:Class;
		
		public function Barrel(ax:Number, ay:Number)
		{
			super(ax,ay);
			loadGraphic(ImgBullet,true, false, 64);
			width = 54;
			height = 62;
			offset.x = 5;
			offset.y = 2;
			
			velocity.y = 5;

			addAnimation("idle",[0]);
			addAnimation("poof",[1,2,3,4,5,6,7,8,9], 10, false);
		}
		
		private function stop() : void
		{
			velocity.y = 0;
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { stop(); }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { stop(); }

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
			play("poof");
		}
	}
}