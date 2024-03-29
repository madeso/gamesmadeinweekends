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

class TutState extends FlxState
{
	private var tut : Img;
	override public function create():Void
	{
		FlxG.bgColor = 0xffffffff;
		
		var text : FlxText = new FlxText(0, 360, Game.Width,
		#if android
		"Touch to continue"
		#else
		"Hit space to continue"
		#end
		, true);
		text.font = "assets/fonts/La-chata-normal.ttf";
		
		text.alignment = "center";
		text.color = 0xff000000;
		text.size = 25;
		tut = new Img("assets/tut2.png");
		tut.visible = false;
		add(new Img("assets/tut1.png"));
		add( tut );
		add(text);
		
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
		
		if (FlxG.keys.justReleased("SPACE"))
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
			if ( tut.visible )
			{
				FlxG.switchState(new GameState());
			}
			else
			{
				tut.visible = true;
			}
		}
	}	
}