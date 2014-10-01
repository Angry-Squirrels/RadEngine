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
	var mCompViewer : ComponentViewer;
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
		mCompViewer.setComponent(comp);
	}
	
	function initCompEditor():Void 
	{
		mCompViewer = new ComponentViewer();
		mCompViewer.init(this);
		mCompViewer.percentWidth = 80;
		mCompViewer.percentHeight = 100;
		mHbox.addChild(mCompViewer);
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