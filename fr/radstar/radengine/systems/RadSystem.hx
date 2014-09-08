package fr.radstar.radengine.systems;

/**
 * @author Thomas B
 */

interface RadSystem 
{
  
	function enterEditMode() : Void;
	
	function leaveEditMode() : Void;
	
	function shouldStop() : Bool;
	
	function pause() : Void;
	
	function resume() : Void;
	
}