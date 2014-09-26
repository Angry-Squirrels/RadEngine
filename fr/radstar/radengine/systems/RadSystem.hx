package fr.radstar.radengine.systems;

/**
 * @author Thomas B
 */

interface RadSystem 
{
	function shouldStop() : Bool;
	
	function pause() : Void;
	
	function resume() : Void;	
}