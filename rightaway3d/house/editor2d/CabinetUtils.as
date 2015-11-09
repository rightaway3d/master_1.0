package rightaway3d.house.editor2d
{
	import rightaway3d.engine.product.ProductObject;

	public final class CabinetUtils
	{
		public function CabinetUtils()
		{
		}
		
		/**
		 * 根据拐角柜相邻柜子的面板线在拐角柜上的位置，来调整拐角柜的产品型号，用于匹配拐角柜的门板及封板
		 * @param cab：指定的拐角柜
		 * @param xpos：相邻柜子的面板位置
		 * 
		 */
		static public function resetCornerProductModel(cab:ProductObject,xpos:Number):void
		{
			var md:String = cab.productInfo.productModel;
			var s:String;
			switch(md)
			{
				
				/*A60-J | A60-J-65		
				100装饰板+500门板 [MIN-50]		
				150装饰板+450门板 (50-MAX]
				*/
				case "A60-J":
				case "A60-J-65":
					if(xpos>50)
						s = "50-MAX";
					else
						s = "MIN-50";
					
					break;
				
				/*900插角配置：A90-J | A90-J-65 | B90-J		
				000封板+300装饰板+600门板 [MIN-250]		
				000封板+400装饰板+500门板 (250-320]		
				300封板+100装饰板+500门板 (320-350]		
				000封板+450装饰板+450门板 (350-370]		
				350封板+100装饰板+450门板 (370-MAX]
				*/
				case "A90-J":
				case "A90-J-65":
				case "B90-J":
					if(xpos>370)
						s = "370-MAX";
					else if(xpos>350)
						s = "350-370";
					else if(xpos>320)
						s = "320-350";
					else if(xpos>250)
						s = "250-320";
					else
						s = "MIN-250";
						
					break;
				
				/*800插角配置：B80-J		
				000封板+300装饰板+500门板 [MIN-250]		
				000封板+400装饰板+400门板 (250-320]		
				300封板+100装饰板+400门板 (320-MAX]
				*/
				case "B80-J":
					if(xpos>320)
						s = "320-MAX";
					else if(xpos>250)
						s = "250-320";
					else
						s = "MIN-250";
					
					break;
				
				/*900插角小怪物配置：AJL90-L/R | AJL90-L/R-65		
				000封板+450装饰板+450门板 (MIN-320]		
				300封板+150装饰板+450门板 (320-370]		
				350封板+100装饰板+450门板 (370-MAX]
				*/
				case "AJL90-L/R":
				case "AJL90-L/R-65":
					if(xpos>370)
						s = "370-MAX";
					else if(xpos>320)
						s = "320-370";
					else
						s = "MIN-320";
					break;
				
				default:
					return;
			}
			
			cab.productModel = md + "_" + s;
			trace("-----corner productModel:"+cab.productModel);
		}
	}
}