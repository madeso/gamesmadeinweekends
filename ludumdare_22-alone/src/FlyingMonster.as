package
{
	import org.flixel.*;

	public class FlyingMonster extends FlxSprite
	{
		[Embed(source="walkingmonster.png")] private var ImgMonster:Class;
		[Embed(source = "sfx/monster-die.mp3")] private var SndDie:Class;
		[Embed(source = "sfx/monster-hit.mp3")] private var SndHit:Class;
		[Embed(source = "sfx/flyingmonster-flap.mp3")] private var SndJump:Class;
		
		private var player : Player;
		private var shooting : Boolean = false;
		private var ps : PlayState;
		private var px : Number = 0;
		private var py : Number = 0;
		private var jumpTime : Number = 0;
		
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
		}
		
		private function jump() : void
		{
			if ( jumpTime < 0 )
			{
				if ( onScreen() )
				{
					FlxG.play(SndJump);
				}
				velocity.y = -150;
				setupJump();
			}
		}
		private function setupJump() : void
		{
			jumpTime = 0.1 + Math.random() * 0.5;
		}
		
		public function FlyingMonster(ax:Number, ay:Number, pla:Player, pls:PlayState)
		{
			super(ax, ay);
			player = pla;
			ps = pls;
			loadGraphic(ImgMonster,true, true, 64);
			width = 17;
			height = 20;
			offset.x = 25;
			offset.y = 28;
			
			health = 2;
			
			setupJump();
			
			acceleration.y = 200;

			addAnimation("walking", [12, 13, 12, 14], 10);
			addAnimation("die", [12], 10, false);
			play("walking");
		}

		override public function update():void
		{
			if(dead && finished) exists = false;
			else
			{
				var mod : Number = 1;
				
				if ( x > player.x )
				{
					facing = LEFT;
				}
				else
				{
					facing = RIGHT;
				}
				
				if ( facing == LEFT )
				{
					mod = -1;
				}
				
				if ( jumpTime > 0 ) jumpTime -= FlxG.elapsed;
				
				if ( flickering() && Math.abs(velocity.y) < 10)
				{
					mod = mod * 0.25;
				}
				
				velocity.x = mod * 50;
				
				if ( y > player.y+30 )
				{
					jump();
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