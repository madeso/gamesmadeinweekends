package
{
	import org.flixel.*;

	public class Treasure extends FlxSprite
	{
		[Embed(source="treasure.png")] private var ImgTreasure:Class;
		
		public var text : String;
		public function Treasure(ax:Number, ay:Number, n : String)
		{
			super(ax,ay);
			loadGraphic(ImgTreasure, true, false, 64);
			text = n;
			width = 55;
			height = 57;
			offset.x = 3;
			offset.y = 7;
			
			velocity.y = 25;

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