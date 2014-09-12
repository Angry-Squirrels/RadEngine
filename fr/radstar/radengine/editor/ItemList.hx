package fr.radstar.radengine.editor;

/**
 * ...
 * @author Thomas B
 */
class ItemList extends GuiElem
{
	
	var mScrollPane : ScrollPane;
	var mScrollBar : VScrollBar;
	
	var mItemMap : Map<String, Label>;
	var mDataMap : Map<String, Dynamic>;
	
	var mNbItem : UInt;

	public function new() 
	{
		super();
		
		mNbItem = 0;
		
		mItemMap = new Map<String, Label>();
		mDataMap = new Map<String, Dynamic>();
		
		mScrollPane = new ScrollPane();
		add(mScrollPane);
		
		mScrollBar = new VScrollBar();
		mScrollBar.connect(mScrollPane);
		add(mScrollBar);
		
		mScrollPane.setDim(200, 200);
	}
	
	public function addItem(name : String, data : Dynamic) {
		var item = new Label(name);
		item.y = item.height * mNbItem;
		mScrollPane.add(item);
		mItemMap[name] = item;
		mDataMap[name] = data;
		
		mNbItem++;
		
		invalidate();
	}
	
	public function removeItem(name : String) {
		var item = mItemMap[name];
		
		mItemMap[name] = null;
		mDataMap[name] = null;
		
		mScrollPane.remove(item);
		
		mNbItem--;
		
		invalidate();
	}
	
}