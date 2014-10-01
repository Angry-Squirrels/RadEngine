package fr.radstar.radengine.editor;
import ash.core.Entity;
import fr.radstar.radengine.core.Prefab;
import fr.radstar.radengine.core.RadAsset;
import fr.radstar.radengine.editor.command.AddComponentToEntity;
import fr.radstar.radengine.editor.command.ChangeComponentField;
import fr.radstar.radengine.editor.command.RemoveComponentFromEntity;
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
	var mCompeditorTitle : Text;
	var mComponentList : ComponentList;

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
		mComponentList = new ComponentList();
		mComponentList.init(this);
		mComponentList.percentWidth = 20;
		mComponentList.percentHeight = 100;
		mHbox.addChild(mComponentList);
		
		mComponentList.addEventListener(ComponentList.COMPONENT_SELECTED, onCompSelected);
	}
	
	function onCompSelected(e:UIEvent):Void 
	{
		var data = e.data;
		editComponent(data.text, data.component);
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
	
	override public function load(asset:RadAsset) 
	{
		super.load(asset);
		mPrefab = new Prefab("p" + Std.int(Math.random() * 999999));
		mPrefab.load(asset.path);
		mComponentList.setEntity(mPrefab);
	}
	
	override public function save() 
	{
		mPrefab.save(mAsset.path);
		super.save();
	}
	
}