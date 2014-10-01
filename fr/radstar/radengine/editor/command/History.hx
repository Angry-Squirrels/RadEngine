package fr.radstar.radengine.editor.command;
import fr.radstar.radengine.editor.asset.AssetEditor;
import openfl.events.Event;

/**
 * ...
 * @author Thomas BAUDON
 */
class History
{
	
	var mCommands : Array<ICommand>;
	var mCurrentPosition : Int;
	
	var mAssetEditor : AssetEditor;

	public function new(editor : AssetEditor) 
	{
		mAssetEditor = editor;
		
		mCommands = new Array<ICommand>();
		mCurrentPosition = 0;
	}
	
	public function push(command : ICommand) {
		mAssetEditor.notifyChange();
		while (mCommands.length - 1 > mCurrentPosition)
			mCommands.pop();
		mCommands.push(command);
		mCurrentPosition = mCommands.length - 1;
	}
	
	public function undo() {
		if (canUndo()) {
			mAssetEditor.notifyChange();
			mCommands[mCurrentPosition].undo();
			mCurrentPosition--;
		}
	}
	
	public function canUndo() : Bool {
		return mCommands.length > 0 && mCurrentPosition > -1;
	}
	
	public function canRedo() : Bool {
		return mCommands.length > 0 && mCurrentPosition < mCommands.length-1;
	}
	
	public function redo() {
		if (canRedo()) {
			mAssetEditor.notifyChange();
			mCommands[mCurrentPosition].exec();
			mCurrentPosition++;
		}
	}
	
	
}