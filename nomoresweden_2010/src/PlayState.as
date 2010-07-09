package
{
	import org.flixel.*;
	
	import net.pixelpracht.tmx.TmxMap;
	import net.pixelpracht.tmx.TmxObject;
	import net.pixelpracht.tmx.TmxObjectGroup;
	
	public class PlayState extends FlxState
	{
		[Embed(source = 'level.tmx', mimeType = "application/octet-stream")] 
		private var data_map:Class;
		
		[Embed(source = "tiles.png")]
		public static var data_tiles : Class;
		
		private var map : FlxTilemap;
		
		private var hudText : FlxText;
		
		private var player : Player;
		
		private var worldGroup: FlxGroup;
		
		//[Embed(source = "music.mp3")] private static var SndMusic : Class;
		
		override public function create() : void
		{
			worldGroup = new FlxGroup();
			bgColor = 0xff4A7FB5;
			
			map = new FlxTilemap();
			map.drawIndex = 1;
			map.collideIndex = 42;
			
			var tmx:TmxMap = new TmxMap(new XML( new data_map ));
			map.loadMap(tmx.getLayer('map').toCsv(tmx.getTileSet('tiles')), data_tiles, 64);
			//map.loadMap(new data_map, data_tiles, 64);
			map.x = map.y = 0;
			
			worldGroup.add(map);
			
			add(worldGroup);
			
			hudText = new FlxText(0 , 0, 300, "pirates are awesome");
			hudText.scrollFactor = new FlxPoint(0, 0);
			
			player = new Player(32, 64);
			add(player);
			
			bugUpdateCamera();
			
			add( hudText );
			
			//FlxG.playMusic(SndMusic);
		}
		
		private function bugUpdateCamera() : void
		{
			FlxG.follow(player, 2.5);
			FlxG.followBounds(0, 0, map.right, map.bottom);
		}
		
		override public function update():void
		{
			bugUpdateCamera();
			super.update();
			map.collide(player);
			
			hudText.text = player.velocity.y.toString();
		}
	}

}