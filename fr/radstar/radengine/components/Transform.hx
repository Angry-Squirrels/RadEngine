package fr.radstar.radengine.components;

/**
 * ...
 * @author TBaudon
 */
class Transform implements RadComp
{

	public var x : Float = 0;
	public var y : Float = 0;
	
	public var rotation : Float = 0;
	
	public var scaleX : Float = 1;
	public var scaleY : Float = 1;
	
	/* INTERFACE fr.radstar.radengine.components.RadComp */
	
	public function edit() 
	{
	}
	
	public function unEdit():Void 
	{
		
	}
	
}