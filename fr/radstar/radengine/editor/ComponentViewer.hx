package fr.radstar.radengine.editor;

import fr.radstar.radengine.core.Level;
import fr.radstar.radengine.editor.command.ChangeComponentField;
import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.controls.CheckBox;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.events.UIEvent;
import openfl.events.Event;
import Type;

/**
 * ...
 * @author Thomas BAUDON
 */
class ComponentViewer extends Component
{
	
	var mComponent : Dynamic;
	var mGrid : Grid;
	var mInputs : Map<String, Component>;
	var mEditor : LevelEditor;

	public function new() 
	{
		super();
		
		mInputs = new  Map<String, Component>();
	}
	
	public function init(comp : Dynamic, editor : LevelEditor) 
	{
		mEditor = editor;
		mComponent = comp;
		mGrid = new Grid();
		mGrid.columns = 2;
		mGrid.percentHeight = 100;
		mGrid.percentWidth = 100;
		addChild(mGrid);
		
		var compName = Type.getClassName(Type.getClass(mComponent));
		var nameSplit = compName.split('.');
		compName = nameSplit[nameSplit.length - 1];
		text = compName;
		
		for (field in Reflect.fields(mComponent)) {
			// ignore private field
			if (field.indexOf("m") == 0) continue;
			
			var text : Text = new Text();
			text.text = field;
			mGrid.addChild(text);
			
			var input : Component;
			
			var value : Dynamic = Reflect.field(mComponent, field);
			
			switch(Type.typeof(value)) {
				case ValueType.TBool :
					var check = new CheckBox();
					check.selected = cast value;
					input = check;
				default :
					input = new TextInput();
					input.value = value;
			}
			
			input.percentWidth = 100;
			input.addEventListener(UIEvent.CHANGE, onFieldChange);
			input.userData = field;
			
			mGrid.addChild(input);
			mInputs[field] = input;
			
		}
		
		addEventListener(Event.ENTER_FRAME, update);
	}
	
	function onFieldChange(e:UIEvent):Void 
	{
		var input : Component = e.component;
		var field = input.userData;
		var val : Dynamic;
		
		switch(Type.typeof(Reflect.field(mComponent, field))) {
			case ValueType.TFloat :
				val = Std.parseFloat(input.text);
			case ValueType.TInt :
				val = Std.parseInt(input.text);
			case ValueType.TBool :
				val = cast(input, CheckBox).selected;
			default :
				val = input.text;
		}
		
		var command = new ChangeComponentField(mComponent, field, val);
		command.exec();
		mEditor.getHistory().push(command);
	}
	
	function update(e:Event):Void 
	{
		for (field in Reflect.fields(mComponent)) {
			var currentInput : Component = mInputs[field];
			if (Std.is(currentInput, CheckBox))
				cast(currentInput, CheckBox).selected = Reflect.field(mComponent, field);
			else
				currentInput.value = Reflect.field(mComponent, field);
		}
	}
	
}