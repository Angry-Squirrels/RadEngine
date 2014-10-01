package fr.radstar.radengine.editor.components ;

import fr.radstar.radengine.core.RadAsset;
import fr.radstar.radengine.editor.asset.AssetEditor;
import fr.radstar.radengine.editor.command.ChangeComponentField;
import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.containers.ScrollView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.CheckBox;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.events.UIEvent;
import openfl.events.Event;
import openfl.Lib;
import Type;

/**
 * ...
 * @author Thomas BAUDON
 */
class ComponentViewer extends VBox
{
	
	var mComponent : Dynamic;
	var mGrid : Grid;
	var mInputs : Map<String, Component>;
	var mEditor : AssetEditor;
	var mLastChange : Int = 0;
	var mTitle:Text;

	public function new() 
	{
		super();
		
		mInputs = new  Map<String, Component>();
	}
	
	public function init(editor : AssetEditor) 
	{
		mEditor = editor;
		
		mTitle = new Text();
		addChild(mTitle);
		
		var scrollView = new ScrollView();
		scrollView.percentWidth = 100;
		scrollView.percentHeight = 100;
		addChild(scrollView);
		
		mGrid = new Grid();
		mGrid.columns = 2;
		mGrid.percentWidth = 100;
		scrollView.addChild(mGrid);
		
		addEventListener(Event.ENTER_FRAME, update);
	}
	
	public function setComponent(comp : Dynamic) {
		mComponent = comp;
		
		var compName = Type.getClassName(Type.getClass(mComponent));
		var nameSplit = compName.split('.');
		compName = nameSplit[nameSplit.length - 1];
		mTitle.text = compName;
		
		mGrid.removeAllChildren();
		
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
			input.userData = {field : field, type : Type.typeof(Reflect.field(mComponent, field))};
			mGrid.addChild(input);
			mInputs[field] = input;
			
		}
	}
	
	function onFieldChange(e:UIEvent):Void 
	{
		var input : Component = e.component;
		var field = input.userData.field;
		var val : Dynamic;
		
		switch(input.userData.type) {
			case ValueType.TFloat :
				val = Std.parseFloat(input.text);
			case ValueType.TInt :
				val = Std.parseFloat(input.text);
			case ValueType.TBool :
				val = cast(input, CheckBox).selected;
			default :
				val = input.text;
		}
		
		var command = new ChangeComponentField(mComponent, field, val);
		mEditor.execute(command);
		
		mLastChange = Lib.getTimer();
	}
	
	function update(e:Event):Void 
	{
		var time = Lib.getTimer();
		if (time - mLastChange < 1000) return;
		for (field in Reflect.fields(mComponent)) {
			var currentInput : Component = mInputs[field];
			if (Std.is(currentInput, CheckBox))
				cast(currentInput, CheckBox).selected = Reflect.field(mComponent, field);
			else
				currentInput.value = Reflect.field(mComponent, field);
		}
	}
	
}