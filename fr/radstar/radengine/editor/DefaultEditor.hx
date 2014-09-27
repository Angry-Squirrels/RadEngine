package fr.radstar.radengine.editor;
import fr.radstar.radengine.core.RadAsset;
import haxe.ui.toolkit.controls.TextInput;

/**
 * ...
 * @author Thomas BAUDON
 */
class DefaultEditor extends AssetEditor
{
	
	var mTextEditor : TextInput;

	public function new() 
	{
		super();
		
		mTextEditor = new TextInput();
		mTextEditor.percentWidth = 100;
		mTextEditor.percentHeight = 100;
		mTextEditor.multiline = true;
		addChild(mTextEditor);
	}
	
	override public function load(asset:RadAsset) 
	{
		super.load(asset);
			
		var text = mAsset.getContent();
		text = StringTools.replace(text, '\t', '    ');
		mTextEditor.text = text;
	}
	
	override public function save() {
		mAsset.content = mTextEditor.text;
		mAsset.save();
	}
	
}