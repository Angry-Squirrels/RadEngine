package fr.radstar.radengine.editor;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
 * ...
 * @author TBaudon
 */
class Label extends GuiElem
{
	
	var mTextField : TextField;
	var mText : String;
	
	public function new(text : String) 
	{
		super();
		mTextField = new TextField();
		mTextField.selectable = false;
		mTextField.wordWrap = true;
		mTextField.defaultTextFormat = new TextFormat(mStyle.fontFamily, mStyle.fontSize, mStyle.fontColor);
		mTextField.autoSize = TextFieldAutoSize.LEFT;
		setText(text);
		addChild(mTextField);
	}
	
	public function setText(text : String) {
		mText = text;
		mTextField.text = text;
		
		invalidate();
	}
	
	public function getText() : String {
		return mText;
	}
	
	override function draw() {
		
		if(mWidth != 0 && mHeight != 0)
		{
			mTextField.width = mWidth;
			mTextField.height = mHeight;
		}
		
		addChild(mTextField);
		
		super.draw();
	}
	
}