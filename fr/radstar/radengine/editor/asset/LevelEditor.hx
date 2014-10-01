package fr.radstar.radengine.editor.asset ;
import ash.core.Entity;
import flash.events.Event;
import fr.radstar.radengine.core.Level;
import fr.radstar.radengine.core.RadAsset;
import fr.radstar.radengine.editor.command.AddEntity;
import fr.radstar.radengine.editor.command.RemoveEntity;
import fr.radstar.radengine.editor.command.RenameEntity;
import fr.radstar.radengine.editor.components.ComponentList;
import fr.radstar.radengine.editor.components.ComponentViewer;
import fr.radstar.radengine.editor.components.FileExplorer;
import haxe.ui.toolkit.containers.Absolute;
import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.MenuBar;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.interfaces.IItemRenderer;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.data.IDataSource;
import haxe.ui.toolkit.events.UIEvent;
import openfl.Lib;

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
	
	var mComponentList : ComponentList;
	var mComponentViewer : ComponentViewer;
	var mLevel:Level;
	
	var mMenubar : MenuBar;
	
	var mPlayPauseBtn : Button;
	var mStopBtn : Button;

	public function new() 
	{
		super();
		
		mHbox = new HBox();
		mHbox.percentWidth = 100;
		mHbox.percentHeight = 100;
		
		addChild(mHbox);
		
		var vbox = new VBox();
		vbox.percentWidth = 80;
		vbox.percentHeight = 100;
		
		mMenubar = new MenuBar();
		
		
		mPlayPauseBtn = new Button();
		mPlayPauseBtn.text = "Play";
		mPlayPauseBtn.addEventListener(UIEvent.CLICK, onPlayPauseClick);
		updatePlayPauseBtn();
		
		mMenubar.addChild(mPlayPauseBtn);
		
		mStopBtn = new Button();
		mStopBtn.text = "Stop";
		mStopBtn.addEventListener(UIEvent.CLICK, onStopClick);
		
		mMenubar.addChild(mStopBtn);
		
		vbox.addChild(mMenubar);
		
		mLevelArea = new Absolute();
		mLevelArea.percentWidth = 100;
		mLevelArea.percentHeight = 100;
		mLevelArea.sprite.addChild(RadGame.instance.getRenderArea());
		mLevelArea.clipContent = true;
		mLevelArea.style.backgroundColor = Lib.current.stage.color;
		vbox.addChild(mLevelArea);
		
		mHbox.addChild(vbox);
		
		mInspector = new VBox();
		mInspector.percentWidth = 20;
		mInspector.percentHeight = 100;
		mHbox.addChild(mInspector);
		
		initEntityList();
	}
	
	function updatePlayPauseBtn() {
		if (RadGame.instance.isPaused()){
			mPlayPauseBtn.selected = false;
			mPlayPauseBtn.text = "Play";
		}else {
			mPlayPauseBtn.selected = true;
			mPlayPauseBtn.text = "Pause";
		}
	}
	
	function onStopClick(e:UIEvent):Void 
	{
		mPlayPauseBtn.text = "Play";
		mPlayPauseBtn.selected = false;
		RadGame.instance.stop();
		updatePlayPauseBtn();
	}
	
	function onPlayPauseClick(e:UIEvent):Void 
	{
		RadGame.instance.togglePause();
		updatePlayPauseBtn();
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
		
		mComponentList = new ComponentList();
		mComponentList.init(this);
		mComponentList.percentWidth = 100;
		mComponentList.percentHeight = 30;
		mComponentList.addEventListener(ComponentList.COMPONENT_SELECTED, onComponentSelected);
		mInspector.addChild(mComponentList);
		
		mComponentViewer = new ComponentViewer();
		mComponentViewer.init(this);
		mComponentViewer.percentWidth = 100;
		mComponentViewer.percentHeight = 50;
		mInspector.addChild(mComponentViewer);
	}
	
	function onComponentSelected(e:UIEvent):Void 
	{
		mComponentViewer.setComponent(e.data.component);
	}
	
	function onAddClicked(e:UIEvent):Void 
	{
		var vbox = new VBox();
		vbox.percentWidth = 100;
		
		var fileExplorer = new FileExplorer();
		fileExplorer.percentWidth = 100;
		fileExplorer.height = 200;
		//fileExplorer.percentHeight = 100;
		fileExplorer.explore('assets');
		vbox.addChild(fileExplorer);
		
		var hbox = new HBox();
		hbox.percentWidth = 100;
		
		var instTxt = new Text();
		instTxt.text = "Name : ";
		var instInput = new TextInput();
		instInput.percentWidth = 100;
		
		vbox.addChild(hbox);
		hbox.addChild(instTxt);
		hbox.addChild(instInput);
		
		PopupManager.instance.showCustom(vbox, "Add entity", PopupButton.CANCEL | PopupButton.OK, function(button) {
			if (button == PopupButton.OK) {
				var cmd = new AddEntity(fileExplorer.getSelectedFile(), instInput.text);
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
			mComponentList.setEntity(ent);
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
		super.load(asset);
		var level = new Level();
		level.load(asset.path);
		RadGame.instance.gotoLevel(level);
		mLevel = level;
	}
	
	override public function save() 
	{
		mLevel.save(mAsset.path);
		super.save();
	}
	
}