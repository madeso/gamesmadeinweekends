package
{
	import org.flixel.*;
	
	public class CompleteState extends FlxState
	{
		override public function create() : void
		{
			bgColor = 0xffffffff;
			var text : FlxText = new FlxText(0, (FlxG.height / 2) - 80, FlxG.width, "you were reborn to the living and lived happy everafter");
			text.setFormat(null, 16, 0xff000000, "center");
			add(text);
			
			text = new FlxText(0, FlxG.height - 24, FlxG.width, "press X to restart");
			text.setFormat(null, 8, 0xff000000, "center");
			add(text);
		}
		
		override public function update() : void
		{
			if ( FlxG.keys.pressed("X") )
			{
				bgColor = 0xff000000;
				FlxG.state = new StoryState();
			}
			
			super.update();
		}
	}

}