package fr.radstar.radengine.editor;
import fr.radstar.radengine.core.RadAsset;
import fr.radstar.radengine.editor.command.ChangeText;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.events.UIEvent;
import openfl.events.Event;
import openfl.Lib;

/**
 * ...
 * @author Thomas BAUDON
 */
class DefaultEditor extends AssetEditor
{
	
	var mTextEditor : TextInput;
	
	var mLastTimeChanged : UInt;
	var mChangePushed : Bool;
	
	var mPreviousText : String;

	public function new() 
	{
		super();
		
		mLastTimeChanged = Lib.getTimer();
		
		mTextEditor = new TextInput();
		mTextEditor.percentWidth = 100;
		mTextEditor.percentHeight = 100;
		mTextEditor.multiline = true;
		
		mChangePushed = false;
		
		mTextEditor.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		mTextEditor.addEventListener(UIEvent.CHANGE, onTextChanged);
		
		addChild(mTextEditor);
	}
	
	function onTextChanged(e:UIEvent):Void 
	{
		mLastTimeChanged = Lib.getTimer();
		mChangePushed = false;
	}
	
	function onEnterFrame(e:Event):Void 
	{
		var time : UInt = Lib.getTimer();
		var timeUnchanged : UInt = time - mLastTimeChanged;
		if (timeUnchanged > 500 && !mChangePushed) {
			mHistory.push(new ChangeText(mPreviousText, mTextEditor.text, mTextEditor));
			mChangePushed = true;
			mPreviousText = mTextEditor.text;
		}
	}
	
	override public function load(asset:RadAsset) 
	{
		super.load(asset);
			
		var text = mAsset.getContent();
		text = StringTools.replace(text, '\t', '    ');
		mTextEditor.text = text;
		mPreviousText = mTextEditor.text;
	}
	
	override public function save() {
		mAsset.content = mTextEditor.text;
		mAsset.save();
	}
	
}