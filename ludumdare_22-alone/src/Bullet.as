package
{
	import org.flixel.*;

	public class Bullet extends FlxSprite
	{
		[Embed(source="bullet.png")] private var ImgBullet:Class;
		[Embed(source="sfx/bullet-destroy.mp3")] private var SndHit:Class;
		[Embed(source = "sfx/player-shoot.mp3")] private var SndShoot:Class;
		[Embed(source = "sfx/player-weakshot.mp3")] private var SndWeakShot:Class;
		
		public function Bullet()
		{
			super();
			loadGraphic(ImgBullet,true, true, 64);
			width = 5;
			height = 5;
			offset.x = 25;
			offset.y = 22;
			exists = false;

			addAnimation("idle", [0], 25);
			addAnimation("up", [1], 25);
			addAnimation("down", [2], 25);
			addAnimation("poof",[0], 25, false);
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

		public function shoot(weak:Boolean, X:int, Y:int, VelocityX:int, VelocityY:int):void
		{
			if ( weak )
			{
				FlxG.play(SndWeakShot);
			}
			else
			{
				FlxG.play(SndShoot);
			}
			super.reset(X,Y);
			solid = true;
			velocity.x = VelocityX;
			velocity.y = VelocityY;
			play("idle");
			if ( VelocityX > 0 )
			{
				facing = RIGHT;
			}
			else
			{
				if ( VelocityY > 0 )
				{
					facing = DOWN;
					play("down");
				}
				else if ( VelocityY < 0 )
				{
					facing = UP;
					play("up");
				}
				else
				{
					facing = LEFT;
				}
			}
			//acceleration.y = 3000;
		}
	}
}