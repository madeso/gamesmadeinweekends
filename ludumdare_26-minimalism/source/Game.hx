package ;

import org.flixel.FlxG;
import nme.Assets;

/**
 * ...
 * @author sirGustav
 */

class Game 
{
	public static var Width : Int = 640;
	public static var Height : Int = 480;
	
	public static var Score : Int = 0;
	
	public static inline function rnd(from:Float, to:Float):Float
	{
		return from + ((to - from) * Math.random());
	}
	
	public static inline function irnd(from:Int, to:Int):Int
	{
		return Math.floor(from + ((to - from + 0.1) * Math.random()));
	}
	
	public static inline function brnd() : Bool
	{
		if ( rnd(0, 100) > 50 ) return true;
		else return false;
	}
	
	public static function RandomColor() : Color
	{
		var i : Int = irnd(0, 4);
		if ( i == 0 ) return Color.None;
		if ( i == 1 ) return Color.Red;
		if ( i == 2 ) return Color.Blue;
		if ( i == 3 ) return Color.Yellow;
		return Color.Black;
	}
	
	#if flash
		public static var SoundExtension:String = ".mp3";
	#else
		public static var SoundExtension:String = ".wav";
	#end
	
	#if flash
		public static var MusicExtension:String = ".mp3";
	#else
		public static var MusicExtension:String = ".ogg";
	#end
	
	public static function sfx(f:String)
	{
		var path : String = "assets/sfx/" + f + SoundExtension;
		//Assets.getSound(path)
		FlxG.play(path, 1, false);
	}
	
	public static function music(f:String)
	{
		var sound = Assets.getSound("assets/music/" + f + MusicExtension);
		FlxG.playMusic(sound, .8);
	}
}