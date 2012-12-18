package
{
	import org.flixel.*;

	public class Bullet extends FlxSprite
	{
		[Embed(source="bullet.png")] private var ImgBullet:Class;
		[Embed(source = "scream.mp3")] private var SndShoot:Class;
		
		private var mhasb : Boolean = false;

		public function Bullet()
		{
			super();
			loadGraphic(ImgBullet,false, false, 100);
			width = 28;
			height = 28;
			offset.x = 36;
			offset.y = 44;
			exists = false;

			addAnimation("idle",[0]);
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
		
		override public function kill():void
		{
			if(dead) return;
			velocity.x = 0;
			velocity.y = 0;
			dead = true;
			solid = false;
			exists = false;
			play("poof");
		}

		public function shoot(X:int, Y:int, VelocityX:int, VelocityY:int):void
		{
			FlxG.play(SndShoot);
			super.reset(X,Y);
			solid = true;
			velocity.x = VelocityX;
			velocity.y = VelocityY;
			play("idle");
		}
	}
}