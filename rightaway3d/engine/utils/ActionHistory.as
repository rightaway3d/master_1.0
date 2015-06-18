package rightaway3d.engine.utils
{
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.editor2d.CabinetController;
	import rightaway3d.house.editor2d.SceneParser;

	public class ActionHistory
	{
		private var undoList:Array = [];//可以取消的操作列表
		private var redoList:Array = [];//可以重做的操作列表
		
//		private var productManager:ProductManager = ProductManager.own;
//		private var cabinetCtrller:CabinetController = CabinetController.getInstance();
		
		public function undo():void
		{
			trace("-------undo:"+undoList.length);
			if(undoList.length>0)
			{
				var o:Object = undoList.pop();
				var action:String = o.action;
				var data:* = o.data;
				
				switch(action)
				{
					case ActionType.DELETE:
						var json:Object = JSON.parse(data);
						//var po:ProductObject = ProductManager.own.parseProductObject(json);
						var po:ProductObject = SceneParser.own.parseProduct(json);
						ProductManager.own.loadProduct();
						
						o.data = po;
						redoList.push(o);
						break;
					
				}
			}
		}
		
		public function redo():void
		{
			trace("-------redo:"+redoList.length);
			if(redoList.length>0)
			{
				var o:Object = redoList.pop();
				var action:String = o.action;
				var data:* = o.data;
				//trace("action:"+action);
				switch(action)
				{
					case ActionType.DELETE:
						CabinetController.getInstance().deleteProduct(data,true);
						break;
					
				}
			}
		}
		
		public function clear():void
		{
			undoList.length = 0;
			redoList.length = 0;
		}
		
		public function addAction(actionName:String,data:*,isRedoCMD:Boolean=false):void
		{
			var o:Object = {action:actionName,data:data};
			undoList.push(o);
			
			//如果是在执行redo时，则不清空redoList
			if(!isRedoCMD)redoList.length = 0;
		}
		
		//==============================================================================================
		public function ActionHistory(value:InstanceClass)
		{
			if(!value)
			{
				throw new Error("ActionHistory是一个单例类，请用静态方法getInstance()方法来获得类的实例。");
			}
			
			//initCabinetData();
		}
		
		//==============================================================================================
		static private var instance:ActionHistory;
		
		static public function getInstance():ActionHistory
		{
			instance ||= new ActionHistory(new InstanceClass());
			return instance;
		}
		
		//==============================================================================================
	}
}

class InstanceClass{}

