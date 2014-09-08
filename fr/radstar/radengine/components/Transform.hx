package fr.radstar.radengine.components;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.Lib;

/**
 * ...
 * @author TBaudon
 */
class Transform 
#if debug
implements RadComp
#end
{

	public var x : Float = 0;
	public var y : Float = 0;
	
	public var rotation : Float = 0;
	
	public var scaleX : Float = 1;
	public var scaleY : Float = 1;
	
	/* INTERFACE fr.radstar.radengine.components.RadComp */
	
	#if debug
	
	var mGizmo : Sprite;
	var mDown : Bool;
	
	public function edit() 
	{
		if (mGizmo == null) initEdit();
		
		mGizmo.x = x;
		mGizmo.y = y;
		
		Lib.current.stage.addChild(mGizmo);
	}
	
	public function unEdit():Void 
	{
		Lib.current.stage.removeChild(mGizmo);
	}
	
	function initEdit() {
		mGizmo = new Sprite();
		
		mDown = false;
			
		mGizmo.graphics.clear();
		mGizmo.graphics.beginFill(0x00ff00,0.5);
		mGizmo.graphics.lineStyle(1, 0x00ff00);
		mGizmo.graphics.drawRect(0, -20, 20, 20);
		mGizmo.graphics.endFill();
		mGizmo.graphics.lineStyle(3, 0xcccc00);
		mGizmo.graphics.moveTo(0, 0);
		mGizmo.graphics.lineTo(0, -30);
		mGizmo.graphics.lineStyle(3, 0x0000cc);
		mGizmo.graphics.moveTo(0, 0);
		mGizmo.graphics.lineTo(30, 0);
		
		mGizmo.addEventListener(MouseEvent.MOUSE_DOWN, onMDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMUp);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMMove);
	}
	
	function onMMove(e:MouseEvent):Void 
	{
		if (mDown) {
			x = e.stageX;
			y = e.stageY;
			
			mGizmo.x = x;
			mGizmo.y = y;
		}
	}
	
	function onMUp(e:Event):Void 
	{
		mDown = false;
	}
	
	function onMDown(e:Event):Void 
	{
		mDown = true;
	}
	#end
}