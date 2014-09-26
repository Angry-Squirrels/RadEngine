package fr.radstar.radengine;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.System;
import ash.core.SystemList;
import fr.radstar.radengine.command.Commander;
import fr.radstar.radengine.components.RadComp;
import fr.radstar.radengine.editor.Editor;
import fr.radstar.radengine.systems.RadSystem;
import fr.radstar.radengine.tools.Console;
import haxe.Json;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.ui.Keyboard;

/**
 * ...
 * @author TBaudon
 */
class RadGame extends Sprite
{
	
	var mCurrentScene : Level;
	var mLastTime : Int;
	var mEngine : Engine;
	var mEditMode : Bool;
	
	var mBaseLevel : String;
	
	var mSelectedEntity : Entity;
	
	var mStop : Bool;
	
	var mConfig : GameConfig;
	
	public static var instance : RadGame;

	public function new() 
	{
		if(instance == null){
			super();
			instance = this;
			
			mEngine = new Engine();
			
			// loadConfig 
			mConfig = new GameConfig();
			mConfig.load();
			
			// get systemList
			var systems = mConfig.systemList;
			for (system in systems) {
				var sysClass = Type.resolveClass(system.name);
				var sys = Type.createInstance(sysClass, []);
				for (field in Reflect.fields(system.params))
					Reflect.setField(sys, field, Reflect.field(system.params, field));
				mEngine.addSystem(sys, sys.priority);
			}
			
			// get first level
			mBaseLevel = mConfig.initialLevel;
			loadLevel(mBaseLevel);
			
			mStop = false;
			
			#if debug
			initDebugTools();
			#end
			
			Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			mLastTime = Lib.getTimer();
		}
		
	}
	#if debug
	
	var mEditor : Editor;
	var mCommander : Commander;
	
	function initDebugTools() 
	{
		mCommander = Commander.getInstance();
		
		mCommander.add(this, loadLevel, 'load');
		mCommander.add(this, editMode, 'edit');
		mCommander.add(this, selectEntityByName, 'select');
		mCommander.add(this, saveScene, 'save');
		mCommander.add(this, createEntity, 'create');
		mCommander.add(this, addComponent, 'add');
		mCommander.add(this, createScene, 'createScene');
		mCommander.add(this, addSystem, 'addSystem');
		mCommander.add(this, editComp, 'editComp');
		mCommander.add(this, stop, 'stop');
		mCommander.add(this, resume, 'resume');
		mCommander.add(this, pause, 'pause');
		mCommander.add(this, removeEntity, 'remove');
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDebugDown);
		
		mEditor = new Editor(mEngine, this);
	}
	
	private function onKeyDebugDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.D && e.ctrlKey == true && e.altKey == true) {
			editMode(true);
			mEditor.show();
		}
	}
	
	function editMode(edit : Bool) {
		mEditMode = edit;
		
		var systems = mEngine.systems;
		
		if (!mEditMode) {
			selectEntity(null);
			resume();
		}
		else {
			pause();
		}
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
	
	function removeEntity() {
		mEngine.removeEntity(mSelectedEntity);
		mSelectedEntity = null;
	}
	
	function createScene(name : String) {
		var scene = new Level(name);
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
		loadLevel(mCurrentScene.name, true);
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
	
	public function getBaseLevel() : String {
		return mBaseLevel;
	}
	
	public function setBaseLevel(name :  String) {
		mBaseLevel = name;
	}
	
	public function getSystems() : Iterable<System> {
		return mEngine.systems;
	}
	
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
	
	public function loadLevel(name : String, goto : Bool = true) : Level {
		var level = new Level(name);
		level.load();
		if (goto) gotoScene(level);
		return level;
	}
	
	public function gotoScene(scene : Level) {
		// clear all systems and entity
		mEngine.removeAllEntities();
		if (mCurrentScene != null)
			mCurrentScene.end();
		mCurrentScene = scene;
		mCurrentScene.start(mEngine);
	}
	
	public function addScene(scene : Level) {
		
	}
	
	function onEnterFrame(e:Event):Void 
	{
		var time = Lib.getTimer();
		var delta : Float = (time - mLastTime) * 0.001;
		mLastTime = time;
		
		mEngine.update(delta);
	}
	
}