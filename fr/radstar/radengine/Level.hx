package fr.radstar.radengine;
import ash.core.Engine;
import ash.core.Entity;
import ash.core.System;
import haxe.io.Path;
import haxe.Json;
import openfl.Assets;

import sys.io.File;

/**
 * ...
 * @author TBaudon
 */
class Level
{
	
	public var asset : RadAsset;
	
	var mSystems : Array<System>;
	var mEntitys : Array<Entity>;
	
	public var name : String;
	
	public function new(n : String, autoLoad : Bool = true) 
	{
		name = n;
		asset = new RadAsset(name, "Level");
		
		mSystems = new Array<System>();
		mEntitys = new Array<Entity>();
		
		if(autoLoad)
			load();
	}
	
	// set the engine systems and entity
	public function start(engine : Engine) 
	{
		for (entity in mEntitys) engine.addEntity(entity);
	}
	
	public function end() 
	{
		
	}
	
	public function pause()
	{
		
	}
	
	public function save(engine : Engine)
	{
		mSystems = new Array<System>();
		for (system in engine.systems) mSystems.push(system);
		
		mEntitys = new Array<Entity>();
		for (entity in engine.entities) mEntitys.push(entity);
		
		var sysTab = new Array<String>();
		for (system in mSystems) {
			var name = Type.getClassName(Type.getClass(system));
			var split = name.split('.');
			name = split[split.length - 1];
			sysTab.push(name);
		}
		
		var entityTab = new Array<Dynamic>();
		for (entity in mEntitys) {
			
			var compTab = new Array<Dynamic>();
			for (comp in entity.components) {
				
				var compName = Type.getClassName(Type.getClass(comp));
				var compSplit = compName.split('.');
				compName = compSplit[compSplit.length - 1];
				compTab.push( { name : compName, params : comp } );
			}
			
			var ent = { name : entity.name, components : compTab };
			entityTab.push(ent);
		}
		
		var level = { systems : sysTab, entitys : entityTab };
		var result = Json.stringify(level, replace, '\t');
		asset.content = result;
		asset.save();
	}
	
	function replace(key : Dynamic, value : Dynamic) : Dynamic {
		var name : String = cast key;
		if (name.indexOf('m') == 0)
			return null;
		return value;
	}
	
	/**
	 * Read from json scene file systems to use and entity
	 */
	function load() 
	{
		var levelData = Json.parse(asset.getContent());
		
		// systems list
		var systems : Array<Dynamic> = levelData.systems;
		for (current in systems) loadSystem(current);
		
		// entity list
		var entitys : Array<Dynamic> = levelData.entitys;
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