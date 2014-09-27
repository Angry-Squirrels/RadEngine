package fr.radstar.radengine.editor;
import ash.core.Engine;
import fr.radstar.radengine.core.RadAsset;
import fr.radstar.radengine.RadGame;
import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.containers.TabView;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.ClassManager;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.XMLController;
import haxe.ui.toolkit.events.MenuEvent;
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
	
	var mActiveEditor : AssetEditor;
	var mOpenedEditors : Array<AssetEditor>;
	var mEditorTabBars : TabView;
	var mAssetsBrowser : AssetsBrowser;
	
	public static var instance : Editor;
	
	public function new() 
	{
		instance = this;
		ClassManager.instance.registerComponentClass(AssetsBrowser, "assetsbrowser");
		
		Toolkit.theme = new GradientTheme();
		Toolkit.openFullscreen(initToolkit);
		Toolkit.init();
		
		super("editor/main.xml");
		
		mGame = RadGame.instance;
		mOpenedEditors = new Array<AssetEditor>();
		mEditorTabBars = getComponentAs("editors", TabView);
		
		mAssetsBrowser = getComponentAs("assetsBrowser", AssetsBrowser);
		
		mRoot.addChild(this.view);

		bindEvents();
		
		open(mGame.getLoadedLevels()[0].asset);
		
		updatePlayPauseButton();
	}
	
	public function newFile() : Void {
		
		var box = new Grid();
		box.percentWidth = 100;
		box.columns = 2;
		
		var nameTxt = new Text();
		nameTxt.text = "Name:";
		box.addChild(nameTxt);
		
		var nameInput = new TextInput();
		nameInput.percentWidth = 100;
		box.addChild(nameInput);
		
		var typeTxt = new Text();
		typeTxt.text = "Type:";
		box.addChild(typeTxt);
		
		var typeInput = new TextInput();
		typeInput.percentWidth = 100;
		box.addChild(typeInput);
		
		showCustomPopup(box, "New asset", PopupButton.CANCEL | PopupButton.OK, function(button : Dynamic) {
			if (button == PopupButton.OK) {
				var asset = new RadAsset(nameInput.text, typeInput.text);
				open(asset);
			}
		});
	}
	
	public function open(asset : RadAsset) {
		var editorClassName = "fr.radstar.radengine.editor." + asset.type+"Editor";
		var editor : AssetEditor;
		var editorClass = Type.resolveClass(editorClassName);
		
		if (editorClass != null)
			editor  = Type.createInstance(editorClass, []);
		else
			editor = new DefaultEditor();

		editor.text = asset.name;
		mEditorTabBars.addChild(editor);
		editor.load(asset);
		
		mActiveEditor = editor;
		mEditorTabBars.selectedIndex = mEditorTabBars.pageCount - 1;
	}
	
	public function getAssetsBrowser() : AssetsBrowser {
		return mAssetsBrowser;
	}
	
	function initToolkit(root : Root) {				
		mRoot = root;
	}
	
	function bindEvents() 
	{
		attachEvent("menuFile", MenuEvent.SELECT, onFileSelect);
		attachEvent("play/pause", UIEvent.CLICK, onPlayPauseClicked);
		attachEvent("stop", UIEvent.CLICK, onStop);
		
	}
	
	function onFileSelect(e : MenuEvent) 
	{
		if(mActiveEditor != null){
			switch(e.menuItem.id) {
				case "newFile" :
					newFile();
				case "saveFile" :
					mActiveEditor.save();
				case "closeFile" :
					closeAcitveEditor();
			}
		}
	}
	
	function closeAcitveEditor() {
		mEditorTabBars.removeTab(mEditorTabBars.selectedIndex);
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