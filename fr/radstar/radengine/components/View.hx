package fr.radstar.radengine.components;
import openfl.display.Sprite;

/**
 * ...
 * @author TBaudon
 */
class View extends Sprite 
#if debug
implements RadComp
#end
{
	
	public var pivotX : Int;
	public var pivotY : Int;

	public function new() 
	{
		super();
		
		graphics.beginFill(0xff0000);
		graphics.drawCircle(0, 0, 50);
		
		pivotX = 50;
		pivotY = 50;
	}
	
	/* INTERFACE fr.radstar.radengine.components.RadComp */
	
	#if debug
	
	var mBox : Sprite;
	
	public function edit() 
	{
		if(mBox == null)
			mBox = new Sprite();
		addChild(mBox);
		
		mBox.graphics.clear();
		mBox.graphics.lineStyle(2, 0xcccccc);
		mBox.graphics.drawRect(-pivotX, -pivotY, width, height);
	}
	
	public function unEdit():Void 
	{
		removeChild(mBox);
	}
	#end
}