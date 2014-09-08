package fr.radstar.radengine.systems;
import ash.tools.ListIteratingSystem;
import ash.core.Entity;
import flash.events.Event;
import fr.radstar.radengine.nodes.RenderNode;
import fr.radstar.radengine.components.View;

import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.Lib;

/**
 * ...
 * @author TBaudon
 */
class Render extends ListIteratingSystem<RenderNode> 
#if debug
implements RadSystem
#end
{
	
	var mCanvas : Sprite;
	
	var mNodeMap : Map<RenderNode, Sprite>;
	var mViewMap : Map<Sprite, RenderNode>;
	var mEditMode : Bool;

	public function new() 
	{
		super(RenderNode, onNodeUpdate, onNodeAdded, onNodeRemoved);
		
		mCanvas = new Sprite();
		Lib.current.stage.addChild(mCanvas);
		
		mNodeMap = new Map<RenderNode, Sprite>();
		mViewMap = new Map<Sprite, RenderNode>();
		mEditMode = false;
	}
	
	/* INTERFACE fr.radstar.radengine.systems.RadSystem */
	#if debug
	public function enterEditMode() 
	{
		mEditMode = true;
		for (node in nodeList) {
			var current : RenderNode = node;
			mNodeMap[current].addEventListener(MouseEvent.CLICK, onClick);
			current.view.setView(mNodeMap[current]);
		}
	}
	
	public function leaveEditMode() 
	{
		mEditMode = false;
		for (node in nodeList) {
			var current : RenderNode = node;
			mNodeMap[current].removeEventListener(MouseEvent.CLICK, onClick);
		}
	}
	
	private function onClick(e:Event):Void 
	{
		var view = e.currentTarget;
		var entity = mViewMap[view].entity;
		RadGame.instance.selectEntity(entity);
	}
	#end
	
	function onNodeRemoved(node : RenderNode) 
	{
		mCanvas.removeChild(mNodeMap[node]);
	}
	
	function onNodeAdded(node : RenderNode) 
	{
		var view = new Sprite();
		view.graphics.beginFill(0xff0000);
		view.graphics.drawCircle(0, 0, 50);
		mCanvas.addChild(view);
		mNodeMap[node] = view;
		mViewMap[view] = node;
	}
	
	function onNodeUpdate(node : RenderNode, time : Float) 
	{
		var view = mNodeMap[node];
		view.x = node.transform.x;
		view.y = node.transform.y;
		view.rotation = node.transform.rotation;
		view.scaleX = node.transform.scaleX;
		view.scaleY = node.transform.scaleY;
	}
	
}