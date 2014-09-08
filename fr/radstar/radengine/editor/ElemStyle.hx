package fr.radstar.radengine.editor;

/**
 * ...
 * @author TBaudon
 */
class ElemStyle
{

	public var backgroundColor : UInt = 0xcccccc;
	public var border : UInt = 2;
	public var borderColor : UInt = 0x999999;
	public var borderRadius : UInt = 10;
	
	public var padding : { top : Int, left : Int, bottom : Int, right : Int };
	
	public var fontSize : UInt = 16;
	public var fontFamily : String = "arial";
	public var fontColor : UInt = 0x000000;
	
	public function new() 
	{
		padding = { top:2, left:5, bottom:2, right:5 };
	}
	
}