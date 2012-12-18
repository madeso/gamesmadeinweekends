package
{
	import org.flixel.*;

	public class Hearts extends FlxSprite
	{
		[Embed(source = "hearts.png")] private var ImgGnome:Class;
		
		private var player : Player;
		
		public function Hearts(ax:Number, ay:Number, pl: Player)
		{
			super(ax,ay);
			loadGraphic(ImgGnome,true, false, 64);
			this.player = pl;
			addAnimation("0", [0]);
			addAnimation("1", [0,1], 4);
			addAnimation("2", [2]);
			addAnimation("3", [3]);
			addAnimation("4", [4]);
		}
		
		override public function update():void
		{
			play(player.health.toString());
			super.update();
		}

		override public function render():void
		{
			super.render();
		}
	}
}