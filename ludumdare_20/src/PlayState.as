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
		
		[Embed(source = "player-grab-heart.mp3")] private static var SndGrabHeart : Class;
		[Embed(source = "player-respawn.mp3")] private static var SndRespawn : Class;
		[Embed(source = "player-hurt.mp3")] private static var SndPlayerHurt : Class;
		
		[Embed(source = "tiles.png")]
		public static var data_tiles : Class;
		
		private static const kDisplayTime : Number = 5;
		
		private var map : FlxTilemap;
		
		private var helpText : FlxText;
		private var completedText : FlxText;
		
		private var player : Player;
		private var worldGroup: FlxGroup;
		private var spikeMonsters : FlxGroup;
		private var goals : FlxGroup;
		private var objectsThatCollideWithWorld: FlxGroup;
		private var displayTime : Number = 0;
		
		private var heart : Heart = null;
		
		//[Embed(source = "music.mp3")] private static var SndMusic : Class;
		
		override public function create() : void
		{
			worldGroup = new FlxGroup();
			spikeMonsters = new FlxGroup();
			goals = new FlxGroup();
			player = new Player(64, 64, this);
			
			objectsThatCollideWithWorld = new FlxGroup();
			bgColor = 0xffADD6E7;
			
			map = new FlxTilemap();
			map.drawIndex = 1;
			map.collideIndex = 54;
			
			var tmx:TmxMap = new TmxMap(new XML( new data_map ));
			map.loadMap(tmx.getLayer('map').toCsv(tmx.getTileSet('tiles')), data_tiles, 64);
			for each(var o:TmxObject in tmx.getObjectGroup("spikes").objects)
			{
				spikeMonsters.add( new SpikeMonster(o.x-25, o.y) );
			}
			for each(o in tmx.getObjectGroup("goal").objects)
			{
				goals.add( new LoadComplete(o.x, o.y, player) );
			}
			
			map.x = map.y = 0;
			
			heart = new Heart();
			
			worldGroup.add(map);
			add(worldGroup);
			
			add(spikeMonsters);
			add(goals);
			
			helpText = new FlxText(0 , 90, 640, "they gave you a heart, they gave you a name");
			helpText.size = 142;
			helpText.scrollFactor = new FlxPoint(0, 0);
			helpText.alignment = "center";
			helpText.color = 0xffffffff;
			
			completedText = new FlxText(0 , 455, 640, "");
			completedText.size = 20;
			completedText.scrollFactor = new FlxPoint(0, 0);
			completedText.alignment = "right";
			completedText.color = 0xff000000;
			
			add(player);
			add(heart);
			
			objectsThatCollideWithWorld.add(player);
			objectsThatCollideWithWorld.add(spikeMonsters);
			objectsThatCollideWithWorld.add(goals);
			objectsThatCollideWithWorld.add(heart);
			
			bugUpdateCamera();
			
			add(helpText);
			add(completedText);
			
			positionPlayer();
			
			//FlxG.playMusic(SndMusic);
		}
		
		private function positionPlayer() : void
		{
			player.x = 64;
			player.y = 64 * 96;
			heart.kill();
		}
		
		private function bugUpdateCamera() : void
		{
			FlxG.follow(player, 5.5);
			FlxG.followBounds(0, 0, map.right, map.bottom);
		}
		
		protected function CB_PlayerHeart(aplayer : FlxObject, h : FlxObject) : void
		{
			if ( player.flickering() )
			{
			}
			else
			{
				heart.kill();
				FlxG.play(SndGrabHeart);
			}
		}
		
		protected function respawn() : void
		{
			heart.kill();
			positionPlayer();
			FlxG.play(SndRespawn);
		}
		
		protected function CB_PlayerSpikeMonster(aplayer : FlxObject, monster: FlxObject) : void
		{
			player.velocity.y = -750;
			PlayerHurt();
		}
		
		protected function CB_HeartSpikeMonster(h: FlxObject, monster: FlxObject) : void
		{
			var heart : Heart = h as Heart;
			heart.velocity.y = -150;
		}
		
		private static function r() : Number
		{
			const range : Number = 70;
			var sign : int = 1;
			if ( Math.random() > 0.5 ) sign = -1;
			return (Math.random() * range + 70)* sign;
		}
		
		public function PlayerHurt() : void
		{
			FlxG.flash.start(0xffff0000, 0.25);
			FlxG.play(SndPlayerHurt);
			player.flicker();
			if ( heart.dead == true )
			{
				displayTime = kDisplayTime;
				heart.shoot(player.x, player.y, r(), r());
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
			FlxU.overlap(player, spikeMonsters, CB_PlayerSpikeMonster);
			FlxU.overlap(heart, spikeMonsters, CB_HeartSpikeMonster);
			FlxU.overlap(player, heart, CB_PlayerHeart);
			
			if ( heart.dead == false )
			{
				if ( displayTime <= 0 )
				{
					displayTime = kDisplayTime;
				}
				
				if ( displayTime > 0 )
				{
					helpText.text = String(int(displayTime));
					displayTime -= FlxG.elapsed;
					if ( displayTime < 0 )
					{
						respawn();
					}
				}
			}
			else
			{
				helpText.text = "";
			}
		}
	}
}