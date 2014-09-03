package fr.radstar.radengine;
import ash.core.Engine;
import ash.core.Entity;
import ash.core.System;
import haxe.io.Path;
import haxe.Json;
import openfl.Assets;

/**
 * ...
 * @author TBaudon
 */
class Scene
{
	
	var mPath : Path;
	
	
	var mSystems : Array<System>;
	var mEntitys : Array<Entity>;

	public function new(sceneName : String) 
	{
		mPath = new Path("scenes/" + sceneName + ".json");
		
		mSystems = new Array<System>();
		mEntitys = new Array<Entity>();
		
		load();
	}
	
	public function update(deltaTime : Float) {
		
	}
	
	// set the engine systems and entity
	public function start(engine : Engine) 
	{
		for (system in mSystems) engine.addSystem(system,0);
		for (entity in mEntitys) engine.addEntity(entity);
	}
	
	public function end() 
	{
		
	}
	
	public function pause()
	{
		
	}
	
	/**
	 * Read from json scene file systems to use and entity
	 */
	function load() 
	{
		var json = Assets.getText(mPath.toString());
		var sceneData = Json.parse(json);
		
		// systems list
		var systems : Array<Dynamic> = sceneData.systems;
		for (current in systems) loadSystem(current);
		
		// entity list
		var entitys : Array<Dynamic> = sceneData.entitys;
		for (current in entitys) loadEntity(current);
	}
	
	function loadSystem(current : Dynamic) {
		var systemClassName = 'fr.radstar.radengine.systems.' + current;
		var systemClass = Type.resolveClass(systemClassName);
		var system = Type.createInstance(systemClass, []);
		mSystems.push(system);
	}
	
	function loadEntity(current : Dynamic) {
		var entity = new Entity(current.name);
		mEntitys.push(entity);
		
		var comps : Array<Dynamic> = current.components;
		for (current in comps) {
			var comp = loadComponent(current);
			entity.add(comp, Type.getClass(comp));
		}
	}
	
	function loadComponent(current : Dynamic) : Dynamic {
		var compClassName = "fr.radstar.radengine.components." + current.name;
		var compClass = Type.resolveClass(compClassName);
		var comp = Type.createInstance(compClass, []);
		var params = current.params;
		
		for (field in Reflect.fields(params)) {
			var value = Reflect.getProperty(params, field);
			Reflect.setField(comp, field, value);
		}
		
		return comp;
	}
}