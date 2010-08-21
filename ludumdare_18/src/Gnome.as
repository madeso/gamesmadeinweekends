package
{
	import org.flixel.*;

	public class Gnome extends FlxSprite
	{
		[Embed(source = "barrel.png")] private var ImgGnome:Class;
		
		private var player : Player;
		
		public function Gnome(ax:Number, ay:Number, ps: PlayState, pl: Player)
		{
			super(ax,ay);
			loadGraphic(ImgMagician,true, false, 64);
			width = 54;
			height = 62;
			offset.x = 5;
			offset.y = 2;
			this.ps = ps;
			this.player = pl;
			
			velocity.y = 5;

			addAnimation("idle",[0]);
			addAnimation("die", [1, 2, 3, 4, 5, 6, 7, 8, 9], 10, false);
			
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
		private const kMax : int = 3;
		private var state : int = 0; // 0 = fire, 1 = reloading

		override public function update():void
		{
			if (dead && finished)
			{
				exists = false;
			}
			else
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
						ps.fireMonsterBullet(x, y + 10, dx * kFireSpeed, dy * kFireSpeed);
						heat = kTime;
						bullets -= 1;
						
						if ( bullets == 0 ) state = 1;
					}
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
				}
				if ( onScreen() == false ) bullets = kMax;
				
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