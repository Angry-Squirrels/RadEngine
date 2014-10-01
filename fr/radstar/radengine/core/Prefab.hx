package fr.radstar.radengine.core ;
import ash.core.Entity;
import haxe.Json;
import Type;

/**
 * ...
 * @author Thomas B
 */
class Prefab extends Entity
{
	
	public var asset : RadAsset;

	public static function getAssetStructure() : Dynamic {
		return { 
			type : "Prefab",
			components : []
		};
	}
	
	public function new(instanceName : String) 
	{
		super(instanceName);
	}
	
	public function load(path : String) {
		asset = RadAsset.get(path);
		
		var loaded = asset.getContent();
		
		var components : Array<Dynamic> = loaded.components;
		for (comp in components) {
			var compClass = comp.name;
			var newComp = Type.createInstance(Type.resolveClass(compClass), []);
			var params = comp.params;
			for (param in Reflect.fields(params))
				Reflect.setProperty(newComp, param, Reflect.getProperty(params, param));
			add(newComp);
		}
	}
	
	/**
	 * List diff between the instance and the prefab
	 */
	public function diff() : Dynamic {
		var loaded = asset.getContent();
		var baseComps : Array<Dynamic> = loaded.components;
		var compToRemove = new Array<String>();
		var diffs = new Array<Dynamic>();
		
		for (comp in components) {
			var compName = Type.getClassName(Type.getClass(comp));
			var orignalComp = getCompByName(compName, baseComps);
			
			// this component is not in the original prefab
			if (orignalComp == null) {
				
				var p = { };
				for (field in Reflect.fields(comp)) {
					if (field.indexOf("m") == 0) continue;
					Reflect.setProperty(p, field, Reflect.getProperty(comp, field));
				}
				diffs.push( { name:compName, params : p } );	
			}else{
			
				var diff = getDiffBetweenTwoComp(orignalComp.params, comp);
				if (diff != null) {
					var obj = { };
					Reflect.setField(obj, "name", compName);
					Reflect.setField(obj, "params", diff);
					diffs.push(obj);
				}
			}
		}
		
		// removed components
		for (comp in baseComps) {
			if (getCompByClass(comp.name) == null)
			{
				var obj = { };
				Reflect.setField(obj, "name", comp.name);
				Reflect.setField(obj, "remove", true);
				diffs.push(obj);
			}
		}
		
		return diffs;
	}
	
	function getCompByClass(className : String) : Dynamic {
		for (comp in components) {
			if (Type.getClassName(Type.getClass(comp)) == className)
				return comp;
		}
		return null;
	}
	
	function getCompByName(name : String, comps : Array<Dynamic>) : Dynamic {
		for (comp in comps) {
			if (comp.name == name)
				return comp;
		}
		return null;
	}
	
	function getDiffBetweenTwoComp(original : Dynamic, instance : Dynamic) : Dynamic {
		var diff = { };
		for (field in Reflect.fields(original)) {
			
			if (field.indexOf("m") == 0) continue;
			
			var valueA  = Reflect.getProperty(original, field);
			var valueB  = Reflect.getProperty(instance, field);
			if (valueA != valueB) 
				Reflect.setField(diff, field, valueB);
		}
		if (Reflect.fields(diff).length == 0) return null;
		return diff;
	}
	
	public function save(path : String) {
		if (asset == null)
			asset = RadAsset.create(path, "Prefab", Prefab.getAssetStructure());
		
		// parse components
		var compArray = new Array<Dynamic>();
		for (comp in components) {
			var compName = Type.getClassName(Type.getClass(comp));
			var params = { };
			for (field in Reflect.fields(comp)) { 
				if (field.indexOf("m") != 0) 
					Reflect.setField(params, field, Reflect.getProperty(comp, field));
			}
			var pushedComp = { name : compName, params : params };
			compArray.push(pushedComp);
		}
		
		var obj = {
			components : compArray
		};
		
		asset.setContent(obj);
		asset.save();
	}
	
}