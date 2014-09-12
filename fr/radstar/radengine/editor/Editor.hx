package fr.radstar.radengine.editor;
import ash.core.Engine;
import ash.core.Entity;
import fr.radstar.radengine.RadGame;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.xml.XMLProcessor;
import haxe.ui.toolkit.core.XMLController;
import haxe.ui.toolkit.themes.GradientTheme;
import haxe.ui.toolkit.util.XmlUtil;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import haxe.ui.toolkit.controls.Button;

/**
 * ...
 * @author Thomas B
 */
class Editor extends XMLController
{

	var mEngine : Engine;
	var mGame : RadGame;
	
	var mRoot : Root;
	
	public function new(engine : Engine, game : RadGame) 
	{
		Toolkit.theme = new GradientTheme();
		Toolkit.init();
		Toolkit.openFullscreen(initToolkit);
		
		super("editor/main.xml");
		
		mEngine = engine;
		mEngine.entityAdded.add(onEntityAdded);
		mEngine.entityRemoved.add(onEntityRemoved);
	}
	
	public function show() {
		mRoot.addChild(this.view);
		var comp : Component = getComponent("renderZone");
		comp.clipContent = true;
		comp.sprite.addChild(RadGame.getView());
	}
	
	public function hide() {
		mRoot.removeChild(this.view, false);
		RadGame.instance.addChild(RadGame.getView());
	}
	
	function initToolkit(root : Root) {				
		mRoot = root;
		mRoot.addChild(this.view);
	}
	
	function onEntityRemoved(ent : Entity) 
	{
		
	}
	
	function onEntityAdded(ent : Entity) {
		var list : ListView = cast getComponent("entities") ;
		list.dataSource.add( { text: ent.name, userData: ent } );
	}
	
}