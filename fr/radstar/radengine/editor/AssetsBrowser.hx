package fr.radstar.radengine.editor;
import fr.radstar.radengine.core.RadAsset;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.events.UIEvent;
import openfl.events.Event;
import sys.FileSystem;

/**
 * ...
 * @author Thomas BAUDON
 */
class AssetsBrowser extends Component
{
	
	var mActiveList : ListView;

	public function new() 
	{
		super();
	}
	
	override function postInitialize() : Void {
		super.postInitialize();	
		
		var refreshbtn = findChild("refresh", Button, true);
		refreshbtn.onClick = refresh;
		
		var deleteBtn = findChild("delete", Button, true);
		deleteBtn.addEventListener(UIEvent.CLICK, onDeleteClick);
		
		refresh();
	}
	
	public function refresh(e : UIEvent = null) : Void{
		var folderList = FileSystem.readDirectory("assets");
		var accordion : Accordion = findChild("folders", Accordion, true);
		accordion.addEventListener(UIEvent.CLICK, onAccordionClick);
		
		mActiveList = null;
		
		accordion.removeAllChildren();
		var i = 0;
		for (folder in folderList) {
			var files = FileSystem.readDirectory('assets/$folder');
			var list = new ListView();
			list.text = folder;
			list.percentWidth = 100;
			list.percentHeight = 100;
			list.userData = i;
			i++;
			list.addEventListener(UIEvent.DOUBLE_CLICK, onListDoubleClick);
			list.addEventListener(UIEvent.CLICK, onListClicked);
			for (file in files)
				list.dataSource.add( { text : file.split('.')[0], type : folder, path:'assets/$folder/$file' } );
			accordion.addChild(list);
		}
	}
	
	function onDeleteClick(e:UIEvent):Void 
	{
		Editor.instance.askConfirmation(deleteSelectedItem);
	}
	
	function deleteSelectedItem() {
		if (mActiveList != null) {
			var data = mActiveList.getItem(mActiveList.selectedIndex).data;
			var type = data.type;
			var name = data.text;
			FileSystem.deleteFile('assets/$type/$name.radasset');
			refresh();
		}
	}
	
	function onAccordionClick(e:UIEvent):Void 
	{
		var accordion : Accordion = cast e.displayObject;
	}
	
	function onListClicked(e:UIEvent):Void 
	{
		var list : ListView = cast e.displayObject;
		mActiveList = list;
	}
	
	function onListDoubleClick(e:UIEvent):Void 
	{
		var list : ListView = cast e.displayObject;
		if (list.selectedIndex != -1) {
			var data = list.getItem(list.selectedIndex).data;
			var asset = RadAsset.get(data.path);
			Editor.instance.open(asset);
		}
	}
	
}