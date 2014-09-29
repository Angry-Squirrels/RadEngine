package fr.radstar.radengine.core ;
import haxe.io.Path;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author Thomas B
 */
class RadAsset
{
	
	public var path : String;
	public var type : String;
	public var content : Dynamic;
	public var name : String;
	
	private static var mCache : Map<String, RadAsset>;
	
	public static function get(path : String) : RadAsset {
		if (mCache == null)
			mCache = new Map<String, RadAsset>();
			
		var asset : RadAsset= mCache[path];
		if (asset == null) {
			asset = new RadAsset();
			asset.load(path);
			mCache[path] = asset;
		}
		
		return asset;
	}
	
	public static function create(path : String, type : String) : RadAsset {
		var asset = new RadAsset();
		asset.path = path;
		asset.type = type;
		mCache[path] = asset;
		
		return asset;
	}
	
	function new() 
	{
	}
	
	public function getContent() : Dynamic {
		return content;
	}
	
	public function load(path : String) {
		if (FileSystem.exists(path)) {
			this.path = path;
			var p : Path = new Path(path);
			this.name = p.file;
			this.name = name.split('.')[0];
			content = Json.parse(File.getContent(path));
			this.type = content.type;
		}
	}
	
	public function save() {
		if (content == null)
			content = { };
		Reflect.setField(content, "type", type);
		var p : Path = new Path(path);
		FileSystem.createDirectory(p.dir);
		
		File.saveContent(path, Json.stringify(content));
	}
	
	public function exists() : Bool {
		return FileSystem.exists(path);
	}
	
	public function equals(assets : RadAsset) {
		return (path == assets.path);
	}
	
}