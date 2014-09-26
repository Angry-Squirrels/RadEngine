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
	
	public function new(n : String) 
	{
		name = n;
		asset = new RadAsset(name, "Level");
		
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
	
	public function save(engine : Engine)
	{
		mEntitys = new Array<Entity>();
		for (entity in engine.entities) mEntitys.push(entity);
		
		var entityTab = new Array<Dynamic>();
		for (entity in mEntitys) {
			var prefab : Prefab = cast entity;
			var ent = { prefab : prefab.asset.name, name:prefab.name, params : prefab.diff() };
			entityTab.push(ent);
		}
		
		var level = {entitys : entityTab};
		var result = Json.stringify(level, null, '\t');
		asset.content = result;
		asset.save();
	}
	
	public function load() 
	{
		if(asset.exists()){
			var levelData = Json.parse(asset.getContent());
			
			// entity list
			var entitys : Array<Dynamic> = levelData.entitys;
			for (current in entitys) {
				var prefab = new Prefab(current.prefab, current.name);
				prefab.load();
				
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
							
						for (field in Reflect.fields(comp.params)) 
							Reflect.setField(currentComp, field, Reflect.field(comp.params, field));
					}
				}
				
				mEntitys.push(prefab);
			}
		}
	}
}