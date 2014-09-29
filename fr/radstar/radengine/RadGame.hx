package fr.radstar.radengine;

import ash.core.Engine;
import fr.radstar.radengine.core.GameConfig;
import fr.radstar.radengine.core.Level;
import fr.radstar.radengine.editor.Editor;
import fr.radstar.radengine.systems.RadSystem;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

/**
 * ...
 * @author TBaudon
 */
class RadGame extends Sprite
{
	
	var mLastTime : Int;
	var mEngine : Engine;
	
	var mBaseLevel : String;
	
	var mPause : Bool;
	
	var mConfig : GameConfig;
	
	var mRenderArea : Sprite;
	
	// loaded levels;
	var mLevels : Array<Level>;
	
	public static var instance : RadGame;

	public function new() 
	{
		if(instance == null){
			super();
			instance = this;
			
			mEngine = new Engine();
			mRenderArea = new Sprite();
			
			// loaded levels;
			mLevels = new Array<Level>();
			
			// loadConfig 
			mConfig = new GameConfig();
			mConfig.load();
			
			// get systemList
			var systems = mConfig.systemList;
			if(systems != null)
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
			
			mPause = false;
			
			Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			mLastTime = Lib.getTimer();
			
			#if !noEditor
			addEventListener(Event.ADDED_TO_STAGE, initEditor);
			pause();
			#else
			addChild(mRenderArea);
			#end
		}
	}
	
	#if !noEditor
	function initEditor(e : Event) {
		removeEventListener(Event.ADDED_TO_STAGE, initEditor);
		new Editor();
	}
	#end
	
	// Play / Pause
	public function pause() {
		mPause = true;
		for (system in mEngine.systems) 
			if (Std.is(system, RadSystem)) {
				var current : RadSystem = cast system;
				if (current.shouldPause()) 
					current.pause();
			}
	}
	
	public function stop() {
		var levelToReload = new Array<String>();
		for (level in mLevels) 
			levelToReload.push(level.asset.path);
		
		unloadAllLevels();
		
		for (l in levelToReload)
			var newLvl = loadLevel(l, true);
		
		pause();
	}
	
	public function resume() {
		mPause = false;
		for (system in mEngine.systems)
			if (Std.is(system, RadSystem)) {
				var current : RadSystem = cast system;
				current.resume();
			}
	}
	
	public function togglePause() {
		if (mPause)
			resume();
		else
			pause();
	}
	
	public function isPaused() : Bool {
		return mPause;
	}
	
	public function getBaseLevel() : String {
		return mBaseLevel;
	}
	
	public function getEngine() : Engine {
		return mEngine;
	}
	
	public function getRenderArea() : Sprite {
		return mRenderArea;
	}
	
	// LEVELS HANDLING
	
	public function loadLevel(path : String, add : Bool = true) : Level {
		var level = new Level();
		level.load(path);
		if (add) addLevel(level);
		return level;
	}
	
	public function addLevel(level : Level) {
		mLevels.push(level);
		level.start(mEngine);
	}
	
	public function removeLevel(level : Level) {
		mLevels.remove(level);
		level.end();
	}
	
	public function unloadAllLevels() {
		while (mLevels.length > 0)
			mLevels.pop().end();
		mEngine.removeAllEntities();
	}
	
	public function gotoLevel(level : Level) {
		unloadAllLevels();
		addLevel(level);
	}
	
	public function getLoadedLevels() : Array<Level> {
		return mLevels;
	}
	
	// MAIN LOOP
	
	function onEnterFrame(e:Event):Void 
	{
		var time = Lib.getTimer();
		var delta : Float = (time - mLastTime) * 0.001;
		mLastTime = time;
		
		mEngine.update(delta);
	}
	
}