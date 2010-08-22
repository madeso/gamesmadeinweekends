package
{
	import org.flixel.*;

	public class Magician extends FlxSprite
	{
		[Embed(source = "magician.png")] private var ImgMagician:Class;
		
		private const kFireSpeed : Number = 500;
		
		private var ps : PlayState;
		private var player : Player;
		
		public function Magician(ax:Number, ay:Number, ps: PlayState, pl: Player)
		{
			super(ax,ay);
			loadGraphic(ImgMagician,true, false, 64);
			width = 54;
			height = 62;
			offset.x = 25;
			offset.y = 2;
			this.ps = ps;
			this.player = pl;
			
			velocity.y = 150;

			addAnimation("idle", [0, 1, 2, 1], 2);
			addAnimation("shoot", [3], 5);
			addAnimation("die", [4,5,6,7], 4, false);
			
			heat = Math.random();
		}
		
		private function stop() : void
		{
			velocity.y = 0;
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { stop(); }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void { stop(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { stop(); }
		
		private var heat : Number = 0;
		private const kTime : Number = 0.25;
		private var bullets : int = kMax;
		private const kMax : int = 6;
		private var state : int = 0; // 0 = fire, 1 = reloading

		override public function update():void
		{
			if (dead && finished)
			{
				exists = false;
				ps.spawnStar(x, y+25);
			}
			else if( dead == false )
			{
				if ( heat > 0 )
				{
					heat -= FlxG.elapsed;
				}
				if ( state == 0 )
				{
					if ( onScreen() && heat <= 0 && bullets > 0 )
					{
						var dx : Number = player.x - x;
						var dy : Number = player.y - y;
						var le : Number = Math.sqrt( dx * dx + dy * dy);
						dx /= le;
						dy /= le;
						ps.fireMonsterBullet(x+5, y +35, dx * kFireSpeed, dy * kFireSpeed);
						heat = kTime;
						bullets -= 2;
						
						if ( bullets == 0 ) state = 1;
					}
					play("shoot");
				}
				else
				{
					if ( onScreen() && heat <= 0 && bullets < kMax )
					{
						bullets += 1;
						heat = kTime * 2;
					}
					if ( bullets == kMax )
					{
						state = 0;
						heat = 0;
					}
					play("idle");
				}
				if ( onScreen() == false ) bullets = kMax;
				
				super.update();
			}
			else
			{
				super.update();
			}
		}

		override public function render():void
		{
			super.render();
		}

		override public function kill():void
		{
			if(dead) return;
			velocity.x = 0;
			velocity.y = 0;
			if (onScreen())
			{
				FlxG.quake.start(0.05, 0.3);
			}
			dead = true;
			solid = false;
			play("die");
		}
	}
}