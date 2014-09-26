package fr.radstar.radengine;

import ash.core.Engine;
import ash.core.Entity;
import ash.core.System;
import ash.core.SystemList;
import fr.radstar.radengine.editor.Editor;
import fr.radstar.radengine.systems.RadSystem;
import haxe.Json;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.ui.Keyboard;
import fr.radstar.radengine.core.GameConfig;
import fr.radstar.radengine.core.Level;

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
	
	// loaded levels;
	var mLevels : Array<Level>;
	
	public static var instance : RadGame;

	public function new() 
	{
		if(instance == null){
			super();
			instance = this;
			
			mEngine = new Engine();
			
			// loaded levels;
			mLevels = new Array<Level>();
			
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
			
			mPause = false;
			
			#if debug
			initDebugTools();
			#end
			
			Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			mLastTime = Lib.getTimer();
		}
		
	}
	#if debug
	
	var mEditor : Editor;
	
	function initDebugTools() 
	{
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDebugDown);
		
		mEditor = new Editor();
	}
	
	function onKeyDebugDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.D && e.ctrlKey == true && e.altKey == true) 
			mEditor.show();
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
			levelToReload.push(level.name);
		
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
	
	// LEVELS HANDLING
	
	public function loadLevel(name : String, add : Bool = true) : Level {
		var level = new Level(name);
		level.load();
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
	
	// MAIN LOOP
	
	function onEnterFrame(e:Event):Void 
	{
		var time = Lib.getTimer();
		var delta : Float = (time - mLastTime) * 0.001;
		mLastTime = time;
		
		mEngine.update(delta);
	}
	
}