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
	
	var mActivePanel : Int;
	var mActiveItem : Int;

	public function new() 
	{
		super();
	}
	
	override function postInitialize() : Void {
		super.postInitialize();	
		
		var refreshbtn = findChild("refresh", Button, true);
		refreshbtn.onClick = refresh;
		
		mActiveItem = -1;
		mActivePanel = -1;
		
		refresh(null);
	}
	
	public function refresh(e : UIEvent) : Void{
		var folderList = FileSystem.readDirectory("assets");
		var accordion : Accordion = findChild("folders", Accordion, true);
		accordion.addEventListener(UIEvent.CLICK, onAccordionClick);
		
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
				list.dataSource.add( { text : file.split('.')[0], type : folder } );
			accordion.addChild(list);
		}
		
		if (mActivePanel != -1){
			accordion.showPage(mActivePanel);
			
			if (mActiveItem != -1) 
				for (child in accordion.children) 
					if (Std.is(child, ListView)) 
						if (cast(child, ListView).userData == mActiveItem) 
							cast(child, ListView).selectedIndex = mActiveItem;
		}
	}
	
	function onAccordionClick(e:UIEvent):Void 
	{
		var accordion : Accordion = cast e.displayObject;
		mActivePanel = accordion.selectedIndex;
		for (a in accordion.children) {
			trace(cast(a, Component).text);
		}
	}
	
	function onListClicked(e:UIEvent):Void 
	{
		var list : ListView = cast e.displayObject;
		if (list.selectedIndex != -1) 
			mActiveItem = list.selectedIndex;
	}
	
	function onListDoubleClick(e:UIEvent):Void 
	{
		var list : ListView = cast e.displayObject;
		if (list.selectedIndex != -1) {
			var data = list.getItem(list.selectedIndex).data;
			var asset = new RadAsset(data.text, data.type);
			Editor.instance.open(asset);
		}
	}
	
}