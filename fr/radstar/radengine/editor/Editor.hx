package fr.radstar.radengine.editor;
import ash.core.Engine;
import ash.core.Entity;
import fr.radstar.radengine.command.Commander;
import fr.radstar.radengine.RadGame;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.CheckBox;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.XMLController;
import haxe.ui.toolkit.events.MenuEvent;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.themes.GradientTheme;
import openfl.Lib;
import Type;

/**
 * ...
 * @author Thomas B
 */
class Editor extends XMLController
{

	var mEngine : Engine;
	var mGame : RadGame;
	
	var mRoot : Root;
	
	var mCommander : Commander;
	
	public function new(engine : Engine, game : RadGame) 
	{
		Toolkit.theme = new GradientTheme();
		Toolkit.openFullscreen(initToolkit);
		Toolkit.init();
		
		mCommander = Commander.getInstance();
		
		super("editor/main.xml");
		
		mEngine = engine;
		mEngine.entityAdded.add(onEntityAdded);
		mEngine.entityRemoved.add(onEntityRemoved);

		bindEvents();
	}
	
	public function show() {
		mRoot.addChild(this.view);
		var comp : Component = getComponent("renderZone");
		comp.clipContent = true;
		comp.sprite.addChild(RadGame.instance);
		initEntityList();
	}
	
	public function hide() {
		mRoot.removeChild(this.view, false);
		Lib.current.stage.addChild(RadGame.instance);
		clearEntityList();
	}
	
	function initToolkit(root : Root) {				
		mRoot = root;
		mRoot.addChild(this.view);
	}
	
	function bindEvents() 
	{
		attachEvent("menuScene", MenuEvent.SELECT, onSceneSelect);
		attachEvent("menuEntity", MenuEvent.SELECT, onEntitySelect);
		attachEvent("play/pause", UIEvent.CLICK, onPlayPauseClicked);
		attachEvent("stop", UIEvent.CLICK, onStop);
		attachEvent("entities", UIEvent.CLICK, onEntityListClicked);
	}
	
	function onEntityListClicked(e : UIEvent) 
	{
		var list : ListView = cast getComponent("entities");
		if(list.selectedIndex != -1){
			var entity : Entity = list.getItem(list.selectedIndex).data.userData;
			onEntitySelected(entity);
		}
	}
	
	function onEntitySelected(entity : Entity) {
		mCommander.exec("select", [entity.name]);
		initComponentList(entity);
	}
	
	function initComponentList(ent : Entity) 
	{
		var compList : Accordion = cast getComponent("components");
		compList.removeAllChildren();
		
		for (comp in ent.components) {
			var vbox = new VBox();
			var name = Type.getClassName(Type.getClass(comp));
			var nameSplit = name.split('.');
			name = nameSplit[nameSplit.length - 1];
			vbox.text = name;
			compList.addChild(vbox);
			for (field in Reflect.fields(comp)) {
				var fieldName : String = cast field;
				if (fieldName.indexOf("m") != 0)
				{
					var inputType : ValueType = Type.typeof(Reflect.field(comp, field));
					
					switch (inputType) {
						case ValueType.TBool :
							var check : CheckBox = new CheckBox();
							var value : Bool = Reflect.getProperty(comp, field);
							check.selected = value;
							check.text = field;
							check.userData = { component: comp, field:fieldName };
							check.addEventListener(UIEvent.CHANGE, onChangeCheckBox);
							check.percentWidth = 100;
							vbox.addChild(check);
						
						case ValueType.TFloat :
							var text : Text = new Text();
							text.text = field;
							vbox.addChild(text);
							
							var inputFloat = new TextInput();
							inputFloat.text = Reflect.getProperty(comp, field);
							inputFloat.userData = { component: comp, field:fieldName };
							inputFloat.addEventListener(UIEvent.CHANGE, onChangeFloat);
							inputFloat.percentWidth = 100;
							vbox.addChild(inputFloat);
						
						case ValueType.TInt :
							var text : Text = new Text();
							text.text = field;
							vbox.addChild(text);
							
							var inputInt = new TextInput();
							inputInt.text = Reflect.getProperty(comp, field);
							inputInt.userData = { component: comp, field:fieldName };
							inputInt.addEventListener(UIEvent.CHANGE, onChangeInt);
							inputInt.percentWidth = 100;
							vbox.addChild(inputInt);
							
						default :
							var text : Text = new Text();
							text.text = field;
							vbox.addChild(text);
							
							var input = new TextInput();
							input.text = Reflect.getProperty(comp, field);
							input.userData = { component: comp, field:fieldName };
							input.addEventListener(UIEvent.CHANGE, onChangeDefault);
							input.percentWidth = 100;
							vbox.addChild(input);
					}
				}
			}
		}
	}
	
