package fr.radstar.radengine.editor;

/**
 * ...
 * @author Thomas BAUDON
 */
class LevelEditor extends AssetEditor
{

	public function new() 
	{
		super();
		
		sprite.addChild(RadGame.instance.getRenderArea());
	}
	
}