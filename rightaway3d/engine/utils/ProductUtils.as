package rightaway3d.engine.utils
{
	import away3d.entities.Mesh;
	
	import rightaway3d.engine.product.ProductObject;

	public class ProductUtils
	{
		public function ProductUtils()
		{
		}
		
		static public function showBounds(po:ProductObject,value:Boolean):void
		{
			if(po.modelObject)
			{
				for each(var m:Mesh in po.modelObject.meshs)
				{
					m.showBounds = value;
				}
				return;
			}
			
			for each(var sp:ProductObject in po.subProductObjects)
			{
				showBounds(sp,value);
			}
			
			if(po.dynamicSubProductObjects)
			{
				for each(sp in po.dynamicSubProductObjects)
				{
					showBounds(sp,value);
				}
			}
		}
	}
}