package fr.radstar.radengine.editor;
import flash.events.Event;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.Lib;

/**
 * ...
 * @author TBaudon
 */
class VScrollBar extends GuiElem
{
	
	var mScrollPane : ScrollPane;
	
	var mScrollBar : Sprite;
	var mDown : Bool;
	
	var mPrevY : Float;

	public function new() 
	{
		super();
		
		mScrollBar = new Sprite();
		addChild(mScrollBar);
		
		mDown = false;
		
		mScrollBar.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
	}
	
	private function onUp(e:Event):Void 
	{
		mDown = false;
	}
	
	private function onMove(e:MouseEvent):Void 
	{
		if (mDown) {
			var coef : Float = (mHeight - 30) / mScrollPane.getMaxVScroll();
			var scrollAmount = (e.stageY - mPrevY) / coef;
			var newScroll = mScrollPane.getVScroll() + scrollAmount;
			mScrollPane.vScroll(newScroll);
			mPrevY = e.stageY;
		}
	}
	
	private function onDown(e:MouseEvent):Void 
	{
		mDown = true;
		mPrevY = e.stageY;
	}
	
	public function connect(scrollPane : ScrollPane) {
		mScrollPane = scrollPane;
		
		setDim(20, cast mScrollPane.getMaskHeight());
		x = mScrollPane.x + mScrollPane.width + 3;
		y = mScrollPane.y;
		
		mScrollPane.connect(this);
	}
	
	override public function draw() {
		if (mScrollPane != null) {
			graphics.clear();
			graphics.beginFill(mStyle.borderColor);
			graphics.lineStyle(mStyle.border, mStyle.backgroundColor);
			graphics.drawRoundRect(0, 0, mWidth, mHeight, mStyle.borderRadius, mStyle.borderRadius);
			
			var coef : Float = (mHeight - 30) / mScrollPane.getMaxVScroll();
			var barY : Float = coef * mScrollPane.getVScroll() + 15;
			
			mScrollBar.graphics.clear();
			mScrollBar.graphics.beginFill(mStyle.backgroundColor);
			mScrollBar.graphics.lineStyle(mStyle.border, mStyle.borderColor);
			mScrollBar.graphics.drawRoundRect(0, barY - 15, mWidth, 30, mStyle.borderRadius, mStyle.borderRadius);
		}
		
		super.draw();
	}
	
}