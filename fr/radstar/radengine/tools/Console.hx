package fr.radstar.radengine.tools;

import ash.core.Engine;
import fr.radstar.radengine.RadGame;
import hscript.Parser;
import hscript.Expr;
import hscript.Interp;
import openfl.Assets;
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
	
	var mAst : Expr;
	var mInterp : Interp;
	var mParser : Parser;

	public function new(game : RadGame, engine : Engine) 
	{
		super();
		
		mGame = game;
		mEngine = engine;
		initInput();
		initInterp();
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		mVisible = false;
	}
	
	function initInterp() 
	{
		mParser = new Parser();
		mParser.allowJSON = true;
		mParser.allowTypes = true;
		
		mInterp = new Interp();
		mInterp.variables.set('engine', mEngine);
		mInterp.variables.set('game', mGame);
	}
	
	private function onKeyDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.TAB && e.ctrlKey) {
			
			drawBg();
			
			mVisible = !mVisible;
			
			if (mVisible)
				Lib.current.stage.addChild(this);
			else
				Lib.current.stage.removeChild(this);
		}else if (e.keyCode == Keyboard.ENTER && mVisible) {
			e.stopImmediatePropagation();
			
			try {
				var command = mInput.text.substr(2) ;
				mAst = mParser.parseString(command);
				mInterp.execute(mAst);
				mInput.text = "=>";
			}catch (e : Error) {
				trace(e.getName());
			}
		}
	}
	
	function drawBg():Void 
	{
		var w = Lib.current.stage.stageWidth;
		
		graphics.clear();
		graphics.lineStyle(1, 0x00cc00);
		graphics.beginFill(0x000000, 0.5);
		graphics.drawRect(0, 0, w, 150);
	}
	
	function initInput():Void 
	{
		mInput = new TextField();
		mInput.defaultTextFormat = new TextFormat('arial', 12, 0x00cc00);
		mInput.multiline = false;
		mInput.type = TextFieldType.INPUT;
		mInput.autoSize = TextFieldAutoSize.LEFT;
		mInput.text = "=>";
		addChild(mInput);
		mInput.y = 150 - mInput.height;
	}
	
}