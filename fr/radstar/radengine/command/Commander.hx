package fr.radstar.radengine.command;

/**
 * ...
 * @author TBaudon
 */
class Commander
{
	
	static var mInstance : Commander;

	public static function getInstance() : Commander{
		if (mInstance == null) {
			mInstance = new Commander();
		}
		return mInstance;
	}
	
	/*========================*/
	
	var mCommands : Map<String, {target : Dynamic, method : Dynamic}>;
	
	function new() 
	{
		mCommands = new Map<String, {target : Dynamic, method : Dynamic}>();
	}
	
	public function add(object : Dynamic, func : Dynamic, alias : String) {
		mCommands[alias] = { target : object, method : func };
	}
	
	public function remove(alias : String) {
		mCommands[alias] = null;
	}
	
	public function exec(command : String, params : Array<Dynamic> = null) {
		var current = mCommands[command];
		if (current != null) {
			try {
				Reflect.callMethod(current.target, current.method, params);
			}catch (e : Dynamic) {
				trace(e);
			}
		}else {
			trace("No such command");
		}
	}
	
}