package fr.radstar.radengine.editor.command;

/**
 * @author Thomas BAUDON
 */

interface ICommand 
{
	function exec() : Void;
	function undo() : Void;
}