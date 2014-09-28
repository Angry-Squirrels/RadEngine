package fr.radstar.radengine.editor.command;

/**
 * ...
 * @author Thomas BAUDON
 */
class ChangeComponentField implements ICommand
{
	
	var mComp : Dynamic;
	var mField : String;
	var mOld : Dynamic;
	var mNew : Dynamic;

	public function new(comp : Dynamic, field : String, newValue : Dynamic) 
	{
		mComp = comp;
		mField = field;
		mOld = Reflect.field(comp, field);
		mNew = newValue;
	}
	
	/* INTERFACE fr.radstar.radengine.editor.command.ICommand */
	
	public function exec():Void 
	{
		Reflect.setProperty(mComp, mField, mNew);
	}
	
	public function undo():Void 
	{
		Reflect.setProperty(mComp, mField, mOld);
	}
	
	
	
}