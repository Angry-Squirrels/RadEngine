package fr.radstar.radengine.editor;
import fr.radstar.radengine.core.Prefab;
import fr.radstar.radengine.core.RadAsset;
import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.MenuBar;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.events.UIEvent;

/**
 * ...
 * @author Thomas B
 */
class PrefabEditor extends AssetEditor
{
	
	var mPrefab : Prefab;
	var mHbox : HBox;
	var mCompEditorGrid : Grid;
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
		
		var addBtn = new Button();
		addBtn.text = "Add";
		hbox.addChild(addBtn);
		
		var removeBtn = new Button();
		removeBtn.text = "Remove";
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
		
		mCompEditorGrid.removeAllChildren();
		
		for (field in Reflect.fields(comp)) {
			var txt = new Text();
			txt.text = field;
			mCompEditorGrid.addChild(txt);
			
			var input = new TextInput();
			input.percentWidth = 100;
			//input.text = Reflect.field(comp, field);
			mCompEditorGrid.addChild(input);
		}
	}
	
	function initCompEditor():Void 
	{
		var vbox = new VBox();
		vbox.percentHeight = 100;
		vbox.percentWidth = 80;
		mHbox.addChild(vbox);
		
		mCompEditorGrid = new Grid();
		mCompEditorGrid.columns = 2;
		mCompEditorGrid.percentWidth = 100;
		mCompEditorGrid.percentHeight = 100;
		
		mCompeditorTitle = new Text();
		vbox.addChild(mCompeditorTitle);
		
		vbox.addChild(mCompEditorGrid);
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
	}
	
	override public function save() 
	{
		mPrefab.save(mAsset.path);
		super.save();
	}
	
}