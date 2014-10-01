package fr.radstar.radengine.editor.components ;
import haxe.io.Path;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.events.UIEvent;
import sys.FileSystem;

/**
 * ...
 * @author Thomas BAUDON
 */
class FileExplorer extends VBox
{
	
	var mList : ListView;
	var mPathBar : HBox;
	var mCurrentDirectory : String;
	
	public static var FILE_OPENED : String = "fileOpened";

	public function new() 
	{
		super();
		
		mPathBar = new HBox();
		mPathBar.percentWidth = 100;
		addChild(mPathBar);
		
		mList = new ListView();
		mList.percentHeight = 100;
		mList.percentWidth = 100;
		addChild(mList);
		
		mList.addEventListener(UIEvent.DOUBLE_CLICK, onListClick);
	}
	
	private function onListClick(e:UIEvent):Void 
	{
		if (mList.selectedIndex != -1) {
			var item  = mList.getItem(mList.selectedIndex);
			var data = item.data;
			if (data.folder)
			{
				var path = data.path;
				explore(path);
			}else {
				var e = new UIEvent(FILE_OPENED, this);
				e.data = data.path;
				dispatchEvent(e);
			}
		}
	}
	
	public function explore(path : String) {
		path = Path.removeTrailingSlashes(path);
		var files = FileSystem.readDirectory(path);
		mList.dataSource.removeAll();
		//mList.dataSource.add( { text : "../", icon : "icons/folder.png", path: path+"/.." , folder : true } );

		mPathBar.removeAllChildren();
		
		var totalPath = "";
		
		for (elem in path.split('/')) {
			var button = new Button();
			button.text = elem + "/";
			totalPath += button.text;
			mPathBar.addChild(button);
			button.userData = totalPath;
			button.addEventListener(UIEvent.CLICK, onPathButtonPressed);
		}
		
		
		mCurrentDirectory = path;
		
		for (file in files) {
			var icon : String;
			var folder : Bool = false;
			if (FileSystem.isDirectory(path+"/"+file))
			{
				folder = true;
				icon = "editor/icons/folder.png";
			}
			else
				icon = "editor/icons/file.png";
			mList.dataSource.add( { text : file, icon : icon, path: path + "/" + file, folder : folder} );
		}
	}
	
	private function onPathButtonPressed(e:UIEvent):Void 
	{
		var button = e.component;
		explore(button.userData);
	}
	
	public function getCurrentDirectory() : String {
		return mCurrentDirectory;
	}
	
	public function getSelectedFile() : String{
		if (mList.selectedIndex != -1) {
			var item = mList.getItem(mList.selectedIndex);
			return item.data.path;
		}
		return null;
	}
}