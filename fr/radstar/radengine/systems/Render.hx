package fr.radstar.radengine.systems;
import ash.tools.ListIteratingSystem;
import fr.radstar.radengine.nodes.RenderNode;
import openfl.display.Sprite;
import openfl.Lib;

/**
 * ...
 * @author TBaudon
 */
class Render extends ListIteratingSystem<RenderNode>
{
	
	var mCanvas : Sprite;

	public function new() 
	{
		super(RenderNode, onNodeUpdate, onNodeAdded, onNodeRemoved);
		
		mCanvas = new Sprite();
		Lib.current.stage.addChild(mCanvas);
	}
	
	function onNodeRemoved(node : RenderNode) 
	{
		mCanvas.removeChild(node.view);
	}
	
	function onNodeAdded(node : RenderNode) 
	{
		mCanvas.addChild(node.view);
	}
	
	function onNodeUpdate(node : RenderNode, time : Float) 
	{
		node.view.x = node.transform.x;
		node.view.y = node.transform.y;
		node.view.rotation = node.transform.rotation;
		node.view.scaleX = node.transform.scaleX;
		node.view.scaleY = node.transform.scaleY;
	}
	
}