package fr.radstar.radengine.tools;

import ash.core.Engine;
import fr.radstar.radengine.RadGame;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Thomas B
 */
class Console extends Sprite
{
	var mVisible : Bool;
	var mGame : RadGame;
	var mEngine : Engine;
	
	var mInput : TextField;
	
	var mCommands : Map<String, Dynamic>;
	
	var mCommandHistoy : Array<String>;
	var mHistoryPos : Int;

	public function new(game : RadGame, engine : Engine) 
	{
		super();
		
		mGame = game;
		mEngine = engine;
		mCommandHistoy = new Array<String>();
		mHistoryPos = 0;
		initInput();
		
		mCommands = new Map<String, Dynamic>();
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(Event.RESIZE, updateSize);
		
		mVisible = false;
	}
	
	public function addCommad(object : Dynamic, name : String) {
		mCommands[name] = object;
	}
	
	function updateSize(e : Event = null) {
		mInput.width = Lib.current.stage.stageWidth;
		mInput.height = 20;
		mInput.y = Lib.current.stage.stageHeight - mInput.height;
	}
	
	function onKeyDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.D && e.ctrlKey && e.altKey) {
			
			e.stopImmediatePropagation();
			
			mVisible = !mVisible;
			
			if (mVisible){
				Lib.current.stage.addChild(this);
				Lib.current.stage.focus = mInput;
				updateSize();
			}
			else
				Lib.current.stage.removeChild(this);
		}else if (e.keyCode == Keyboard.ENTER && mVisible) {
			e.stopImmediatePropagation();
			
			var command = mInput.text;
			var name = command.split(' ')[0];
			var params : Array<String> = command.split(' ');
			params.shift();
			
			var paramToApply = new Array<Dynamic>();
			
			for (i in 0 ... params.length) {
				if (params[i] == 'false')
					paramToApply.push(false);
				else if (params[i] == 'true')
					paramToApply.push(true);
				else
					paramToApply.push(params[i]);
			}
			
			if (mCommands[name] != null) {
				try{
					var o = mCommands[name];
					Reflect.callMethod(o, Reflect.field(o, name), paramToApply);
					mCommandHistoy.push(command);
					mHistoryPos = mCommandHistoy.length - 1;
				}catch (e : Dynamic) {
					trace(e);
				}
			}else {
				trace("No such command");
			}
			mInput.text = "";
		}else if (e.keyCode == Keyboard.UP && mVisible) {
			e.stopImmediatePropagation();
			
			if (mCommandHistoy.length > 0) { 
				mHistoryPos--;
				if (mHistoryPos < 0)
					mHistoryPos = mCommandHistoy.length - 1;
				mInput.text = mCommandHistoy[mHistoryPos];
			}
			
		}
	}
	
	function initInput():Void 
	{
		mInput = new TextField();
		mInput.defaultTextFormat = new TextFormat('arial', 14, 0x00cc00, true);
		mInput.multiline = false;
		mInput.type = TextFieldType.INPUT;
		mInput.background = true;
		mInput.backgroundColor = 0x000000;
		mInput.border = true;
		mInput.borderColor = 0x00ff00;
		mInput.alpha = 0.8;
		updateSize();
		addChild(mInput);
	}
	
}