package
{
	import org.flixel.*;

	public class StonePickup extends FlxSprite
	{
		[Embed(source="powerup.png")] private var ImgStones:Class;
		
		public function StonePickup(ax:Number, ay:Number)
		{
			super(ax,ay);
			loadGraphic(ImgStones,true, false, 64);
			width = 23;
			height = 15;
			offset.x = 7;
			offset.y = 9;
			
			velocity.y = 15;

			addAnimation("idle",[0]);
		}
		
		private function stop() : void
		{
			velocity.y = 0;
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { stop(); }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { stop(); }
	}
}