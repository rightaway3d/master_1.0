package rightaway3d.house.vo
{
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.view2d.Product2D;

	public class WallSubArea
	{
		/**
		 * 此区域所在的墙体
		 */
		public var cw:CrossWall;
		
		/**
		 * 此区域的开始位置
		 */
		public var x0:Number = 0;
		
		/**
		 * 此区域的结束位置
		 */
		public var x1:Number = 0;
		
		/**
		 * 此区域台面的Y位置
		 */
		public var tableY:int = 800;
		
		private var _length:Number = 0;

		/**
		 * 此区域的长度
		 */
		public function get length():Number
		{
			return x1-x0;
		}

		/**
		 * 当前区域中的地柜子分区
		 */
		public var groundObjects:Array;
		
		/**
		 * 当前区域中的吊柜子分区
		 */
		public var wallObjects:Array;
		
		/**
		 * 当前区域中放置的产品列表（仅当此区域为子分区时）
		 */
		//public var products:Array;
		
		/**
		 * 区域中厨柜的起始偏移量
		 */
		public var startOffset:Number = 0;
		
		/**
		 * 首端障碍物类型
		 */
		public var headType:String;
		
		/**
		 * 尾端障碍物类型
		 */
		public var endType:String;
		
		/**
		 * 起始为拐角柜
		 */
		public var headCorner:Boolean;
		
		/**
		 * 末尾为拐角柜
		 */
		public var endCorner:Boolean;
		
		/**
		 * 水盆定位标志
		 */
		public var drainerFlag:Product2D;
		
		/**
		 * 灶台定位标志
		 */
		public var flueFlag:Product2D;
		
		/**
		 * 首端中高柜或高柜
		 */
		public var headCabinet:ProductObject;
		
		/**
		 * 尾端高柜或高柜
		 */
		public var endCabinet:ProductObject;
		
		/**
		 * 区域可用 
		 */
		public var enable:Boolean = true;
		
		public function WallSubArea()
		{
		}
	}
}




