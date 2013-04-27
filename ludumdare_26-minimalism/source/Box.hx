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
	override public function hurt(Damage:Float):Void 
	{
		flicker();
	}

	public function new(X:Float, Y:Float, size:BoxSize, c : Color, Parent: GameState)
	{
		super(X, Y);
		gs = Parent;
		
		loadGraphic("assets/items.png", true, true, 40, 40);
		var base : Int = 0;
		
		if ( size == BoxSize.Normal )
		{
			base = 0;
		}
		else if ( size == BoxSize.Half )
		{
			base = 1;
		}
		else if ( size == BoxSize.RotatedHalf )
		{
			base = 2;
		}
		else
		{
			base = 3;
		}
		
		addAnimation("None", [base * 6 + 0]); // never visible
		addAnimation("Red", [base * 6 + 0]);
		addAnimation("Blue", [base * 6 + 1]);
		addAnimation("Yellow", [base * 6 + 2]);
		addAnimation("Black", [base * 6 + 3]);
		
		setColor(c);
	}
	
	public function setColor(c:Color):Void
	{
		if ( c == Color.None )
		{
			visible = false;
		}
		else
		{
			visible = true;
		}
		play( Std.string(c) );
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