package fr.radstar.radengine.editor;
import ash.core.Engine;
import ash.core.Entity;
import fr.radstar.radengine.command.Commander;
import fr.radstar.radengine.RadGame;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Menu;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.xml.XMLProcessor;
import haxe.ui.toolkit.core.XMLController;
import haxe.ui.toolkit.events.MenuEvent;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.themes.GradientTheme;
import haxe.ui.toolkit.util.XmlUtil;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import haxe.ui.toolkit.controls.Button;
import openfl.events.MouseEvent;
import openfl.Lib;

/**
 * ...
 * @author Thomas B
 */
class Editor extends XMLController
{

	var mEngine : Engine;
	var mGame : RadGame;
	
	var mRoot : Root;
	
	var mCommander : Commander;
	
	public function new(engine : Engine, game : RadGame) 
	{
		Toolkit.theme = new GradientTheme();
		Toolkit.openFullscreen(initToolkit);
		Toolkit.init();
		
		mCommander = Commander.getInstance();
		
		super("editor/main.xml");
		
		mEngine = engine;
		mEngine.entityAdded.add(onEntityAdded);
		mEngine.entityRemoved.add(onEntityRemoved);

		bindEvents();
	}
	
	public function show() {
		mRoot.addChild(this.view);
		var comp : Component = getComponent("renderZone");
		comp.clipContent = true;
		comp.sprite.addChild(RadGame.instance);
		initEntityList();
	}
	
	public function hide() {
		mRoot.removeChild(this.view, false);
		Lib.current.stage.addChild(RadGame.instance);
		clearEntityList();
	}
	
	function initToolkit(root : Root) {				
		mRoot = root;
		mRoot.addChild(this.view);
	}
	
	function bindEvents() 
	{
		attachEvent("menuScene", MenuEvent.SELECT, onSceneSelect);
		attachEvent("play/pause", UIEvent.CLICK, onPlayPauseClicked);
		attachEvent("stop", UIEvent.CLICK, onStop);
		attachEvent("entities", UIEvent.CLICK, onEntityListClicked);
	}
	
	function onEntityListClicked(e : UIEvent) 
	{
		var list : ListView = cast getComponent("entities");
		var entity : Entity = list.getItem(list.selectedIndex).data.userData;
		onEntitySelected(entity);
	}
	
	function onEntitySelected(entity : Entity) {
		mCommander.exec("select", [entity.name]);
		initComponentList(entity);
	}
	
	function initComponentList(ent : Entity) 
	{
		var compList : Accordion = cast getComponent("components");
		compList.removeAllChildren();
		
		for (comp in ent.components) {
			var vbox = new VBox();
			var name = Type.getClassName(Type.getClass(comp));
			var nameSplit = name.split('.');
			name = nameSplit[nameSplit.length - 1];
			vbox.text = name;
			compList.addChild(vbox);
			for (field in Reflect.fields(comp)) {
				var fieldName : String = cast field;
				if (fieldName.indexOf("m") != 0)
				{
					var text : Text = new Text();
					text.text = fieldName;
					var input : TextInput = new TextInput();
					input.text = Reflect.getProperty(comp, field);
					input.userData = { component: comp, field:fieldName };
					input.percentWidth = 100;
					input.addEventListener(UIEvent.CHANGE, onCompFieldChanged);
					vbox.addChild(text);
					vbox.addChild(input);
				}
			}
		}
	}
	
	function onCompFieldChanged(e:UIEvent):Void 
	{
		var input : TextInput =cast e.displayObject;
		try {
			var comp = input.userData.component;
			var field = input.userData.field;
			Reflect.setProperty(comp, field, input.value);
		}catch (e : Dynamic) {
			trace(e);
		}
	}
	
	function onPlayPauseClicked(e : UIEvent) 
	{
		var playPause : Button = cast getComponent("play/pause");
		if (playPause.selected){
			playPause.text = "play";
			mCommander.exec("pause");
		}
		else{
			playPause.text = "pause";
			mCommander.exec("resume");
		}
	}
	
	function onStop(e : UIEvent) {
		var playPause : Button = cast getComponent("play/pause");
		playPause.text = "play";
		playPause.selected = false;
		mCommander.exec("stop");
	}
	
	function onSceneSelect(e:MenuEvent):Void 
	{
		switch(e.menuItem.id) {
			case 'saveScene' :
				mCommander.exec("save", []);
			case 'newScene' :
				mCommander.exec("createScene", ["test"]);
		}
	}
	
	function initEntityList() {
		var list : ListView = cast getComponent("entities");
		for (ent in mEngine.entities) {
			list.dataSource.add( { text: ent.name, userData: ent } );
		}
	}
	
	function clearEntityList() {
		var list : ListView = cast getComponent("entities");
		list.dataSource.removeAll();
	}
	
	function onEntityRemoved(ent : Entity) 
	{
		var list : ListView = cast getComponent("entities");
		list.dataSource.moveFirst();
		
		do {
			var current = list.dataSource.get();
			if (current.userData == ent)
			{
				list.dataSource.remove();
				break;
			}
		}while(list.dataSource.moveNext());
	}
	
	function onEntityAdded(ent : Entity) {
		var list : ListView = cast getComponent("entities") ;
		list.dataSource.add( { text: ent.name, userData: ent } );
	}
	
}