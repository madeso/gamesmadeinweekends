package
{
	import org.flixel.*;
	
	public class StoryState extends FlxState
	{
		private var text1 : FlxText = null;
		private var text2 : FlxText = null;
		private var text3 : FlxText = null;
		private var text4 : FlxText = null;
		private var text5 : FlxText = null;
		private var text6 : FlxText = null;
		private var text7 : FlxText = null;
		private var text8: FlxText = null;
		
		private var timer : Number = -1;
		private const kTimer : Number = 2;
		private var index : int = -1;
		
		private function ta(y : int) : FlxText
		{
			var t : FlxText =  new FlxText(0, 40 + y*25, FlxG.width, "");
			t.setFormat(null, 16, 0xffffffff, "left");
			add(t)
			return t;
		}
		
		override public function create() : void
		{
			var text : FlxText = new FlxText(0, FlxG.height - 24, FlxG.width, "press X to skip story");
			text.setFormat(null, 8, 0xffffffff, "center");
			add(text);
			
			text1 = ta(0);
			text2 = ta(1);
			text3 = ta(2);
			text4 = ta(3);
			text5 = ta(4);
			text6 = ta(5);
			text7 = ta(6);
			text8 = ta(7);
			
		}
		
		override public function update() : void
		{
			timer -= FlxG.elapsed;
			if ( timer < 0 )
			{
				timer = kTimer;
				index = index + 1;
				switch(index)
				{
					case 0: text1.text = "you are letting me go?"; break;
					case 1: text2.text = "YES SPAWN, YOU MAY ENTER THE WORLD OF THE LIVING"; break;
					case 2: text3.text = "YOUR NEW HUMAN HEART WILL DIE IF IT LEAVES YOUR BODY FOR"; break;
					case 3: text4.text = "TOO LONG. THE ROAD MAY NOT BE LONG BUT"; break;
					case 4: text5.text = "ITS DANGEROUS TO GO ALONE, TAKE THIS!"; break;
					case 5: text6.text = "what is it?"; break;
					case 6: text7.text = "ITS A NAMETAG! SPAWNS WITH NAMES ARE STRONGER"; break;
					case 7: text8.text = "so I am..."; break;
					case 8:
					FlxG.fade.start(0xff000000, 1, startMenu);
					break;
				}
			}
			
			if ( FlxG.keys.pressed("X") )
			{
				FlxG.flash.start(0xffffffff, 0.75, onFadeCompleted);
			}
			
			super.update();
		}
		
		private function startMenu() : void
		{
			FlxG.state = new MenuState();
		}
		private function onFadeCompleted() : void
		{
			FlxG.state = new PlayState();
		}
	}

}