package fr.radstar.radengine.tools;

import ash.core.Engine;
import fr.radstar.radengine.RadGame;
import openfl.display.Sprite;
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

	public function new(game : RadGame, engine : Engine) 
	{
		super();
		
		mGame = game;
		mEngine = engine;
		initInput();
		
		mCommands = new Map<String, Dynamic>();
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		mVisible = false;
	}
	
	public function addCommad(object : Dynamic, name : String) {
		mCommands[name] = object;
	}
	
	function onKeyDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.TAB && e.ctrlKey) {
			
			mVisible = !mVisible;
			
			if (mVisible)
				Lib.current.stage.addChild(this);
			else
				Lib.current.stage.removeChild(this);
		}else if (e.keyCode == Keyboard.ENTER && mVisible) {
			e.stopImmediatePropagation();
			
			var command = mInput.text.substr(2);
			var name = command.split(' ')[0];
			var params : Array<Dynamic> = command.split(' ');
			params.shift();
			
			for (i in 0 ... params.length) {
				if (params[i] == 'false')
					params[i] = false;
				else if (params[i] == 'true')
					params[i] = true;
			}
			
			if (mCommands[name] != null) {
				try{
					var o = mCommands[name];
					Reflect.callMethod(o, Reflect.field(o, name), params);
					mInput.text = '=>';
				}catch (e : Dynamic) {
					trace(e);
				}
			}
		}
		
		if (mInput.text.length < 2 || (mInput.text.length == 2 && mInput.text != "=>"))
			mInput.text = "=>";
	}
	
	function initInput():Void 
	{
		mInput = new TextField();
		mInput.defaultTextFormat = new TextFormat('arial', 14, 0x00cc00, true);
		mInput.multiline = false;
		mInput.type = TextFieldType.INPUT;
		mInput.text = "=>";
		mInput.width = Lib.current.stage.stageWidth;
		mInput.height = 20;
		mInput.background = true;
		mInput.backgroundColor = 0x000000;
		mInput.border = true;
		mInput.borderColor = 0x00ff00;
		mInput.alpha = 0.8;
		addChild(mInput);
		mInput.y = Lib.current.stage.stageHeight - mInput.height;
	}
	
}