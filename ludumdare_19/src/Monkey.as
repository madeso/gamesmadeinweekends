package
{
	import org.flixel.*;

	public class Monkey extends FlxSprite
	{
		[Embed(source="monkey.png")] private var ImgMonkey:Class;
		[Embed(source = "monkey-die.mp3")] private var SndHit:Class;
		
		private var player : Player;
		private var shooting : Boolean = false;
		private var ps : PlayState;
		private var px : Number = 0;
		private var py : Number = 0;
		
		public function Monkey(ax:Number, ay:Number, pla:Player, pls:PlayState)
		{
			super(ax, ay);
			player = pla;
			ps = pls;
			loadGraphic(ImgMonkey,true, true, 64);
			width = 54;
			height = 62;
			offset.x = 5;
			offset.y = 2;
			
			velocity.y = -50;

			addAnimation("idle", [0, 1, 2, 3, 4, 5], 5);
			addAnimation("shooting",[6,7,8,9,10,11,6,7,8,9,10,11,6,7,8,9,10,11,6,7,8,9,10,11], 35, false);
			addAnimation("die", [12, 12, 13, 14, 15, 16, 17], 4, false);
			play("idle");
		}

		override public function update():void
		{
			if(dead && finished) exists = false;
			else
			{
				if ( shooting && finished )
				{
					shooting = false;
					play("idle");
					var dx : Number = (px-x);
					var dy : Number = (py-y);
					var len : Number = Math.sqrt( dx * dx + dy * dy );
					var mul : Number = 250 / len;
					ps.throwCoconut(x+25, y+26, dx*mul, dy*mul);
				}
				else
				{
					if ( onScreen() && finished )
					{
						shooting = true;
						play("shooting");
						px = player.x;
						py = player.y;
					}
					else
					{
						if ( player.x > x ) facing = LEFT;
						else facing = RIGHT;
					}
				}
				
				super.update();
			}
		}

		override public function render():void
		{
			super.render();
		}

		override public function kill():void
		{
			_flicker = false;
			if(dead) return;
			velocity.x = 0;
			velocity.y = 0;
			if (onScreen())
			{
				FlxG.play(SndHit);
				FlxG.quake.start(0.05, 0.3);
			}
			dead = true;
			solid = false;
			play("die");
		}
		
		private function stop() : void
		{
			velocity.y = 0;
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { stop(); }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { stop(); }
	}
}