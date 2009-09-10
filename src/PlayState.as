package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	public class PlayState extends GameState {
		
		public const SCREEN_WIDTH:int = 640, SCREEN_HEIGHT:int = 480;
		static public var main:Object;
		
		public var g:Graphics;
		//public var buffer:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0xffffff);
		static public var buffer:Sprite = new Sprite;
		public var rotation_container:Sprite = new Sprite;
		public var player:Player, enemies:Array;
		
		// For mouse control
		public var mouseButtonDown:Boolean = false;
		public var startingAngle:Number, currentAngle:Number, previousAngle:Number, mouseRotations:int = 0;		// For rotational movement
		
		public function PlayState():void {
			main = this;
			g = graphics;
			
			player = new Player(SCREEN_WIDTH >> 1, SCREEN_HEIGHT >> 1, 0x00ff00);
			
			buffer.x = -player.x; 
			buffer.y = -player.y;
			rotation_container.x = player.x; 
			rotation_container.y = player.y;
			
			rotation_container.addChild(buffer);
			addChild(rotation_container);
			
			enemies = new Array();
			
			// Embed a PNG, convert it to BitmapData, then use for block placement =]
			[Embed(source = "../levels/1.png")] var LevelData:Class;
			var levelData:Sprite = new Sprite;
			levelData.addChild(new LevelData);
			var bmd:BitmapData = new BitmapData(levelData.width, levelData.height);
			bmd.draw(levelData);
			
			for (var i:int = 0; i < bmd.width; i++) 
				for (var j:int = 0; j < bmd.height; j++)
				{
					//trace(i + ", " + j + "=" + bmd.getPixel(i, j).toString(16));
					if (bmd.getPixel(i, j).toString(16) == "0")
						enemies.push(new Actor(i * 20, j * 20, 0xff0000));
				}

			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		public function update(e:Event = null):void 
		{
			buffer.graphics.clear();
			
			// Draw player
			player.draw(buffer.graphics);
			
			// Change player's "rotation" based on keyboard input
			if (Main.keys[0x25] || Main.keys[0x41]) player.angle -= 10;
			if (Main.keys[0x27] || Main.keys[0x44]) player.angle += 10;
			
			if (mouseButtonDown) 
			{
				previousAngle = currentAngle;
				currentAngle = Math.atan2(player.x - this.mouseX, player.y - this.mouseY) * 180 / Math.PI + 90;
				var diff:Number = startingAngle - currentAngle;
				if (diff < 0) diff += 360;
				
				player.angle = startingAngle - diff;		// Change to degrees
				trace("Starting angle: " + startingAngle);
				trace("Angle diff: " + (startingAngle - currentAngle));
			}
			
			// Determine player acceleration based on "which way is down"
			player.ddx = Math.cos(player.angle * Math.PI / 180);
			player.ddy = Math.sin(player.angle * Math.PI / 180);
			
			// Rotate the container that holds teh buffar
			rotation_container.rotation = -player.angle + 90;
			
			// Increment volocity based on acceleration
			player.dx += player.ddx;
			player.dy += player.ddy;
			
			// Increment player position based on velocity
			player.x += player.dx;
			player.y += player.dy;
			
			// Move buffer in relation to player
			buffer.x -= player.dx;
			buffer.y -= player.dy;
			
			// Collision detection
			for each(var enemy:Actor in enemies) 
			{
				// Draw the enemy on the buffar!
				enemy.draw(buffer.graphics);
				
				// If this is non-zero, there has been a collision
				var penetration_vector:Object = player.collides_with(enemy);
				
				if (penetration_vector) 
				{
					// Change color, just to show what was hit
					enemy.color = 0xfff000;
					
					// Move player out of colliding object
					player.x += penetration_vector.x;
					player.y += penetration_vector.y;
					
					// Add a "bounce" velocity to player
					//player.dx += 4 * penetration_vector.x * 0.8;
					//player.dy += 4 * penetration_vector.y * 0.8;
					
					// Move buffer in relation to player
					buffer.x -= penetration_vector.x;
					buffer.y -= penetration_vector.y;
				}
				else {
					enemy.color = 0xff0000;
				}
			}
		
			// Affect velocity by a "friction" value
			player.dx *= 0.8;
			player.dy *= 0.8;
		}
		
		public function mouseDown(e:MouseEvent = null):void 
		{
			mouseButtonDown = true;
			startingAngle = Math.atan2(player.x - this.mouseX, player.y - this.mouseY) * 180 / Math.PI + 90;
			if (startingAngle < 0) startingAngle += 360;
		}
		
		public function mouseUp(e:MouseEvent = null):void 
		{
			mouseButtonDown = false;
		}
		
		public override function destroy():void {
			removeChild(rotation_container);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
	}
}