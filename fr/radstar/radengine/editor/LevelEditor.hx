package fr.radstar.radengine.editor;
import ash.core.Entity;
import haxe.ui.toolkit.containers.Absolute;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Text;
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
		
		var btnRemove = new Button();
		btnRemove.text = "remove";
		
		var btnRename = new Button();
		btnRename.text = "rename";
		
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
		}
		
		mEntityList.addEventListener(UIEvent.CLICK, onListSelect);
		
		mInspector.addChild(mEntityList);
		
		mComponentInspector = new ComponentInspector();
		mComponentInspector.percentWidth = 100;
		mComponentInspector.percentHeight = 80;
		mInspector.addChild(mComponentInspector);
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
		var data : IDataSource = mEntityList.dataSource;
		data.add( { text : ent.name, entity : ent } );
	}
	
	function onEntityRemoved(ent : Entity)
	{
		var data : IDataSource = mEntityList.dataSource;
		data.moveFirst();
		var current = data.get();
		while (current.entity != ent) 
			data.moveNext();
		data.remove();
	}
	
}