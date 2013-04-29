package;

import nme.Assets;
import nme.geom.Rectangle;
import nme.net.SharedObject;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxU;

import org.flixel.system.input.FlxTouchManager;
import org.flixel.system.input.FlxTouch;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Quint;

class LostState extends FlxState
{
	private var score : Int;
	override public function create():Void
	{
		score = Game.Score;
		Game.Score = 0;
		
		FlxG.bgColor = 0xffffffff;
		
		var text : FlxText = new FlxText(0, 360, Game.Width,
		#if android
		"Touch to restart"
		#else
		"Hit space to restart"
		#end
		, true);
		text.font = "assets/fonts/La-chata-normal.ttf";
		
		text.alignment = "center";
		text.color = 0xff000000;
		text.size = 25;
		add( new Img("assets/fail.png"));
		add(text);
		
		var tscore : FlxText = new FlxText(0, 330, Game.Width, "Score: " + Std.string(score) + "00", 25);  
		tscore.font = "assets/fonts/La-chata-normal.ttf";
		tscore.alignment = "center";
		tscore.color = 0xff000000;
		add(tscore);
		
		Actuate.tween(text, 0.5, { size: 30 } ).repeat().reflect().ease(Quint.easeInOut);
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		
		var next : Bool = false;
		
		if (FlxG.keys.justPressed("SPACE"))
		{
			next = true;
		}
		
		if ( FlxG.mouse.justReleased() )
		{
			next = true;
		}
		
		for (touch in FlxG.touchManager.touches)
		{
			if ( touch.justReleased() )
			{
				next = true;
			}
		}
		
		var touch:FlxTouch;
		for (touch in FlxG.touchManager.touches)
		{
			if (touch.justPressed())
			{
				next = true;
			}
		}
		
		if ( next )
		{
			FlxG.switchState(new GameState());
		}
	}	
}