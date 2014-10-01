package fr.radstar.radengine.editor;
import ash.fsm.IComponentProvider;
import fr.radstar.radengine.core.RadAsset;
import fr.radstar.radengine.editor.command.History;
import fr.radstar.radengine.editor.command.ICommand;
import haxe.ui.toolkit.core.Component;
import openfl.events.Event;

/**
 * ...
 * @author Thomas BAUDON
 */
class AssetEditor extends Component
{
	
	
	public static var MODIFIED : String = "modified";
	public static var SAVED : String = "saved";
	
	var mAsset : RadAsset;
	var mHistory : History;
	var mUnsaved : Bool;

	public function new() 
	{
		super();
		
		mHistory = new History(this);
		
		percentWidth = 100;
		percentHeight = 100;
		
		mUnsaved = false;
	}
	
	public function load(asset : RadAsset) {
		mAsset = asset;
	}
	
	public function save() {
		mAsset.save();
		mUnsaved = false;
		dispatchEvent(new Event(SAVED));
	}
	
	public function notifyChange() {
		mUnsaved = true;
		dispatchEvent(new Event(MODIFIED));
	}
	
	public function getHistory() : History{
		return mHistory;
	}
	
	public function getAsset() : RadAsset {
		return mAsset;
	}
	
	public function execute(command : ICommand) {
		command.exec();
		mHistory.push(command);
	}
	
}