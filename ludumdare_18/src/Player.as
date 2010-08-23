package
{
	import org.flixel.*;
	
	public class Player extends FlxSprite
	{
		[Embed(source = "player.png")] private var ImgPlayer : Class;
		
		[Embed(source = "jump1.mp3")] private static var SndJump : Class;
		[Embed(source = "jump2.mp3")] private static var SndWallJump : Class;
		[Embed(source = "land1.mp3")] private static var SndLand : Class;
		[Embed(source = "up1.mp3")] private static var SndPowerup : Class;
		[Embed(source = "walk2.mp3")] private static var SndHurt : Class;
		[Embed(source = "up2.mp3")] private static var SndThrowGnome : Class;
		
		// ------------------------------------------------
		
		private const kRunSpeed:int = 400;
		private const kFriction:int  = 1800;
		
		private const kJumpSpeed:int = 700;
		private const kGravity:int = 2300;
		
		private const kJumpPushSpeed:int = 500;
		private const kJumpPushAcceletation:int = 300;
		
		private const kReactionTime:Number = 0.1;
		private const kSlideMaxVelociy:int = 250;
		private const kSlideVelocityReduction:Number = 5500;
		
		private const kFireLoad : Number = 1; // number of seconds before star can be fired
		
		private var loader: Number = 0;
		private const kLoader : Number = 0.3;
		
		[Embed(source = "coin.mp3")] private static var SndShotLoaded : Class;
		[Embed(source = "coin2.mp3")] private static var SndLoadShot : Class;
		
		// -------------------------------------------------------
		
		private var onBottomTime : Number = 0;
		private var onHitBottom : Boolean = false;
		
		private var onLeftTime : Number = 0;
		private var onHitLeft : Boolean = false;
		
		private var onRightTime : Number = 0;
		private var onHitRight : Boolean = false;
		
		private var fireload : Number = 0;
		private var hasStar : Boolean = false;
		
		// --------------------------------------------------------
		
		private var bullet : PlayerBullet;
		
		private var carrying : DeadGnome;
		
		private var ps : PlayState;
		
		private var starloader : Starloader;
		
		public function Player(X:int, Y:int, B : PlayerBullet, dg : DeadGnome, P : PlayState, sl : Starloader)
		{
			super(X, Y);
			bullet = B;
			ps = P;
			starloader = sl;
			carrying = dg;
			loadGraphic(ImgPlayer, true, true, 64,64);
			drag.x = kFriction;
			maxVelocity.x = kRunSpeed;
			maxVelocity.y = kGravity;
			acceleration.y = kGravity;
			width = 40;
			height = 43;
			offset.x = 11;
			offset.y = 20;
			
			addAnimation("moving", [4,5,6,7], 10);
			addAnimation("jumping", [8,9], 10);
			//addAnimation("attack", [4, 5, 6],10);
			addAnimation("idle", [0,1,2,3], 10);
			//addAnimation("hurt", [2, 7], 10);
			//addAnimation("dead", [7, 7, 7], 5);
			
			facing = RIGHT;
		}
		
		public function getPowerup() : void
		{
			FlxG.play(SndPowerup);
			hasStar = true;
			flicker();
		}
		
		public function cBullet( b : FlxObject ) : void
		{
			if ( flickering() ) return;
			
			var d : Number = 1;
			if ( b.x > x ) d = -1;
			velocity.x = d*kJumpPushAcceletation;
			if ( Math.abs(velocity.y) > 30 )
			{
				d = 1;			
				if ( b.y < y ) d = -1;
				velocity.y -= d * 500;
			}
			
			flicker();
			hasStar = false;
			FlxG.play(SndHurt);
		}
		
		private function Shoot(right : Boolean, xv : Number, yv:Number) : void
		{
			var dx : Number = 0;
			var dy : Number = 0;
			if ( right )
			{
				dx = 27;
				dy = 5;
			}
			else
			{	
				dx = -5;
				dy = 5;
			}
			bullet.shoot(x+dx, y+dy, xv, yv);
		}
		
		private function shoot(right : Boolean) : void
		{
			var mod : Number = 1;
			if ( right == false)
			{
				mod = -1;
			}
			
			Shoot(right, mod * 400, 0);
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
			onHitRight = true;
			onRightTime = 0;
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void
		{
			super.hitLeft(Contact, Velocity);
			onHitLeft = true;
			onLeftTime = 0;
		}
		
		private function updateStateTimers() : void
		{
			if ( onHitBottom )
			{
				onBottomTime = 0;
				onHitBottom = false;
			}
			else
			{
				if ( onBottomTime < kReactionTime )
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
				if ( onRightTime < kReactionTime )
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
				if ( onLeftTime < kReactionTime )
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
			if ( onRight ) onLeft = false;
			
			updateCarrying();
			
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
			
			if ( true )
			{
				var canfire : Boolean = true;
				
				/*if ( onLeftTime < kReactionTime)
				{
					canfire = false;
				}
				if ( onRightTime < kReactionTime)
				{
					canfire = false;
				}*/
				
				/*if ( onBottom == false )
				{
					canfire = false;
				}*/
				
				if ( canfire )
				{
					if ( carrying.exists )
					{
						if ( FlxG.keys.justPressed("Z") )
						{
							throwGnome();
						}
					}
					else if( hasStar )
					{
						var dofire : Boolean = false;
						
						if ( FlxG.keys.pressed("Z") )
						{
							if ( fireload < kFireLoad )
							{
								fireload += FlxG.elapsed;
								if ( fireload > kFireLoad )
								{
									fireload = kFireLoad;
									FlxG.play(SndShotLoaded);
								}
								else
								{
									loader += FlxG.elapsed;
									if ( loader > kLoader )
									{
										loader = 0;
										FlxG.play(SndLoadShot);
										// create star?
									}
								}
							}
						}
						else
						{
							if ( fireload >= kFireLoad ) dofire = true;
							fireload = 0;
						}
						
						if ( dofire && bullet.solid == false)
						{
							shoot(facing == RIGHT);
							if ( facing == RIGHT )
							{
								velocity.x = -kJumpPushSpeed;
							}
							else
							{
								velocity.x = kJumpPushSpeed;
							}
						}
						
						starloader.start(x, y);
					}
					else
					{
						starloader.kill();
					}
				}
				else
				{
					fireload = 0;
					loader = 0;
				}
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
			
			if ( onLeft || onRight )
			{
				if ( velocity.y > kSlideMaxVelociy )
				{
					//velocity.y = slideVel;
					velocity.y -= kSlideVelocityReduction * FlxG.elapsed;
					if ( velocity.y < kSlideMaxVelociy ) velocity.y = kSlideMaxVelociy;
				}
			}
			
			if ( onBottom == false )
			{
				if ( onLeft && jump )
				{
					velocity.y = -kJumpPushSpeed;
					velocity.x = kJumpPushAcceletation;
					FlxG.play(SndWallJump);
				}
				
				if ( onRight && jump )
				{
					velocity.y = -kJumpPushSpeed;
					velocity.x = -kJumpPushAcceletation;
					FlxG.play(SndWallJump);
				}
			}
			
			onLeft = false;
			onRight = false;
			
			
			if ( velocity.y == 0 )
			{
				if ( velocity.x == 0 )
				{
					play("idle");
				}
				else
				{
					play("moving");
				}
			}
			else
			{
				play("jumping");
			}
			
			
			acceleration.y = kGravity;
			
			super.update();
			
			updateCarrying();
		}
		
		private function move(dx:int) : void
		{
			acceleration.x += dx * 500 * kRunSpeed * FlxG.elapsed;
		}
		
		public function canPickupGnome() : Boolean
		{
			return hasStar == false && carrying.exists == false;
		}
		
		private function throwGnome() : void
		{
			carrying.carryingRemove();
			var d : Number = 1;
			if ( facing != RIGHT ) d = -1;
			ps.throwGnomeBullet(carrying.x, y, d * 500, -200);
			FlxG.log("throwed gnome");
			FlxG.play(SndThrowGnome);
		}
		
		public function pickupGnome() : void
		{
			FlxG.log("picked up gnome");
			carrying.exists = true;
			carrying.visible = true;
			carrying.dead = false;
			updateCarrying();
		}
		
		private function updateCarrying() : void
		{
			if ( carrying.exists )
			{
				carrying.x = x;
				carrying.y = y - 40;
			}
			
			if ( starloader.exists )
			{
				starloader.x = x;
				starloader.y = y+10;
			}
		}
	}

}