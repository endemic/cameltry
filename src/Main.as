package {
	import flash.display.Sprite;
	
	[SWF(frameRate='30',width='640',height='480',backgroundColor='0xffffff')]
	
	public class Main extends Sprite {
		
		static public var main:Object;
		public var state:*;
		public const SCREEN_WIDTH:int = 640, SCREEN_HEIGHT:int = 480;
		
		public function Main():void {
			main = this;
			
			state = new MenuState;
			addChild(state);
		}
		
	}
	
}