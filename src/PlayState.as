package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	public class PlayState extends GameState {
		
		static public var SCREEN_WIDTH:int = 640, SCREEN_HEIGHT:int = 480;
		static public var main:Object;

		public var g:Graphics;
		static public var buffer:Sprite = new Sprite;
		public var rotation_container:Sprite = new Sprite;
		
		// Containes for variables
		public var player:Player;
		public var enemies:Array;
		public var blocks:Array;
		
		// For mouse control
		public var mouseButtonDown:Boolean = false;
		public var startingAngle:Number, currentAngle:Number, previousAngle:Number, mouseRotations:int = 0;		// For rotational movement
		
		// Stuff for hand cursor
		public var cursor:Sprite = new Sprite;
		[Embed(source = "../images/hand-icon-open.png")] public var HandIconOpen:Class;
		[Embed(source = "../images/hand-icon-closed.png")] public var HandIconClosed:Class;
		
		public function PlayState():void {
			main = this;
			g = graphics;
			
			// For some reason, mouse clicks won't activate unless there's a background
			[Embed(source = "../images/clouds.jpg")] var CloudBackground:Class;
			addChild(new CloudBackground);
			this.getChildAt(0).width = SCREEN_WIDTH;
			this.getChildAt(0).height = SCREEN_HEIGHT;
			
			player = new Player(SCREEN_WIDTH >> 1, SCREEN_HEIGHT >> 1, 0x00ff00);
			
			buffer.x = -player.x; 
			buffer.y = -player.y;
			rotation_container.x = player.x; 
			rotation_container.y = player.y;
			
			rotation_container.addChild(buffer);
			addChild(rotation_container);
			
			/**
			 * Initialize mouse cursor
			 */
			cursor.addChild(new HandIconOpen);
			cursor.addChild(new HandIconClosed);
			cursor.getChildAt(1).visible = false;
			addChild(cursor);
			addEventListener(MouseEvent.MOUSE_MOVE, function (e:MouseEvent):void { cursor.visible = true;  cursor.x = e.stageX; cursor.y = e.stageY; } );
			addEventListener(Event.MOUSE_LEAVE, function (e:Event):void { cursor.visible = false; } );
			
			/**
			 * Create 100x100 2D level array - each cell represents 100x100px
			 */
			
			 blocks = new Array(100);
			 for (var i:int = 0; i < blocks.length; i++) 
			 {
				 blocks[i] = new Array(100);
				 for (var j:int = 0; j < blocks[i].length; j++) 
				 {
					 blocks[i][j] = new Array;
				 }
			 }
			 
			/**
			 * Load the level via PNG pixel values
			 * Embed a PNG, convert it to BitmapData, then use for block placement =]
			 */
			[Embed(source = "../levels/1.png")] var LevelData:Class;
			var levelData:Sprite = new Sprite;
			levelData.addChild(new LevelData);
			var bmd:BitmapData = new BitmapData(levelData.width, levelData.height);
			bmd.draw(levelData);
			
			enemies = new Array();
			for (i = 0; i < bmd.width; i++) 
				for (j = 0; j < bmd.height; j++)
				{
					//trace(i + ", " + j + "=" + bmd.getPixel(i, j).toString(16));
					//trace("Trying to put a block in cell " + Math.floor(i * 20 / 100) + "," + Math.floor(j * 20 / 100));
					if (bmd.getPixel(i, j).toString(16) == "0") 
					{
						//enemies.push(new Actor(i * 20, j * 20, 0xff0000));
						blocks[Math.floor(i * 20 / 100)][Math.floor(j * 20 / 100)].push(new Actor(i * 20, j * 20, 0xff0000));
					}
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
				currentAngle = Math.atan2(SCREEN_WIDTH / 2 - this.mouseX, SCREEN_HEIGHT / 2 - this.mouseY) * 180 / Math.PI + 180;
				var diff:Number = currentAngle - previousAngle;
				
				player.angle += diff;		// Change to degrees
				//trace("Starting angle: " + startingAngle);
				//trace("Angle diff: " + (startingAngle - currentAngle));
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
			
			// Determine which collision detection "block" the player is in

			// Collision detection
			var playerXCell:int = Math.floor(player.x / 100);
			var playerYCell:int = Math.floor(player.y / 100);
			var collisionArray:Array = new Array;
			
			// Make an array of the 9 collision detection block arrays around the player
			for (var i:int = playerXCell - 1; i <= playerXCell + 1; i++) 
				for (var j:int = playerYCell - 1; j <= playerYCell + 1; j++) 
					if (i >= 0 && i < 100 && j >=0 && j < 100) 
						collisionArray = collisionArray.concat(blocks[i][j]);
						
			for each (var enemy:Actor in collisionArray)
			//for each(var enemy:Actor in enemies) 
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
			swapCursor();
			mouseButtonDown = true;
			startingAngle = currentAngle = Math.atan2(SCREEN_WIDTH / 2 - this.mouseX, SCREEN_HEIGHT / 2 - this.mouseY) * 180 / Math.PI + 180;
			//if (startingAngle < 0) startingAngle += 360;
			
		}
		
		public function mouseUp(e:MouseEvent = null):void 
		{
			swapCursor();
			mouseButtonDown = false;
		}
		
		public function swapCursor():void
		{
			if (cursor.getChildAt(1).visible == true)
			{
				cursor.getChildAt(1).visible = false;
				cursor.getChildAt(0).visible = true;
			}
			else
			{
				cursor.getChildAt(1).visible = true;
				cursor.getChildAt(0).visible = false;
			}
		}
		
		public override function destroy():void {
			removeChild(rotation_container);
			removeChild(cursor);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
	}
}