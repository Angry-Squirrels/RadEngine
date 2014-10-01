package fr.radstar.radengine.core ;
import ash.core.Engine;
import ash.core.Entity;
import haxe.Json;


/**
 * ...
 * @author TBaudon
 */
class Level
{
	
	public var asset : RadAsset;
	
	var mEntitys : Array<Entity>;
	
	public var name : String;
	
	
	public static function getAssetStructure() : Dynamic {
		return { 
			type : "Level",
			entitys : []
		};
	}
	
	public function new() 
	{
		mEntitys = new Array<Entity>();
	}
	
	// set the engine systems and entity
	public function start(engine : Engine) 
	{
		for (entity in mEntitys) engine.addEntity(entity);
	}
	
	public function end() 
	{
		
	}
	
	public function save(path : String)
	{
		if (asset == null)
			asset = RadAsset.create(path, "Level", Level.getAssetStructure());
		
		var engine = RadGame.instance.getEngine();
		mEntitys = new Array<Entity>();
		for (entity in engine.entities) mEntitys.push(entity);
		
		var entityTab = new Array<Dynamic>();
		for (entity in mEntitys) {
			var prefab : Prefab = cast entity;
			var ent = { prefab : prefab.asset.path, name:prefab.name, params : prefab.diff() };
			entityTab.push(ent);
		}
		
		var level = {entitys : entityTab};
		asset.setContent(level);
		asset.save();
	}
	
	public function load(path : String) 
	{
		asset = RadAsset.get(path);
		name = asset.name;
		
		var levelData = asset.getContent();
		// entity list
		var entitys : Array<Dynamic> = levelData.entitys;
		for (current in entitys) {
			var prefab = new Prefab(current.name);
			prefab.load(current.prefab);
			var comps : Array<Dynamic> = current.params;
			for (comp in comps) {
				var compClass = Type.resolveClass(comp.name);
				if (comp.remove) 
					prefab.remove(compClass);
				else {
					var currentComp : Dynamic;
					if (!prefab.has(compClass))
					{
						currentComp = Type.createInstance(compClass, []);
						prefab.add(currentComp);
					}
					else
						currentComp = prefab.get(compClass);
						
					for (field in Reflect.fields(comp.params)){ 
						Reflect.setProperty(currentComp, field, Reflect.getProperty(comp.params, field));
					}
				}
			}
			
			mEntitys.push(prefab);
		}
		
	}
}