package rightaway3d.house.editor2d
{
	import flash.display.Sprite;
	
	import rightaway3d.house.view2d.BackGrid2D;
	import rightaway3d.house.view2d.Base2D;
	import rightaway3d.house.view2d.Floor2D;
	import rightaway3d.house.view2d.House2D;
	import rightaway3d.house.view2d.NodeController2D;
	import rightaway3d.house.view2d.Product2D;
	import rightaway3d.house.view2d.Room2D;
	import rightaway3d.house.view2d.Wall2D;
	import rightaway3d.house.vo.Floor;
	
	public class Scene2D extends Base2D
	{
		/**
		 * 场景宽度的屏幕尺寸
		 */
		static public var sceneWidth:int = 4000;
		/**
		 * 场景高度的屏幕尺寸
		 */
		static public var sceneHeight:int = 4000;
		
		/**
		 * 场景宽度，单位mm
		 * @return 
		 * 
		 */
		static public function get sceneWidthSize():int
		{
			return screenToSize(sceneWidth);
		}
		
		/**
		 * 场景高度，单位mm
		 * @return 
		 * 
		 */
		static public function get sceneHeightSize():int
		{
			return screenToSize(sceneHeight);
		}
		
		//===============================================		
		public var backGrid:BackGrid2D;
		
		public var house:House2D;
		
		public var products:Sprite;
		
		public var wallNodes:NodeController2D;
		
		public function Scene2D()
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.mouseChildren = true;
			this.focusRect = false;
			
			backGrid = new BackGrid2D();
			this.addChild(backGrid);
			
			house = new House2D();
			this.addChild(house);
			
			products = new Sprite();
			this.addChild(products);
			
			this.wallNodes = NodeController2D.getInstance();
			this.addChild(this.wallNodes);
			this.wallNodes.scene = this;
		}
		
		public function createFloor(floor:Floor):void
		{
			house.createFloor(floor);
		}
		//=========================================================================================================================
		
		public function get currFloor():Floor2D
		{
			return house.currFloor;
		}
		
		public function removeAllFloors():void
		{
			house.vo.removeAllFloor();
			/*for each(var floor:Floor2D in house.floors)
			{
				floor.vo.dispose();
			}*/
		}
		
		public function addWall(wall:Wall2D):void
		{
			house.addWall(wall);
		}
		
		public function removeWall(wall:Wall2D):void
		{
			house.removeWall(wall);
		}
		
		public function addRoom(room:Room2D):void
		{
			house.addRoom(room);
		}
		
		public function removeRoom(room:Room2D):void
		{
			house.removeRoom(room);
		}
		
		private var level0Products:Array = [];
		public function addProduct(p:Product2D,level:int=0):void
		{
			//trace("addProduct level:",level);
			if(level==0)//放置到显示列表最底层
			{
				products.addChildAt(p,level0Products.length);
				level0Products.push(p);
			}
			else if(level==1)//放置到显示列表中间层
			{
				products.addChildAt(p,level0Products.length);
			}
			else
			{
				products.addChild(p);//放置到显示列表最上层
			}
			//trace("addProduct level0Products:",level0Products.length);
		}
		
		public function removeProduct(p:Product2D,level:int=0):void
		{
			//trace("removeProduct level:",level);
			products.removeChild(p);
			if(level==0)
			{
				level0Products.splice(level0Products.indexOf(p),1);//清除最底层产品
			}
			//trace("removeProduct level0Products:",level0Products.length);
		}
		
		/*public function addSizeMark(value:SizeMarking2D):void
		{
			house.addSizeMark(value);
		}*/
		
		public function render():void
		{
			house.render();
		}
		
		/*public function toJsonString():String
		{
			var s:String = house.vo.toJsonString();
			return s;
		}*/
	}
}



















