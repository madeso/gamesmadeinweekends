package
{
	import org.flixel.*;

	public class DeadGnome extends FlxSprite
	{
		[Embed(source = "gnome.png")] private var ImgMagician:Class;
		
		public function DeadGnome()
		{
			super(0,0);
			loadGraphic(ImgMagician,true, false, 64);
			width = 40;
			height = 43;
			offset.x = 11;
			offset.y = 20;
			
			dou = false;
			dead = true;
			exists = false;
			
			acceleration.y = 550;

			addAnimation("idle", [4]);
			play("idle");
		}
		
		public function carryingRemove() : void
		{
			exists = false;
			visible = false;
			dead = true;
		}
		
		private var dou : Boolean = false;
		
		public function start(ax:Number, ay:Number, xv:Number, yv:Number, b : Boolean) : void
		{
			super.reset(ax, ay);
			velocity.x = xv;
			velocity.y = yv;
			dou = true;
			dead = false;
			exists = true;
			solid = b;
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void {  }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void {  }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void {  }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { }

		override public function update():void
		{
			if (dead)
			{
				exists = false;
			}
			else
			{
				if ( onScreen() == false )
				{
					FlxG.log("killed dead gnome offscreen");
					kill();
				}
				if ( dou )
				{
					super.update();
				}
			}
		}

		override public function render():void
		{
			super.render();
		}

		override public function kill():void
		{
			if(dead) return;
			dead = true;
			solid = false;
			exists = false;
		}
	}
}