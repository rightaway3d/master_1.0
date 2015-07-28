package rightaway3d.engine.utils
{
	import away3d.entities.Mesh;
	
	import rightaway3d.engine.product.ProductObject;

	public class ProductUtils
	{
		public function ProductUtils()
		{
		}
		
		static public function showBounds(po:ProductObject,value:Boolean,color:uint):void
		{
			if(po.modelObject)
			{
				for each(var m:Mesh in po.modelObject.meshs)
				{
					if(value)m.bounds.boundingRenderable.color = color;
					m.showBounds = value;
				}
				return;
			}
			
			for each(var sp:ProductObject in po.subProductObjects)
			{
				showBounds(sp,value,color);
			}
			
			if(po.dynamicSubProductObjects)
			{
				for each(sp in po.dynamicSubProductObjects)
				{
					showBounds(sp,value,color);
				}
			}
		}
	}
}