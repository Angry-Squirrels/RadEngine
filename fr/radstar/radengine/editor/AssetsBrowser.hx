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

	public function new() 
	{
		super();
		
		
	}
	
	override function postInitialize() : Void {
		super.postInitialize();	
		
		var refreshbtn = findChild("refresh", Button, true);
		refreshbtn.onClick = refresh;
		
		refresh(null);
	}
	
	function refresh(e : UIEvent) : Void{
		var folderList = FileSystem.readDirectory("assets");
		var accordion : Accordion = findChild("folders", Accordion, true);
		accordion.removeAllChildren();
		for (folder in folderList) {
			var files = FileSystem.readDirectory('assets/$folder');
			var vbox = new VBox();
			vbox.percentHeight = 100;
			vbox.percentWidth = 100;
			vbox.text = folder;
			var list = new ListView();
			list.percentWidth = 100;
			list.percentHeight = 100;
			list.addEventListener(UIEvent.DOUBLE_CLICK, onListDoubleClick);
			for (file in files)
				list.dataSource.add( { text : file.split('.')[0], type : folder } );
			vbox.addChild(list);
			accordion.addChild(vbox);
		}
	}
	
	private function onListDoubleClick(e:UIEvent):Void 
	{
		var list : ListView = cast e.displayObject;
		if (list.selectedIndex != -1) {
			var data = list.getItem(list.selectedIndex).data;
			var asset = new RadAsset(data.text, data.type);
			Editor.instance.open(asset);
		}
	}
	
}