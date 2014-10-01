package fr.radstar.radengine.editor.command;
import ash.core.Entity;

/**
 * ...
 * @author Thomas B
 */
class AddComponentToEntity implements ICommand
{
	
	var mEntity : Entity;
	var mComponent : Dynamic;

	public function new(entity : Entity, component : Dynamic) 
	{
		mEntity = entity;
		mComponent = component;
	}
	
	/* INTERFACE fr.radstar.radengine.editor.command.ICommand */
	
	public function exec():Void 
	{
		mEntity.add(mComponent);
	}
	
	public function undo():Void 
	{
		mEntity.remove(Type.getClass(mComponent));
	}
	
	
	
}