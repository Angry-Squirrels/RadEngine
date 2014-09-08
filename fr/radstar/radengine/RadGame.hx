package fr.radstar.radengine;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.System;
import fr.radstar.radengine.components.RadComp;
import fr.radstar.radengine.systems.RadSystem;
import fr.radstar.radengine.tools.Console;
import haxe.Json;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

/**
 * ...
 * @author TBaudon
 */
class RadGame extends Sprite
{
	
	var mCurrentScene : Scene;
	var mLastTime : Int;
	var mEngine : Engine;
	var mEditMode : Bool;
	var mSelectedEntity : Entity;
	var mStop : Bool;
	
	public static var instance : RadGame;

	public function new(firstScene : String) 
	{
		super();
		
		instance = this;
		
		mStop = false;
		
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		mLastTime = Lib.getTimer();
		
		mEngine = new Engine();
		
		loadScene(firstScene);
		
		#if debug
		initDebugTools();
		#end
	}
	
	#if debug
	function initDebugTools() 
	{
		var console = new Console(this, mEngine);
		console.addCommad(this, loadScene, 'load');
		console.addCommad(this, editMode, 'edit');
		console.addCommad(this, selectEntityByName, 'select');
		console.addCommad(this, saveScene, 'save');
		console.addCommad(this, createEntity, 'create');
		console.addCommad(this, addComponent, 'add');
		console.addCommad(this, createScene, 'createScene');
		console.addCommad(this, addSystem, 'addSystem');
		console.addCommad(this, editComp, 'editComp');
		console.addCommad(this, stop, 'stop');
		console.addCommad(this, resume, 'resume');
		console.addCommad(this, pause, 'pause');
	}
	
	function editMode(edit : Bool) {
		mEditMode = edit;
		
		var systems = mEngine.systems;
		
		for (current in systems) {
			if (Std.is(current, RadSystem)) {
				var system : RadSystem = cast current;
				if (mEditMode) 
					system.enterEditMode();
				else
					system.leaveEditMode();
			}
		}
		
		if (!edit) selectEntity(null);
	}
	
	function editComp(name : String, prop : String, value : Dynamic) {
		if (mSelectedEntity != null) {
			var comp = mSelectedEntity.get(Type.resolveClass('fr.radstar.radengine.components.' + name));
			Reflect.setProperty(comp, prop, value);
		}
	}
	
	function saveScene() {
		if (mCurrentScene != null)
			mCurrentScene.save(mEngine);
	}
	
	function addComponent(name : String) {
		var comp = Type.createInstance(Type.resolveClass('fr.radstar.radengine.components.' + name), []);
		mSelectedEntity.add(comp);
	}
	
	function createEntity(name : String) : Entity {
		var ent = new Entity(name);
		mEngine.addEntity(ent);
		selectEntity(ent);
		return ent;
	}
	
	function createScene(name : String) {
		var scene = new Scene(name, false);
		gotoScene(scene);
	}
	
	function addSystem(name : String) {
		var system = Type.createInstance(Type.resolveClass('fr.radstar.radengine.systems.' + name), []);
		mEngine.addSystem(system, 0);
	}
	
	function pause() {
		mStop = true;
		for (system in mEngine.systems) {
			if (Std.is(system, RadSystem)) {
				var current : RadSystem = cast system;
				if (current.shouldStop()) {
					current.pause();
				}
			}
		}
	}
	
	function stop() {
		loadScene(mCurrentScene.name, true);
		pause();
	}
	
	function resume() {
		mStop = false;
		for (system in mEngine.systems)
			if (Std.is(system, RadSystem)) {
				var current : RadSystem = cast system;
				current.resume();
			}
	}
	#end
	
	public function getSelectedEntity() : Entity {
		return mSelectedEntity;
	}
	
	public function selectEntity(entity : Entity) {

		if (mSelectedEntity != null) {
			for (comp in mSelectedEntity.components) 
				if (Std.is(comp, RadComp)) {
					var curentComp : RadComp = cast comp;
					curentComp.unEdit();
				}
		}
	
		mSelectedEntity = entity;
		if(entity != null)
			for (comp in mSelectedEntity.components) {
				if (Std.is(comp, RadComp)) {
					var curentComp : RadComp = cast comp;
					curentComp.edit();
				}
			}
	}
	
	public function selectEntityByName(name : String) {
		var ent = mEngine.getEntityByName(name);
		if(ent != null)
			selectEntity(ent);
		else trace("no such entity");
	}
	
	public function loadScene(name : String, goto : Bool = true) : Scene {
		var scene = new Scene(name);
		if (goto) gotoScene(scene);
		return return scene;
	}
	
	public function gotoScene(scene : Scene) {
		#if debug
		editMode(false);
		#end
		// clear all systems and entity
		mEngine.removeAllEntities();
		mEngine.removeAllSystems();
		if (mCurrentScene != null)
			mCurrentScene.end();
		mCurrentScene = scene;
		mCurrentScene.start(mEngine);
	}
	
	public function addScene(scene : Scene) {
		
	}
	
	function onEnterFrame(e:Event):Void 
	{
		var time = Lib.getTimer();
		var delta : Float = (time - mLastTime) * 0.001;
		mLastTime = time;
		
		if (mCurrentScene != null){
			mCurrentScene.update(delta);
			mEngine.update(delta);
		}
		
	}
	
}