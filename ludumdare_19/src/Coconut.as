package
{
	import org.flixel.*;

	public class Coconut extends FlxSprite
	{
		[Embed(source="coconut.png")] private var ImgCoconut:Class;
		[Embed(source="coconut-destroy.mp3")] private var SndHit:Class;
		[Embed(source = "coconut-throw.mp3")] private var SndShoot:Class;
		
		public function Coconut()
		{
			super();
			loadGraphic(ImgCoconut,true, false, 64);
			width = 5;
			height = 5;
			offset.x = 25;
			offset.y = 22;
			exists = false;

			addAnimation("idle",[0]);
			addAnimation("poof",[1,2,3], 15, false);
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

		public function shoot(X:Number, Y:Number, VelocityX:Number, VelocityY:Number):void
		{
			super.reset(X,Y);
			solid = true;
			velocity.x = VelocityX;
			velocity.y = VelocityY;
			play("idle");
			if ( onScreen() )
			{
				FlxG.play(SndShoot);
			}
		}
	}
}