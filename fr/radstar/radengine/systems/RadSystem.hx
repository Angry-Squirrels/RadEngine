package fr.radstar.radengine.systems;

/**
 * @author Thomas B
 */

interface RadSystem 
{
	function shouldPause() : Bool;
	
	function pause() : Void;
	
	function resume() : Void;	
}