package fr.radstar.radengine.systems;
import ash.tools.ListIteratingSystem;
import fr.radstar.radengine.nodes.PhysicNode;
import openfl.Lib;

/**
 * ...
 * @author Thomas B
 */
class PhysicSys extends ListIteratingSystem<PhysicNode>
#if debug
implements RadSystem
#end
{
	
	var mPause : Bool;

	public function new() 
	{
		super(PhysicNode, onNodeUpdate, onNodeAdded, onNodeRemoved);
		mPause = false;
	}
	
	#if debug
	/* INTERFACE fr.radstar.radengine.systems.RadSystem */
	
	public function enterEditMode():Void 
	{
		
	}
	
	public function leaveEditMode():Void 
	{
		
	}
	#end
	
	public function shouldStop() : Bool {
		return true;
	}
	
	/* INTERFACE fr.radstar.radengine.systems.RadSystem */
	
	public function pause():Void 
	{
		mPause = true;
	}
	
	public function resume():Void 
	{
		mPause = false;
	}
	
	function onNodeRemoved(node : PhysicNode) 
	{
		
	}
	
	function onNodeAdded(node : PhysicNode) 
	{
		
	}
	
	override function update(time : Float) {
		if (mPause) return;
		
		super.update(time);
	}
	
	function onNodeUpdate(node : PhysicNode, delta : Float) 
	{
		if (!node.physic.isStatic) {
			node.physic.vitY += 5;
			
			node.transform.x += node.physic.vitX;
			node.transform.y += node.physic.vitY;
			
			if (node.transform.y >= Lib.current.stage.stageHeight) {
				node.transform.y = Lib.current.stage.stageHeight;
				node.physic.vitY *= - node.physic.elasticity;
			}
		}
	}
	
	
}