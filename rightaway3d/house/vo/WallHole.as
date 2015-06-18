package rightaway3d.house.vo
{
	public class WallHole extends BaseVO
	{
		public var wall:Wall;
		
		/**
		 * 墙体正面的数据
		 */
		public var objectInfo:WallObject;
		
		/**
		 * 墙体背面的数据
		 */
		public var objectInfo2:WallObject;
		
		//public var points:Vector.<Point> = new Vector.<Point>();//以逆时针方针组成的一个闭合多边形来作为墙洞洞口
		
		//public var rect:Rectangle = new Rectangle();
		private var _x:int = 0;

		/**
		 * 洞口在墙体XY面上的x位置
		 */
		public function get x():int
		{
			return _x;
		}

		/**
		 * @private
		 */
		public function set x(value:int):void
		{
			if(_x==value)return;
			
			_x = value;
			
			objectInfo.x = value + width;
			objectInfo2.x = value;
			
			this.isChanged = true;
		}

		private var _y:int = 0;

		/**
		 * 洞口在墙体XY面上的y位置
		 */
		public function get y():int
		{
			return _y;
		}

		/**
		 * @private
		 */
		public function set y(value:int):void
		{
			if(_y==value)return;
			
			_y = value;
			
			objectInfo.y = value;
			objectInfo2.y = value;
			
			this.isChanged = true;
		}

		private var _width:int = 800;

		/**
		 * 洞口宽度
		 */
		public function get width():int
		{
			return _width;
		}

		/**
		 * @private
		 */
		public function set width(value:int):void
		{
			if(_width==value)return;
			
			_width = value;
			
			objectInfo.width = value;
			objectInfo2.width = value;
			
			this.isChanged = true;
		}

		private var _height:int = 1800;

		/**
		 * 洞口高度
		 */
		public function get height():int
		{
			return _height;
		}

		/**
		 * @private
		 */
		public function set height(value:int):void
		{
			if(_height==value)return;
			
			_height = value;
			
			objectInfo.height = value;
			objectInfo2.height = value;
			
			this.isChanged = true;
		}

		
		/**
		 * 洞口门或窗模型的框厚度
		 */
		public var modelThickness:int = 100;
		
		/**
		 * 模型类型，100为外载门模型，大于100小于200为内建门模型，200为外载窗模型，大于200为窗模型
		 */
		public var modelType:int = 101;
		
		public var modelURL:String = "";//外载模型的url
		
		public function WallHole()
		{
			objectInfo = new WallObject();
			objectInfo.object = this;
			
			objectInfo2 = new WallObject();
			objectInfo2.object = this;
		}
		
		override public function dispose():void
		{
			if(wall)
			{
				wall.removeHole(this);
				wall = null;
			}
			if(objectInfo)
			{
				objectInfo.dispose();
				objectInfo = null;
			}
			if(objectInfo2)
			{
				objectInfo2.dispose();
				objectInfo2 = null;
			}
			dispatchDisposeEvent();
		}
		
		public function toJsonString():String
		{
			var s:String = "{";
			s += "\"x\":" + _x + ",";
			s += "\"y\":" + _y + ",";
			s += "\"width\":" + _width + ",";
			s += "\"height\":" + _height + ",";
			s += "\"thickness\":" + modelThickness + ",";
			s += "\"type\":" + modelType + ",";
			s += "\"url\":\"" + modelURL + "\"";
			s += "}";
			return s;
		}
	}
}