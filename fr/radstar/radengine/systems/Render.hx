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
class Render extends ListIteratingSystem<RenderNode> implements RadSystem
{
	
	var mCanvas : Sprite;
	
	var mViewEntityMap : Map<View, Entity>;
	var mEditMode : Bool;

	public function new() 
	{
		super(RenderNode, onNodeUpdate, onNodeAdded, onNodeRemoved);
		
		mCanvas = new Sprite();
		Lib.current.stage.addChild(mCanvas);
		
		mViewEntityMap = new Map<View, Entity>();
		mEditMode = false;
	}
	
	/* INTERFACE fr.radstar.radengine.systems.RadSystem */
	
	public function enterEditMode() 
	{
		mEditMode = true;
		for (node in nodeList) {
			var current : RenderNode = node;
			mViewEntityMap[current.view] = current.entity;
			current.view.addEventListener(MouseEvent.CLICK, onClick);
		}
	}
	
	public function leaveEditMode() 
	{
		mEditMode = false;
		for (node in nodeList) {
			var current : RenderNode = node;
			mViewEntityMap.remove(current.view);
			current.view.removeEventListener(MouseEvent.CLICK, onClick);
		}
	}
	
	private function onClick(e:Event):Void 
	{
		var view = e.currentTarget;
		var entity = mViewEntityMap[view];
		RadGame.instance.selectEntity(entity);
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