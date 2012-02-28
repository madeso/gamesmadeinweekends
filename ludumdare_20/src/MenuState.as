package
{
	import org.flixel.*;
	
	public class MenuState extends FlxState
	{
		override public function create() : void
		{
			add(new TitleSprite());
			var text : FlxText = new FlxText(0, FlxG.height - 24, FlxG.width, "press X to start");
			text.setFormat(null, 8, 0xffffffff, "center");
			add(text);
		}
		
		override public function update() : void
		{
			if ( FlxG.keys.pressed("X") )
			{
				FlxG.flash.start(0xffffffff, 0.75, onFadeCompleted);
			}
			
			super.update();
		}
		
		private function onFadeCompleted() : void
		{
			FlxG.state = new PlayState();
		}
	}

}