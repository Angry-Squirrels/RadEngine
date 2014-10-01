package fr.radstar.radengine.editor.command;
import ash.core.Entity;

/**
 * ...
 * @author Thomas B
 */
class RemoveComponentFromEntity implements ICommand
{
	var mEntity:Entity;
	var mComp:Dynamic;

	public function new(entity : Entity, comp : Dynamic) 
	{
		mEntity = entity;
		mComp = comp;
	}
	
	/* INTERFACE fr.radstar.radengine.editor.command.ICommand */
	
	public function exec():Void 
	{
		mEntity.remove(Type.getClass(mComp));
	}
	
	public function undo():Void 
	{
		mEntity.add(mComp);
	}
	
}