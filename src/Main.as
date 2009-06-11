package {
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	
	[SWF(frameRate='30',width='640',height='480',backgroundColor='0xffffff')]
	
	public class Main extends Sprite {
		
		static public var main:Object;
		static public var currentState:GameState;
		static public var buffer:BitmapData;
		static public const SCREEN_WIDTH:int = 640, SCREEN_HEIGHT:int = 480;
		static public var keys:Array = new Array(256);	// Stores boolean values for keypresses
		
		public function Main():void {
			main = this;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void { keys[e.keyCode] = true; } );
			stage.addEventListener(KeyboardEvent.KEY_UP,   function(e:KeyboardEvent):void { keys[e.keyCode] = false; } );
			
			// Change to inital game state
			changeState(MenuState);
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