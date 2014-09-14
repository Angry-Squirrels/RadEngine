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
	
	public function add(ohject : Dynamic, func : Dynamic, alias : String) {
		mCommands[alias] = { target : ohject, method : func };
	}
	
	public function remove(alias : String) {
		mCommands[alias] = null;
	}
	
	public function exec(command : String, params : Array<Dynamic>) {
		var current = mCommands[command];
		if (current != null) {
			try {
				trace(current.target, current.method);
				Reflect.callMethod(current.target, current.method, params);
			}catch (e : Dynamic) {
				trace(e);
			}
		}else {
			trace("No such command");
		}
	}
	
}