package fr.radstar.radengine.editor.command;
import fr.radstar.radengine.core.Prefab;

/**
 * ...
 * @author Thomas B
 */
class RemoveComponentFromPrefab implements ICommand
{
	var mPrefab:Prefab;
	var mComp:Dynamic;

	public function new(prefab : Prefab, comp : Dynamic) 
	{
		mPrefab = prefab;
		mComp = comp;
	}
	
	/* INTERFACE fr.radstar.radengine.editor.command.ICommand */
	
	public function exec():Void 
	{
		mPrefab.remove(Type.getClass(mComp));
	}
	
	public function undo():Void 
	{
		mPrefab.add(mComp);
	}
	
}