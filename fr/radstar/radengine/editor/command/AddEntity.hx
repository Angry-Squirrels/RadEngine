package fr.radstar.radengine.editor.command;
import fr.radstar.radengine.core.Prefab;

/**
 * ...
 * @author Thomas BAUDON
 */
class AddEntity implements ICommand
{
	
	var mPrefab : String;
	var mName : String;

	public function new(prefab : String, name : String) 
	{
		mPrefab = prefab;
		mName = name;
	}
	
	/* INTERFACE fr.radstar.radengine.editor.command.ICommand */
	
	public function exec():Void 
	{
		var prefab = new Prefab(mPrefab, mName);
		prefab.load();
		RadGame.instance.getEngine().addEntity(prefab);
	}
	
	public function undo():Void 
	{
		var engine = RadGame.instance.getEngine();
		var ent = engine.getEntityByName(mName);
		engine.removeEntity(ent);
	}
	
}