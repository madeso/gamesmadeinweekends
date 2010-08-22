package
{
	import org.flixel.*;

	public class Gnome extends FlxSprite
	{
		[Embed(source = "gnome.png")] private var ImgGnome:Class;
		
		private var player : Player;
		private var ps : PlayState;
		
		private var mright : Boolean = true;
		
		public function Gnome(ax:Number, ay:Number, ps: PlayState, pl: Player)
		{
			super(ax,ay);
			loadGraphic(ImgGnome,true, true, 64);
			width = 40;
			height = 43;
			offset.x = 11;
			offset.y = 20;
			this.player = pl;
			this.ps = ps;
			
			acceleration.y = 1500;

			addAnimation("walk",[0,1,2,1],5);
			addAnimation("jumped", [4, 5, 6, 5, 4, 5, 6, 5, 4, 5, 6, 5, 4, 5, 6, 5, 4, 5, 6, 5, 4], 10, false);
			
			mright = Math.random() > 0.5;
			switchDir();
			play("walk");
		}
		
		private function stop() : void
		{
			velocity.y = 0;
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { switchDir(); }
		override public function hitRight(Contact:FlxObject, Velocity:Number):void { switchDir(); }
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void { updateOutside = false; stop(); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { stop(); }
		
		private function switchDir() : void
		{
			mright = !mright;
			
			if ( mright ) facing = RIGHT;
			else facing = LEFT;
		}
		
		private var cooldown : Number = 0;
		
		private var updateOutside : Boolean = true;

		private var jumped : Boolean = false;
		
		public function canBeDamagedBy() : Boolean
		{
			if ( flickering() ) return false;
			if ( jumped ) return false;
			return true;
		}
		
		override public function update():void
		{
			if ( flickering() )
			{
				jumped = true;
				play("jumped");
				velocity.x = 0;
			}
			if ( jumped && finished )
			{
				jumped = false;
				play("walk");
			}
			
			if ( jumped )
			{
				super.update();
			}
			else
			{
				if ( onScreen() )
				{
					if ( cooldown >= 0 )
					{
						cooldown -= FlxG.elapsed;
					}
					
					var d : int = 1;
					if ( !mright )
					{
						d = -1;
					}
					
					if ( ps.issolid(x + (d*30), y + 65) == false )
					{
						switchDir();
						cooldown = 1;
					}
					
					if ( onScreen() )
					{
						velocity.x = d * 100;
					}
					else
					{
						velocity.x = 0;
					}
					
					if ( updateOutside == false )
					{
						super.update();
					}
				}
				
				if ( updateOutside )
				{
					super.update();
				}
			}
		}

		override public function render():void
		{
			super.render();
		}
		
		public function pickup() : void
		{
			dead = true;
			exists = false;
			solid = false;
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
			exists = false;
			solid = false;
		}
	}
}