package fr.radstar.radengine.editor;
import ash.fsm.IComponentProvider;
import fr.radstar.radengine.core.RadAsset;
import fr.radstar.radengine.editor.command.History;
import fr.radstar.radengine.editor.command.ICommand;
import haxe.ui.toolkit.core.Component;

/**
 * ...
 * @author Thomas BAUDON
 */
class AssetEditor extends Component
{
	
	var mAsset : RadAsset;
	var mHistory : History;

	public function new() 
	{
		super();
		
		mHistory = new History();
		
		percentWidth = 100;
		percentHeight = 100;
	}
	
	public function load(asset : RadAsset) {
		mAsset = asset;
	}
	
	public function save() {
		mAsset.save();
	}
	
	public function getHistory() : History{
		return mHistory;
	}
	
	function execute(command : ICommand) {
		command.exec();
		mHistory.push(command);
	}
	
}