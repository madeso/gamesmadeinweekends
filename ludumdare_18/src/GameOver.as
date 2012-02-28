package
{
	import org.flixel.*;
	
	public class GameOver extends FlxState
	{
		override public function create() : void
		{
			var text : FlxText = new FlxText(0, (FlxG.height / 2) - 80, FlxG.width, "Game over");
			text.setFormat(null, 16, 0xffffffff, "center");
			add(text);
			
			text = new FlxText(0, FlxG.height - 24, FlxG.width, "press X to restart");
			text.setFormat(null, 8, 0xffffffff, "center");
			add(text);
		}
		
		override public function update() : void
		{
			if ( FlxG.keys.pressed("X") )
			{
				FlxG.flash.start(0xffffffff, 0.75);
				FlxG.fade.start(0xff000000, 1, onFadeCompleted);
			}
			
			super.update();
		}
		
		private function onFadeCompleted() : void
		{
			FlxG.state = new PlayState();
		}
	}

}