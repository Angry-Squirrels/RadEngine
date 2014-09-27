package fr.radstar.radengine.editor;
import fr.radstar.radengine.core.RadAsset;
import haxe.ui.toolkit.core.Component;

/**
 * ...
 * @author Thomas BAUDON
 */
class AssetEditor extends Component
{
	
	var mAsset : RadAsset;

	public function new() 
	{
		super();
		
		percentWidth = 100;
		percentHeight = 100;
	}
	
	public function load(asset : RadAsset) {
		mAsset = asset;
	}
	
	public function save() {
		mAsset.save();
	}
	
}