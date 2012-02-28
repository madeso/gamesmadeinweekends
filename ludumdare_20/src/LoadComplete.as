package
{
	import org.flixel.*;

	public class LoadComplete extends FlxSprite
	{
		[Embed(source = "heart.png")] private var ImgHeart:Class;
		
		private var p : Player = null
		
		public function LoadComplete(xa:Number, ya:Number, pl : Player)
		{
			super(xa, ya);
			visible = false;
			loadGraphic(ImgHeart, true, false, 48);
			p = pl;
			width = 31;
			height = 26;
			offset.x = 7;
			offset.y = 9;
			visible = false;

			addAnimation("idle", [0]);
			play("idle");
		}

		override public function update():void
		{
			if(dead && finished) exists = false;
			else
			{
				var dx : Number = x - p.x;
				var dy : Number = y - p.y;
				var l : Number = Math.sqrt(dx * dx + dy * dy);
				if ( l < 100 )
				{
					FlxG.fade.start(0xffffffff, 1, onFadeCompleted);
				}
				
				super.update();
			}
		}
		
		private function onFadeCompleted() : void
		{
			FlxG.state = new CompleteState();
		}

		override public function render():void
		{
			super.render();
		}
	}
}