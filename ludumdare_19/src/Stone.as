package
{
	import org.flixel.*;

	public class Stone extends FlxSprite
	{
		[Embed(source="stone.png")] private var ImgStone:Class;
		[Embed(source="stone-crash.mp3")] private var SndHit:Class;
		[Embed(source = "stone-throw.mp3")] private var SndShoot:Class;
		
		public function Stone()
		{
			super();
			loadGraphic(ImgStone,true, false, 64);
			width = 5;
			height = 5;
			offset.x = 25;
			offset.y = 22;
			exists = false;

			addAnimation("idle",[0,1,2,3], 25);
			addAnimation("poof",[4,5], 25, false);
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

		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { kill(); }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void { kill(); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { kill(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { kill(); }
		
		private static function sign(n : Number) : int
		{
			if ( n > 0 ) return 1;
			else return -1;
		}
		
		override public function kill():void
		{
			if(dead) return;
			velocity.x = 0;
			velocity.y = 0;
			if(onScreen()) FlxG.play(SndHit);
			dead = true;
			solid = false;
			play("poof");
		}

		public function shoot(X:int, Y:int, VelocityX:int, VelocityY:int):void
		{
			FlxG.play(SndShoot);
			super.reset(X,Y);
			solid = true;
			velocity.x = VelocityX;
			velocity.y = VelocityY - 700;
			acceleration.y = 3000;
			play("idle");
		}
	}
}