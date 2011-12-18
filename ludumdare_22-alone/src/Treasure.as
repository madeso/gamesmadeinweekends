package
{
	import org.flixel.*;

	public class Treasure extends FlxSprite
	{
		[Embed(source = "treasure.png")] private var ImgTreasure:Class;
		
		private function sign() : Number
		{
			if ( Math.random() > 0.5 ) return 1;
			else return -1;
		}
		
		private var pl : Player  = null;
		
		public function Treasure(ax:Number, ay:Number, apl:Player)
		{
			super(ax,ay);
			loadGraphic(ImgTreasure, true, false, 64);
			width = 30;
			height = 30;
			offset.x = 11;
			offset.y = 33;
			
			var speed : Number = 500;
			velocity.x = Math.random() * sign() * speed;
			velocity.y = Math.random() * speed * -1;
			acceleration.y = 800;
			pl = apl;

			addAnimation("0",[0]);
			addAnimation("1", [1]);
			addAnimation("2", [2]);
			addAnimation("3", [3]);
			
			drag.x = 50.0;
			
			play(Math.floor(Math.random() * 3).toFixed(0));
		}
		
		private static function sscale(d:Number, le:Number):Number
		{
			var s : Number = d / le;
			const M : Number = 800;
			if ( le < M )
			{
				s = s * ((M-le) / M);
			}
			else s = 0;
			//s = Math.min(0.001, s);
			return s;
		}
		
		private var wasStopped : Boolean = false;
		
		override public function update() : void
		{
			if ( velocity.x * velocity.x + velocity.y * velocity.y < 30 )
			{
				wasStopped = true;
			}
			if ( wasStopped )
			{
				var dx : Number = pl.x - x;
				var dy : Number = pl.y - y;
				var l : Number = Math.sqrt(dx * dx + dy * dy);
				dx = sscale(dx, l);
				dy = sscale(dy, l);
				var change : Number = 500;
				velocity.x = dx*change;
				velocity.y = dy * change;
			}
			
			super.update();
		}
		
		private function stopH() : void
		{
			velocity.x *= - 0.25;
		}
		private function stop() : void
		{
			velocity.y *= -0.5;
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { stopH(); }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void { stopH(); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { stop(); }
	}
}