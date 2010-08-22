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
		
		public var map : FlxTilemap;
		
		private var hudText : FlxText;
		
		private var player : Player;
		
		private var worldGroup: FlxGroup;
		private var bullets: FlxGroup;
		
		private var powerups : FlxGroup;
		private var gnomes : FlxGroup;
		private var magicians : FlxGroup;
		
		private var metaObjects: FlxGroup;
		private var bulletsIndex : uint = 0;
		private var playerBullet : PlayerBullet;
		
		public function fireMonsterBullet(x : Number, y:Number, xv:Number, yv: Number) : void
		{
			bullets.members[bulletsIndex].shoot(x, y, xv, yv);
			bulletsIndex++;
			if ( bulletsIndex >= bullets.members.length ) bulletsIndex = 0;
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
			
			for (var i:uint = 0; i < 100; ++i)
			{
				bullets.add( new Bullet() );
			}
			
			metaObjects = new FlxGroup();
			bgColor = 0xff969696;
			
			map = new FlxTilemap();
			map.drawIndex = 1;
			map.collideIndex = 42;
			
			player = new Player(64, 64, playerBullet);
			
			var tmx:TmxMap = new TmxMap(new XML( new data_map ));
			map.loadMap(tmx.getLayer('map').toCsv(tmx.getTileSet('tiles')), data_tiles, 64);
			for each(var o:TmxObject in tmx.getObjectGroup("powerups").objects)
			{
				magicians.add( new Magician(o.x, o.y, this, player) );
			}
			
			for each(o in tmx.getObjectGroup("barrels").objects)
			{
				gnomes.add( new Gnome(o.x, o.y, this, player) );
			}
			//map.loadMap(new data_map, data_tiles, 64);
			map.x = map.y = 0;
			
			worldGroup.add(map);
			
			add(worldGroup);
			
			add(powerups);
			add(gnomes);
			add(magicians);
			add(bullets);
			add(playerBullet);
			
			hudText = new FlxText(0 , 0, 300, "Z: shoot | X: jump");
			hudText.scrollFactor = new FlxPoint(0, 0);
			
			add(player);
			
			metaObjects.add(player);
			metaObjects.add(bullets);
			metaObjects.add(gnomes);
			metaObjects.add(magicians);
			metaObjects.add(playerBullet);
			
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
			if ( (player.y > gnome.y - 30) && player.velocity.y > 0 )
			{
				if ( gnome.flickering() )
				{
					if ( player.canPickupGnome() )
					{
						player.pickupGnome();
						gnome.pickup();
						FlxG.play(SndPickupGnome);
					}
				}
				else
				{
					gnome.flicker();
				}
				player.velocity.y = -100;
			}
			else
			{
				player.cBullet(agnome);
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
			map.collide(metaObjects);
			
			FlxU.overlap(player, powerups, CB_Powerup);
			FlxU.overlap(playerBullet, gnomes, CB_BulletEnemy);
			FlxU.overlap(playerBullet, magicians, CB_BulletEnemy);
			FlxU.overlap(player, bullets, CB_PlayerBullet);
			
			FlxU.overlap(player, gnomes, CB_PlayerGnome);
			
			//hudText.text = player.rand.toString();
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