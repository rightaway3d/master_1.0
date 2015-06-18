package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import rightaway3d.house.vo.WallHole;
	import rightaway3d.utils.MyMath;

	public class WinDoor2D extends Base2D
	{
		static public var lineColor:uint = 0x808080;
		static public var fillColor:uint = 0xCCCCCC;
		
		public var vo:WallHole;
		
		public var wall:Wall2D;
		
		public var testArea:Sprite;
		
		public var drawArea:Shape;
		
		public var lineColor:uint = WinDoor2D.lineColor;
		
		public function WinDoor2D()
		{
			init();
		}
		
		private function init():void
		{
			testArea = new Sprite();
			this.addChild(testArea);
			
			drawArea = new Shape();
			this.addChild(drawArea);
		}
		
		override public function dispose():void
		{
			if(wall)
			{
				wall.removeWindoor(this);
				wall = null;
			}
			if(testArea)
			{
				this.removeChild(testArea);
				testArea = null;
			}
			if(drawArea)
			{
				this.removeChild(drawArea);
				drawArea = null;
			}
			vo = null;
		}
		
		public function updateView():void
		{
			//trace("updateView lineColor:"+this.lineColor.toString(16));
			_updateView(this);
		}
		
		/*public function updatePosition():void
		{
			
		}*/
		
		static private function _updateView(view:WinDoor2D):void
		{
			var type:int = view.vo.modelType;
			
			if(type==0)
			{
				drawOpenDoor(view);
			}
			else if(type<200)
			{
				if(type==101)
				{
					drawDoor101(view);
				}
			}
			else
			{
				if(type==201)
				{
					drawWindow201(view);
				}
			}
		}
		
		private static function drawOpenDoor(view:WinDoor2D):void
		{
			var vo:WallHole = view.vo;
			var w:Number = Base2D.sizeToScreen(vo.width);//窗户的宽度
			var thick:Number = (vo.wall && vo.wall.width>vo.modelThickness)?vo.wall.width:vo.modelThickness;
			thick = Base2D.sizeToScreen(thick);
			
			var x0:Number;// = w * 0.5;
			var y0:Number = thick * 0.5;
			
			var wallColor:uint = view.lineColor;
			var bgColor:uint = vo.wall?BackGrid2D.backgroundColor:fillColor;
			
			var gra:Graphics = view.testArea.graphics;
			gra.clear();
			gra.moveTo(0,y0);
			
			gra.beginFill(bgColor);
			gra.lineStyle(0,bgColor);
			gra.lineTo(w,y0);
			
			gra.lineStyle(0,wallColor);
			gra.lineTo(w,-y0);
			
			gra.lineStyle(0,bgColor);
			gra.lineTo(0,-y0);
			
			gra.lineStyle(0,wallColor);
			gra.lineTo(0,y0);
			
			gra.endFill();
		}
		
		static private function drawDoor101(view:WinDoor2D):void
		{
			var vo:WallHole = view.vo;
			var w:Number = Base2D.sizeToScreen(vo.width);//窗户的宽度
			var thick:Number = (vo.wall && vo.wall.width>vo.modelThickness)?vo.wall.width:vo.modelThickness;
			thick = Base2D.sizeToScreen(thick);
			
			var x0:Number;// = w * 0.5;
			var y0:Number = thick * 0.5;
			
			var wallColor:uint = view.lineColor;
			var bgColor:uint = vo.wall?BackGrid2D.backgroundColor:fillColor;
			
			var gra:Graphics = view.testArea.graphics;
			gra.clear();
			gra.moveTo(0,y0);
			
			gra.beginFill(bgColor);
			gra.lineStyle(0,bgColor);
			gra.lineTo(w,y0);
			
			gra.lineStyle(0,wallColor);
			gra.lineTo(w,-y0);
			
			gra.lineStyle(0,bgColor);
			gra.lineTo(0,-y0);
			
			gra.lineStyle(0,wallColor);
			gra.lineTo(0,y0);
			
			gra.endFill();
			
			var a:Number = MyMath.anglesToRadians(-60);
			x0 = w * Math.cos(a);
			y0 = w * Math.sin(a);
			
			gra = view.drawArea.graphics;
			gra.clear();
			
			gra.lineStyle(0,wallColor);
			gra.moveTo(0,0);
			gra.lineTo(x0,y0);
			
			var angleMid:Number = MyMath.anglesToRadians(-30);
			var avg:Number = Math.cos(MyMath.anglesToRadians(30));
			var bx:Number = w * Math.cos(angleMid) / avg;
			var by:Number = w * Math.sin(angleMid) / avg;
			gra.lineStyle(0,wallColor);
			gra.curveTo(bx,by,w,0);
		}
		
		static private function drawWindow201(view:WinDoor2D):void
		{
			var vo:WallHole = view.vo;
			var w:Number = Base2D.sizeToScreen(vo.width);//窗户的宽度
			var thick:Number = (vo.wall && vo.wall.width>vo.modelThickness)?vo.wall.width:vo.modelThickness;
			thick = Base2D.sizeToScreen(thick);
			
			//var x0:Number = w * 0.5;
			var y0:Number = thick * 0.5;
			
			//var wallColor:uint = Wall2D.lineColor;
			view.drawArea.graphics.clear();
			var gra:Graphics = view.testArea.graphics;
			gra.clear();
			
			gra.lineStyle(0,view.lineColor);
			gra.beginFill(fillColor);
			
			gra.moveTo(0,y0);
			gra.lineTo(w,y0);
			gra.lineTo(w,-y0);
			gra.lineTo(0,-y0);
			gra.lineTo(0,y0);
			
			gra.endFill();
			
			thick = Base2D.sizeToScreen(vo.modelThickness);
			y0 = thick * 0.3;
			
			//gra.lineStyle(0,view.lineColor);
			
			gra.moveTo(0,y0);
			gra.lineTo(w,y0);
			
			gra.moveTo(w,-y0);
			gra.lineTo(0,-y0);
		}
		
		/*public static function drawSector(obj:Graphics,x:Number=0,y:Number=0,radius:Number=100,fromRadian:Number=0,radian:Number=0):void
		{
			obj.moveTo(x,y);
			if(Math.abs(radian) > Math.PI * 2){
				obj.drawCircle(x,y,radius);
			}else{
				var n:int = Math.ceil(radian * 4 / Math.PI);
				var angleAvg:Number = radian / n;
				var angleMid:Number, bx:Number, by:Number,cx:Number, cy:Number;
				obj.lineTo(x + radius * Math.cos(fromRadian),y + radius * Math.sin(fromRadian));
				for (var i:int=1; i<=n; i++)
				{
					fromRadian +=  angleAvg;
					angleMid = fromRadian - angleAvg * .5;
					bx=x + radius * Math.cos(angleMid) / Math.cos(angleAvg * .5);
					by=y + radius * Math.sin(angleMid) / Math.cos(angleAvg * .5);
					cx = x + radius * Math.cos(fromRadian);
					cy = y + radius * Math.sin(fromRadian);
					obj.curveTo(bx,by,cx,cy);
				}
				obj.lineTo(x,y);
			}
		}*/
	}
}















