package
{
	import org.flixel.*;
	
	public class Player extends FlxSprite
	{
		[Embed(source = "player.png")] private var ImgPlayer : Class;
		
		[Embed(source = "jump.mp3")] private static var SndJump : Class;
		[Embed(source = "wallJump.mp3")] private static var SndWallJump : Class;
		[Embed(source = "land.mp3")] private static var SndLand : Class;
		[Embed(source = "kick.mp3")] private static var SndRoundhouse : Class;
		
		// ------------------------------------------------
		
		private const kRunSpeed:int = 400;
		private const kFriction:int  = 1800;
		
		private const kJumpSpeed:int = 700;
		private const kGravity:int = 2300;
		
		private const kRoundHouseGravity : Number = 10;
		private const kRoundhouseMaxVel : Number = 250;
		
		private const kJumpPushSpeed:int = 500;
		private const kJumpPushAcceletation:int = 300;
		
		private const kReactionTime:Number = 0.1;
		private const kSlideMaxVelociy:int = 250;
		private const kSlideVelocityReduction:Number = 5500;
		
		private const kRoundHouseTime : Number = 0.2;
		
		// -------------------------------------------------------
		
		private var onBottomTime : Number = 0;
		private var onHitBottom : Boolean = false;
		
		private var onLeftTime : Number = 0;
		private var onHitLeft : Boolean = false;
		
		private var onRightTime : Number = 0;
		private var onHitRight : Boolean = false;
		
		private var roundhouseTime : Number = kRoundHouseTime * 2; // less than kRoundhouseTime zero gravity -> were roundhousing
		
		// --------------------------------------------------------
		
		private var bullets : Array;
		private var bulletsIndex : uint = 0;
		
		public function Player(X:int, Y:int, B : Array)
		{
			super(X, Y);
			bullets = B;
			loadGraphic(ImgPlayer, true, true, 48, 48);
			drag.x = kFriction;
			maxVelocity.x = kRunSpeed;
			maxVelocity.y = kGravity;
			acceleration.y = kGravity;
			width = 25;
			height = 28;
			offset.x = 12;
			offset.y = 15;
			
			addAnimation("moving", [0, 1, 2, 1], 10);
			addAnimation("jumping", [2]);
			//addAnimation("attack", [4, 5, 6],10);
			addAnimation("idle", [0]);
			addAnimation("roundkick", [3,4], 7);
			//addAnimation("hurt", [2, 7], 10);
			//addAnimation("dead", [7, 7, 7], 5);
			
			facing = RIGHT;
		}
		
		private function shoot(right : Boolean) : void
		{
			var xv : Number = 900;
			var dx : Number = 0;
			var dy : Number = 0;
			if ( right )
			{
				dx = 12;
			}
			else
			{
				xv *= -1;
			}
			bullets[bulletsIndex].shoot(x+dx, y+dy, xv, 0);
			bulletsIndex++;
			if ( bulletsIndex >= bullets.length ) bulletsIndex = 0;
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
			if ( roundhouseTime < kRoundHouseTime ) roundhouseTime += FlxG.elapsed;
			
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
			
			if ( FlxG.keys.justPressed("Z") )
			{
				var fire : Boolean = true;
				
				if ( onLeftTime < kReactionTime)
				{
					fire = false;
				}
				if ( onRightTime < kReactionTime)
				{
					fire = false;
				}
				
				if ( roundhouseTime < kRoundHouseTime )
				{
					fire = false;
				}
				
				if ( fire )
				{
					shoot(facing == RIGHT);
				}
			}
			
			var jump : Boolean = FlxG.keys.justPressed("X");
			if ( FlxG.keys.DOWN ) jump = false;
			
			var roundhouse : Boolean = FlxG.keys.justPressed("C");
			
			if ( onLeft || onRight ) roundhouse = false;
			
			if ( roundhouse ) 
			{
				roundhouseTime = 0;
				FlxG.play(SndRoundhouse);
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
			
			if ( roundhouseTime < kRoundHouseTime )
			{
				play("roundkick");
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
			
			if ( roundhouseTime < kRoundHouseTime )
			{
				acceleration.y = kRoundHouseGravity;
				
				if ( velocity.y > kRoundhouseMaxVel ) velocity.y = kRoundhouseMaxVel;
				if ( velocity.y < -kRoundhouseMaxVel ) velocity.y = -kRoundhouseMaxVel;
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