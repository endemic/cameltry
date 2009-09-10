package {
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	[SWF(frameRate='30',width='640',height='480',backgroundColor='0xffffff')]
	
	public class Main extends Sprite {
		
		static public var main:Object;
		static public var currentState:GameState;
		static public var buffer:BitmapData;
		static public const SCREEN_WIDTH:int = 640, SCREEN_HEIGHT:int = 480;
		static public var keys:Array = new Array(256);	// Stores boolean values for keypresses
		static public var mouse:Point = new Point;
		static public var mouseClick:int = 0;
		
		// Stuff for hand cursor
		static public var cursor:Sprite = new Sprite;
		[Embed(source = "../images/hand-icon-open.png")] public var HandIconOpen:Class;
		[Embed(source = "../images/hand-icon-closed.png")] public var HandIconClosed:Class;
		
		public function Main():void {
			main = this;
			
			Mouse.hide();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void { keys[e.keyCode] = true; } );
			stage.addEventListener(KeyboardEvent.KEY_UP,   function(e:KeyboardEvent):void { keys[e.keyCode] = false; } );
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			addEventListener(Event.ENTER_FRAME, update);
			
			cursor.addChild(new HandIconOpen);
			cursor.addChild(new HandIconClosed);
			cursor.getChildAt(1).visible = false;
			addChild(cursor);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function (e:MouseEvent):void { cursor.visible = true;  cursor.x = e.stageX; cursor.y = e.stageY; } );
			stage.addEventListener(Event.MOUSE_LEAVE, function (e:Event):void { cursor.visible = false; } );
			
			// Change to inital game state
			changeState(PlayState);
		}
		
		private function update(e:Event):void 
		{
			mouse.x = stage.mouseX;
			mouse.y = stage.mouseY;
		}
		
		private function mouseDown(e:MouseEvent):void
		{
			if (mouseClick > 0) mouseClick = 2;
			else mouseClick = 1;
		}
		
		private function mouseUp(e:MouseEvent):void 
		{
			mouseClick = 0;
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
		
		static public function changeState(state:Class):void {
			var newState:GameState = new state;
			main.addChild(newState);
			if(currentState != null) {
				main.swapChildren(newState, currentState);
				main.removeChild(currentState);
				currentState.destroy();
			}
			currentState = newState;
		}
		
		
		
	}
	
}