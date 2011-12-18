package
{
	import org.flixel.*;

	public class CrawlingMonster extends FlxSprite
	{
		[Embed(source="walkingmonster.png")] private var ImgMonster:Class;
		[Embed(source = "sfx/monster-die.mp3")] private var SndDie:Class;
		[Embed(source = "sfx/monster-hit.mp3")] private var SndHit:Class;
		
		private var player : Player;
		private var ps : PlayState;
		private var px : Number = 0;
		private var py : Number = 0;
		
		public function damage() : void
		{
			if ( health > 0 )
			{
				health -= 1;
				flicker();
				
				if (onScreen() && health > 0)
				{
					FlxG.play(SndHit);
				}
			}
			
			if ( health <= 0 )
			{
				kill();
			}
		}
		
		public function CrawlingMonster(ax:Number, ay:Number, pla:Player, pls:PlayState)
		{
			super(ax, ay);
			player = pla;
			ps = pls;
			loadGraphic(ImgMonster,true, true, 64);
			width = 37;
			height = 13;
			offset.x = 7;
			offset.y = 52;
			
			health = 3;
			
			if ( Math.random() < 0.5 )
			{
				facing = LEFT;
			}
			else
			{
				facing = RIGHT;
			}
			
			acceleration.y = 900;

			addAnimation("walking", [6, 7, 6, 8], 10);
			addAnimation("die", [6], 10, false);
			play("walking");
		}

		override public function update():void
		{
			if(dead && finished) exists = false;
			else
			{
				var mod : Number = 1;
				if ( facing == LEFT )
				{
					mod = -1;
				}
				
				if ( flickering() && Math.abs(velocity.y) < 10)
				{
					mod = mod * 1.25;
				}
				
				if ( player.x < x && facing == LEFT || player.x > x && facing == RIGHT )
				{
					mod *= 1.25;
				}
				else
				{
					mod *= 0.5;
				}
				
				velocity.x = mod * 220;
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
				FlxG.play(SndDie);
				FlxG.quake.start(0.05, 0.3);
			}
			dead = true;
			solid = false;
			play("die");
			ps.spawnTreasures(x,y);
		}
		
		private function stop() : void
		{
			velocity.y = 0;
		}
		
		private function flipdir() : void
		{
			if (facing == LEFT)
			{
				facing = RIGHT;
			}
			else
			{
				facing = LEFT;
			}
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { flipdir(); }
		override public function hitRight(Contact:FlxObject,Velocity:Number):void { flipdir(); }
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void { stop(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { stop(); }
	}
}