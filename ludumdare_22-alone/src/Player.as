package
{
	import org.flixel.*;
	
	public class Player extends FlxSprite
	{
		[Embed(source = "player.png")] private var ImgPlayer : Class;
		
		[Embed(source = "sfx/player-jump.mp3")] private static var SndJump : Class;
		[Embed(source = "sfx/player-walljump.mp3")] private static var SndWallJump : Class;
		[Embed(source = "sfx/player-land.mp3")] private static var SndLand : Class;
		[Embed(source = "sfx/player-pickup-ammo.mp3")] private static var SndPickupBullets : Class;
		[Embed(source = "sfx/player-pickup-health.mp3")] private static var SndPickupHealth : Class;
		[Embed(source = "sfx/player-lowonammo.mp3")] private static var SndLowOnAmmo : Class;
		
		// ------------------------------------------------
		
		private const kRunSpeed:int = 400;
		private const kFriction:int  = 1800;
		
		private const kJumpSpeed:int = 800;
		private const kGravity:int = 1900;
		
		private const kJumpPushY:int = 600;
		private const kJumpPushX:int = 400;
		
		private const kReactionTime:Number = 0.1;
		private const kCooldownTime : Number = 0.1;
		private const kCooldownTimePower : Number = kCooldownTime / 2;
		
		private const kMaximumBullets:uint = 500;
		private const kPickupBullets:uint = 100;
		
		// -------------------------------------------------------
		
		private var onBottomTime : Number = 0;
		private var onHitBottom : Boolean = false;
		
		private var onLeftTime : Number = 0;
		private var onHitLeft : Boolean = false;
		
		private var onRightTime : Number = 0;
		private var onHitRight : Boolean = false;
		
		private var numberOfBullets : uint = 100;
		private var cooldown : Number = 0;
		private var ignoreGrabbing : Number = kReactionTime * 2;
		
		private var state : uint = 0;
		
		
		
		// --------------------------------------------------------
		
		private var bullets : Array;
		private var indexOfNextBulletToShoot : uint = 0;
		
		public var myHealth : uint = 4;
		
		public function pickupHealth() : void
		{
			myHealth = 4;
			FlxG.play(SndPickupHealth);
		}
		
		public function canPickupHealth() : Boolean
		{
			return myHealth < 4;
		}
		
		public function Player(X:int, Y:int, B : Array)
		{
			super(X, Y);
			bullets = B;
			loadGraphic(ImgPlayer, true, true, 64, 64);
			drag.x = kFriction;
			maxVelocity.x = kRunSpeed;
			maxVelocity.y = kGravity;
			acceleration.y = kGravity;
			width = 20;
			height = 40;
			offset.x = 14;
			offset.y = 12;
			
			addAnimation("moving", [0, 1, 2, 1], 15);
			addAnimation("jumping", [1]);
			//addAnimation("attack", [5],10);
			addAnimation("idle", [0]);
			addAnimation("aimup", [5]);
			addAnimation("aimdown", [6]);
			addAnimation("crouch", [4]);
			
			addAnimation("grab", [3]);
			
			facing = RIGHT;
		}
		
		public function canPickupAmmobox() : Boolean
		{
			return numberOfBullets < kMaximumBullets;
		}
		
		public function getNumberOfBullets() : uint
		{
			return numberOfBullets;
		}
		
		public function pickupBullets() : void
		{
			numberOfBullets += kPickupBullets;
			if ( numberOfBullets > kMaximumBullets) numberOfBullets = kMaximumBullets;
			FlxG.play(SndPickupBullets);
		}
		
		private function spawnBullet(weak:Boolean, dx:Number, dy:Number, xv : Number, yv:Number) : void
		{
			bullets[indexOfNextBulletToShoot].shoot(weak, x+dx, y+dy, xv, yv);
			indexOfNextBulletToShoot++;
			if ( indexOfNextBulletToShoot >= bullets.length ) indexOfNextBulletToShoot = 0;
		}
		
		private function fireGun(weak:Boolean) : void
		{
			var dx : Number = 0;
			var dy : Number = 0;
			var xv : Number = 0;
			var yv : Number = 0;
			var dir : Number = 1;
			if ( facing == LEFT )
			{
				dir = -1;
			}
			
			// aim down
			if ( state == 4 )
			{
				velocity.y -= 100;
				yv = 1;
				dx = 5;
				dy = 3;
			}
			// aim up
			else if ( state == 1 )
			{
				yv = -1;
				
				if ( facing == LEFT )
				{
					dx = 12;
				}
				else
				{
					dx = 9;
				}
				dy = -6;
			}
			// crouching
			else if (state == 2)
			{
				if ( facing == LEFT )
				{
					dx = -13;
				}
				else
				{
					dx = 37;
				}
				dy = 33;
				xv = dir;
			}
			// grabbing
			else if (state == 6 )
			{
				if ( facing == LEFT )
				{
					dx = 39;
				}
				else
				{
					dx = -15;
				}
				dy = 13;
				xv = -dir;
			}
			// fallback
			else
			{
				if ( facing == LEFT )
				{
					dx = -2;
				}
				else
				{
					dx = 25;
				}
				dy = 15;
				
				xv = dir;
			}
			var bulletSpeed : Number = 900;
			spawnBullet(weak, dx,dy,xv*bulletSpeed,yv*bulletSpeed);
		}
	
		
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void
		{
			if ( velocity.y > 840 )
			{
				//FlxG.log(velocity.y);
				FlxG.play(SndLand);
			}
			else if ( velocity.y > 80 )
			{
				//FlxG.log(velocity.y);
			}
			super.hitBottom(Contact, Velocity);
			onHitBottom = true;
			onBottomTime = 0;
		}
		
		override public function hitRight(Contact:FlxObject, Velocity:Number):void
		{
			super.hitRight(Contact, Velocity);
			if ( ignoreGrabbing > kReactionTime )
			{
				onHitRight = true;
				onRightTime = 0;
			}
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void
		{
			super.hitLeft(Contact, Velocity);
			
			if ( ignoreGrabbing > kReactionTime )
			{			
				onHitLeft = true;
				onLeftTime = 0;
			}
		}
		
		private function updateStateTimers() : void
		{
			if ( ignoreGrabbing < kReactionTime )
			{
				ignoreGrabbing += FlxG.elapsed;
			}
			else
			{
				ignoreGrabbing = kReactionTime*2;
			}
			
			if ( onHitBottom )
			{
				onBottomTime = 0;
				onHitBottom = false;
			}
			else
			{
				if ( onBottomTime <= kReactionTime )
				{
					onBottomTime += FlxG.elapsed;
				}
			}
			
			if ( onHitRight )
			{
				onRightTime = 0;
				onHitRight = false;
			}
			else
			{
				if ( onRightTime <= kReactionTime )
				{
					onRightTime += FlxG.elapsed;
				}
			}
			
			if ( onHitLeft )
			{
				onLeftTime = 0;
				onHitLeft = false;
			}
			else
			{
				if ( onLeftTime <= kReactionTime )
				{
					onLeftTime += FlxG.elapsed;
				}
			}
		}
		
		override public function update():void
		{
			acceleration.x = 0;
			
			updateStateTimers();
			
			var onBottom:Boolean = onBottomTime < kReactionTime;
			var onRight:Boolean = onRightTime < kReactionTime;
			var onLeft : Boolean = onLeftTime < kReactionTime;
			
			if ( FlxG.keys.RIGHT )
			{
				move(1);
				facing = RIGHT;
			}
			else if ( FlxG.keys.LEFT )
			{
				move( -1);
				facing = LEFT;
			}
			
			if ( numberOfBullets > 0 )
			{
				if ( FlxG.keys.Z && cooldown <= 0)
				{
					fireGun(false);
					numberOfBullets -= 1;
					if ( numberOfBullets > kPickupBullets )
					{
						cooldown += kCooldownTimePower;
					}
					else
					{
						cooldown += kCooldownTime;
					}
					
					if ( numberOfBullets == 10 )
					{
						FlxG.play(SndLowOnAmmo);
					}
				}
			}
			else
			{
				if ( FlxG.keys.justPressed("Z") )
				{
					fireGun(true);
				}
			}
			
			if ( cooldown >= 0 )
			{
				cooldown -= FlxG.elapsed;
			}
			
			var jump : Boolean = FlxG.keys.justPressed("X");
			if ( FlxG.keys.DOWN ) jump = false;
			
			if ( jump )
			{
				if( onBottom )
				{
					velocity.y = -kJumpSpeed;
					FlxG.play(SndJump);
				}
			}
			
			if ( onBottom == false )
			{
				var upm : Number = 1;
				var horm : Number = 1;
				
				if ( FlxG.keys.UP )
				{
					upm = 1.20;
					horm = 0.25;
				}
				else if ( FlxG.keys.DOWN )
				{
					upm = 0.25;
					horm = 0.25;
				}
				
				if ( onLeft && jump )
				{
					velocity.y = -kJumpPushY * upm;
					velocity.x = kJumpPushX * horm;
					FlxG.play(SndWallJump);
					onLeft = false;
					onLeftTime = kReactionTime * 2;
					onHitLeft = false;
					ignoreGrabbing = 0;
				}
				
				if ( onRight && jump )
				{
					velocity.y = -kJumpPushY * upm;
					velocity.x = -kJumpPushX * horm;
					FlxG.play(SndWallJump);
					onRight = false;
					onRightTime = kReactionTime * 2;
					onHitRight = false;
					ignoreGrabbing = 0;
				}
			}
			
			acceleration.y = kGravity;
			
			var grabbing : Boolean = false;
			
			if ( onLeft || onRight )
			{
				grabbing = true;
				
			//	if ( velocity.y > 0 )
				{
					velocity.y = 0;
					acceleration.y = 0;
				}
			}
			
			var aimDown : Boolean = FlxG.keys.DOWN;
			var aimUp : Boolean = FlxG.keys.UP;
			
			if ( grabbing )
			{
				play("grab");
				state = 6;
			}
			else
			{
				if ( onBottom )
				{
					if ( velocity.x == 0 )
					{
						if ( aimUp )
						{
							play("aimup");
							state = 1;
						}
						else if( aimDown )
						{
							play("crouch");
							state = 2;
						}
						else
						{
							play("idle");
							state = 0;
						}
					}
					else
					{
						play("moving");
						state = 3;
					}
				}
				else
				{
					if ( aimDown )
					{
						play("aimdown");
						state = 4;
					}
					else
					{
						play("jumping");
						state = 5;
					}
				}
			}
			
			super.update();
		}
		
		private function move(dx:int) : void
		{
			var inf : Number = 50;
			if ( onBottomTime < kReactionTime )
			{
				inf = 220;
			}
			acceleration.x += dx * inf * kRunSpeed * FlxG.elapsed;
		}
	}

}