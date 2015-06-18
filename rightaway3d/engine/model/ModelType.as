package rightaway3d.engine.model
{
	public final class ModelType
	{
		static public const DAE:String = ".dae";
		static public const SEA:String = ".sea";
		static public const AWD:String = ".awd";
		static public const BOX:String = ".box";
		static public const CYLINDER:String = ".cld";
		/**
		 * 用户动态创建的自定义尺寸立方体
		 */
		static public const BOX_C:String = ".box2";//用户自定义尺寸
		/**
		 * 用户动态创建的自定义尺寸圆柱体
		 */
		static public const CYLINDER_C:String = ".cld2";//用户自定义尺寸
		/**
		 * 没有模型的模型，一般用于子产品中，只作数据统计，而不需要显示的产品
		 */
		//static public const NULL:String = "null";//用户自定义尺寸
	}
}