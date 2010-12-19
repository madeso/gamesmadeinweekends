package
{
	import org.flixel.*;

	public class SaveSign extends FlxSprite
	{
		[Embed(source="save.png")] private var ImgStones:Class;
		
		public var text : String = "";
		
		public function SaveSign(ax:Number, ay:Number, t:String)
		{
			super(ax, ay);
			text = t;
			loadGraphic(ImgStones,true, false, 64);
			width = 55;
			height = 57;
			offset.x = 3;
			offset.y = 7;
			
			velocity.y = 35;

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