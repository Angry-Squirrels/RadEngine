package fr.radstar.radengine.editor.command;
import ash.core.Entity;

/**
 * ...
 * @author Thomas BAUDON
 */
class RemoveEntity implements ICommand
{
	
	var mEntity : Entity;

	public function new(ent : Entity) 
	{
		mEntity = ent;
	}
	
	public function exec() {
		var engine = RadGame.instance.getEngine();
		engine.removeEntity(mEntity);
	}
	
	public function undo() {
		var engine = RadGame.instance.getEngine();
		engine.addEntity(mEntity);
	}
	
}