	function onChangeDefault(e:UIEvent):Void 
	{
		var input : TextInput = cast e.displayObject;
		
		try {
			var comp = input.userData.component;
			var field = input.userData.field;
			Reflect.setProperty(comp, field, input.text);
		}catch (e : Dynamic) {
			trace(e);
		}
	}
	
	function onChangeCheckBox(e:UIEvent):Void {
		var checkBox : CheckBox = cast e.displayObject;
		try {
			var comp = checkBox.userData.component;
			var field = checkBox.userData.field;
			Reflect.setProperty(comp, field, checkBox.selected);
		}catch (e : Dynamic) {
			trace(e);
		}
	}
	
	function onChangeFloat(e:UIEvent):Void {
		var floatInput : TextInput = cast e.displayObject;
		var allowedChar = "1234567890.-";
		
		var val : String = floatInput.text;
		for (i in 0 ... val.length) {
			if (allowedChar.indexOf(val.charAt(i)) == -1)
				val = val.substr(0, i) + val.substr(i + 1);
		}
		
		floatInput.text = val;
		
		try {
			var comp = floatInput.userData.component;
			var field = floatInput.userData.field;
			Reflect.setProperty(comp, field, floatInput.text);
		}catch (e : Dynamic) {
			trace(e);
		}
	}
		
	function onChangeInt(e:UIEvent):Void {
		var intInput : TextInput = cast e.displayObject;
		var allowedChar = "1234567890-";
		
		var val : String = intInput.text;
		for (i in 0 ... val.length) {
			if (allowedChar.indexOf(val.charAt(i)) == -1)
				val = val.substr(0, i) + val.substr(i + 1);
		}
		
		intInput.text = val;
		
		try {
			var comp = intInput.userData.component;
			var field = intInput.userData.field;
			Reflect.setProperty(comp, field, intInput.text);
		}catch (e : Dynamic) {
			trace(e);
		}
	}
	
	function onPlayPauseClicked(e : UIEvent) 
	{
		var playPause : Button = cast getComponent("play/pause");
		if (playPause.selected){
			playPause.text = "play";
			mCommander.exec("pause");
		}
		else{
			playPause.text = "pause";
			mCommander.exec("resume");
		}
	}
	
	function onStop(e : UIEvent) {
		var playPause : Button = cast getComponent("play/pause");
		playPause.text = "play";
		playPause.selected = false;
		mCommander.exec("stop");
	}
	
	function onSceneSelect(e:MenuEvent):Void 
	{
		switch(e.menuItem.id) {
			case 'saveScene' :
				mCommander.exec("save", []);
			case 'newScene' :
				commandWithParam("createScene", [ { name:"name", fieldClass:TextInput } ]);
			case 'loadScene' : 
				commandWithParam("load", [ { name:"name", fieldClass:TextInput } ]);
		}
	}
	
	function onEntitySelect(e:MenuEvent):Void 
	{
		switch(e.menuItem.id) {
			case 'createEntity' :
				commandWithParam("create", [ { name:"name", fieldClass:TextInput } ]);

		}
	}
	
	function initEntityList() {
		var list : ListView = cast getComponent("entities");
		for (ent in mEngine.entities) {
			list.dataSource.add( { text: ent.name, userData: ent } );
		}
	}
	
	function commandWithParam(command : String, params : Array<{name:String, fieldClass : Class<Component>}>) {
		var vbox = new VBox();
		vbox.percentWidth = 100;
		var fields = new Array<Component>();
		
		for (param in params) {
			var name : Text = new Text();
			name.text = param.name;
			
			var input : Component = Type.createInstance(param.fieldClass, []);
			input.percentWidth = 100;
			vbox.addChild(name);
			vbox.addChild(input);
			fields.push(input);
		}
		
		PopupManager.instance.showCustom(vbox, command, PopupButton.CONFIRM | PopupButton.CANCEL, function (button) {
			if (button == PopupButton.CONFIRM) {
				var paramArray = new Array<Dynamic>();
				for (field in fields) {
					paramArray.push(field.value);
				}
				mCommander.exec(command, paramArray);
			}
		});
	}
	
	function clearEntityList() {
		var list : ListView = cast getComponent("entities");
		list.dataSource.removeAll();
	}
	
	function onEntityRemoved(ent : Entity) 
	{
		var list : ListView = cast getComponent("entities");
		list.dataSource.moveFirst();
		
		do {
			var current = list.dataSource.get();
			if (current.userData == ent)
			{
				list.dataSource.remove();
				break;
			}
		}while(list.dataSource.moveNext());
	}
	
	function onEntityAdded(ent : Entity) {
		var list : ListView = cast getComponent("entities") ;
		list.dataSource.add({ text: ent.name, userData: ent });
	}
}