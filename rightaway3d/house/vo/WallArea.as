package rightaway3d.house.vo
{
	import rightaway3d.engine.product.ProductObject;

	public class WallArea extends BaseVO
	{
		/**
		 * 墙体区域的最小长度
		 */
		static public var MinLength:int = 1000;
		/**
		 * 墙体区域端点到墙体的最小间距
		 */
		static public var MinDist:int = 50;
		
		/**
		 * 此区域所在的墙体
		 */
		public var wall:Wall;
		
		/**
		 * 此区域的开始位置
		 */
		public var x0:Number = 0;
		
		/**
		 * 此区域的结束位置
		 */
		public var x1:Number = 0;
		/**
		 * 此区域的长度
		 */
		public function get length():Number
		{
			return x1-x0;
		}
		
		/**
		 * 此区域范围的最小限制值
		 */
		public var maxX:Number = 0;
		/**
		 * 此区域范围的最大限制值
		 */
		public var minX:Number = 0;
		
		/**
		 * 是否允许编辑此区域的头部
		 */
		public var headEnable:Boolean = true;
		/**
		 * 是否允许编辑此区域的尾部
		 */
		public var endEnable:Boolean = true;
		
		/**
		 * 初始类型
		 */
		public var headType0:String;
		/**
		 * 编辑后的类型
		 */
		public var headType1:String;
		
		/**
		 * 初始类型
		 */
		public var endType0:String;
		/**
		 * 编辑后的类型
		 */
		public var endType1:String;
		
		/**
		 * 首端有拐角柜
		 */
		public var headCorner:Boolean;
		
		/**
		 * 尾端有拐角柜
		 */
		public var endCorner:Boolean;
		
		/**
		 * 首端中高柜或高柜
		 */
		public var headCabinet:ProductObject;
		
		/**
		 * 尾端高柜或高柜
		 */
		public var endCabinet:ProductObject;
		
		/**
		 * 此区域是否有效
		 */
		public var enable:Boolean = true;
		
		public function WallArea()
		{
		}
		
		public function clearCabinetFlag():void
		{
			if(this.headCabinet)
			{
				this.headCabinet.dispose();
				this.headCabinet = null;
			}
			if(this.endCabinet)
			{
				this.endCabinet.dispose();
				this.endCabinet = null;
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			clearCabinetFlag();
			this.wall = null;
		}
	}
}