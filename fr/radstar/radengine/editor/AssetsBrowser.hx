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
class AssetsBrowser extends VBox
{
	
	var mActiveList : ListView;
	var mFileExplorer : FileExplorer;

	public function new() 
	{
		super();
	}
	
	override function postInitialize() : Void {
		super.postInitialize();	
		
		var newFileBtn = findChild("newFile", Button, true);
		newFileBtn.onClick = Editor.instance.newFile;
		
		var newFolderBtn = findChild("newFolder", Button, true);
		newFolderBtn.onClick = Editor.instance.newFolder;
		
		var refreshbtn = findChild("refresh", Button, true);
		refreshbtn.onClick = refresh;
		
		var deleteBtn = findChild("delete", Button, true);
		deleteBtn.onClick = onDeleteClick;
		
		mFileExplorer = new FileExplorer();
		mFileExplorer.percentWidth = 100;
		mFileExplorer.percentHeight = 100;
		addChild(mFileExplorer);
		mFileExplorer.explore('assets');
		
		mFileExplorer.addEventListener(FileExplorer.FILE_OPENED, onFileOpened);
	}
	
	function onFileOpened(e:UIEvent):Void 
	{
		var file = e.data;
		Editor.instance.open(RadAsset.get(file));
	}
	
	public function refresh(e : UIEvent = null) : Void{
		var dir = mFileExplorer.getCurrentDirectory();
		mFileExplorer.explore(dir);
	}
	
	public function getCurrentDirectory() : String {
		return mFileExplorer.getCurrentDirectory();
	}
	
	function onDeleteClick(e:UIEvent):Void 
	{
		Editor.instance.askConfirmation(deleteSelectedItem);
	}
	
	function deleteSelectedItem() {
		var file = mFileExplorer.getSelectedFile();
		if (file != null) {
			try{
				if (FileSystem.isDirectory(file)) 
					FileSystem.deleteDirectory(file);
				else
					FileSystem.deleteFile(file);
			}catch (e : Dynamic) {
				trace(e);
			}
			refresh();
		}
	}
	
}