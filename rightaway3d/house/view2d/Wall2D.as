package rightaway3d.house.view2d
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import rightaway3d.house.editor2d.Scene2D;
	import rightaway3d.house.editor2d.WallController;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.utils.ColorCalculate;
	import rightaway3d.utils.MyMath;

	public class Wall2D extends Base2D
	{
		static public var lineColor:uint = 0x666666;//0x111111;
		static public var normalColor:uint = 0x7d7d7d;//0x808080;
		static public var selectColor:uint = 0x008080;
		static public var overColor:uint = 0x808000;
		
		public var fillColor:uint = normalColor;
		
		private var _vo:Wall;

		public function get vo():Wall
		{
			return _vo;
		}

		public function set vo(value:Wall):void
		{
			_vo = value;
			_vo.addEventListener("size_change",onSizeChange);
			_vo.frontCrossWall.addEventListener("size_change",onSizeChange);
		}
		
		protected function onSizeChange(event:Event):void
		{
			this.sizeMark.updateView();
		}
		
		public var background:Sprite;
		
		/**
		 * 用于存储临时数据
		 */
		//public var data:*;
		
		/**
		 * 临时点
		 */
		//public var tmpPoint:Point;
		
		/**
		 * 关联到此墙体的橱柜
		 */
		//private var cabinets:Array = [];
		
		/*public function sortCabinet2():void
		{
			cabinets.sortOn("xWall",Array.NUMERIC);
		}*/
		
		/*public function addCabinet(cabinet:CustomizeProduct2D):void
		{
		if(cabinet.wall)
		{
		cabinet.wall.removeCabinet(cabinet);
		}
		cabinets.push(cabinet);
		this.selected = true;
		cabinet.wall = this;
		}*/
		
		/*public function removeCabinet(cabinet:CustomizeProduct2D):void
		{
			cabinets.splice(cabinets.indexOf(cabinet),1);
			if(cabinet.wall.cabinets.length==0)cabinet.wall.selected = false;
			cabinet.wall = null;
		}*/
		
		private var wc:WallController = WallController.getInstance();
		
		public function Wall2D()
		{
			super();
			init();
		}
		
		private function init():void
		{
			background = new Sprite();
			this.addChild(background);
		}
		
		/**
		 * 此墙体是否锁定，锁定后将禁止任何交互操作
		 */
		public var isLock:Boolean = false;
		
		override public function set selected(value:Boolean):void
		{
			if(_selected==value)return;
			
			_selected = value;
			
			fillColor = value?selectColor:normalColor;
			
			updateView();
		}
		
		override public function dispose():void
		{
			if(background)
			{
				this.removeChild(background);
				background = null;
			}
			
			if(sizeMark)
			{
				sizeMark.dispose();
				sizeMark = null;
			}
			
			if(windoors)
			{
				if(windoors.length>0)windoors.pop().dispose();
				windoors = null;
			}
			
			headPoint = null;
			headPoint1 = null;
			headPoint2 = null;
			endPoint = null;
			endPoint1 = null;
			endPoint2 = null;
			
			if(_vo)
			{
				_vo.removeEventListener("size_change",onSizeChange);
				_vo = null;
			}
			wc = null;
		}
		
		/**
		 * 墙体头端点坐标（全局）
		 */
		public var headPoint:Point = new Point();
		/**
		 * 墙体正面头端点坐标（本地）
		 */
		public var headPoint1:Point = new Point();
		/**
		 * 墙体背面头端点坐标（本地）
		 */
		public var headPoint2:Point = new Point();
		
		/**
		 * 墙体尾端点坐标（全局）
		 */
		public var endPoint:Point = new Point();
		/**
		 * 墙体正面尾端点坐标（本地）
		 */
		public var endPoint1:Point = new Point();
		/**
		 * 墙体背面尾端点坐标（本地）
		 */
		public var endPoint2:Point = new Point();
		
		
		public var sizeMark:SizeMarking2D = new SizeMarking2D();
		
		//更新墙体视图
		public function updateView():void
		{
			var w:Number = vo.length/Base2D.scaleRuler;
			var h:Number = vo.width/Base2D.scaleRuler;
			
			var x1:Number = Base2D.sizeToScreen(vo.groundHeadPoint.point.x);
			var y1:Number = Base2D.sizeToScreen(Base2D.screenToSize(Scene2D.sceneHeight) - vo.groundHeadPoint.point.z);
			this.x = x1;
			this.y = y1;
			headPoint.x = x1;
			headPoint.y = y1;
			
			var x2:Number = Base2D.sizeToScreen(vo.groundEndPoint.point.x);
			var y2:Number = Base2D.sizeToScreen(Base2D.screenToSize(Scene2D.sceneHeight) - vo.groundEndPoint.point.z);
			endPoint.x = x2;
			endPoint.y = y2;
			
			var radians:Number = Math.atan2(y2-y1,x2-x1);
			this.rotation = MyMath.radiansToAngles(radians);//屏幕坐标系下的墙体角度
			//trace("view rotation:"+this.rotation);
			
			//var fillColor2:uint = ColorCalculate.subtraction(fillColor,0x222222);
			//var fillColor2:uint = ColorCalculate.addition(fillColor,0x111111);
			var fillColor2:uint = ColorCalculate.subtraction(fillColor,0x111111);
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(w,h,Math.PI/2);
			
			var x0:Number = 0,y0:Number = 0;
			var x:Number,y:Number;
			var a:Number = 0.75;
			
			var gra:Graphics = background.graphics;
			gra.clear();
			gra.lineStyle(0,lineColor,a);			
			//gra.lineStyle(0,0xff0000);			
			//gra.beginGradientFill(GradientType.LINEAR,[fillColor2,fillColor,fillColor2],[a,a,a],[0,127,255],matrix);
			gra.beginGradientFill(GradientType.LINEAR,[fillColor2,fillColor,fillColor2],[a,a,a],[0,127,255],matrix);
			gra.moveTo(x0,y0);//起点为墙体首端中心点
			
			x = Base2D.sizeToScreen(vo.groundFrontHead.x);
			y = -Base2D.sizeToScreen(vo.groundFrontHead.z);
			headPoint1.x = x;
			headPoint1.y = y;
			gra.lineTo(x,y);//正面头端点
			
			//gra.lineStyle(0,0x00ff00);			
			x = Base2D.sizeToScreen(vo.groundFrontEnd.x);
			y = -Base2D.sizeToScreen(vo.groundFrontEnd.z);
			endPoint1.x = x;
			endPoint1.y = y;
			gra.lineTo(x,y);
			
			//gra.lineStyle(0,0x0000ff);			
			x = Base2D.sizeToScreen(vo.groundEnd.x);
			y = -Base2D.sizeToScreen(vo.groundEnd.z);
			gra.lineTo(x,y);
			
			//gra.lineStyle(0,0xff0000);			
			x = Base2D.sizeToScreen(vo.groundBackEnd.x);
			y = -Base2D.sizeToScreen(vo.groundBackEnd.z);
			endPoint2.x = x;
			endPoint2.y = y;
			gra.lineTo(x,y);
			
			//gra.lineStyle(0,0x0000ff);			
			x = Base2D.sizeToScreen(vo.groundBackHead.x);
			y = -Base2D.sizeToScreen(vo.groundBackHead.z);
			headPoint2.x = x;
			headPoint2.y = y;
			gra.lineTo(x,y);
			
			//gra.lineStyle(0,0x00ff00);			
			gra.lineTo(x0,y0);
			
			gra.endFill();
			
			sizeMark.updateView();
		}
		
		//==============================================================================================
		private var windoors:Vector.<WinDoor2D> = new Vector.<WinDoor2D>();
		
		public function addWindoor(wind:WinDoor2D):void
		{
			this.addChild(wind);
			wind.scaleX = 1;
			wind.scaleY = 1;
			wind.rotation = 0;
			wind.wall = this;
			
			windoors.push(wind);
		}
		
		public function removeWindoor(wind:WinDoor2D):void
		{
			var n:int = windoors.indexOf(wind);
			if(n>-1)
			{
				if(n<windoors.length-1)
				{
					windoors[n] = windoors.pop();
				}
				else
				{
					windoors.pop();
				}
				this.removeChild(wind);
				wind.wall = null;
			}
		}
		
		//==============================================================================================
	}
}








