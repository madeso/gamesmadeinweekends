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
		
		private var helpText : FlxText;
		
		private var player : Player;
		
		private var worldGroup: FlxGroup;
		private var playerStones: FlxGroup;
		
		private var stonePickups : FlxGroup;
		private var monkeys : FlxGroup;
		
		private var objectsThatCollideWithWorld: FlxGroup;
		
		//[Embed(source = "music.mp3")] private static var SndMusic : Class;
		
		override public function create() : void
		{
			worldGroup = new FlxGroup();
			playerStones = new FlxGroup();
			stonePickups = new FlxGroup();
			monkeys = new FlxGroup();
			
			for (var i:uint = 0; i < 100; ++i)
			{
				playerStones.add( new Stone() );
			}
			
			objectsThatCollideWithWorld = new FlxGroup();
			bgColor = 0xffADD6E7;
			
			map = new FlxTilemap();
			map.drawIndex = 1;
			map.collideIndex = 60;
			
			var tmx:TmxMap = new TmxMap(new XML( new data_map ));
			map.loadMap(tmx.getLayer('map').toCsv(tmx.getTileSet('tiles')), data_tiles, 64);
			for each(var o:TmxObject in tmx.getObjectGroup("stones").objects)
			{
				stonePickups.add( new Powerup(o.x, o.y) );
			}
			for each(o in tmx.getObjectGroup("monkeys").objects)
			{
				monkeys.add( new Monkey(o.x, o.y) );
			}
			//map.loadMap(new data_map, data_tiles, 64);
			map.x = map.y = 0;
			
			worldGroup.add(map);
			
			add(worldGroup);
			
			add(stonePickups);
			add(monkeys);
			add(playerStones);
			
			helpText = new FlxText(0 , 0, 300, "when average joe is jungle joe");
			helpText.scrollFactor = new FlxPoint(0, 0);
			
			player = new Player(64, 64, playerStones.members);
			add(player);
			
			objectsThatCollideWithWorld.add(player);
			objectsThatCollideWithWorld.add(playerStones);
			objectsThatCollideWithWorld.add(monkeys);
			objectsThatCollideWithWorld.add(stonePickups);
			
			bugUpdateCamera();
			
			add( helpText );
			
			//FlxG.playMusic(SndMusic);
		}
		
		private function bugUpdateCamera() : void
		{
			FlxG.follow(player, 5.5);
			FlxG.followBounds(0, 0, map.right, map.bottom);
		}
		
		protected function CB_PlayerStonespickup(aplayer : FlxObject, stonesPickup : FlxObject) : void
		{
			if ( player.canPickupStones() )
			{
				player.pickupStone();
				//stonesPickup.kill();
			}
		}
		
		protected function CB_StoneMonkey(stone : FlxObject, monkey : FlxObject) : void
		{
			stone.kill();
			if ( monkey.flickering() )
			{
				monkey.kill();
			}
			else
			{
				monkey.flicker();
			}
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
			map.collide(objectsThatCollideWithWorld);
			
			FlxU.overlap(player, stonePickups, CB_PlayerStonespickup);
			FlxU.overlap(playerStones, monkeys, CB_StoneMonkey);
			
			//hudText.text = player.rand.toString();
		}
	}

}