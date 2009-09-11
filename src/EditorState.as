package {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	public class EditorState extends GameState {
		
		public var buffer:Sprite = new Sprite;
		public var camera_offset:Object = { x:0, y:0 }
		public const MAX_WIDTH:int = 2000, MAX_HEIGHT:int = 2000;	// Maximum size of level... for now
		public var collision_block_size:int = 100;
		public var mouse_button_down:Boolean = false;
		public var level_data:Array;
		public var display_objects:Array = new Array;
		public var show_level_data:Boolean = false;
		
		// Update/display a text field w/ level array info - byte array then writeObject
		private var overlay:Sprite = new Sprite();
		private var levelXML:TextField = new TextField;
		private var serialized_level_data:ByteArray = new ByteArray();
		
		public function EditorState():void {
			
			addChild(buffer);
			
			// Init level_data array
			level_data = new Array(MAX_WIDTH / collision_block_size);
			for(var i:int = 0; i < level_data.length; i++) {
				level_data[i] = new Array(MAX_HEIGHT / collision_block_size);
				for(var j:int = 0; j < level_data[i].length; j++)
					level_data[i][j] = new Array;
			}
			
			// Set up event listeners
			addEventListener(Event.ENTER_FRAME, update);
			
			// Set up "console" sprite to display level data
			overlay.graphics.beginFill(0x000000, 0.5);
			overlay.graphics.drawRect(0, 0, 640, 480);
			overlay.graphics.endFill();
			
			levelXML.width = Main.SCREEN_WIDTH;
			levelXML.height = Main.SCREEN_HEIGHT;
			levelXML.selectable = true;
			levelXML.wordWrap = true;
			levelXML.defaultTextFormat = new TextFormat('_typewriter', 8, 0xffffff);
			
			overlay.addChild(levelXML);
			addChild(overlay);
		}
		
		public function update(e:Event = null):void {
			// Reset buffer
			buffer.graphics.clear();
			
			// Box showing level boundaries
			buffer.graphics.beginFill(0x0000ff, 0.5);
			buffer.graphics.drawRect(0, 0, MAX_WIDTH, MAX_HEIGHT);
			buffer.graphics.endFill();
			
			// Handle camera movement
			if (Main.keys[0x25] || Main.keys[0x41]) camera_offset.x += 10;
	        if (Main.keys[0x26] || Main.keys[0x57]) camera_offset.y += 10;
	        if (Main.keys[0x27] || Main.keys[0x44]) camera_offset.x -= 10;
	        if (Main.keys[0x28] || Main.keys[0x53]) camera_offset.y -= 10;
			
			// ESC toggles showing level data string
			if (Main.keys[0x1B]) 
				show_level_data = show_level_data ? false : true;
				
			overlay.visible = false;
			if (show_level_data) 
			{
				//serialized_level_data.writeObject(display_objects);
				//levelXML.text = serialized_level_data.toString();
				overlay.visible = true;
				Mouse.show();
				levelXML.text = "<level>";
				for each (var a:Actor in display_objects) 
					levelXML.appendText("<object><x>" + String(a.x) + "</x><y>" + String(a.y) + "</y></object>");
				levelXML.appendText("</level>");
			}
			else 
			{
				// Draw cursor based on mouse status
				Mouse.hide();
				buffer.graphics.lineStyle(2, 0xff0000);
				buffer.graphics.drawRect(Main.mouse.x - 10, Main.mouse.y - 10, 20, 20);
			}
			
			// Move buffer based on camera offset
			buffer.x = camera_offset.x;
			buffer.y = camera_offset.y;
			
			// Draw objects
			for each(a in display_objects)
				a.draw(buffer.graphics);
				
			if (Main.mouseClick == 2 && !overlay.visible) 
			{
				// Check mouse status here -- decide whether to add an object, modify it (adjust width/height, rotation), or delete it
				// For now, just place objects
				// Place object at rounded cursor position
				
				
				for (var i:int = 0; i < display_objects.length; i++)
					if (Main.mouse.x > a.x - (a.w / 2) && Main.mouse.x < a.x + (a.w / 2) && Main.mouse.y > a.y - (a.h / 2) && Main.mouse.y < a.y + (a.h / 2)) 
					{
						display_objects.splice(i, 1);
						var deletedObject:Boolean = true;
					}
				
				if (!deletedObject)
				{
				//var collision_block_x:int = Math.floor((Main.mouse.x - camera_offset.x) / collision_block_size);
				//var collision_block_y:int = Math.floor((Main.mouse.y - camera_offset.y) / collision_block_size);
				a = new Actor(Main.mouse.x - camera_offset.x, Main.mouse.y - camera_offset.y, 0x00ff00);
				// Push objects into the broad phase collision array within the game itself, not the editor 
				//level_data[collision_block_x][collision_block_y].push(a);
				display_objects.push(a);
				}
			}
		}

		public override function destroy():void {
			removeChild(buffer);
			removeEventListener(Event.ENTER_FRAME, update);
		}
	}
}