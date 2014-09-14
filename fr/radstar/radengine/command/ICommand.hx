package fr.radstar.radengine.command;

/**
 * ...
 * @author TBaudon
 */
interface ICommand
{

	function exec() : Void;
	function undo() : Void;
	
}