package fr.radstar.radengine;
import haxe.io.Path;
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
	public var content : String;
	
	public function new(name : String, type : String) 
	{
		this.path = type+"/"+name+".radAsset";
	}
	
	public function getContent() : String {
		if (FileSystem.exists(path))
			content = File.getContent(path);
		return content;
	}
	
	public function save() {
		if (content == null)
			content = "{}";
		var p : Path = new Path(path);
		FileSystem.createDirectory(p.dir);
		File.saveContent(path, content);
	}
	
}