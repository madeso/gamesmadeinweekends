package
{
	import org.flixel.*;

	public class Gnome extends FlxSprite
	{
		[Embed(source = "barrel.png")] private var ImgGnome:Class;
		
		private var player : Player;
		private var ps : PlayState;
		
		private var mright : Boolean = true;
		
		public function Gnome(ax:Number, ay:Number, ps: PlayState, pl: Player)
		{
			super(ax,ay);
			loadGraphic(ImgGnome,true, false, 64);
			width = 54;
			height = 62;
			offset.x = 5;
			offset.y = 2;
			this.player = pl;
			this.ps = ps;
			
			acceleration.y = 1500;

			addAnimation("idle",[0]);
			addAnimation("die", [1, 2, 3, 4, 5, 6, 7, 8, 9], 10, false);
			
			mright = Math.random() > 0.5;
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
		}
		
		private var cooldown : Number = 0;
		
		private var updateOutside : Boolean = true;

		override public function update():void
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