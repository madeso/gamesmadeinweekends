package
{
	import org.flixel.*;

	public class Powerup extends FlxSprite
	{
		[Embed(source="powerup.png")] private var ImgCoconut:Class;
		
		public var isHealth:Boolean = false;
		
		public function Powerup(x:Number, y:Number, aisHealth:Boolean)
		{
			super(x,y);
			loadGraphic(ImgCoconut,true, false, 64);
			width = 24;
			height = 24;
			offset.x = 22;
			offset.y = 24;
			
			isHealth = aisHealth;
			
			velocity.y = 100;

			addAnimation("health", [0]);
			addAnimation("ammo",[1]);
			addAnimation("poof", [2], 20, false);
			
			if ( isHealth )
			{
				play("health");
			}
			else
			{
				play("ammo");
			}
		}

		override public function update():void
		{
			super.update();
		}

		private function stop() : void
		{
			velocity.x = 0;
			velocity.y = 0;
		}

		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { stop(); }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { stop(); }
		
		override public function kill():void
		{
			if(dead) return;
			velocity.x = 0;
			velocity.y = 0;
			dead = true;
			solid = false;
			exists = false;
		}
	}
}