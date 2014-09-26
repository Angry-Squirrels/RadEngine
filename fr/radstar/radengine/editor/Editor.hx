package fr.radstar.radengine.editor;
import ash.core.Engine;
import fr.radstar.radengine.RadGame;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.XMLController;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.themes.GradientTheme;

/**
 * ...
 * @author Thomas B
 */
class Editor extends XMLController
{
	
	var mRoot : Root;
	
	var mGame : RadGame;
	
	public function new() 
	{
		Toolkit.theme = new GradientTheme();
		Toolkit.openFullscreen(initToolkit);
		Toolkit.init();
		
		super("editor/main.xml");
		
		mGame = RadGame.instance;
		
		mRoot.addChild(this.view);

		bindEvents();
		
		updatePlayPauseButton();
	}
	
	function initToolkit(root : Root) {				
		mRoot = root;
	}
	
	function bindEvents() 
	{
		attachEvent("play/pause", UIEvent.CLICK, onPlayPauseClicked);
		attachEvent("stop", UIEvent.CLICK, onStop);
	}
	
	function updatePlayPauseButton() {
		var playPause : Button = cast getComponent("play/pause");
		if (mGame.isPaused())
			playPause.text = "play";
		else
			playPause.text = "pause";
	}
	
	function onPlayPauseClicked(e : UIEvent) 
	{
		mGame.togglePause();
		updatePlayPauseButton();
	}
	
	function onStop(e : UIEvent) {
		var playPause : Button = cast getComponent("play/pause");
		playPause.text = "play";
		playPause.selected = false;
		mGame.stop();
	}
}