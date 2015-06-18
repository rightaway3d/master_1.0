package rightaway3d.house.vo
{
	public class ObstacleType
	{
		//障碍物类型(null：,wall：,hole：,hood：,cabinet：,object：)
		/**
		 * 没有障碍物
		 */
		static public const NULL:String = "null";
		/**
		 * 厨柜顶墙
		 */
		static public const WALL:String = "wall";
		/**
		 * 墙（门或窗）洞
		 */
		static public const HOLE:String = "hole";
		/**
		 * 烟机
		 */
		static public const HOOD:String = "hood";
		/**
		 * 高柜
		 */
		static public const HEIGHT_CABINET:String = "height_cabinet";//
		/**
		 * 中高柜
		 */
		static public const MIDDLE_CABINET:String = "middle_cabinet";//
		/**
		 * 邻墙的拐角柜
		 */
		static public const CORNER_CABINET:String = "corner_cabinet";
		/**
		 * 隔着障碍物的拐角柜
		 */
		static public const OBJECT_CORNER_CABINET:String = "object_corner_cabinet";//
		/**
		 * 其它的障碍物
		 */
		static public const OBJECT:String = "object";
		/**
		 * 隔着的障碍物前面可以放吊柜
		 */
		static public const CABINET_OBJECT:String = "cabinet_object";//
		/**
		 * 隔着的障碍物前面可以放吊柜
		 */
		static public const MIDDLE_CABINET_OBJECT:String = "middle_cabinet_object";//
		/**
		 * 障碍物两侧都有地柜的情况
		 */
		static public const MIDDLE_OBJECT:String = "middle_object";//
		/**
		 * 障碍物当墙
		 */
		static public const OBJECT_WALL:String = "object_wall";//
	}
}



