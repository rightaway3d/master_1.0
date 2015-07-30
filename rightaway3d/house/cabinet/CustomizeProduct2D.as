package rightaway3d.house.cabinet
{
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.view2d.Product2D;

	public class CustomizeProduct2D extends Product2D
	{
		static private var index:int = -1;
		static public function getNextIndex():int
		{
			return --index;//自定义产品的infoID为负值
		}
		static public function setNextIndex(value:int):void
		{
			if(value<index)index = value;
		}
		
		//==========================================================================
		
		public function CustomizeProduct2D(vo:ProductObject)
		{
			super(vo);
		}
		//====================================================================
		/*override public function dispose():void
		{
			super.dispose();
		}*/
		//====================================================================
	}
}















