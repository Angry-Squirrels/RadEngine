package fr.radstar.radengine.editor;
import ash.core.Entity;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.CheckBox;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.Component;
import Type;

/**
 * ...
 * @author Thomas BAUDON
 */
class ComponentInspector extends Component
{
	
	var mEntity : Entity;
	
	var mVbox : VBox;
	
	var mAccordion : Accordion;

	public function new() 
	{
		super();
		
		mVbox = new VBox();
		mVbox.percentWidth = 100;
		mVbox.percentHeight = 100;
		addChild(mVbox);
		
		var text = new Text();
		text.text = "Components";
		mVbox.addChild(text);
		
		var hbox = new HBox();
		hbox.percentWidth = 100;
		mVbox.addChild(hbox);
		
		var addBtn : Button = new Button();
		addBtn.text = "add";
		hbox.addChild(addBtn);
		
		var removeBtn : Button = new Button();
		removeBtn.text = "remove";
		hbox.addChild(removeBtn);
		
		mAccordion = new Accordion();
		mAccordion.percentWidth = 100;
		mAccordion.percentHeight = 100;
		mVbox.addChild(mAccordion);
	}
	
	public function setEntity(ent : Entity) {
		if (mEntity != null){
			mEntity.componentRemoved.remove(onCompRemoved);
			mEntity.componentAdded.remove(onCompAdded);
		}
		
		mEntity = ent;
		mEntity.componentAdded.add(onCompAdded);
		mEntity.componentRemoved.add(onCompRemoved);
		
		mAccordion.removeAllChildren();
		
		for (comp in ent.components) {
			var grid : Grid = new Grid();
			grid.columns = 2;
			grid.percentHeight = 100;
			grid.percentWidth = 100;
			grid.userData = comp;
			var compName = Type.getClassName(Type.getClass(comp));
			var nameSplit = compName.split('.');
			compName = nameSplit[nameSplit.length - 1];
			grid.text = compName;
			mAccordion.addChild(grid);
			
			for (field in Reflect.fields(comp)) {
				// ignore private field
				if (field.indexOf("m") == 0) continue;
				
				var text : Text = new Text();
				text.text = field;
				grid.addChild(text);
				
				var input : Component;
				
				var value : Dynamic = Reflect.field(comp, field);
				
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
				
				grid.addChild(input);
			}
		}
	}
	
	function onCompRemoved(ent : Entity, comp : Class<Dynamic>) 
	{
		
	}
	
	function onCompAdded(ent : Entity, comp : Class<Dynamic>) 
	{
		
	}
	
}