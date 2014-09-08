package fr.radstar.radengine.editor;
import openfl.display.Sprite;

/**
 * ...
 * @author TBaudon
 */
class ScrollPane extends GuiElem
{
	
	var mScrollRegion : Sprite;
	var mScrollMask : Sprite;
	
	var mVScroll : Float = 0;
	var mMaxVScroll : Float = 0;
	
	var mConnectedBar : Array<GuiElem>;

	public function new() 
	{
		mConnectedBar = new Array<GuiElem>();

		super();
		
		mScrollRegion = new Sprite();
		mAddTarget = mScrollRegion;
		addChild(mScrollRegion);
		mScrollMask = new Sprite();
	}
	
	override public function setDim(w:Float, h : Float) {
		mScrollMask.graphics.clear();
		mScrollMask.graphics.beginFill(0);
		mScrollMask.graphics.drawRect(0, 0, w, h);
		
		mScrollRegion.mask = mScrollMask;
		
		super.setDim(w,h);
	}
	
	override function invalidate() {
		super.invalidate();
		if(mScrollMask != null && mScrollRegion != null)
			mMaxVScroll = mScrollRegion.height - mScrollMask.height;
			
		for (item in mConnectedBar) item.invalidate();
	}	
	
	public function getVScroll() {
		return mVScroll;
	}
	
	public function getMaskHeight() {
		return mScrollMask.height;
	}
	
	public function getMaxVScroll() {
		return mMaxVScroll;
	}
	
	public function connect(elem : GuiElem) {
		if (mConnectedBar.indexOf(elem) == -1)
			mConnectedBar.push(elem);
	}
	
	public function vScroll(value : Float) {
		if (value > mMaxVScroll) value = cast mMaxVScroll;
		else if (value < 0) value = 0;
		
		mVScroll = value;
		mScrollRegion.y = -mVScroll;
		
		invalidate();
	}
	
}