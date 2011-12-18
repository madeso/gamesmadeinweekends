package
{
	import org.flixel.*;

	public class Spawner extends FlxSprite
	{
		[Embed(source="groundspawner.png")] private var ImgStones:Class;
		
		public function Spawner(ax:Number, ay:Number, vel:Number)
		{
			super(ax,ay);
			loadGraphic(ImgStones,true, false, 64);
			width = 23;
			height = 15;
			offset.x = 7;
			offset.y = 9;
			
			velocity.y = vel;
			visible = false;

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