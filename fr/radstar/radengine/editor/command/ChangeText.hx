package fr.radstar.radengine.editor.command;
import haxe.ui.toolkit.controls.TextInput;

/**
 * ...
 * @author Thomas BAUDON
 */
class ChangeText implements ICommand
{
	
	var mBefore : String;
	var mAfter : String;
	var mTarget : TextInput;

	public function new(before : String, after : String, target :TextInput) 
	{
		mBefore = before;
		mAfter = after;
		mTarget = target;
	}
	
	/* INTERFACE fr.radstar.radengine.editor.command.ICommand */
	
	public function exec():Void 
	{
		mTarget.text = mAfter;
	}
	
	public function undo():Void 
	{
		mTarget.text = mBefore;
	}
	
}