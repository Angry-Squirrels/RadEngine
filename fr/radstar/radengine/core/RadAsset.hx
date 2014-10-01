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
	public var name : String;
	
	var mContent : Dynamic;
	
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
	
	public static function create(path : String, type : String, baseContent : Dynamic) : RadAsset {
		var asset = new RadAsset();
		asset.path = path;
		asset.type = type;
		asset.mContent = baseContent;
		mCache[path] = asset;
		asset.setNameFromPath(path);
		
		return asset;
	}
	
	public static function getEmpty(type : String) : RadAsset {
		var asset = create('empty/$type', type, null );
		return asset;
	}
	
	function new() 
	{
	}
	
	function setNameFromPath(path : String) {
		var p : Path = new Path(path);
		this.name = p.file;
		this.name = name.split('.')[0];
	}
	
	public function getContent() : Dynamic {
		return mContent;
	}
	
	public function setContent(content) : Dynamic {
		mContent = content;
		return mContent;
	}
	
	public function load(path : String) {
		if (FileSystem.exists(path)) {
			this.path = path;
			setNameFromPath(path);
			mContent = Json.parse(File.getContent(path));
			this.type = mContent.type;
		}
	}
	
	public function save() {
		if (mContent == null)
			mContent = { };
		Reflect.setField(mContent, "type", type);
		var p : Path = new Path(path);
		FileSystem.createDirectory(p.dir);
		
		File.saveContent(path, Json.stringify(mContent, null, "\t"));
	}
	
	public static function replacer(key : Dynamic, value : Dynamic) : Dynamic {
		if (Type.getClass(value) == RadAsset)
		{
			return cast(value, RadAsset).path;
		}
		else 
			return value;
	}
	
	public function exists() : Bool {
		return FileSystem.exists(path);
	}
	
	public function equals(assets : RadAsset) {
		return (path == assets.path);
	}
	
}