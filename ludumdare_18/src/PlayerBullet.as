package
{
	import org.flixel.*;

	public class PlayerBullet extends FlxSprite
	{
		[Embed(source="bullet.png")] private var ImgBullet:Class;
		[Embed(source="bang1.mp3")] private var SndHit:Class;
		[Embed(source = "msh.mp3")] private var SndShoot:Class;
		
		public function PlayerBullet()
		{
			super();
			loadGraphic(ImgBullet,true, true, 64);
			width = 5;
			height = 5;
			offset.x = 25;
			offset.y = 22;
			exists = false;
			solid = false;

			addAnimation("idle",[4]);
			addAnimation("poof",[5,6], 10, false);
		}
		
		override public function update():void
		{
			if(dead && finished) exists = false;
			else
			{
				if ( onScreen() == false ) kill();
				super.update();
			}
		}

		override public function render():void
		{
			super.render();
		}

		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { kill(); }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void { kill(); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { kill(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { kill(); }
		
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
			velocity.y = VelocityY;
			if ( VelocityX > 0 ) facing = RIGHT;
			else facing = LEFT;
			play("idle");
		}
	}
}