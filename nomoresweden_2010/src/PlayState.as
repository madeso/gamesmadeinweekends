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
		private var playerBullets: FlxGroup;
		
		private var powerups : FlxGroup;
		
		private var metaObjects: FlxGroup;
		
		//[Embed(source = "music.mp3")] private static var SndMusic : Class;
		
		override public function create() : void
		{
			worldGroup = new FlxGroup();
			playerBullets = new FlxGroup();
			powerups = new FlxGroup();
			
			for (var i:uint = 0; i < 100; ++i)
			{
				playerBullets.add( new Bullet() );
			}
			
			metaObjects = new FlxGroup();
			bgColor = 0xff969696;
			
			map = new FlxTilemap();
			map.drawIndex = 1;
			map.collideIndex = 42;
			
			var tmx:TmxMap = new TmxMap(new XML( new data_map ));
			map.loadMap(tmx.getLayer('map').toCsv(tmx.getTileSet('tiles')), data_tiles, 64);
			var pug : TmxObjectGroup = tmx.getObjectGroup("powerups");
			var c : uint = 0;
			for each(var o:TmxObject in pug.objects)
			{
				c += 1;
				powerups.add( new Powerup(o.x, o.y) );
			}
			FlxG.log("pu: " + c.toString() );
			//map.loadMap(new data_map, data_tiles, 64);
			map.x = map.y = 0;
			
			worldGroup.add(map);
			
			add(worldGroup);
			
			add(powerups);
			add(playerBullets);
			
			hudText = new FlxText(0 , 0, 300, "pirates are awesome");
			hudText.scrollFactor = new FlxPoint(0, 0);
			
			player = new Player(64, 64, playerBullets.members);
			add(player);
			
			metaObjects.add(player);
			metaObjects.add(playerBullets);
			
			bugUpdateCamera();
			
			add( hudText );
			
			//FlxG.playMusic(SndMusic);
		}
		
		private function bugUpdateCamera() : void
		{
			FlxG.follow(player, 5.5);
			FlxG.followBounds(0, 0, map.right, map.bottom);
		}
		
		protected function CB_Powerup(aplayer : FlxObject, powerup : FlxObject) : void
		{
			player.getPowerup();
			powerup.kill();
		}
		
		override public function update():void
		{
			if ( FlxG.keys.justPressed("R") )
			{
				destroy();
				create();
			}
			
			bugUpdateCamera();
			super.update();
			map.collide(metaObjects);
			
			FlxU.overlap(player, powerups, CB_Powerup);
			
			//hudText.text = player.rand.toString();
		}
	}

}