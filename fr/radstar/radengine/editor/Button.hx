package fr.radstar.radengine.editor;

/**
 * ...
 * @author TBaudon
 */
class Button extends GuiElem
{
	
	public var data : Dynamic;

	public function new() 
	{
		super();
		
		buttonMode = true;
		useHandCursor = true;
	}
	
	override function draw() {
		graphics.clear();
		
		graphics.lineStyle(mStyle.border, mStyle.borderColor);
		graphics.beginFill(mStyle.backgroundColor);
		graphics.drawRoundRect(0, 0, mWidth, mHeight, mStyle.borderRadius, mStyle.borderRadius);
		graphics.endFill();
		
		for (i in 0 ... mChildren.length) {
			var current : GuiElem = mChildren[i];
			
			var w = mWidth - mStyle.padding.left - mStyle.padding.right;
			var h = (mHeight - mStyle.padding.top - mStyle.padding.bottom) / mChildren.length;
			
			current.setDim(mWidth - 10, h);
			current.x = mStyle.padding.left;
			current.y = mStyle.padding.top + i * h;
		}
		
		super.draw();
	}
	
}