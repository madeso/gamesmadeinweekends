package
{
	import org.flixel.*;

	public class Heart extends FlxSprite
	{
		[Embed(source="heart.png")] private var ImgHeart:Class;
		
		public function Heart()
		{
			super();
			loadGraphic(ImgHeart,true, false, 48);
			width = 31;
			height = 26;
			offset.x = 7;
			offset.y = 9;
			exists = false;

			addAnimation("idle",[0]);
		}

		override public function update():void
		{
			if(dead && finished) exists = false;
			else
			{
				velocity.x -= velocity.x * 0.10 * FlxG.elapsed;
				velocity.y -= velocity.y * 0.10 * FlxG.elapsed;
				super.update();
			}
		}

		override public function render():void
		{
			if ( dead == false )
			{
				super.render();
			}
		}

		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { bounce(true); }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void { bounce(true); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { bounce(false); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { bounce(false); }
		
		private function bounce(rl:Boolean) : void
		{
			if ( rl )
			{
				velocity.x = velocity.x * sign(velocity.x);
			}
			else
			{
				velocity.y = velocity.y * sign(velocity.y);
			}
		}
		
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
		}
	}
}