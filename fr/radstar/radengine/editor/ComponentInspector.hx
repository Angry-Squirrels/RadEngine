package fr.radstar.radengine.editor;
import ash.core.Entity;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.core.Component;

/**
 * ...
 * @author Thomas BAUDON
 */
class ComponentInspector extends Component
{
	
	var mEntity : Entity;
	
	var mVbox : VBox;
	
	var mAccordion : Accordion;
	
	var mEditor : LevelEditor;

	public function new() 
	{
		super();
		
		mVbox = new VBox();
		mVbox.percentWidth = 100;
		mVbox.percentHeight = 100;
		addChild(mVbox);
		
		var text = new Text();
		text.text = "Components";
		mVbox.addChild(text);
		
		var hbox = new HBox();
		hbox.percentWidth = 100;
		mVbox.addChild(hbox);
		
		var addBtn : Button = new Button();
		addBtn.text = "add";
		hbox.addChild(addBtn);
		
		var removeBtn : Button = new Button();
		removeBtn.text = "remove";
		hbox.addChild(removeBtn);
		
		mAccordion = new Accordion();
		mAccordion.percentWidth = 100;
		mAccordion.percentHeight = 100;
		mVbox.addChild(mAccordion);
	}
	
	public function setEditor(editor : LevelEditor) {
		mEditor = editor;
	}
	
	public function setEntity(ent : Entity) {
		if (mEntity != null){
			mEntity.componentRemoved.remove(onCompRemoved);
			mEntity.componentAdded.remove(onCompAdded);
		}
		
		mEntity = ent;
		mEntity.componentAdded.add(onCompAdded);
		mEntity.componentRemoved.add(onCompRemoved);
	}
	
	public function refreshCompList() {
		mAccordion.removeAllChildren();
		for (comp in mEntity.components) {
			var viewer = new ComponentViewer();
			viewer.init(comp, mEditor);
			viewer.percentWidth = 100;
			viewer.percentHeight = 100;
			mAccordion.addChild(viewer);
		}
	}
	
	function onCompRemoved(ent : Entity, comp : Class<Dynamic>) 
	{
		refreshCompList();
	}
	
	function onCompAdded(ent : Entity, comp : Class<Dynamic>) 
	{
		refreshCompList();
	}
	
}