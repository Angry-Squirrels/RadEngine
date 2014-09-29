package fr.radstar.radengine.editor;
import ash.core.Entity;
import fr.radstar.radengine.core.Level;
import fr.radstar.radengine.core.Prefab;
import fr.radstar.radengine.core.RadAsset;
import fr.radstar.radengine.editor.command.AddEntity;
import fr.radstar.radengine.editor.command.RemoveEntity;
import fr.radstar.radengine.editor.command.RenameEntity;
import haxe.ui.toolkit.containers.Absolute;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.interfaces.IItemRenderer;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.renderers.ItemRenderer;
import haxe.ui.toolkit.data.IDataSource;
import haxe.ui.toolkit.events.UIEvent;

/**
 * ...
 * @author Thomas BAUDON
 */
class LevelEditor extends AssetEditor
{
	
	var mHbox : HBox;
	
	var mLevelArea : Absolute;
	var mInspector : VBox;
	
	var mEntityList : ListView;
	var mCurrentEntity : Entity;
	
	var mComponentInspector : ComponentInspector;
	var mLevel:Level;

	public function new() 
	{
		super();
		
		mHbox = new HBox();
		mHbox.percentWidth = 100;
		mHbox.percentHeight = 100;
		
		addChild(mHbox);
		
		mLevelArea = new Absolute();
		mLevelArea.percentWidth = 80;
		mLevelArea.percentHeight = 100;
		mLevelArea.sprite.addChild(RadGame.instance.getRenderArea());
		mHbox.addChild(mLevelArea);
		
		mInspector = new VBox();
		mInspector.percentWidth = 20;
		mInspector.percentHeight = 100;
		mHbox.addChild(mInspector);
		
		initEntityList();
	}
	
	function initEntityList() 
	{
		var engine = RadGame.instance.getEngine();
		engine.entityAdded.add(onEntityAdded);
		engine.entityRemoved.add(onEntityRemoved);
		
		var text = new Text();
		text.text = "Entities";
		mInspector.addChild(text);
		
		var hbox = new HBox();
		hbox.percentWidth = 100;
		
		var btnAdd = new Button();
		btnAdd.text = "add";
		btnAdd.addEventListener(UIEvent.CLICK, onAddClicked);
		
		var btnRemove = new Button();
		btnRemove.text = "remove";
		btnRemove.addEventListener(UIEvent.CLICK, onRemoveClicked);
		
		var btnRename = new Button();
		btnRename.text = "rename";
		btnRename.addEventListener(UIEvent.CLICK, onRenameClicked);
		
		hbox.addChild(btnAdd);
		hbox.addChild(btnRemove);
		hbox.addChild(btnRename);
		
		mInspector.addChild(hbox);
		
		mEntityList = new ListView();
		mEntityList.percentWidth = 100;
		mEntityList.percentHeight = 20;
		
		var entities = engine.entities;
		for (ent in entities) {
			var data : IDataSource = mEntityList.dataSource;
			data.add( { text : ent.name, entity : ent } );
			ent.nameChanged.add(onEntityNameChanged);
		}
		
		mEntityList.addEventListener(UIEvent.CLICK, onListSelect);
		
		mInspector.addChild(mEntityList);
		
		mComponentInspector = new ComponentInspector();
		mComponentInspector.setEditor(this);
		mComponentInspector.percentWidth = 100;
		mComponentInspector.percentHeight = 80;
		mInspector.addChild(mComponentInspector);
	}
	
	function onAddClicked(e:UIEvent):Void 
	{
		var grid = new Grid();
		grid.percentWidth = 100;
		grid.columns = 2;
		
		var txt : Text = new Text();
		txt.text = "Prefab : ";
		var input = new TextInput();
		input.percentWidth = 100;
		
		var instTxt = new Text();
		instTxt.text = "Name : ";
		var instInput = new TextInput();
		instInput.percentWidth = 100;
		
		grid.addChild(txt);
		grid.addChild(input);
		grid.addChild(instTxt);
		grid.addChild(instInput);
		
		PopupManager.instance.showCustom(grid, "Add entity", PopupButton.CANCEL | PopupButton.OK, function(button) {
			if (button == PopupButton.OK) {
				var cmd = new AddEntity(input.text, instInput.text);
				execute(cmd);
			}
		});
	}
	
	function onRemoveClicked(e : UIEvent):Void {
		if (mEntityList.selectedIndex != -1) {
			var ent = mEntityList.getItem(mEntityList.selectedIndex).data.entity;
			var command = new RemoveEntity(ent);
			execute(command);
		}
	}
	
	function onRenameClicked(e:UIEvent):Void 
	{
		if (mEntityList.selectedIndex != -1) {
			var grid = new Grid();
			grid.percentWidth = 100;
			grid.columns = 2;
			
			var text = new Text();
			text.text = "New name : ";
			
			var input = new TextInput();
			input.percentWidth = 100;
			grid.addChild(text);
			grid.addChild(input);
			
			var item : IItemRenderer = mEntityList.getItem(mEntityList.selectedIndex);
			
			var ent = item.data.entity;
			
			PopupManager.instance.showCustom(grid, "Rename entity", PopupButton.CANCEL | PopupButton.OK, function (button) {
				if (button == PopupButton.OK) {
					var engine = RadGame.instance.getEngine();
					var exists = engine.getEntityByName(input.text) != null;
					if (!exists) {
						var command = new RenameEntity(ent, input.text);
						execute(command);
					}
				}
			});
		}
	}
	
	function onListSelect(e:UIEvent):Void 
	{
		if (mEntityList.selectedIndex == -1) return;
		
		var ent = mEntityList.getItem(mEntityList.selectedIndex).data.entity;
		if (ent != mCurrentEntity) {
			mCurrentEntity = ent;
			mComponentInspector.setEntity(ent);
		}
	}
	
	function onEntityAdded(ent : Entity) 
	{
		ent.nameChanged.add(onEntityNameChanged);
		var data : IDataSource = mEntityList.dataSource;
		data.add( { text : ent.name, entity : ent } );
	}
	
	function onEntityRemoved(ent : Entity)
	{
		var data : IDataSource = mEntityList.dataSource;
		data.moveFirst();
		var current = data.get();
		while (current.entity != ent) {
			data.moveNext();
			current = data.get();
		}
		data.remove();
		ent.nameChanged.remove(onEntityNameChanged);
	}
	
	function onEntityNameChanged(ent : Entity, name : String) 
	{
		var i = 0;
		mEntityList.dataSource.moveFirst();
		var data = mEntityList.dataSource.get();
		while (data.entity != ent) {
			i++;
			mEntityList.dataSource.moveNext();
			data = mEntityList.dataSource.get();
		}
		data.text = ent.name;
		var item = mEntityList.getItem(i);
		item.text = ent.name;
		
		mEntityList.invalidate();
	}
	
	override public function load(asset:RadAsset) 
	{
		var level = new Level(asset.name);
		level.load();
		mAsset = level.asset;
		RadGame.instance.gotoLevel(level);
		mLevel = level;
	}
	
	override public function save() 
	{
		mLevel.save(RadGame.instance.getEngine());
		super.save();
	}
	
}