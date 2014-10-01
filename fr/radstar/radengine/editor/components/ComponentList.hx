package fr.radstar.radengine.editor.components ;
import ash.core.Entity;
import flash.events.Event;
import fr.radstar.radengine.editor.asset.AssetEditor;
import fr.radstar.radengine.editor.command.AddComponentToEntity;
import fr.radstar.radengine.editor.command.RemoveComponentFromEntity;
import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.events.UIEvent;

/**
 * ...
 * @author Thomas B
 */
class ComponentList extends VBox
{
	
	var mEntity : Entity;
	var mEditor : AssetEditor;
	var mComponentList:ListView;
	
	public static inline var COMPONENT_SELECTED : String = "componentSelected";
	
	public function new() 
	{
		super();
	}
	
	public function init(editor : AssetEditor) {
		mEditor = editor;
		
		var text = new Text();
		text.text = "Components";
		addChild(text);
		
		var hbox = new HBox();
		hbox.percentWidth = 100;
		
		var addBtn : Button = new Button();
		addBtn.text = "Add";
		addBtn.addEventListener(UIEvent.CLICK, onAddClicked);
		hbox.addChild(addBtn);
		
		var removeBtn = new Button();
		removeBtn.text = "Remove";
		removeBtn.addEventListener(UIEvent.CLICK, onRemovedClicked);
		hbox.addChild(removeBtn);
		
		addChild(hbox);
		
		mComponentList = new ListView();
		mComponentList.percentHeight = 100;
		mComponentList.percentWidth = 100;
		
		addChild(mComponentList);
		
		mComponentList.addEventListener(UIEvent.DOUBLE_CLICK, onListDoubleClick);
	}
	
	public function setEntity(ent : Entity) {
		if (mEntity != null) {
			mEntity.componentAdded.remove(onCompChanged);
			mEntity.componentRemoved.remove(onCompChanged);
		}
		mEntity = ent;
		
		mEntity.componentAdded.add(onCompChanged);
		mEntity.componentRemoved.add(onCompChanged);
		
		refreshCompList();
	}
	
	function refreshCompList() 
	{
		mComponentList.dataSource.removeAll();
		
		for (comp in mEntity.components) {
			var name = Type.getClassName(Type.getClass(comp));
			var nameSplit = name.split('.');
			name = nameSplit[nameSplit.length - 1];
			
			mComponentList.dataSource.add( { text : name, component : comp } );
		}
	}
	
	function onCompChanged(ent : Entity, comp : Dynamic) 
	{
		refreshCompList();
	}
	
	function onListDoubleClick(e:Event):Void 
	{
		if (mComponentList.selectedIndex != -1) {
			var item = mComponentList.getItem(mComponentList.selectedIndex);
			var event = new UIEvent(COMPONENT_SELECTED);
			event.data = item.data;
			dispatchEvent(event);
		}
	}
	
	function onAddClicked(e : UIEvent) {
		
		var grid = new Grid();
		grid.percentWidth = 100;
		
		var text = new Text();
		text.text = "Name"; 
		grid.addChild(text);
		
		var input = new TextInput();
		input.percentWidth =  100;
		grid.addChild(input);
		
		PopupManager.instance.showCustom(grid, "Add comp", PopupButton.CANCEL | PopupButton.OK, function (button) {
			if (button == PopupButton.OK) {
				var compClass = Type.resolveClass("fr.radstar.radengine.components." + input.text);
				var comp = Type.createInstance(compClass,[]);
				mEditor.execute(new AddComponentToEntity(mEntity, comp));
			}
		});
	}
	
	function onRemovedClicked(e : UIEvent) {
		if (mComponentList.selectedIndex != -1) {
			var item = mComponentList.getItem(mComponentList.selectedIndex);
			var data = item.data;
			var comp = data.component;
			mEditor.execute(new RemoveComponentFromEntity(mEntity, comp));
		}
	}
	
}