package fr.radstar.radengine.editor.command;
import fr.radstar.radengine.core.Prefab;

/**
 * ...
 * @author Thomas B
 */
class AddComponentToPrefab implements ICommand
{
	
	var mPrefab : Prefab;
	var mComponent : Dynamic;

	public function new(prefab : Prefab, component : Dynamic) 
	{
		mPrefab = prefab;
		mComponent = component;
	}
	
	/* INTERFACE fr.radstar.radengine.editor.command.ICommand */
	
	public function exec():Void 
	{
		mPrefab.add(mComponent);
	}
	
	public function undo():Void 
	{
		mPrefab.remove(Type.getClass(mComponent));
	}
	
	
	
}