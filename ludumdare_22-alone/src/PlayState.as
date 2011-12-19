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
		
		//[Embed(source = "get-save.mp3")] private static var SndGetSave : Class;
		[Embed(source = "sfx/player-die.mp3")] private static var SndPlayerDie : Class;
		[Embed(source = "sfx/player-hurt.mp3")] private static var SndPlayerHurt : Class;
		[Embed(source = "sfx/player-collected-score.mp3")] private static var SndCollectedTreasure : Class;
		
		[Embed(source = "tiles.png")]
		public static var data_tiles : Class;
		
		private static const kDisplayTime : Number = 1;
		private static const kDisplayTimeMulti : Number = 20;
		
		private var map : FlxTilemap;
		
		private var scoreText : FlxText;
		private var ammoHud : FlxText;
		
		private var player : Player;
		
		private var worldGroup: FlxGroup;
		private var playerBullets: FlxGroup;
		
		private var groundSpawners : FlxGroup;
		private var flyingSpawners : FlxGroup;
		private var powerupSpawners : FlxGroup;
		private var groundMonsters : FlxGroup;
		private var flyingMonsters : FlxGroup;
		
		private var powerups : FlxGroup;
		private var coconutToThrow : uint = 0;
		
		private var saves : FlxGroup;
		
		private var objectsThatCollideWithWorld: FlxGroup;
		private var healthDisplay : HealthDisplay;
		
		private var treasures : FlxGroup;
		
		private var displayString : String;
		private var displayTime : Number = 0;
		
		private var enemySpawnTime : Number = 0;
		private var fenemySpawnTime : Number = 0;
		private var powerupSpawnTime : Number = 0;
		
		//[Embed(source = "music.mp3")] private static var SndMusic : Class;
		
		override public function create() : void
		{
			worldGroup = new FlxGroup();
			playerBullets = new FlxGroup();
			groundSpawners = new FlxGroup();
			powerupSpawners = new FlxGroup();
			flyingSpawners = new FlxGroup();
			groundMonsters = new FlxGroup();
			flyingMonsters = new FlxGroup();
			powerups = new FlxGroup();
			saves = new FlxGroup();
			treasures = new FlxGroup();
			
			player = new Player(64, 64, playerBullets.members);
			
			for (var i:uint = 0; i < 100; ++i)
			{
				playerBullets.add( new Bullet() );
			}
			
			objectsThatCollideWithWorld = new FlxGroup();
			bgColor = 0xff3852A7;
			
			map = new FlxTilemap();
			map.drawIndex = 1;
			map.collideIndex = 40;
			
			var tmx:TmxMap = new TmxMap(new XML( new data_map ));
			map.loadMap(tmx.getLayer('map').toCsv(tmx.getTileSet('tiles')), data_tiles, 64);
			
			for each(var o:TmxObject in tmx.getObjectGroup("ground").objects)
			{
				groundSpawners.add( new Spawner(o.x, o.y, 70) );
			}
			for each(o in tmx.getObjectGroup("powerup").objects)
			{
				powerupSpawners.add( new Spawner(o.x, o.y, -70) );
			}
			for each(o in tmx.getObjectGroup("fly").objects)
			{
				flyingSpawners.add( new Spawner(o.x, o.y, 0) );
			}
			map.x = map.y = 0;
			
			worldGroup.add(map);
			
			add(worldGroup);
			
			add(groundSpawners);
			add(flyingSpawners);
			add(powerupSpawners);
			add(groundMonsters);
			add(flyingMonsters);
			add(playerBullets);
			add(powerups);
			add(saves);
			add(treasures);
			
			scoreText = new FlxText(0 , 10, 640, "");
			scoreText.size = 20;
			scoreText.scrollFactor = new FlxPoint(0, 0);
			scoreText.alignment = "right";
			scoreText.color = 0xff000000;
			
			ammoHud = new FlxText(0 , 455, 640, "");
			ammoHud.size = 20;
			ammoHud.scrollFactor = new FlxPoint(0, 0);
			ammoHud.alignment = "right";
			ammoHud.color = 0xff000000;
			
			healthDisplay = new HealthDisplay();
			healthDisplay.scrollFactor = new FlxPoint(0, 0);
			
			add(player);
			
			objectsThatCollideWithWorld.add(player);
			objectsThatCollideWithWorld.add(playerBullets);
			objectsThatCollideWithWorld.add(groundMonsters);
			objectsThatCollideWithWorld.add(groundSpawners);
			objectsThatCollideWithWorld.add(powerupSpawners);
			objectsThatCollideWithWorld.add(powerups);
			objectsThatCollideWithWorld.add(saves);
			objectsThatCollideWithWorld.add(treasures);
			
			bugUpdateCamera();
			
			add(scoreText);
			add(healthDisplay);
			add(ammoHud);
			
			positionPlayer();
			
			//FlxG.playMusic(SndMusic);
		}
		
		private static function RemoveDeadItems(arr:FlxGroup) : void
		{
			var o : FlxObject = arr.getFirstAvail();
			while ( o != null )
			{
				arr.remove(o);
				o = arr.getFirstAvail();
			}
		}
		
		private function positionPlayer() : void
		{
			player.x = 64;
			player.y = 64;
		}
		
		private function bugUpdateCamera() : void
		{
			FlxG.follow(player);
			FlxG.followBounds(0, 0, map.right, map.bottom);
		}
		
		protected function CB_PlayerPowerup(aplayer : FlxObject, apowerup : FlxObject) : void
		{
			var p : Powerup = apowerup as Powerup;
			if ( p.isHealth )
			{
				player.pickupHealth();
				apowerup.kill();
			}
			else
			{			
				if ( player.canPickupAmmobox() )
				{
					player.pickupBullets();
					apowerup.kill();
				}
			}
		}
		protected function CB_PlayerTreasure(aplayer : FlxObject, treasure : FlxObject) : void
		{
			treasure.kill();
			FlxG.play(SndCollectedTreasure);
			var t : Treasure = treasure as Treasure;
			displayTime = kDisplayTime;
			FlxG.score += 100;
		}
		
		protected function CB_PlayerMonster(aplayer : FlxObject, coconut : FlxObject) : void
		{
			if ( player.flickering() == false )
			{
				player.flicker();
				player.myHealth -= 1;
				if ( player.myHealth == 0 )
				{
					FlxG.state = new ScoreState();
					FlxG.play(SndPlayerDie);
				}
				else
				{
					FlxG.play(SndPlayerHurt);
					FlxG.flash.start(0xffff0000, 0.25);
				}
			}
		}
		
		protected function CB_Bullet_WalkingMonster(bullet : FlxObject, omonster : FlxObject) : void
		{
			var wmonster : WalkingMonster = omonster as WalkingMonster;
			var cmonster : CrawlingMonster = omonster as CrawlingMonster;
			var fmonster : FlyingMonster = omonster as FlyingMonster;
			bullet.kill();
			if ( wmonster != null ) wmonster.damage();
			if ( cmonster != null ) cmonster.damage();
			if ( fmonster != null ) fmonster.damage();
		}
		
		public function spawnTreasure(x:Number, y:Number) : void
		{
			treasures.add( new Treasure(x, y, player) );
		}
		
		public function spawnTreasures(x:Number, y:Number) : void
		{
			spawnTreasure(x, y);
			spawnTreasure(x, y);
			spawnTreasure(x, y);
		}
		
		private function getRandom(collection:FlxGroup) : Spawner
		{
			// for some reason, one of our collections is empty causing this loop to hang, igonre this by returning null
			if ( collection.members.length == 0 ) return null;
			var o : Spawner = null;
			while (o == null )
			{
				o = collection.getRandom() as Spawner;
				
				if ( o == null ) return null;
				{
					var dx:Number = player.x - o.x;
					var dy:Number = player.y - o.y;
					var le : Number = Math.sqrt( dx * dx + dy + dy );
					if ( le < 150 )
					{
						// this is to close to the player, ignore it
						o = null;
					}
				}
			}
			
			return o;
		}
		
		override public function update():void
		{	
			bugUpdateCamera();
			super.update();
			map.collide(objectsThatCollideWithWorld);
			
			FlxU.overlap(playerBullets, groundMonsters, CB_Bullet_WalkingMonster);
			FlxU.overlap(playerBullets, flyingMonsters, CB_Bullet_WalkingMonster);
			FlxU.overlap(player, groundMonsters, CB_PlayerMonster);
			FlxU.overlap(player, flyingMonsters, CB_PlayerMonster);
			if ( displayTime > 0 )
			{
				displayTime -= FlxG.elapsed;
			}
			else
			{
				displayTime = 0;
			}
			scoreText.text = "Score: " + FlxG.score.toString();
			scoreText.size = 20 + displayTime*kDisplayTimeMulti;
			FlxU.overlap(player, treasures, CB_PlayerTreasure);
			FlxU.overlap(player, powerups, CB_PlayerPowerup);
			
			healthDisplay.setHealth(player.myHealth);
			
			if ( player.getNumberOfBullets()<=0 )
			{
				ammoHud.text = "";
			}
			else
			{
				ammoHud.text = "Remaining shots: " + player.getNumberOfBullets().toString();
				
				if ( player.getNumberOfBullets() <= 20 )
				{
					ammoHud.color = 0xffff0000;
				}
				else
				{
					ammoHud.color = 0xff000000;
				}
			}
			
			var o : Spawner = null;
			
			if ( enemySpawnTime < 0 )
			{
				if ( groundMonsters.countLiving() < 15 )
				{
					o = getRandom(groundSpawners);
					if ( o != null )
					{
						if ( Math.random() > 0.4 )
						{
							groundMonsters.add(new CrawlingMonster(o.x, o.y - 10, player, this));
						}
						else
						{
							groundMonsters.add(new WalkingMonster(o.x, o.y - 10, player, this));
						}
					}
				}
				enemySpawnTime = Math.random() * 3;
			}
			else
			{
				enemySpawnTime -= FlxG.elapsed;
			}
			
			if ( fenemySpawnTime < 0 )
			{
				if ( flyingMonsters.countLiving() < 20 )
				{
					o = getRandom(flyingSpawners);
					if ( o != null )
					{
						flyingMonsters.add(new FlyingMonster(o.x, o.y - 10, player, this));
					}
				}
				fenemySpawnTime = Math.random() * 3;
			}
			else
			{
				fenemySpawnTime -= FlxG.elapsed;
			}
			
			if ( powerupSpawnTime < 0 )
			{
				if ( powerups.countLiving() < 5 )
				{
					var powerupSpawner : Spawner = getRandom(powerupSpawners);
					if ( powerupSpawner != null )
					{
						var b : Boolean = Math.random() > 0.5;
						powerups.add(new Powerup(powerupSpawner.x, powerupSpawner.y, b));
					}
				}
				powerupSpawnTime = Math.random() * 5;
			}
			else
			{
				powerupSpawnTime -= FlxG.elapsed;
			}
			
			RemoveDeadItems(groundMonsters);
			RemoveDeadItems(flyingMonsters);
			RemoveDeadItems(treasures);
			RemoveDeadItems(powerups);
		}
	}
}