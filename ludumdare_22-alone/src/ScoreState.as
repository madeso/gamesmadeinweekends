package
{
	import org.flixel.*;
	
	public class ScoreState extends FlxState
	{
		private static function Sorter(a:int, b:int) : int
		{
			return a < b ? 1: -1;
		}
		override public function create() : void
		{
			bgColor = 0xff000000;
			var o:Object = null;
			var atext:String = "HIGHSCORE";
			
			if ( FlxG.score > 0 )
			{
				var sum:Number = 0;
				for each (o in FlxG.scores)
				{
					sum += (o as int)
				}
				FlxG.scores.push(FlxG.score);
				FlxG.scores.sort(Sorter);
				FlxG.score = 0;
				
				while ( FlxG.scores.length > 5 )
				{
					FlxG.scores.pop();
				}
				
				var newsum:Number = 0;
				for each (o in FlxG.scores)
				{
					newsum += (o as int)
				}
				
				if ( newsum > sum )
				{
					FlxG.flash.start(0xffffffff, 0.25);
					atext = "NEW HIGHSCORE";
				}
			}
			
			var text : FlxText = new FlxText(0, 20, FlxG.width, atext);
			text.setFormat(null, 16, 0xffffffff, "center");
			add(text);
			
			var index : int = 0;
			
			for each (o in FlxG.scores)
			{
				text = new FlxText(160, 120+index*22, FlxG.width-160, (index+1).toString() + ". " +  (o as int).toString() + " points");
				text.setFormat(null, 20, 0xffffffff, "left");
				add(text);
				index += 1;
			}
			
			text = new FlxText(0, FlxG.height - 24, FlxG.width, "hit ENTER to beat your highscore");
			text.setFormat(null, 8, 0xffffffff, "center");
			add(text);
		}
		
		override public function update() : void
		{
			if ( FlxG.keys.pressed("ENTER") )
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