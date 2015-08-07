package rightaway3d.house.view2d
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	
	import rightaway3d.engine.model.ModelType;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.WallObject;

	public class Product2D extends Base2D
	{
		static public var selectBorder:uint = 0x00ff00;
		
		public var border:uint = 0x999999;
		public var fill:uint = 0xEEEEEE;
		
		public var vo:ProductObject;
		
		/**
		 * 此橱柜所背靠的墙体
		 */
		public var wall:Wall2D;
		
		private var shape:Shape;
		
		public function Product2D(vo:ProductObject)
		{
			super();
			
			this.vo = vo;
			vo.view2d = this;
			
			shape = new Shape();
			this.addChild(shape);
			
			if(!vo.objectInfo)
			{
				vo.objectInfo = new WallObject();
				vo.objectInfo.object = vo;
			}
			
			vo.objectInfo.width = productWidth;
			vo.objectInfo.height = productHeight;
			vo.objectInfo.depth = productDepth;
			
			//trace("product dimensions:",vo.productInfo.dimensions);
			
			if(vo.modelObject)
			{
				vo.objectInfo.type = vo.modelObject.modelInfo.modelType;
				fill = vo.modelObject.modelInfo.color;
			}
			
			//trace("Product2D file:"+vo.productInfo.fileURL+" productWidth:"+productWidth+" productHeight:"+productHeight);
			
			if(!vo.productInfo.isReady)
			{
				vo.productInfo.addEventListener("ready",onProductInfoReady);
			}
			
			var url:String = (vo.image2dURL)?vo.image2dURL:vo.productInfo.image2dURL;
			if(url)
			{
				_loadImage(url);
			}
		}
		//====================================================================
		override public function dispose():void
		{
			/*if(vo)
			{
				vo.dispose();
				vo = null;
			}*/
			if(shape)
			{
				this.removeChild(shape);
				shape = null;
			}

			if(image)
			{
				this.removeChild(image);
				image = null;
			}
			
			vo = null;
			
			wall = null;
		}
		//====================================================================
		
		private function onProductInfoReady(event:Event):void
		{
			vo.productInfo.removeEventListener("ready",onProductInfoReady);
			
			//trace("onProductInfoReady productWidth:"+productWidth+" productHeight:"+productHeight);
			vo.objectInfo.width = productWidth;
			vo.objectInfo.height = productHeight;
			vo.objectInfo.depth = productDepth;
			
			if(vo.objectInfo.crossWall)
			{
				//vo.objectInfo.crossWall.initTestObject();
				var cw:CrossWall = vo.objectInfo.crossWall;
				cw.initTestObject();
				cw.wall.dispatchSizeChangeEvent();
				cw.headCrossWall.initTestObject();
				cw.headCrossWall.wall.dispatchSizeChangeEvent();
				cw.endCrossWall.initTestObject();
				cw.endCrossWall.wall.dispatchSizeChangeEvent();
			}
			
			this.updateView();
		}
		
		public function get productWidth():int
		{
			return vo.productInfo.dimensions.x;
		}
		
		public function get productHeight():int
		{
			return vo.productInfo.dimensions.y;
		}
		
		public function get productDepth():int
		{
			return vo.productInfo.dimensions.z;
		}
		
		public function loadImage(url:String):void
		{
			if(url!=vo.image2dURL)
			{
				vo.image2dURL = url;
				_loadImage(url);
			}
		}
		
		private function _loadImage(url:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onImageLoaded);
			loader.load(new URLRequest(url));			
		}
		
		private var image:DisplayObject;
		
		protected function onImageLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onImageLoaded);
			
			image = loaderInfo.content;
			if(image is Bitmap)
			{
				Bitmap(image).smoothing = true;
			}
			
			this.addChildAt(image,0);
			
			updateView();
		}
		
		private var _errorFlag:Boolean = false;

		public function get errorFlag():Boolean
		{
			return _errorFlag;
		}

		public function set errorFlag(value:Boolean):void
		{
			if(_errorFlag == value)return;
			
			_errorFlag = value;
			updateView();
		}

		
		public function updateView():void
		{
			//var border:uint = 0xCCCCCC;
			//var fill:uint = 0xEEEEEE;
			//trace("Product2D updateView:"+vo.productInfo.fileURL+" "+productWidth+"x"+productHeight+"x"+productDepth);
			
			var w:Number = sizeToScreen(productWidth);
			var h:Number = sizeToScreen(productDepth);
			//trace("-----------updateView:"+w+"x"+h);
			
			//vo.objectInfo.width = productWidth;
			//vo.objectInfo.height = productHeight;
			
			var g:Graphics = shape.graphics;
			g.clear();
			
			if(image)
			{
				image.x = 0;
				image.y = -h;
				image.width = w;
				image.height = h;
				
				if(!selected)
				{
					drawErrorFlag(g,w);
					return;//如果加载了图片，在非选中状态不绘制边框
				}
			}

			var type:String = vo.modelObject ? vo.modelObject.modelInfo.modelType : null;
			if(type==ModelType.CYLINDER || type==ModelType.CYLINDER_C)
			{
				//border = selected?selectBorder:0x999999;
				//fill = 0x999999;
				g.lineStyle(0,selected?selectBorder:0x999999);
				if(!image)g.beginFill(fill);
				var rot:Vector3D = vo.modelObject.modelInfo.rotation;
				if(rot.z==90 && rot.x==0 && rot.y==0)
				{
					g.drawRect(0,-h,w,h);
				}
				else
				{
					var r:Number = w*0.5;
					g.drawCircle(r,-r,r);
				}
			}
			else if(type==ModelType.BOX || type==ModelType.BOX_C)
			{
				//border = selected?selectBorder:0xAAAAAA;
				fill = 0xAAAAAA;
				g.lineStyle(0,selected?selectBorder:0xAAAAAA);
				if(!image)g.beginFill(fill);
				g.drawRect(0,-h,w,h);
			}
			else
			{
				//border = selected?selectBorder:border;
				g.lineStyle(0,selected?selectBorder:border);
				if(!image)g.beginFill(fill,0.9);
				g.drawRect(0,-h,w,h);
			}
			if(!image)g.endFill();
			
			drawErrorFlag(g,w);
			//trace("updateView selected:"+selected+" border:"+border);
		}
		
		private function drawErrorFlag(g:Graphics,w:Number):void
		{
			if(_errorFlag)//绘制错误标志，一个X
			{
				g.lineStyle(1,0xff0000,0.9);
				var d:int = 3;
				g.moveTo(w-d,-d);
				g.lineTo(w+d,d);
				g.moveTo(w+d,-d);
				g.lineTo(w-d,d);
			}
		}
	}
}



