package fr.radstar.radengine.editor;
import ash.core.Entity;
import fr.radstar.radengine.core.Prefab;
import fr.radstar.radengine.core.RadAsset;
import fr.radstar.radengine.editor.command.AddComponentToPrefab;
import fr.radstar.radengine.editor.command.ChangeComponentField;
import fr.radstar.radengine.editor.command.RemoveComponentFromPrefab;
import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.MenuBar;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.CheckBox;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.events.UIEvent;
import Type;

/**
 * ...
 * @author Thomas B
 */
class PrefabEditor extends AssetEditor
{
	
	var mPrefab : Prefab;
	var mHbox : HBox;
	var mCompEditorBox : VBox;
	var mCompListBox : VBox;
	var mComponentList:ListView;
	var mCompeditorTitle : Text;

	public function new() 
	{
		super();
		
		mHbox = new HBox();
		mHbox.percentHeight = 100;
		mHbox.percentWidth = 100;
		addChild(mHbox);
		
		initCompEditor();
		
		initCompList();
	}
	
	function initCompList() {
		mCompListBox = new VBox();
		mCompListBox.percentHeight = 100;
		mCompListBox.percentWidth = 20;
		
		var text = new Text();
		text.text = "Components";
		mCompListBox.addChild(text);
		
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
		
		mCompListBox.addChild(hbox);
		
		mComponentList = new ListView();
		mComponentList.percentHeight = 100;
		mComponentList.percentWidth = 100;
		
		mCompListBox.addChild(mComponentList);
		
		mHbox.addChild(mCompListBox);
		
		mComponentList.addEventListener(UIEvent.DOUBLE_CLICK, onListDoubleClick);
	}
	
	function onListDoubleClick(e:UIEvent):Void 
	{
		if (mComponentList.selectedIndex != -1) {
			var item = mComponentList.getItem(mComponentList.selectedIndex);
			var data = item.data;
			editComponent(data.text, data.component);
		}
	}
	
	function editComponent(name : String, comp : Dynamic) {
		mCompeditorTitle.text = name;
		
		mCompEditorBox.removeAllChildren();
		
		var compViewer = new ComponentViewer();
		compViewer.init(comp, this);
		compViewer.percentWidth = 100;
		compViewer.percentHeight = 100;
		mCompEditorBox.addChild(compViewer);
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
				execute(new AddComponentToPrefab(mPrefab, comp));
			}
		});
	}
	
	function onRemovedClicked(e : UIEvent) {
		if (mComponentList.selectedIndex != -1) {
			var item = mComponentList.getItem(mComponentList.selectedIndex);
			var data = item.data;
			var comp = data.component;
			execute(new RemoveComponentFromPrefab(mPrefab, comp));
		}
	}
	
	function initCompEditor():Void 
	{
		var vbox = new VBox();
		vbox.percentHeight = 100;
		vbox.percentWidth = 80;
		mHbox.addChild(vbox);
		
		mCompEditorBox = new VBox();
		mCompEditorBox.percentWidth = 100;
		mCompEditorBox.percentHeight = 100;
		
		mCompeditorTitle = new Text();
		vbox.addChild(mCompeditorTitle);
		
		vbox.addChild(mCompEditorBox);
	}
	
	function refreshList() {
		mComponentList.dataSource.removeAll();
		
		for (comp in mPrefab.components) {
			var name = Type.getClassName(Type.getClass(comp));
			var splitName = name.split('.');
			name = splitName[splitName.length - 1];
			mComponentList.dataSource.add( { text : name, component : comp } );
		}
	}
	
	override public function load(asset:RadAsset) 
	{
		super.load(asset);
		mPrefab = new Prefab("p" + Std.int(Math.random() * 999999));
		mPrefab.load(asset.path);
		refreshList();
		
		mPrefab.componentAdded.add(onCompChanged);
		mPrefab.componentRemoved.add(onCompChanged);
	}
	
	function onCompChanged(entity : Entity, comp : Class<Dynamic>) 
	{
		refreshList();
	}
	
	override public function save() 
	{
		mPrefab.save(mAsset.path);
		super.save();
	}
	
}