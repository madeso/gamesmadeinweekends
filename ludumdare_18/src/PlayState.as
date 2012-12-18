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
		
		[Embed(source = "mdie.mp3")] private var SndMonsterDie:Class;
		[Embed(source = "walk1.mp3")] private var SndGnomeFlicker:Class;
		
		public var map : FlxTilemap;
		
		private var hudText : FlxText;
		private var hudHearts : Hearts;
		
		private var player : Player;
		
		private var worldGroup: FlxGroup;
		private var bullets: FlxGroup;
		
		private var powerups : FlxGroup;
		private var gnomes : FlxGroup;
		private var magicians : FlxGroup;
		private var deadGnomes : FlxGroup;
		private var gnomeBullets : FlxGroup;
		
		private var metaObjects: FlxGroup;
		private var bulletsIndex : uint = 0;
		private var playerBullet : PlayerBullet;
		private var deadGnomeIndex : uint = 0;
		private var gnomeIndex : uint = 0;
		
		private var playerGnome : DeadGnome;
		private var starloader : Starloader;
		
		private var goalx : Number = -100;
		private var goaly : Number = -100;
		
		public function fireMonsterBullet(x : Number, y:Number, xv:Number, yv: Number) : void
		{
			bullets.members[bulletsIndex].shoot(x, y, xv, yv);
			bulletsIndex++;
			if ( bulletsIndex >= bullets.members.length ) bulletsIndex = 0;
		}
		
		public function fireDeadGnome(x : Number, y:Number, xv:Number, yv: Number) : void
		{
			deadGnomes.members[deadGnomeIndex].start(x, y, xv, yv, false);
			deadGnomeIndex++;
			if ( deadGnomeIndex >= deadGnomes.members.length ) deadGnomeIndex = 0;
		}
		
		public function throwGnomeBullet(x : Number, y:Number, xv:Number, yv: Number) : void
		{
			gnomeBullets.members[gnomeIndex].start(x, y, xv, yv, true);
			gnomeIndex++;
			if ( gnomeIndex >= gnomeBullets.members.length ) gnomeIndex = 0;
		}
		
		//[Embed(source = "music.mp3")] private static var SndMusic : Class;
		
		override public function create() : void
		{
			worldGroup = new FlxGroup();
			bullets = new FlxGroup();
			powerups = new FlxGroup();
			gnomes = new FlxGroup();
			magicians = new FlxGroup();
			playerBullet = new PlayerBullet();
			playerGnome = new DeadGnome();
			deadGnomes = new FlxGroup();
			gnomeBullets = new FlxGroup();
			starloader = new Starloader();
			
			for (var i:uint = 0; i < 100; ++i)
			{
				bullets.add( new Bullet() );
			}
			
			for (var gi:uint = 0; gi < 100; ++gi)
			{
				deadGnomes.add( new DeadGnome() );
			}
			for (var di:uint = 0; di < 100; ++di)
			{
				gnomeBullets.add( new DeadGnome() );
			}
			
			metaObjects = new FlxGroup();
			bgColor = 0xff6a6a6a;
			
			map = new FlxTilemap();
			map.drawIndex = 1;
			map.collideIndex = 42;
			
			player = new Player(64, 64, playerBullet, playerGnome, this, starloader);
			
			var tmx:TmxMap = new TmxMap(new XML( new data_map ));
			map.loadMap(tmx.getLayer('map').toCsv(tmx.getTileSet('tiles')), data_tiles, 64);
			for each(var o:TmxObject in tmx.getObjectGroup("magicians").objects)
			{
				magicians.add( new Magician(o.x, o.y, this, player) );
			}
			
			for each(o in tmx.getObjectGroup("gnomes").objects)
			{
				gnomes.add( new Gnome(o.x, o.y, this, player) );
			}
			
			for each(o in tmx.getObjectGroup("complete").objects)
			{
				goalx = o.x;
				goaly = o.y;
			}
			//map.loadMap(new data_map, data_tiles, 64);
			map.x = map.y = 0;
			
			worldGroup.add(map);
			
			add(worldGroup);
			
			add(starloader);
			add(powerups);
			add(gnomes);
			add(magicians);
			add(bullets);
			add(playerBullet);
			add(playerGnome);
			add(deadGnomes);
			add(gnomeBullets);
			
			hudText = new FlxText(340 , 0, 300, "Z: shoot | X: jump");
			hudText.scrollFactor = new FlxPoint(0, 0);
			hudText.alignment = "right";
			
			hudHearts = new Hearts(0, 0, player);
			hudHearts.scrollFactor = new FlxPoint(0, 0);
			
			add(player);
			
			metaObjects.add(player);
			metaObjects.add(bullets);
			metaObjects.add(gnomes);
			metaObjects.add(magicians);
			metaObjects.add(playerBullet);
			//metaObjects.add(gnomeBullets);
			
			bugUpdateCamera();
			
			add( hudText );
			add(hudHearts);
			
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
		
		protected function CB_BulletEnemy(bullet : FlxObject, monster : FlxObject) : void
		{
			if ( monster.onScreen() )
			{
				FlxG.play(SndMonsterDie);
			}
			monster.kill();
		}
		
		protected function CB_PlayerBullet(player : FlxObject, bullet: FlxObject) : void
		{
			(player as Player).cBullet(bullet);
			bullet.kill();
		}
		
		[Embed(source = "up3.mp3")] private var SndPickupGnome:Class;
		
		protected function CB_PlayerGnome(aplayer : FlxObject, agnome: FlxObject) : void
		{
			var player : Player = aplayer as Player;
			var gnome : Gnome = agnome as Gnome;
			
			FlxG.log("Gnome hurt player: player " + player.y.toString() + " gnome " + gnome.x.toString() + " / " + player.velocity.y.toString());
			
			// (player.y > gnome.y - 20) 
			if ( player.velocity.y > 0 )
			{
				if ( gnome.flickering() )
				{
					if ( player.canPickupGnome() )
					{
						player.pickupGnome();
						gnome.pickup();
						FlxG.play(SndPickupGnome);
					}
					else
					{
						killGnome(gnome);
					}
				}
				else
				{
					gnome.flicker();
					FlxG.play(SndGnomeFlicker);
				}
				player.velocity.y = -450;
			}
			else
			{
				
				if ( gnome.canBeDamagedBy() )
				{
					player.dmg(agnome);
				}
			}
		}
		
		private function randomSign() : int
		{
			if ( Math.random() > 0.5 ) return 1;
			else return -1;
		}
		
		private function killGnome(gnome : Gnome ) : void
		{
			fireDeadGnome(gnome.x, gnome.y, 150 * Math.random() * randomSign(), -(150 + Math.random() * 100 ));
			gnome.pickup();
			FlxG.play(SndMonsterDie);
		}
		
		protected function CB_DeadGnomeGnome(dead : FlxObject, agnome: FlxObject) : void
		{
			var gnome : Gnome = agnome as Gnome;
			killGnome(gnome);
			FlxG.log("killed gnome");
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
			FlxU.overlap(playerBullet, gnomes, CB_DeadGnomeGnome);
			FlxU.overlap(gnomeBullets, gnomes, CB_DeadGnomeGnome);
			FlxU.overlap(playerBullet, magicians, CB_BulletEnemy);
			FlxU.overlap(gnomeBullets, magicians, CB_BulletEnemy);
			FlxU.overlap(player, bullets, CB_PlayerBullet);
			
			FlxU.overlap(player, gnomes, CB_PlayerGnome);
			
			if ( Math.abs(player.x - goalx ) < 64 && Math.abs(player.y - goaly ) < 64 )
			{
				FlxG.fade.start(0xff000000, 1, onFadeCompleted);
			}
			
			var str : String = "press X to jump";
			
			if ( playerGnome.exists )
			{
				hudText.text = "hit Z to throw gnome | " + str;
			}
			else
			{
				switch(player.gunStatus())
				{
					case 0: hudText.text = str; break;
					case 2: hudText.text = "keep holding Z | " + str; break;
					case 3: hudText.text = "release Z to fire | " + str; break;
					case 1: hudText.text = "hold Z to load shot| " + str; break;
				}
			}
		}
		
		private function onFadeCompleted() : void
		{
			FlxG.state = new CompleteState();
		}
		
		public function issolid(ax:Number, ay:Number) : Boolean
		{
			var rx : uint = Math.floor(ax / 64) as uint;
			var ry : uint = Math.floor(ay / 64) as uint;
			var i : uint = map.getTile(rx, ry);
			return i >= map.collideIndex;
		}
		
		public function spawnStar(x:Number, y:Number) : void
		{
			powerups.add( new StarPickup(x, y) );
		}
	}

}