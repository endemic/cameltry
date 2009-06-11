package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class MenuState extends GameState {
		public var play_button:TextField = new TextField;
		public var edit_button:TextField = new TextField;
		
		public function MenuState():void {
			var format:TextFormat = new TextFormat();
            format.font = "_typewriter";
            format.color = 0xFF0000;
            format.size = 20;

			play_button.defaultTextFormat = format; 
			edit_button.defaultTextFormat = format; 
			
			play_button.x = (640 - play_button.width) / 2;
			play_button.y = 100;
			
			edit_button.x = (640 - edit_button.width) / 2;
			edit_button.y = 300;
			
			play_button.text = "PLAY";
			edit_button.text = "EDIT";
			
			edit_button.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { Main.changeState(EditorState) });
			play_button.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { Main.changeState(PlayState) });
			
			addChild(edit_button);
			addChild(play_button);
		}
		
		public override function destroy():void {
			removeChild(play_button);
			removeChild(edit_button);
			edit_button.removeEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { Main.changeState(EditorState) });
			play_button.removeEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { Main.changeState(PlayState) });
		}
	}
	
}