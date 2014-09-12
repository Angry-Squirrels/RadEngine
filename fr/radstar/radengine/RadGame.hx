package fr.radstar.radengine;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.System;
import fr.radstar.radengine.components.RadComp;
import fr.radstar.radengine.editor.Button;
import fr.radstar.radengine.editor.Editor;
import fr.radstar.radengine.editor.Label;
import fr.radstar.radengine.editor.ScrollPane;
import fr.radstar.radengine.editor.VScrollBar;
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
	
	var mCurrentScene : Scene;
	var mLastTime : Int;
	var mEngine : Engine;
	var mEditMode : Bool;
	var mSelectedEntity : Entity;
	var mStop : Bool;
	
	var mRenderZone : Sprite;
	
	public static var instance : RadGame;

	public function new(firstScene : String) 
	{
		super();
		
		instance = this;
		
		mStop = false;
		
		mEngine = new Engine();
		
		mRenderZone = new Sprite();
		addChild(mRenderZone);
		
		loadScene(firstScene);
		
		#if debug
		initDebugTools();
		#end
		
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		mLastTime = Lib.getTimer();
		
	}
	
	public function getRenderZone() : Sprite {
		return mRenderZone;
	}
	
	public static function getView() : Sprite {
		return instance.getRenderZone();
	}
	
	#if debug
	
	var mConsole : Console;
	var mEditor : Editor;
	var mEditorLayer : Sprite;
	
	function initDebugTools() 
	{
		mEditorLayer = new Sprite();
		
		mConsole = new Console(this, mEngine);
		mConsole.addCommad(this, loadScene, 'load');
		mConsole.addCommad(this, editMode, 'edit');
		mConsole.addCommad(this, selectEntityByName, 'select');
		mConsole.addCommad(this, saveScene, 'save');
		mConsole.addCommad(this, createEntity, 'create');
		mConsole.addCommad(this, addComponent, 'add');
		mConsole.addCommad(this, createScene, 'createScene');
		mConsole.addCommad(this, addSystem, 'addSystem');
		mConsole.addCommad(this, editComp, 'editComp');
		mConsole.addCommad(this, stop, 'stop');
		mConsole.addCommad(this, resume, 'resume');
		mConsole.addCommad(this, pause, 'pause');
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDebugDown);
		
		mEditor = new Editor(mEngine, this);
	}
	
	private function onKeyDebugDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.D && e.ctrlKey == true && e.altKey == true) {
			e.stopImmediatePropagation();
			var v = mConsole.toggleVisibility();
			editMode(v);
			if (v){
				Lib.current.stage.focus = mConsole.getInput();
				mEditor.show();
			}else {
				mEditor.hide();
			}
		}
	}
	
	function editMode(edit : Bool) {
		mEditMode = edit;
		
		var systems = mEngine.systems;
		
		for (current in systems) {
			if (Std.is(current, RadSystem)) {
				var system : RadSystem = cast current;
				if (mEditMode) 
					system.enterEditMode();
				else{
					system.leaveEditMode();
					Lib.current.stage.removeChild(mEditorLayer);
				}
			}
		}
		
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
	
	public function getEditorLayer() : Sprite {
		return mEditorLayer;
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
		
		#if debug
		if(mEditMode){
			Lib.current.stage.addChild(mEditorLayer);
		}
		#end
	}
	
}