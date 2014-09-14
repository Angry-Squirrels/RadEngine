package fr.radstar.radengine.editor;
import ash.core.Engine;
import ash.core.Entity;
import fr.radstar.radengine.command.Commander;
import fr.radstar.radengine.RadGame;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Menu;
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
	}
	
	public function show() {
		mRoot.addChild(this.view);
		var comp : Component = getComponent("renderZone");
		comp.clipContent = true;
		comp.sprite.addChild(RadGame.instance);
	}
	
	public function hide() {
		mRoot.removeChild(this.view, false);
		Lib.current.stage.addChild(RadGame.instance);
	}
	
	function initToolkit(root : Root) {				
		mRoot = root;
		mRoot.addChild(this.view);
		mRoot.addEventListener(UIEvent.INIT, onReady);
	}
	
	function onReady(e : UIEvent) {
		bindEvents();
	}
	
	function bindEvents() 
	{
		var saveItem : Menu = cast getComponent("menuFile");
		trace(saveItem != null);
		//saveItem.addEventListener(MenuEvent.SELECT, onFileSelect);
	}
	
	function onFileSelect(e:MenuEvent):Void 
	{
		switch(e.menuItem.id) {
			case 'menuSave' :
				mCommander.exec("save", []);
		}
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