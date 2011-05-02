package
{
	import org.flixel.*;
	
	public class Player extends FlxSprite
	{
		[Embed(source = "player.png")] private var ImgPlayer : Class;
		
		[Embed(source = "jump.mp3")] private static var SndJump : Class;
		[Embed(source = "land.mp3")] private static var SndLand : Class;
		[Embed(source = "thrust.mp3")] private static var SndThrust : Class;
		[Embed(source = "cue.mp3")] private static var SndCue : Class;
		[Embed(source = "quake.mp3")] private static var SndQuake : Class;
		[Embed(source = "denied.mp3")] private static var SndAborted : Class;
		
		// ------------------------------------------------
		
		private const kRunSpeed:int = 400;
		private const kFriction:int  = 1800;
		
		private const kJumpSpeed:int = 700;
		private const kGravity:int = 2300;
		
		private const kJumpPushSpeed:int = 500;
		private const kJumpPushAcceletation:int = 300;
		
		private const kReactionTime:Number = 0.05;
		
		private const kDashReaction : Number = 0.01;
		private const kTimeToDeniedDash : Number = 0.8;
		private const kSecondsOfDashing : Number = 0.4;
		private const kDashSpeed : Number = 1500;
		
		private const kSlideMaxVelociy:int = 250;
		private const kSlideVelocityReduction:Number = 5500;
		
		// -------------------------------------------------------
		
		private var onBottomTime : Number = 0;
		private var onHitBottom : Boolean = false;
		
		private var onLeftTime : Number = 0;
		private var onHitLeft : Boolean = false;
		
		private var onRightTime : Number = 0;
		private var onHitRight : Boolean = false;
		
		private var dashLoadTimer : Number = 0;
		private var dashTime : Number = -1;
		private var oldFacing : uint;
		private var dashfacing : uint = RIGHT;
		
		private var hasPerformedDash :  Boolean = false;
		
		// --------------------------------------------------------
		
		private function setOldFacing() : void
		{
			if ( facing == LEFT || facing == RIGHT )
			{
			}
			else
			{
				facing = oldFacing;
			}
		}
		
		private var ps : PlayState = null;
		
		public function Player(X:int, Y:int, a:PlayState)
		{
			super(X, Y);
			loadGraphic(ImgPlayer, true, true, 48, 48);
			ps = a;
			drag.x = kFriction;
			maxVelocity.x = kRunSpeed;
			maxVelocity.y = kGravity;
			acceleration.y = kGravity;
			width = 25;
			height = 28;
			offset.x = 12;
			offset.y = 15;
			
			addAnimation("moving", [3, 1, 2, 1], 10);
			addAnimation("jumping", [1]);
			addAnimation("idle", [0]);
			addAnimation("charge", [4, 5], 10);
			addAnimation("thrust", [6, 7], 10);
			addAnimation("thrustup", [8, 9], 10);
			addAnimation("thrustdown", [10, 11], 10);
			
			facing = RIGHT;
		}
		
		private function dashCollision() : void
		{
			FlxG.play(SndQuake);
			FlxG.quake.start(0.01, 0.2);
			dashTime = 0;
			dashLoadTimer = 0;
			hasPerformedDash = false;
		}
		
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void
		{
			if (dashTime > 0 )
			{
				dashCollision();
			}
			else
			{
				if ( velocity.y > 1200 )
				{
					ps.PlayerHurt();
				}
				else if ( velocity.y > 840 )
				{
					FlxG.play(SndLand);
				}
				else if ( velocity.y > 80 )
				{
					// ignore
				}
			}
			super.hitBottom(Contact, Velocity);
			onHitBottom = true;
			onBottomTime = 0;
		}
		
		override public function hitRight(Contact:FlxObject, Velocity:Number):void
		{
			if (dashTime > 0 )
			{
				dashCollision();
			}
			
			super.hitRight(Contact, Velocity);
			onHitRight = true;
			onRightTime = 0;
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void
		{
			if (dashTime > 0 )
			{
				dashCollision();
			}
			super.hitLeft(Contact, Velocity);
			onHitLeft = true;
			onLeftTime = 0;
		}
		
		override public function hitTop(Contact:FlxObject, Velocity:Number):void
		{
			if (dashTime > 0 )
			{
				dashCollision();
			}
			super.hitTop(Contact, Velocity);
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
			
			if ( FlxG.keys.C )
			{
				if ( dashTime < 0 && hasPerformedDash == false)
				{
					if ( dashLoadTimer < kDashReaction )
					{
						if ( dashLoadTimer < 0 ) dashLoadTimer = FlxG.elapsed;
						else dashLoadTimer += FlxG.elapsed;
					
						if ( dashLoadTimer >= kDashReaction )
						{
							FlxG.play(SndCue);
						}
					}
					else if ( dashLoadTimer < kTimeToDeniedDash )
					{
						dashLoadTimer += FlxG.elapsed;
						if ( dashLoadTimer > kTimeToDeniedDash )
						{
							FlxG.play(SndAborted);
						}
					}
					
					if ( dashTime < 0 && dashLoadTimer > kDashReaction && dashLoadTimer < kTimeToDeniedDash)
					{
						oldFacing = facing;
						if( FlxG.keys.justPressed("LEFT") )
						{
							dashTime = kSecondsOfDashing;
							hasPerformedDash = true;
							FlxG.play(SndThrust);
							dashfacing = LEFT;
							facing = LEFT;
						}
						else if( FlxG.keys.justPressed("UP") )
						{
							hasPerformedDash = true;
							dashTime = kSecondsOfDashing;
							FlxG.play(SndThrust);
							dashfacing = UP;
						}
						else if( FlxG.keys.justPressed("RIGHT") )
						{
							hasPerformedDash = true;
							dashTime = kSecondsOfDashing;
							FlxG.play(SndThrust);
							dashfacing = RIGHT;
							facing = RIGHT;
						}
						else if( FlxG.keys.justPressed("DOWN") )
						{
							hasPerformedDash = true;
							dashTime = kSecondsOfDashing;
							FlxG.play(SndThrust);
							dashfacing = DOWN;
						}
					}
				}
				else
				{
					if ( facing != DOWN )
					{
						dashTime -= FlxG.elapsed;
						
						if ( dashTime < 0 )
						{
							setOldFacing();
						}
					}
				}
			}
			else
			{
				dashLoadTimer = -1;
				hasPerformedDash = false;
				if ( dashTime > 0 )
				{
					dashTime = -1;
					setOldFacing();
				}
			}
			
			var slashFreeze:Boolean = (dashLoadTimer > kDashReaction && dashLoadTimer < kTimeToDeniedDash && hasPerformedDash==false) || dashTime > 0;
			
			if ( slashFreeze == false )
			{
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
			}
			
			var jump : Boolean = FlxG.keys.justPressed("X") && slashFreeze == false;
			
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
					velocity.y -= kSlideVelocityReduction * FlxG.elapsed;
					if ( velocity.y < kSlideMaxVelociy ) velocity.y = kSlideMaxVelociy;
				}
			}
			
			/*var grab : Boolean = false;
			
			if ( onBottom == false )
			{
				if( onLeft || onRight && FlxG.keys.Z )
				{
					grab = true;
					velocity.x = 0;
					velocity.y = 0;
				}
				
				if ( grab && jump )
				{
					velocity.y = -kJumpPushSpeed;
					velocity.x = kJumpPushAcceletation;
					FlxG.play(SndWallJump);
				}
				
				if ( grab && jump )
				{
					velocity.y = -kJumpPushSpeed;
					velocity.x = -kJumpPushAcceletation;
					FlxG.play(SndWallJump);
				}
			}*/
			
			onLeft = false;
			onRight = false;
			if ( dashTime > 0 )
			{
				if ( dashfacing == LEFT || dashfacing == RIGHT )
				{
					play("thrust");
				}
				else if ( dashfacing == UP )
				{
					play("thrustup");
				}
				else if ( dashfacing == DOWN )
				{
					play("thrustdown");
				}
			}
			else if ( dashLoadTimer > kDashReaction && dashLoadTimer < kTimeToDeniedDash && hasPerformedDash == false)
			{
				play("charge");
			}
			else
			{			
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
			}
			
			if ( slashFreeze )
			{
				velocity.x = 0;
				velocity.y = 0;
				
				if ( dashTime > 0 )
				{
					if ( dashfacing == LEFT )
					{
						velocity.x = -kDashSpeed;
					}
					else if ( dashfacing == RIGHT )
					{
						velocity.x = kDashSpeed;
					}
					else if ( dashfacing == UP )
					{
						velocity.y = -kDashSpeed;
					}
					else if ( dashfacing == DOWN )
					{
						velocity.y = kDashSpeed;
					}
				}
				
				acceleration.y = 0;
			}
			else
			{
				acceleration.y = kGravity;
			}
			
			super.update();
		}
		
		private function move(dx:int) : void
		{
			acceleration.x += dx * 500 * kRunSpeed * FlxG.elapsed;
		}
	}

}