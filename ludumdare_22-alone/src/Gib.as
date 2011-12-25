package
{
	import org.flixel.*;

	public class Gib extends FlxSprite
	{
		[Embed(source = "gibs.png")] private var ImgGibs:Class;
		
		private function sign() : Number
		{
			if ( Math.random() > 0.5 ) return 1;
			else return -1;
		}
		
		private const kAlpha : Number = 3;
		
		private var malpha : Number = kAlpha;
		
		public function Gib()
		{
			super(0,0);
			loadGraphic(ImgGibs, true, false, 64);
			width = 30;
			height = 30;
			offset.x = 11;
			offset.y = 33;
			
			exists = false;
			
			

			for (var i:Number = 0; i < 16; ++i)
			{
				addAnimation(i.toFixed(0),[i]);
			}
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
			return s;
		}
		
		override public function update() : void
		{
			if ( velocity.x * velocity.x + velocity.y * velocity.y < 30 )
			{
				kill();
			}
			
			malpha -= FlxG.elapsed;
			
			if ( malpha < 0 )
			{
				kill();
			}
			
			alpha = malpha / kAlpha;
			
			super.update();
		}
		
		private function stopH() : void
		{
			velocity.x *= - 1.00;
		}
		private function stop() : void
		{
			velocity.y *= -0.75;
		}
		
		override public function kill():void
		{
			if(dead) return;
			velocity.x = 0;
			velocity.y = 0;
			dead = true;
			solid = false;
			exists = false;
		}

		public function spawn(X:int, Y:int):void
		{
			super.reset(X,Y);
			solid = true;
			var speed : Number = 300;
			velocity.x = 2 * Math.random() * sign() * speed;
			velocity.y = 2 * Math.random() * sign() * speed;
			acceleration.y = 800;
			drag.x = 100.0;
			malpha = kAlpha;
			
			play(Math.floor(Math.random() * 16).toFixed(0));
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { stopH(); }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void { stopH(); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { stop(); }
	}
}