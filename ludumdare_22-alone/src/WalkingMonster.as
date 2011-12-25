package
{
	import org.flixel.*;

	public class WalkingMonster extends FlxSprite
	{
		[Embed(source="walkingmonster.png")] private var ImgMonkey:Class;
		[Embed(source = "sfx/monster-die.mp3")] private var SndDie:Class;
		[Embed(source = "sfx/monster-hit.mp3")] private var SndHit:Class;
		[Embed(source = "sfx/walking-monster-thrust.mp3")] private var SndJump:Class;
		
		private var player : Player;
		private var shooting : Boolean = false;
		private var ps : PlayState;
		private var px : Number = 0;
		private var py : Number = 0;
		private var jumpTime : Number = 20;
		private var jumpNeed : Number = 1;
		
		public function damage() : void
		{
			if ( health > 0 )
			{
				if ( flickering() )
				{
					jumpTime -= 1;
				}
				
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
			else
			{
				ps.spawnGibs(x, y, 1);
			}
		}
		
		private function jump() : void
		{
			if ( jumpTime < 0 )
			{
				if ( onScreen() )
				{
					FlxG.play(SndJump);
				}
				velocity.y = -400;
				setupJump();
			}
		}
		private function setupJump() : void
		{
			jumpTime = 0 + Math.random() * 5 * jumpNeed;
		}
		
		public function WalkingMonster(ax:Number, ay:Number, pla:Player, pls:PlayState)
		{
			super(ax, ay);
			player = pla;
			ps = pls;
			loadGraphic(ImgMonkey,true, true, 64);
			width = 54;
			height = 62;
			offset.x = 5;
			offset.y = 2;
			
			health = 6;
			
			jumpNeed = Math.random() * 6;
			
			setupJump();
			
			if ( Math.random() < 0.5 )
			{
				facing = LEFT;
			}
			else
			{
				facing = RIGHT;
			}
			
			acceleration.y = 900;

			addAnimation("walking", [0, 1, 0, 2], 10);
			addAnimation("die", [0], 10, false);
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
					mod = mod * 0.25;
				}
				
				velocity.x = mod * 220;
				if ( jumpTime > 0 && flickering() == false)
				{
					jumpTime -= FlxG.elapsed;
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
			ps.spawnTreasures(x, y);
			ps.spawnTreasures(x, y);
			ps.spawnTreasures(x, y);
			ps.spawnGibs(x, y, 10);
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
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void { stop(); jump(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { stop(); }
	}
}