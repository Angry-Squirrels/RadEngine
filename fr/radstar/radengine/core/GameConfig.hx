package fr.radstar.radengine.core ;
import haxe.Json;

/**
 * ...
 * @author Thomas B
 */
class GameConfig
{
	
	public var asset : RadAsset;
	
	public var initialLevel : String;
	public var systemList : Array<Dynamic>;
	
	var mGame : RadGame;

	public function new() 
	{
		asset = RadAsset.get("assets/Config/game.radasset");
		
		mGame = RadGame.instance;
	}
	
	public function load() {
		if(asset.exists()){
			var loaded = asset.getContent();
			initialLevel = loaded.baseLevel;
			systemList = loaded.systems;
		}
	}
	
	public function save() {
		
		var systems = mGame.getEngine().systems;
		var fieldToExclude = ["next", "previous", "nodeList", "nodeClass"];
		
		var config = { };
		var sysList = new Array<Dynamic>();
		
		for (system in systems) {
			var sys = { };
			var sysName = Type.getClassName(Type.getClass(system));
			Reflect.setField(sys, "name", sysName);
			
			var params = { };
			for (field in Reflect.fields(system)) 
				if (fieldToExclude.indexOf(field) == -1 && field.indexOf("m") != 0) 
					Reflect.setField(params, field, Reflect.field(system, field));
			Reflect.setField(sys, "params", params);
			sysList.push(sys);
		}
		
		Reflect.setField(config, "baseLevel", mGame.getBaseLevel());
		Reflect.setField(config, "systems", sysList);
		
		asset.setContent(config);
		asset.save();
	}
	
}