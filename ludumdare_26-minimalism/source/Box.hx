package ;
import org.flixel.FlxSprite;
import org.flixel.FlxG;
import org.flixel.FlxObject;

/**
 * ...
 * @author sirGustav
 */

class Box extends FlxSprite
{
	private var gs : GameState;
	private var size : BoxSize;
	private var canhide : Bool;
	private var mycolor : Color;

	public function new(X:Float, Y:Float, s:BoxSize, c : Color, ch : Bool)
	{
		super(X, Y);
		canhide = ch;
		
		loadGraphic("assets/items.png", true, true, 40, 40);
		addAnimation("Normal", [0 * 6]);
		addAnimation("Half", [1 * 6]);
		addAnimation("RotatedHalf", [2 * 6]);
		addAnimation("Small", [3 * 6]);
		
		setColor(c);
		setSize(s);
	}
	
	public function setSize(s: BoxSize)
	{
		size = s;
		play(Std.string(size));
	}
	
	public function getSize() : BoxSize
	{
		return size;
	}
	
	public function getColor() : Color
	{
		return mycolor;
	}
	
	public function getCenter() : Vec
	{
		return new Vec(x + getWidth() / 2, y + getHeight() / 2);
	}
	
	public function getWidth() : Float
	{
		if ( size == BoxSize.Normal || size == BoxSize.Half ) return 40;
		else return 20;
	}
	
	public function getHeight() : Float
	{
		if ( size == BoxSize.Normal || size == BoxSize.RotatedHalf ) return 40;
		else return 20;
	}
	
	public function setColor(c:Color):Void
	{
		color = Game.CalcColor(c);
		
		if ( c == Color.None && canhide)
		{
			visible = false;
		}
		else
		{
			visible = true;
		}
		
		mycolor = c;
	}
	
	override public function kill():Void 
	{
		super.kill();
	}
	
	public override function update():Void
	{
		super.update();
	}
}