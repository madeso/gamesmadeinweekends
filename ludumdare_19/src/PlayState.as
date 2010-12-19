package
{
	import flash.display.AVM1Movie;
	import org.flixel.*;
	
	import net.pixelpracht.tmx.TmxMap;
	import net.pixelpracht.tmx.TmxObject;
	import net.pixelpracht.tmx.TmxObjectGroup;
	
	public class PlayState extends FlxState
	{
		[Embed(source = 'level.tmx', mimeType = "application/octet-stream")] 
		private var data_map:Class;
		
		[Embed(source = "powerup.mp3")] private static var SndGetSave : Class;
		[Embed(source = "powerup.mp3")] private static var SndRespawn : Class;
		[Embed(source = "powerup.mp3")] private static var SndCollectedTreasure : Class;
		
		[Embed(source = "tiles.png")]
		public static var data_tiles : Class;
		
		private var map : FlxTilemap;
		
		private var helpText : FlxText;
		private var completedText : FlxText;
		
		private var player : Player;
		
		private var worldGroup: FlxGroup;
		private var playerStones: FlxGroup;
		
		private var stonePickups : FlxGroup;
		private var monkeys : FlxGroup;
		
		private var coconuts : FlxGroup;
		private var coconutToThrow : uint = 0;
		
		private var saves : FlxGroup;
		
		private var lastSaveSign : SaveSign = null;
		
		private var objectsThatCollideWithWorld: FlxGroup;
		private var healthDisplay : HealthDisplay;
		
		private var treasures : FlxGroup;
		
		//[Embed(source = "music.mp3")] private static var SndMusic : Class;
		
		public function throwCoconut(x:Number, y:Number, dx:Number, dy:Number) : void
		{
			coconuts.members[coconutToThrow].shoot(x, y, dx, dy);
			coconutToThrow = ( coconutToThrow + 1 ) % coconuts.members.length;
		}
		
		override public function create() : void
		{
			worldGroup = new FlxGroup();
			playerStones = new FlxGroup();
			stonePickups = new FlxGroup();
			monkeys = new FlxGroup();
			coconuts = new FlxGroup();
			saves = new FlxGroup();
			treasures = new FlxGroup();
			
			player = new Player(64, 64, playerStones.members);
			
			for (var i:uint = 0; i < 100; ++i)
			{
				playerStones.add( new Stone() );
			}
			
			for (var j:uint = 0; j < 100; ++j)
			{
				coconuts.add( new Coconut() );
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
				stonePickups.add( new StonePickup(o.x, o.y) );
			}
			for each(o in tmx.getObjectGroup("monkeys").objects)
			{
				monkeys.add( new Monkey(o.x, o.y, player, this) );
			}
			for each(o in tmx.getObjectGroup("saves").objects)
			{
				saves.add( new SaveSign(o.x, o.y, o.name) );
			}
			for each(o in tmx.getObjectGroup("treasures").objects)
			{
				treasures.add( new Treasure(o.x, o.y, o.name) );
			}
			//map.loadMap(new data_map, data_tiles, 64);
			map.x = map.y = 0;
			
			worldGroup.add(map);
			
			add(worldGroup);
			
			add(stonePickups);
			add(monkeys);
			add(playerStones);
			add(coconuts);
			add(saves);
			add(treasures);
			
			helpText = new FlxText(0 , 80, 640, "when average joe is jungle joe");
			helpText.size = 22;
			helpText.scrollFactor = new FlxPoint(0, 0);
			helpText.alignment = "center";
			helpText.color = 0xff000000;
			
			completedText = new FlxText(0 , 455, 640, "");
			completedText.size = 20;
			completedText.scrollFactor = new FlxPoint(0, 0);
			completedText.alignment = "right";
			completedText.color = 0xff000000;
			
			healthDisplay = new HealthDisplay();
			healthDisplay.scrollFactor = new FlxPoint(0, 0);
			
			add(player);
			
			objectsThatCollideWithWorld.add(player);
			objectsThatCollideWithWorld.add(playerStones);
			objectsThatCollideWithWorld.add(monkeys);
			objectsThatCollideWithWorld.add(stonePickups);
			objectsThatCollideWithWorld.add(coconuts);
			objectsThatCollideWithWorld.add(saves);
			objectsThatCollideWithWorld.add(treasures);
			
			bugUpdateCamera();
			
			add(helpText);
			add(healthDisplay);
			add(completedText);
			
			positionPlayer();
			
			//FlxG.playMusic(SndMusic);
		}
		
		private function positionPlayer() : void
		{
			player.x = 64;
			player.y = 64;
			
			if ( lastSaveSign != null )
			{
				player.x = lastSaveSign.x;
				player.y = lastSaveSign.y;
			}
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
		protected function CB_PlayerTreasure(aplayer : FlxObject, treasure : FlxObject) : void
		{
			treasure.kill();
			FlxG.play(SndCollectedTreasure);
		}
		
		protected function CB_PlayerCoconut(aplayer : FlxObject, coconut : FlxObject) : void
		{
			if ( player.flickering() == false )
			{
				player.flicker();
				player.myHealth -= 1;
				if ( player.myHealth == 0 )
				{
					player.myHealth = 3;
					positionPlayer();
					FlxG.play(SndRespawn);
				}
			}
			coconut.kill();
		}
		
		protected function CB_PlayerSave(aplayer : FlxObject, save: FlxObject) : void
		{
			var ss : SaveSign = save as SaveSign;
			helpText.text = ss.text;
			
			if ( ss != lastSaveSign )
			{
				if ( lastSaveSign != null ) lastSaveSign.darken();
				ss.lighten();
				FlxG.play(SndGetSave);
				lastSaveSign = ss;
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
				FlxG.state = new PlayState();
			}
			
			bugUpdateCamera();
			super.update();
			map.collide(objectsThatCollideWithWorld);
			
			FlxU.overlap(player, stonePickups, CB_PlayerStonespickup);
			FlxU.overlap(playerStones, monkeys, CB_StoneMonkey);
			FlxU.overlap(player, coconuts, CB_PlayerCoconut);
			helpText.text = "";
			FlxU.overlap(player, saves, CB_PlayerSave);
			FlxU.overlap(player, treasures, CB_PlayerTreasure);
			
			healthDisplay.setHealth(player.myHealth);
			
			if ( treasures.countLiving() == 0 )
			{
				completedText.text = "Game completed! You are awesome!";
			}
			else
			{
				completedText.text = "Remaining treasures: " + treasures.countLiving().toString();
			}
			
			//hudText.text = player.rand.toString();
		}
	}

}