package fr.radstar.radengine.editor;
import ash.core.Engine;
import ash.core.Entity;
import fr.radstar.radengine.RadGame;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.ScrollView;
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
	
	public function new() 
	{
		Toolkit.theme = new GradientTheme();
		Toolkit.openFullscreen(initToolkit);
		Toolkit.init();
		
		super("editor/main.xml");
		
		mGame = RadGame.instance;
		
		mEngine = mGame.getEngine();
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
		initSystemList();
	}
	
	public function hide() {
		mRoot.removeChild(this.view, false);
		Lib.current.stage.addChild(RadGame.instance);
		clearEntityList();
		clearSystemList();
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
		initComponentList(entity);
	}
	
	function initComponentList(ent : Entity) 
	{
		var compList : Accordion = cast getComponent("components");
		compList.removeAllChildren();
		
		for (comp in ent.components)
			addComponentToList(compList, comp);
	}
	
	function addComponentToList(accordion : Accordion, elem : Dynamic) {
		var scrollView = new ScrollView();
		scrollView.percentWidth = 100;
		scrollView.percentHeight = 100;
		
		var grid = new Grid();
		grid.columns = 2;
		grid.percentWidth = 100;
		scrollView.addChild(grid);
		
		var name = Type.getClassName(Type.getClass(elem));
		var nameSplit = name.split('.');
		name = nameSplit[nameSplit.length - 1];
		
		scrollView.text = name;
		
		accordion.addChild(scrollView);
		
		for (field in Reflect.fields(elem)) {
			var fieldName : String = cast field;
			if (fieldName.indexOf("m") != 0)
			{
				var inputType : ValueType = Type.typeof(Reflect.field(elem, field));
				
				var fieldTxt : Text = new Text();
				fieldTxt.text = field;
				grid.addChild(fieldTxt);
				
				var input : Component;
				
				switch (inputType) {
					case ValueType.TBool :
						var check : CheckBox = new CheckBox();
						var value : Bool = Reflect.getProperty(elem, field);
						check.selected = value;
						check.addEventListener(UIEvent.CHANGE, onChangeCheckBox);
						input = check;
					
					case ValueType.TFloat :
						var inputFloat = new TextInput();
						inputFloat.text = Reflect.getProperty(elem, field);
						inputFloat.addEventListener(UIEvent.CHANGE, onChangeFloat);
						input = inputFloat;
					
					case ValueType.TInt :					
						var inputInt = new TextInput();
						inputInt.text = Reflect.getProperty(elem, field);
						inputInt.addEventListener(UIEvent.CHANGE, onChangeInt);
						input = inputInt;
						
					default :							
						input = new TextInput();
						input.text = Reflect.getProperty(elem, field);
						input.addEventListener(UIEvent.CHANGE, onChangeDefault);
				}
				
				input.userData = { component: elem, field:fieldName };
				input.percentWidth = 100;
				grid.addChild(input);
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
		mGame.togglePause();
		var playPause : Button = cast getComponent("play/pause");
		if (mGame.isPaused()){
			playPause.text = "play";
			playPause.selected = true;
		}
		else{
			playPause.text = "pause";
			playPause.selected = false;
		}
	}
	
	function onStop(e : UIEvent) {
		var playPause : Button = cast getComponent("play/pause");
		playPause.text = "play";
		playPause.selected = false;
		mGame.stop();
	}
	
	function onSceneSelect(e:MenuEvent):Void 
	{
		switch(e.menuItem.id) {
			case 'saveScene' :
			case 'newScene' :
			case 'loadScene' : 
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
	
	function initSystemList() {
		var list : Accordion = cast getComponent("systems");
		for (sys in mEngine.systems) 
			addSystemToList(list, sys);
	}
	
	function sysFieldToExclude(field : String) : Bool {
		if (field.indexOf("m") == 0)
			return true;
			
		var bannedFields : Array<String> = ["next", "previous", "nodeList", "nodeClass"];
		if (bannedFields.indexOf(field) != -1) return true;
		return false;
	}
	
	function addSystemToList(list : Accordion, sys : Dynamic) {
		var scrollView = new ScrollView();
		scrollView.percentWidth = 100;
		scrollView.percentHeight = 100;
		
		var grid = new Grid();
		grid.columns = 2;
		grid.percentWidth = 100;
		scrollView.addChild(grid);
		
		var name = Type.getClassName(Type.getClass(sys));
		var nameSplit = name.split('.');
		name = nameSplit[nameSplit.length - 1];
		
		scrollView.text = name;
		
		list.addChild(scrollView);
		
		for (field in Reflect.fields(sys)) {
			var fieldName : String = cast field;
			
			if (!sysFieldToExclude(field))
			{
				var inputType : ValueType = Type.typeof(Reflect.field(sys, field));
				
				var fieldTxt : Text = new Text();
				fieldTxt.text = field;
				grid.addChild(fieldTxt);
				
				var input : Component;
				
				switch (inputType) {
					case ValueType.TBool :
						var check : CheckBox = new CheckBox();
						var value : Bool = Reflect.getProperty(sys, field);
						check.selected = value;
						input = check;
					
					case ValueType.TFloat :
						var inputFloat = new TextInput();
						inputFloat.text = Reflect.getProperty(sys, field);
						input = inputFloat;
					
					case ValueType.TInt :					
						var inputInt = new TextInput();
						inputInt.text = Reflect.getProperty(sys, field);
						input = inputInt;
						
					default :							
						input = new TextInput();
						input.text = Reflect.getProperty(sys, field);
				}
				
				input.userData = { component: sys, field:fieldName };
				input.percentWidth = 100;
				grid.addChild(input);
			}
		}
	}
	
	function clearSystemList() {
		var list : Accordion = cast getComponent("systems");
		list.removeAllChildren();
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
				//mCommander.exec(command, paramArray);
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