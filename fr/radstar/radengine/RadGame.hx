package fr.radstar.radengine;

import ash.core.Engine;
import fr.radstar.radengine.tools.Console;
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

	public function new() 
	{
		super();
		
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		mLastTime = Lib.getTimer();
		
		mEngine = new Engine();
		
		#if debug
		initDebugTools();
		#end
	}
	
	function initDebugTools() 
	{
		new Console(this, mEngine);
	}
	
	public function loadScene(name : String) : Scene {
		return new Scene(name);
	}
	
	public function gotoScene(scene : Scene) {
		if (mCurrentScene != null)
			mCurrentScene.end();
		mCurrentScene = scene;
		mCurrentScene.start(mEngine);
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