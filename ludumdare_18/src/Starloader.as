package
{
	import org.flixel.*;

	public class Starloader extends FlxSprite
	{
		[Embed(source = "player.png")] private var ImgMagician:Class;
		
		public function Starloader()
		{
			super(0,0);
			loadGraphic(ImgMagician,true, false, 64);
			width = 40;
			height = 43;
			offset.x = 11;
			offset.y = 20;

			addAnimation("idle", [12,13,14,15], 6);
			play("idle");
		}
		
		public function start(ax:Number, ay:Number) : void
		{
			super.reset(ax, ay);
			
			dead = false;
			solid = false;
			exists = true;
			visible = true;
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void {  }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void {  }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void {  }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { }

		override public function update():void
		{
			super.update();
		}

		override public function render():void
		{
			super.render();
		}

		override public function kill():void
		{
			dead = true;
			solid = false;
			exists = false;
			visible = false;
		}
	}
}