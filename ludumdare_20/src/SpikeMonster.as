package
{
	import org.flixel.*;

	public class SpikeMonster extends FlxSprite
	{
		[Embed(source="spikemonster.png")] private var ImgMonkey:Class;
		
		public function SpikeMonster(ax:Number, ay:Number)
		{
			super(ax, ay);
			mx = ax;
			my = ay;
			loadGraphic(ImgMonkey,true, true, 48);
			width = 48;
			height = 48;
			offset.x = 0;
			offset.y = 0;
			velocity.y = 50;

			addAnimation("idle", [0, 1, 2, 1], 5);
			randomFrame();
			play("idle");
		}

		override public function update():void
		{
			if (dead) exists = false;
			else
			{
				//x = mx;
				//y = my;
				//velocity.x = 0;
				//velocity.y = 0;
				super.update();
			}
		}

		override public function render():void
		{
			super.render();
		}

		override public function kill():void
		{
			if(dead) return;
			velocity.x = 0;
			velocity.y = 0;
			dead = true;
			solid = false;
		}
		
		private var mx : int = 0;
		private var my : int = 0;
		
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