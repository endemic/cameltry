package {
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
		public var startingMovementAngle:Number;
		
		public function PlayState():void {
			main = this;
			g = graphics;
			
			player = new Player(320, 240, 0x00ff00);
			
			buffer.x = -320; buffer.y = -240;
			rotation_container.x = player.x; rotation_container.y = player.y;
			
			rotation_container.addChild(buffer);
			addChild(rotation_container);
			
			enemies = new Array();
			
			enemies.push(new Actor(280, 300, 0xff0000));
			enemies.push(new Actor(280, 280, 0xff0000));
			enemies.push(new Actor(280, 260, 0xff0000));
			enemies.push(new Actor(280, 240, 0xff0000));
			enemies.push(new Actor(280, 220, 0xff0000));
			enemies.push(new Actor(280, 200, 0xff0000));
			enemies.push(new Actor(280, 180, 0xff0000));
			enemies.push(new Actor(280, 160, 0xff0000));
			enemies.push(new Actor(280, 140, 0xff0000));
			enemies.push(new Actor(280, 120, 0xff0000));
			enemies.push(new Actor(280, 100, 0xff0000));
			
			enemies.push(new Actor(360, 300, 0xff0000));
			enemies.push(new Actor(360, 280, 0xff0000));
			enemies.push(new Actor(360, 260, 0xff0000));
			enemies.push(new Actor(360, 240, 0xff0000));
			enemies.push(new Actor(360, 220, 0xff0000));
			enemies.push(new Actor(360, 220, 0xff0000));
			enemies.push(new Actor(360, 200, 0xff0000));
			enemies.push(new Actor(360, 180, 0xff0000));
			enemies.push(new Actor(360, 160, 0xff0000));
			enemies.push(new Actor(360, 140, 0xff0000));
			enemies.push(new Actor(360, 120, 0xff0000));
			enemies.push(new Actor(360, 100, 0xff0000));
			
			enemies.push(new Actor(300, 300, 0xff0000));
			enemies.push(new Actor(320, 300, 0xff0000));
			enemies.push(new Actor(340, 300, 0xff0000));
			
			enemies.push(new Actor(300, 100, 0xff0000));
			enemies.push(new Actor(320, 100, 0xff0000));
			enemies.push(new Actor(340, 100, 0xff0000));
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		public function update(e:Event = null):void {
			buffer.graphics.clear();
			buffer.graphics.beginFill(0x0000ff, 0.5);
			buffer.graphics.drawRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
			buffer.graphics.endFill();
			
			// Draw player
			player.draw(buffer.graphics);
			
			// Change player's "rotation" based on keyboard input
			if (Main.keys[0x25] || Main.keys[0x41]) player.angle -= 10;
			if (Main.keys[0x27] || Main.keys[0x44]) player.angle += 10;
			
			if (mouseButtonDown) 
			{
				var currentAngle:Number = Math.atan2(player.x - this.mouseX, player.y - this.mouseY);
				if (currentAngle < startingMovementAngle)
				{
					startingMovementAngle -= 5;
					player.angle -= 5;
				}
				else if (currentAngle > startingMovementAngle) 
				{
					startingMovementAngle += 5;
					player.angle += 5;
				}
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
			startingMovementAngle = Math.atan2(player.x - this.mouseX, player.y - this.mouseY);
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