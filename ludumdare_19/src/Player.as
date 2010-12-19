package
{
	import org.flixel.*;
	
	public class Player extends FlxSprite
	{
		[Embed(source = "player.png")] private var ImgPlayer : Class;
		
		[Embed(source = "player-jump.mp3")] private static var SndJump : Class;
		[Embed(source = "player-walljump.mp3")] private static var SndWallJump : Class;
		[Embed(source = "player-land.mp3")] private static var SndLand : Class;
		[Embed(source = "player-pickup-stones.mp3")] private static var SndPickupStones : Class;
		
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
		
		// -------------------------------------------------------
		
		private var onBottomTime : Number = 0;
		private var onHitBottom : Boolean = false;
		
		private var onLeftTime : Number = 0;
		private var onHitLeft : Boolean = false;
		
		private var onRightTime : Number = 0;
		private var onHitRight : Boolean = false;
		
		private var numberOfStones : uint = 0;
		
		// --------------------------------------------------------
		
		private var stones : Array;
		private var nextStoneToThrow : uint = 0;
		
		public var myHealth : uint = 5;
		
		public function Player(X:int, Y:int, B : Array)
		{
			super(X, Y);
			stones = B;
			loadGraphic(ImgPlayer, true, true, 64, 64);
			drag.x = kFriction;
			maxVelocity.x = kRunSpeed;
			maxVelocity.y = kGravity;
			acceleration.y = kGravity;
			width = 44;
			height = 62;
			offset.x = 8;
			offset.y = 1;
			
			addAnimation("moving", [0, 1, 2, 1, 0 , 3, 4, 3], 20);
			addAnimation("jumping", [2]);
			//addAnimation("attack", [5],10);
			addAnimation("idle", [0]);
			
			facing = RIGHT;
		}
		
		public function canPickupStones() : Boolean
		{
			return numberOfStones < 10;
		}
		
		public function hasStones() : Boolean
		{
			return numberOfStones > 0;
		}
		
		public function pickupStone() : void
		{
			numberOfStones = 10;
			FlxG.play(SndPickupStones);
		}
		
		private function Shoot(right : Boolean, xv : Number, yv:Number) : void
		{
			var dx : Number = 0;
			var dy : Number = 0;
			if ( right )
			{
				dx = 27;
			}
			else
			{	
				dx = -5;
			}
			dy = 20;
			stones[nextStoneToThrow].shoot(x+dx, y+dy, xv, yv);
			nextStoneToThrow++;
			if ( nextStoneToThrow >= stones.length ) nextStoneToThrow = 0;
		}
		
		private function throwStone(right : Boolean) : void
		{
			var mod : Number = 1;
			if ( right == false)
			{
				mod = -1;
			}
			
			Shoot(right, mod * 900, 0);
			
			numberOfStones -= 1;
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
				var canfire : Boolean = hasStones();
				
				if ( onLeftTime < kReactionTime)
				{
					canfire = false;
				}
				if ( onRightTime < kReactionTime)
				{
					canfire = false;
				}
				
				if ( canfire )
				{
					if ( FlxG.keys.justPressed("Z") )
					{
						throwStone(facing == RIGHT);
					}
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
		}
		
		private function move(dx:int) : void
		{
			acceleration.x += dx * 500 * kRunSpeed * FlxG.elapsed;
		}
	}

}