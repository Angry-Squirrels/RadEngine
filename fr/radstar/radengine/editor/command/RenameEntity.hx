package fr.radstar.radengine.editor.command;
import ash.core.Entity;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.core.interfaces.IItemRenderer;
import haxe.ui.toolkit.core.renderers.ItemRenderer;

/**
 * ...
 * @author Thomas BAUDON
 */
class RenameEntity implements ICommand
{
	var mEntity:Entity;
	var mOldName:String;
	var mNewName:String;

	public function new(ent : Entity, newName : String) 
	{
		mEntity = ent;
		mOldName = ent.name;
		mNewName = newName;
	}
	
	/* INTERFACE fr.radstar.radengine.editor.command.ICommand */
	
	public function exec():Void 
	{
		mEntity.name = mNewName;
	}
	
	public function undo():Void 
	{
		mEntity.name = mOldName;
	}
	
}