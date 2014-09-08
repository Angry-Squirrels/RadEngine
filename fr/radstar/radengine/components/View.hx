package fr.radstar.radengine.components;
import openfl.display.Sprite;
import openfl.Lib;

/**
 * ...
 * @author TBaudon
 */
class View  
#if debug
implements RadComp
#end
{
	
	public var pivotX : Int;
	public var pivotY : Int;
	public var view : String;

	public function new() 
	{
		pivotX = 50;
		pivotY = 50;
		view = "default";
	}
	
	/* INTERFACE fr.radstar.radengine.components.RadComp */
	
	#if debug
	
	var mBox : Sprite;
	var mView : Sprite;
	
	public function edit() 
	{
		if(mBox == null)
			mBox = new Sprite();
		mView.addChild(mBox);
		
		mBox.graphics.clear();
		mBox.graphics.lineStyle(2, 0xcccccc);
		mBox.graphics.drawRect(-pivotX, -pivotY, mView.width, mView.height);
	}
	
	public function unEdit():Void 
	{
		mView.removeChild(mBox);
	}
	
	public function setView(sprite : Sprite) {
		mView = sprite;
	}
	#end
}