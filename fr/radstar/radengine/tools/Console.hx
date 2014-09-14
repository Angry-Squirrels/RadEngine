package fr.radstar.radengine.tools;

import ash.core.Engine;
import fr.radstar.radengine.command.Commander;
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
class Console
{
	var mVisible : Bool;
	var mGame : RadGame;
	var mEngine : Engine;
	
	var mInput : TextField;
	
	var mCommander : Commander;
	
	var mCommands : Map<String, {target : Dynamic, method : Dynamic}>;
	
	var mCommandHistoy : Array<String>;
	var mHistoryPos : Int;

	public function new(game : RadGame, engine : Engine) 
	{
		mGame = game;
		mEngine = engine;
		mCommandHistoy = new Array<String>();
		mHistoryPos = 0;
		initInput();
		
		mCommands = new Map<String, {target : Dynamic, method : Dynamic}>();
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(Event.RESIZE, updateSize);
		
		mVisible = false;
	}
	
	public function setCommander(commander : Commander) {
		mCommander = commander;
	}
	
	public function getInput() : TextField {
		return mInput;
	}
	
	public function addCommad(object : Dynamic, func : Dynamic, alias : String) {
		mCommands[alias] = {target : object, method : func};
	}
	
	public function toggleVisibility() : Bool {
		mVisible = !mVisible; 
		
		if (mVisible) {
			//RadGame.instance.getEditorLayer().addChild(mInput);
			updateSize();
			Lib.current.stage.focus = mInput;
		}
		//else
			//RadGame.instance.getEditorLayer().removeChild(mInput);
			
		return mVisible;
	}
	
	function updateSize(e : Event = null) {
		mInput.width = Lib.current.stage.stageWidth;
		mInput.height = 20;
		mInput.y = Lib.current.stage.stageHeight - mInput.height;
	}
	
	function onKeyDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.ENTER && mVisible) {
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
					var o = mCommands[name].target;
					var f = mCommands[name].method;
					Reflect.callMethod(o, f, paramToApply);
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
		//addChild(mInput);
	}
	
}