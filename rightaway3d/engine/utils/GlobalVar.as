package rightaway3d.engine.utils
{
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.lib.CabinetLib;
	import rightaway3d.house.view2d.Product2D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.WallObject;
	import rightaway3d.utils.MyMath;

	/**
	 * 全局变量
	 * @author Jell
	 * 
	 */
	public class GlobalVar
	{
		private var _currProduct:ProductObject;
		
		private var _currProduct2:ProductObject;
		
		public function get currProduct():ProductObject
		{
			return _currProduct;
		}
		
		public function set currProduct(value:ProductObject):void
		{
			if(_currProduct == value)return;
			
			//trace("setCurrProduct:"+p.selected);
			if(_currProduct)
			{
				//trace("currCabinet:"+currCabinet.selected);
				//_currCabinet.selected = false;
				//_currCabinet.updateView();
				if(_currProduct.objectInfo && !_currProduct.objectInfo.crossWall)//当前产品未吸附到墙面上
				{
					updateSelect(_currProduct.view2d,_currProduct,true,errorColor);
				}
				else
				{
					updateSelect(_currProduct.view2d,_currProduct,false);
				}
				_currProduct = null;
			}
			
			if(value)
			{
				_currProduct = value;
				//value.selected = true;
				//value.updateView();
				updateSelect(value.view2d,value,true);
			}
			/*else
			{
				throw new Error();
			}*/
		}
		
		private function setCurrProduct2(value:ProductObject):void
		{
			if(_currProduct2 == value)return;
			
			//trace("setCurrProduct:"+p.selected);
			if(_currProduct2)
			{
				//trace("currCabinet:"+currCabinet.selected);
				//_currCabinet2.selected = false;
				//_currCabinet2.updateView();
				updateSelect(_currProduct2.view2d,_currProduct2,false);
				_currProduct2 = null;
			}
			
			if(value)
			{
				_currProduct2 = value;
				//value.selected = true;
				//value.updateView();
				updateSelect(value.view2d,value,true);
			}
		}
		
		public function get currProduct2():ProductObject
		{
			return _currProduct2;
		}
		
		/**
		 * 设置第二个选中的产品
		 * @param value
		 * 
		 */
		public function set currProduct2(value:ProductObject):void
		{
			if(!value)//如果值为空，清空当前所有选中的产品
			{
				currProduct = null;
				setCurrProduct2(null);
			}
			else if(value==_currProduct)//设置已经选中的产品，则清除之
			{
				currProduct = _currProduct2;//将第二选中的产品设为第一个
				_currProduct2 = null;
			}
			else if(value==_currProduct2)//设置已经选中的产品，则清除之
			{
				setCurrProduct2(null);
			}
			else if(!_currProduct)//第一个产品不存在时
			{
				currProduct = value;
			}
			else
			{
				if(_currProduct2)//存在第二选中产品时，置为第一选中产品
				{
					currProduct = _currProduct2;
				}
				
				_currProduct2 = value;
				//value.selected = true;
				//value.updateView();
				updateSelect(value.view2d,value,true);
				
				replaceEvent();
			}
		}
		
		private function replaceEvent():void
		{
			var wo1:WallObject = _currProduct.objectInfo;
			var wo2:WallObject = _currProduct2.objectInfo;
			var cw1:CrossWall = wo1?wo1.crossWall:null;
			var cw2:CrossWall = wo2?wo2.crossWall:null;
			if(cw1 && cw1==cw2)
			{
				if(MyMath.isEqual(wo1.x-wo1.width,wo2.x) || MyMath.isEqual(wo2.x-wo2.width,wo1.x))
				{
					var ids:Array = [String(_currProduct.productInfo.infoID),String(_currProduct2.productInfo.infoID)];
					var srcs:Array = CabinetLib.lib.getReplaceList(ids);
					trace("replaceEvent1");
					if(srcs)
					{
						trace("replaceEvent2");
						for each(var t:* in srcs)
						{
							trace("t:"+t);
						}
						GlobalEvent.event.dispatchDoubleReplaceEvent([_currProduct,_currProduct2],srcs);
					}
				}
			}
		}
		
		//public var boundsColor:uint = 0x00ff00;
		
		public var defaultColor:uint = 0x00ff00;
		
		public var errorColor:uint = 0xff0000;
		
		private function updateSelect(p2d:Product2D,po:ProductObject,value:Boolean,boundsColor:uint=0x00ff00):void
		{
			if(p2d && p2d.selected!=value)
			{
				p2d.selected = value;
				if(po)
					p2d.updateView();
			}
			
			
			if(po)
			{
				ProductUtils.showBounds(po,value,boundsColor);
			}
		}
		
		/*public function get currProduct():ProductObject
		{
			return _currProduct;
		}
		
		public function set currProduct(value:ProductObject):void
		{
			this.currCabinet = value?value.view2d:null;
		}
		
		public function get currProduct2():ProductObject
		{
			return _currProduct2;
		}
		
		public function set currProduct2(value:ProductObject):void
		{
			this.currCabinet2 = value?value.view2d:null;
		}*/
		
		//-----------------------------------------------------------------------------------------------------
		public function GlobalVar(value:SingleInstanceClass)
		{
			if(!value)
			{
				throw new Error("GlobalEvent是一个单例类，请用静态属性event来获得类的实例。");
			}
		}
		
		static private var _var:GlobalVar;
		
		static public function get own():GlobalVar
		{
			return _var ||= new GlobalVar(new SingleInstanceClass());
		}
		//-----------------------------------------------------------------------------------------------------
	}
}

class SingleInstanceClass{}
