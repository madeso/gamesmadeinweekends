package
{
	import org.flixel.*;
	
	public class Player extends FlxSprite
	{
		[Embed(source = "player.png")] private var ImgPlayer : Class;
		
		[Embed(source = "jump3.mp3")] private static var SndJump : Class;
		[Embed(source = "jump1.mp3")] private static var SndWallJump : Class;
		[Embed(source = "land.mp3")] private static var SndLand : Class;
		[Embed(source = "powerup.mp3")] private static var SndPowerup : Class;
		[Embed(source = "transform2.mp3")] private static var SndGetBeard : Class;
		[Embed(source = "transform.mp3")] private static var SndDropBeard : Class;
		[Embed(source = "fail.mp3")] private static var SndRespawn : Class;
		
		[Embed(source = "win.mp3")] private static var SndWin : Class;
		
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
		
		private const kRapidCooldown : Number = 0.15;
		private const kBulletSpeed : Number = 500;
		
		private const kMeditateMaxVel : Number = 100;
		private const kMeditateGravity : Number = 500;
		private const kMeditateFriction : Number = 300;
		
		private const kSurfFriction : Number = 10;
		private const kSurfSpeed : Number = 750;
		
		private const kBeardString : String = "beard."
		private const kBeardTime : Number = 1;
		
		// -------------------------------------------------------
		
		private var onBottomTime : Number = 0;
		private var onHitBottom : Boolean = false;
		
		private var onLeftTime : Number = 0;
		private var onHitLeft : Boolean = false;
		
		private var onRightTime : Number = 0;
		private var onHitRight : Boolean = false;
		
		private var gunTemp : Number = -1;
		private var isSurfing : Boolean = false;
		
		private var hasBeard : Boolean = false;
		private var beardTime : Number = 0;
		
		public var hintid : String = "I know the meaning of LIFE and I wanna go home!";
		
		// --------------------------------------------------------
		
		private var bullets : Array;
		private var bulletsIndex : uint = 0;
		
		private var xr : Number = 0;
		private var yr : Number = 0;
		
		public function Player(X:int, Y:int, B : Array)
		{
			super(X, Y);
			xr = X;
			yr = Y;
			bullets = B;
			loadGraphic(ImgPlayer, true, true, 100, 100);
			drag.x = kFriction;
			maxVelocity.x = kRunSpeed;
			maxVelocity.y = kGravity;
			acceleration.y = kGravity;
			width = 28;
			height = 74;
			offset.x = 40;
			offset.y = 13;
			
			addAnimation("moving", [1,2,3,2], 10);
			addAnimation("jumping", [3]);
			addAnimation("idle", [0]);
			addAnimation("meditating", [4], 7);
			
			addAnimation(kBeardString+ "moving", [11,12,13,12], 10);
			addAnimation(kBeardString+ "jumping", [13]);
			addAnimation(kBeardString+ "idle", [10]);
			addAnimation(kBeardString + "meditating", [14], 7);
			
			addAnimation("surfing", [15, 16], 15);
			addAnimation("screaming", [5, 6], 5);
			
			facing = RIGHT;
		}
		
		public function getPowerup() : void
		{
			FlxG.play(SndPowerup);
		}
		
		private function Shoot(right : Boolean, xv : Number, yv:Number) : void
		{
			var dx : Number = 0;
			var dy : Number = 0;
			if ( right )
			{
				dx = 27;
				dy = 27;
			}
			else
			{	
				dx = -5;
				dy = 27;
			}
			bullets[bulletsIndex].shoot(x+dx, y+dy, xv, yv);
			bulletsIndex++;
			if ( bulletsIndex >= bullets.length ) bulletsIndex = 0;
		}
		
		private function shoot(right : Boolean) : void
		{
			var mod : Number = 1;
			if ( right == false)
			{
				mod = -1;
			}
			
			Shoot(right, mod * kBulletSpeed, 0);
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
			if ( gunTemp >= 0 )
			{
				gunTemp -= FlxG.elapsed;
			}
			
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
			
			if ( onScreen() == false )
			{
				if ( x > 12731 )
				{
					FlxG.play(SndWin);
					hintid = "I have been reincarnated. I am destined to go home again...";
				}
				else
				{
					FlxG.play(SndRespawn);
					hintid = "I have died recently and luckily been reincarnated so I can go home";
				}
				reset(xr, yr);	
			}
			
			var sbeard : String = "";
			if ( hasBeard ) sbeard = kBeardString;
			
			var onBottom:Boolean = onBottomTime < kReactionTime;
			var onRight:Boolean = onRightTime < kReactionTime;
			var onLeft : Boolean = onLeftTime < kReactionTime;
			if ( onRight ) onLeft = false;
			
			var meditating : Boolean = FlxG.keys.C;
			
			if ( velocity.y > kMeditateMaxVel*2 ) meditating = false;
			if ( velocity.y < -kMeditateMaxVel * 2 ) meditating = false;
			
			if ( FlxG.keys.DOWN && hasBeard && (onBottom || isSurfing ) && (onLeft==false && onRight==false) )
			{
				isSurfing = true;
			}
			else
			{
				isSurfing = false;
			}
			
			if ( FlxG.keys.LEFT == false && FlxG.keys.RIGHT == false )
			{
				isSurfing = false;
			}
			
			if ( meditating == false && isSurfing == false)
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
			
			var isScreaming : Boolean = false;
			
			if ( hasBeard == false )
			{
				var canfire : Boolean = true;
				
				if ( onLeftTime < kReactionTime)
				{
					canfire = false;
				}
				if ( onRightTime < kReactionTime)
				{
					canfire = false;
				}
				
				if ( onBottom==false )
				{
					canfire = false;
				}
				
				if ( FlxG.keys.LEFT == true || FlxG.keys.RIGHT==true )
				{
					canfire = false;
				}
				
				if ( canfire )
				{
					if ( FlxG.keys.Z )
					{
						isScreaming = true;
						if( gunTemp < 0 )
						{
							shoot(facing == RIGHT);
							gunTemp = kRapidCooldown;
						}
					}
				}
			}/*
			else
			{
				// no beard..
				if ( onBottom && FlxG.keys.justPressed("CONTROL"))
				{
					hasBeard = false;
				}
			}*/
			
			var jump : Boolean = FlxG.keys.justPressed("X");
			//if ( FlxG.keys.DOWN ) jump = false;
			
			if ( meditating )
			{
				jump = false;
			}
			
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
			
			if ( meditating && onBottom && beardTime < kBeardTime)
			{
				beardTime += FlxG.elapsed;
				if ( beardTime > kBeardTime )
				{
					if ( hasBeard == false )
					{
						hasBeard = true;
						FlxG.play(SndGetBeard);
					}
					else
					{
						hasBeard = false;
						FlxG.play(SndDropBeard);
					}
					beardTime = 0;
				}
			}
			else
			{
				beardTime = 0;
			}
			
			if ( isSurfing )
			{
				play("surfing");
			}
			else if ( isScreaming )
			{
				play("screaming");
			}
			else if ( meditating )
			{
				play(sbeard+ "meditating");
			}
			else
			{			
				if ( velocity.y == 0 )
				{
					if ( velocity.x == 0 )
					{
						play(sbeard+"idle");
					}
					else
					{
						play(sbeard+"moving");
					}
				}
				else
				{
					play(sbeard+"jumping");
				}
			}
			
			maxVelocity.x = kRunSpeed;
			if ( meditating )
			{
				acceleration.y = kMeditateGravity;
				drag.x = kMeditateFriction;
				
				if ( velocity.y > kMeditateMaxVel ) velocity.y = kMeditateMaxVel;
				if ( velocity.y < -kMeditateMaxVel ) velocity.y = -kMeditateMaxVel;
			}
			else if ( isSurfing )
			{
				maxVelocity.x = kSurfSpeed;
				acceleration.y = kGravity;
				drag.x = kSurfFriction;
				if ( facing != RIGHT )
				{
					velocity.x = -kSurfSpeed;
				}
				else
				{
					velocity.x = kSurfSpeed;
				}
			}
			else
			{
				acceleration.y = kGravity;
				drag.x = kFriction;
			}
			super.update();
		}
		
		private function move(dx:int) : void
		{
			acceleration.x += dx * 500 * kRunSpeed * FlxG.elapsed;
		}
	}

}