package
{
	import org.flixel.*;

	public class Bullet extends FlxSprite
	{
		[Embed(source="bullet.png")] private var ImgBullet:Class;
		[Embed(source="hit.mp3")] private var SndHit:Class;
		[Embed(source = "fire.mp3")] private var SndShoot:Class;
		
		private const kBounces : uint = 2;
		private const kBounceSpeed : Number = 500;
		private const kSpread : Number = 70;
		private const kMinSpread : Number = 10;
		
		private var bounces : uint = 0;

		public function Bullet()
		{
			super();
			loadGraphic(ImgBullet,true, false, 64);
			width = 5;
			height = 5;
			offset.x = 25;
			offset.y = 22;
			exists = false;

			addAnimation("idle",[0]);
			addAnimation("poof",[1,2], 25, false);
		}
		
		private function canBounce() : Boolean
		{
			return true;
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
		
		private static function ms(p:FlxPoint):String
		{
			return "(" + p.x.toString() + ", " + p.y.toString() + ")";
		}
		
		override public function kill():void
		{
			var doit : Boolean = true;
			
			if ( canBounce() )
			{
				if ( bounces < kBounces )
				{
					bounces += 1;
					doit = false;
					
					var a : Number = (FlxU.random() * kSpread) - kSpread / 2;
					a += sign(a) * kMinSpread;
					FlxG.log("a: " + a.toString());
					a = 180 * a / Math.PI;
					var dx : Number = Math.cos(a) * kBounceSpeed;
					var dy : Number = Math.sin(a) * kBounceSpeed;
					
					if ( sign(dx) == sign(velocity.x) )
					{
						dx *= -1;
					}
					if ( sign(dy) == sign(velocity.y) )
					{
						dy *= -1;
					}
					
					velocity.x = dx;
					velocity.y = dy;
					
					//velocity.x *= - 1;
					//velocity.y *= - 1;
					if(onScreen()) FlxG.play(SndHit);
				}
			}
			
			if ( doit )
			{
				if(dead) return;
				velocity.x = 0;
				velocity.y = 0;
				if(onScreen()) FlxG.play(SndHit);
				dead = true;
				solid = false;
				play("poof");
			}
		}

		public function shoot(X:int, Y:int, VelocityX:int, VelocityY:int):void
		{
			FlxG.play(SndShoot);
			super.reset(X,Y);
			solid = true;
			velocity.x = VelocityX;
			velocity.y = VelocityY;
			bounces = 0;
			play("idle");
		}
	}
}