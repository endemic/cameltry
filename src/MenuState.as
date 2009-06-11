package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class MenuState extends Sprite {
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
			
			edit_button.addEventListener(MouseEvent.CLICK, switch_to_edit_state);
			play_button.addEventListener(MouseEvent.CLICK, switch_to_game_state);
			
			addChild(edit_button);
			addChild(play_button);
		}
		
		public function destroy():void {
			removeChild(play_button);
			removeChild(edit_button);
			edit_button.removeEventListener(MouseEvent.CLICK, switch_to_edit_state);
			play_button.removeEventListener(MouseEvent.CLICK, switch_to_game_state);
		}
		
		public function switch_to_game_state(e:MouseEvent = null):void {
			destroy();
			this.parent.addChild(new GameState);
			this.parent.removeChild(this);
		}
		
		public function switch_to_edit_state(e:MouseEvent = null):void {
			destroy();
			this.parent.addChild(new EditorState);
			this.parent.removeChild(this);
		}
	}
	
}