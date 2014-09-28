package fr.radstar.radengine.editor.command;

/**
 * ...
 * @author Thomas BAUDON
 */
class History
{
	
	var mCommands : Array<ICommand>;
	var mCurrentPosition : Int;

	public function new() 
	{
		mCommands = new Array<ICommand>();
		mCurrentPosition = 0;
	}
	
	public function push(command : ICommand) {
		while (mCommands.length - 1 > mCurrentPosition)
			mCommands.pop();
		mCommands.push(command);
		mCurrentPosition = mCommands.length - 1;
	}
	
	public function undo() {
		if(canUndo()){
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
		if(canRedo()){
			mCommands[mCurrentPosition].exec();
			mCurrentPosition++;
		}
	}
	
	
}