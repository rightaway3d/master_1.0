package rightaway3d.house.view2d
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFormatAlign;
	
	import rightaway3d.house.editor2d.Scene2D;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallArea;
	import rightaway3d.house.vo.WallHole;
	import rightaway3d.house.vo.WallObject;
	import rightaway3d.house.vo.WallUtils;
	import rightaway3d.utils.MyMath;
	import rightaway3d.utils.MyTextField;
	
	public class SizeMarking2D extends Sprite
	{
		//static public var sceneScale:Number = 1;
		
		static public var lineColor:uint = 0xFFFFFF;//0x000000;//
		
		//static private var marks:Vector.<SizeMarking2D> = new Vector.<SizeMarking2D>();
		
		/*static public function updateAllMarks():void
		{
			for each(var sm:SizeMarking2D in marks)
			{
				sm.updateView();
			}
		}*/
		
		public var vo:Wall;
		
		private var txt:MyTextField;
		
		private var txts:Sprite;
		
		public function SizeMarking2D()
		{
			super();
			
			this.mouseEnabled = false;
			this.mouseChildren = false;
			
			txts = new Sprite();
			this.addChild(txts);
			
			txt = new MyTextField();
			//txts.addChild(txt);
			txt.textSize = 100;
			
			//var f:GlowFilter = new GlowFilter(BackGrid2D.backgroundColor,1,10,10,8);//
			//txts.filters = [f];
			
			//marks.push(this);
		}
		
		public function dispose():void
		{
			if(parent)
			{
				parent.removeChild(this);
			}
			if(txt)
			{
				txt.dispose();
				txt = null;
			}
			if(txts)
			{
				txts.removeChildren();
				this.removeChild(txts);
				txts = null;
			}
			vo = null;
		}
		
		private var sceneSize:int;
		
		static public var markingGroundObject:Boolean = true;
		static public var markingWallObject:Boolean = true;
		static public var markingWindoor:Boolean = true;
		
		public function updateView():void
		{
			var n:Number = MyMath.ZERO;
			MyMath.ZERO = 2;
			
			sceneSize = Base2D.screenToSize(Scene2D.sceneHeight);
			
			txts.removeChildren();
			
			graphics.clear();
			graphics.lineStyle(0,lineColor);
			
			var d1:int = 200;//尺寸引线起始点偏移量
			var d2:int = 300;//尺寸线位置
			var d3:int = 100;//尺寸引线终点超出尺寸线距离
			
			//markSize(vo.groundFrontHead.x,vo.groundFrontEnd.x,d1,d2,d3);
			var x0:Number = vo.groundFrontHead.x;
			var x1:Number = vo.groundFrontEnd.x;
			var d:int = d2;
			
			if(markingGroundObject)d += this.markGroundObjectSize(x0,x1,d,d2,d3);
			
			if(markingWallObject)d += this.markWallObjectSize(x0,x1,d,d2,d3);
			
			if(markingWindoor)d += this.markWindoorSize(x0,x1,d,d2,d3);
			
			if(vo.selectorArea)
			{
				this.markSelectArea(x0,x1,d1,d,d3);
			}
			else
			{
				this.markWallSize(x0,x1,d1,d,d3);
			}
			
			MyMath.ZERO = n;
		}
		
		private function markSelectArea(start:Number,end:Number,legLineStart:int,legLineLen:int,headLineLen:int):void
		{
			var areas:Array = vo.selectorArea;
			var len:int = areas.length;
			if(len==0)
			{
				this.markWallSize(start,end,legLineStart,legLineLen,headLineLen);
				return;
			}
			
			var a:Array = sortSelectArea(start,end,areas);
			drawMark(a,legLineStart,legLineLen,headLineLen,true,true);
		}
		
		private function sortSelectArea(x0:Number,x1:Number,areas:Array):Array
		{
			var a:Array = [];
			a.push(x0);
			var len:int = areas.length;
			for(var i:int=0;i<len;i++)
			{
				var h:WallArea = areas[i].vo;
				if(h.x0-x0>1)
				{
					a.push(h.x0);
				}
				x0 = h.x1;
				a.push(x0);
			}
			
			if(x1-x0>1)a.push(x1);
			
			return a;
		}
		
		private function markSize(x0:Number,x1:Number,legLineStart:int,legLineLen:int,headLineLen:int,leg1:Boolean=true,leg2:Boolean=true):void
		{
			var length:int = x1 - x0 + 0.5;
			var bmp:Bitmap = setSizeText(length);
			
			var y0:Number = legLineStart;
			
			var p00:Point = getGlobalScreenPoint(x0,y0);
			var p10:Point = getGlobalScreenPoint(x1,y0);
			
			var a:Number = Math.atan2(p10.y-p00.y,p10.x-p00.x);
			a = MyMath.radiansToAngles(a);
			//trace("--------------a:"+a);
			
			var y1:int = y0 + legLineLen;
			
			var p01:Point = getGlobalScreenPoint(x0,y1);
			var p11:Point = getGlobalScreenPoint(x1,y1);
			
			var textWidth:int = Base2D.screenToSize(bmp.width);
			//trace("textwidth:"+textWidth+" length:"+length);
			var tx:Number = x0 + length*0.5;
			var ty:Number = y1;
			
			if(MyMath.isEqual(a,180))
			{
				tx += textWidth * 0.5 + 0;
				ty += textWidth*0.9<length?0:130;
				bmp.rotation = 0;
			}
			else
			{
				tx -= textWidth * 0.5 + 0;
				ty += textWidth*0.9<length?232:362;
				
				bmp.rotation = a;
			}
			
			var pt:Point = getGlobalScreenPoint(tx,ty);
			bmp.x = pt.x;
			bmp.y = pt.y;
			
			var y2:int = y1 + headLineLen;
			
			var g:Graphics = this.graphics;
			
			if(leg1)
			{
				var p02:Point = getGlobalScreenPoint(x0,y2);
				g.moveTo(p00.x,p00.y);
				g.lineTo(p02.x,p02.y);
			}
			
			g.moveTo(p01.x,p01.y);
			g.lineTo(p11.x,p11.y);
			
			drawCircle(g,p01);
			drawCircle(g,p11);
			
			if(leg2)
			{
				var p12:Point = getGlobalScreenPoint(x1,y2);
				g.moveTo(p10.x,p10.y);
				g.lineTo(p12.x,p12.y);
			}
		}
		
		private function drawCircle(g:Graphics,p:Point):void
		{
			g.beginFill(lineColor);
			g.drawCircle(p.x,p.y,0.5);
			g.endFill();
		}
		
		private function getGlobalScreenPoint(x:Number,y:Number):Point
		{
			var p:Point = new Point(x,y);
			vo.localToGlobal2(p,p);
			p.x = Base2D.sizeToScreen(p.x);
			p.y = Base2D.sizeToScreen(sceneSize - p.y);
			return p;
		}
		
		private function sortHoles(x0:Number,x1:Number,objects:Vector.<WallHole>):Array
		{
			var a:Array = [];
			a.push(x0);
			var len:int = objects.length;
			for(var i:int=0;i<len;i++)
			{
				var h:WallHole = objects[i];
				if(h.x-x0>1)
				{
					a.push(h.x);
				}
				x0 = h.x+h.width;
				a.push(x0);
			}
			
			if(x1-x0>1)a.push(x1);
			
			return a;
		}
		
		private function drawMark(marks:Array,legLineStart:int,legLineLen:int,headLineLen:int,leg1:Boolean,leg2:Boolean):void
		{
			//trace("marks:"+marks);
			var len:int = marks.length;
			for(var i:int=1;i<len;i++)
			{
				var x0:Number = marks[i-1];
				var x1:Number = marks[i];
				markSize(x0,x1,legLineStart,legLineLen,headLineLen,i>1?true:leg1,i<len-1?true:leg2);
			}
		}
		
		private function markGroundObjectSize(start:Number,end:Number,legLineStart:int,legLineLen:int,headLineLen:int):int
		{
			var gos:Array = vo.frontCrossWall.groundObjects;
			var len:int = gos.length;
			if(len==0 || isAllWallHole(gos))return 0;//地面物体的数量为0，或都是墙洞，不做标注
			//trace("gos1:",gos);
			gos = WallUtils.sortWallObject(start,end,gos);
			//trace("gos2:",gos);
			drawMark(gos,legLineStart,legLineLen,headLineLen,false,false);
			
			return 500;
		}
		
		private function markWallObjectSize(start:Number,end:Number,legLineStart:int,legLineLen:int,headLineLen:int):int
		{
			var gos:Array = vo.frontCrossWall.wallObjects;
			var len:int = gos.length;
			if(len==0 || isAllWallHole(gos))return 0;//地面物体的数量为0，或都是墙洞，不做标注
			
			//trace("wos1:",gos);
			gos = WallUtils.sortWallObject(start,end,gos);
			//trace("wos2:",gos);
			drawMark(gos,legLineStart,legLineLen,headLineLen,false,false);
			
			return 500;
		}
		
		private function markWindoorSize(start:Number,end:Number,legLineStart:int,legLineLen:int,headLineLen:int):int
		{
			var holes:Vector.<WallHole> = vo.holes;
			var len:int = holes.length;
			if(len==0)return 0;
			
			var a:Array = sortHoles(start,end,holes);
			drawMark(a,legLineStart,legLineLen,headLineLen,false,false);
			
			return 500;
		}
		
		private function markWallSize(start:Number,end:Number,legLineStart:int,legLineLen:int,headLineLen:int):void
		{
			markSize(start,end,legLineStart,legLineLen,headLineLen,true,true);
		}
		
		/**
		 * 判断墙体对象是否都是墙洞
		 * @param wos
		 * @return 
		 * 
		 */
		private function isAllWallHole(wos:Array):Boolean
		{
			var len:int = wos.length;
			for(var i:int=0;i<len;i++)
			{
				var wo:WallObject = wos[i];
				if(!(wo.object is WallHole))
				{
					return false;
				}
			}
			return true;
		}
		
		private function setSizeText(length:int):Bitmap
		{
			txt.text = String(length);
			var tmp:Number = txt.textWidth;
			tmp = txt.textHeight;
			tmp = txt.width;
			tmp = txt.height;
			txt.width = txt.textWidth + 5;
			txt.height = txt.textHeight + 2;
			txt.textColor = lineColor;
			txt.align = TextFormatAlign.CENTER;
			
			var bmd:BitmapData = new BitmapData(txt.width,txt.height,true,0);
			bmd.draw(txt,null,null,null,null,true);
			
			var bmp:Bitmap = new Bitmap(bmd,"auto",true);
			bmp.smoothing = true;
			
			//trace(bmp.width+"x"+bmp.height);
			bmp.scaleX = bmp.scaleY = 0.1;
			//trace(bmp.width+"x"+bmp.height);
			
			txts.addChild(bmp);
			
			return bmp;
		}
	}
}






















