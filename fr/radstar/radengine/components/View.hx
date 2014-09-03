package fr.radstar.radengine.components;
import openfl.display.Sprite;

/**
 * ...
 * @author TBaudon
 */
class View extends Sprite
{

	public function new() 
	{
		super();
		
		graphics.beginFill(0xff0000);
		graphics.drawCircle(0, 0, 50);
	}
	
}