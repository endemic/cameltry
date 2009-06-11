package {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.utils.ByteArray;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	public class EditorState extends Sprite {
		
		public var buffer:Sprite = new Sprite;
		public var camera_offset:Object = { x:0, y:0 }
		public const MAX_WIDTH:int = 2000, MAX_HEIGHT:int = 2000;	// Maximum size of level... for now
		public var collision_block_size:int = 100;
		public var mouse_button_down:Boolean = false;
		public var level_data:Array;
		public var display_objects:Array = new Array;
		public var show_level_data:Boolean = false;
		public var keys:Array = new Array(256);	// Stores boolean values for keypresses
		
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
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouse_clicked);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouse_released);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void { keys[e.keyCode] = true; } );
			stage.addEventListener(KeyboardEvent.KEY_UP,   function(e:KeyboardEvent):void { keys[e.keyCode] = false; } );
		}
		
		public function update(e:Event = null):void {
			// Handle camera movement
			if (keys[0x25] || keys[0x41]) camera_offset.x += 10;
	        if (keys[0x26] || keys[0x57]) camera_offset.y += 10;
	        if (keys[0x27] || keys[0x44]) camera_offset.x -= 10;
	        if (keys[0x28] || keys[0x53]) camera_offset.y -= 10;
			
			// ESC toggles showing level data string
			if(keys[0x1B])
				show_level_data = show_level_data ? false : true;
			
			if(show_level_data) {
				// Update/display a text field w/ level array info - byte array then writeObject
				var transparent_background:Sprite = new Sprite();
				transparent_background.graphics.beginFill(0x000000, 0.5);
				transparent_background.graphics.drawRect(0, 0, 640, 480);
				transparent_background.graphics.endFill();
				
				var serialized_level_string:TextField = new TextField;
				var serialized_level_data:ByteArray = new ByteArray();
				serialized_level_data.writeObject(display_objects);
				serialized_level_string.text = serialized_level_data.toString();
				transparent_background.addChild(serialized_level_string);
				addChild(transparent_background);
			}
			
			buffer.x = camera_offset.x;
			buffer.y = camera_offset.y;
			
			// Draw cursor based on mouse status
			
			// Draw objects
			
			buffer.graphics.clear();
			buffer.graphics.beginFill(0x0000ff, 0.5);
			buffer.graphics.drawRect(0, 0, MAX_WIDTH, MAX_HEIGHT);
			buffer.graphics.endFill();
			
			for each(var a:Actor in display_objects)
				a.draw(buffer.graphics);
		}
		
		public function mouse_clicked(e:MouseEvent = null):void {
			// Check to ensure only one event happens per click
			if(mouse_button_down == false) {
				mouse_button_down = true;
				
				// Check mouse status here -- decide whether to add an object, modify it (adjust width/height, rotation), or delete it
				// For now, just place objects
				// Place object at rounded cursor position
				var collision_block_x:int = Math.floor((stage.mouseX - camera_offset.x) / collision_block_size);
				var collision_block_y:int = Math.floor((stage.mouseY - camera_offset.y) / collision_block_size);
				var a:Actor = new Actor(stage.mouseX - camera_offset.x, stage.mouseY - camera_offset.y, 0x00ff00);
				// do we even need to do this? 
				level_data[collision_block_x][collision_block_y].push(a);
				display_objects.push(a);
			}
		}
		
		public function mouse_released(e:MouseEvent = null):void {
			// Reset "clicked" flag
			mouse_button_down = false;
		}
	}
}