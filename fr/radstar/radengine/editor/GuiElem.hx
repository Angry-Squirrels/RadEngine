package fr.radstar.radengine.editor;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * ...
 * @author TBaudon
 */
class GuiElem extends Sprite
{
	
	var mChildren : Array<GuiElem>;
	var mWidth : Float = 0;
	var mHeight : Float = 0;
	
	var mPaddingTop : Int = 0;
	var mPaddingLeft : Int = 0;
	var mPaddingDown : Int = 0;
	var mPaddingRight : Int = 0;
	
	var mStyle : ElemStyle;
	
	var mAddTarget : Sprite;
	
	var mNeedRedraw : Bool;
	
	public function new() 
	{
		super();
		
		mStyle = new ElemStyle();
		mChildren = new Array<GuiElem>();
		mAddTarget = this;
		
		invalidate();
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	public function add(elem : GuiElem) {
		mChildren.push(elem);
		mAddTarget.addChild(elem);
		
		if (mWidth == 0 || mHeight == 0) {
			var w = elem.width + mStyle.padding.left + mStyle.padding.right;
			var h = elem.height + mStyle.padding.top + mStyle.padding.bottom;
			setDim(w, h);
		}
		
		invalidate();
	}
	
	public function remove(elem : GuiElem) {
		mChildren.remove(elem);
		mAddTarget.removeChild(elem);
		
		invalidate();
	}
	
	public function setDim(width : Float, height : Float) {
		mWidth = width;
		mHeight = height;
		
		invalidate();
	}
	
	public function invalidate() {
		mNeedRedraw = true;
	}
	
	function draw() {
		if (parent == null) return;
		for (child in mChildren)
			child.draw();
		mNeedRedraw = false;
	}
	
	function onEnterFrame(e : Event) {
		if (mNeedRedraw) draw();
	}
	
}