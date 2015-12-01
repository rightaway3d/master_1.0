package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Point;
	
	import rightaway3d.house.editor2d.CabinetCreator;
	import rightaway3d.house.editor2d.Scene2D;
	import rightaway3d.house.utils.Geom;
	import rightaway3d.house.utils.Point3D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallObject;
	import rightaway3d.house.vo.WallSubArea;

	public class CabinetTable2D extends Base2D
	{
		private var cc:CabinetCreator = CabinetCreator.getInstance();
		
		private var shape:Shape;
		
		public function CabinetTable2D()
		{
			super();
			
			shape = new Shape();
			this.addChild(shape);
		}
		
		private var index:int = 0;
		
		public function reset():void
		{
			index = 0;
		}
		
		public function update():Boolean
		{
			var tabless:Array = cc.cabinetTabless;
			if(!tabless)return false;
			
			var depthss:Array = cc.tableDepthss;
			
			var len:int = tabless.length;
			if(index<len)
			{
				drawBG();
				updateView(tabless[index],depthss[index++]);
				return true;
			}
			
			index = 0;
			return false;
		}
		
		private function drawBG():void
		{
			var g:Graphics = this.graphics;
			g.clear();
			var color:uint = 0xffffff;
			g.lineStyle(1,color);
			g.beginFill(color);
			g.drawRect(0,0,Scene2D.viewWidth,Scene2D.viewHeight);
			g.endFill();
		}
		
		private function updateView(tables:Array,depths:Array):void
		{
			var max:Point = new Point();
			var min:Point = new Point();
			countBound(tables,depths,max,min);
			var tw:int = max.x - min.x;
			var th:int = max.y - min.y;
			var dx:int = -min.x;
			var dy:int = max.y;
			
			trace("---updateView:",max,min);
			
			shape.x = (Scene2D.viewWidth - Base2D.sizeToScreen(tw)) * 0.5;
			shape.y = (Scene2D.viewHeight - Base2D.sizeToScreen(th)) * 0.5;
			
			var g:Graphics = shape.graphics;
			g.clear();
			g.lineStyle(1,0);
			
			var points:Array = [];
			var dangshui:Array = [];
			var resetFirstPoint:Boolean = false;//是否需要重新设置第一点
			
			var tableData:WallSubArea = tables[0];
			var cw:CrossWall = tableData.cw;
			
			var x0:Number = tableData.x0;
			var x1:Number = tableData.x1;
			
			if(tableData.headCabinet)x0+=tableData.headCabinet.objectInfo.width;
			if(tableData.endCabinet)x1-=tableData.endCabinet.objectInfo.width;
			
			var h:Point3D = cw.localHead.clone();
			h.x = x0;
			
			var e:Point3D = h.clone();
			e.x = x1;
			
			var head:Point = new Point();
			var end:Point = new Point();
			
			var depth:int=depths[0];
			trace("depth:"+depth);
			cc.offsetCrossWall(cw,depth,head,end,h,e);
			
			var p:Point = cw.isHead?head:end;
			p = p.clone();
			
			var hp:Point = p.clone();
			points.push(p);
			
			turnPoint(p,dx,dy);
			g.moveTo(p.x,p.y);
			
			if(tableData.headCabinet || x0-cw.localHead.x<1)
			{
				if(tableData.headCabinet)
				{
					var tp:Point = cw.wall.globalToLocal2(p);
					tp.y += 50;
					cw.wall.localToGlobal2(tp,tp);
					p = tp;
				}
				dangshui.push(p);//挡水的第一个点坐标（为台面外沿，挡水终点坐标）
				resetFirstPoint = true;
			}
			else
			{
				resetFirstPoint = false;
			}
			
			var tlen2:int = tables.length;
			for(var j:int=1;j<tlen2;j++)//组成台面的每个墙面
			{
				tableData = tables[j];
				cw = tableData.cw;
				x0 = tableData.x0;
				x1 = tableData.x1;
				//trace(j+":",x0,x1,cw.wall.index);
				
				if(tableData.headCabinet)x0+=tableData.headCabinet.objectInfo.width;
				if(tableData.endCabinet)x1-=tableData.endCabinet.objectInfo.width;
				
				h = cw.localHead.clone();
				h.x = x0;
				e = h.clone();
				e.x = x1;
				
				var head2:Point = new Point();
				var end2:Point = new Point();
				
				depth=depths[j];
				cc.offsetCrossWall(cw,depth,head2,end2,h,e);
				
				var cp:Point = Geom.intersection(head,end,head2,end2);//计算台面外沿相交点坐标
				trace("cp:"+cp,head,end,h,e);
				points.push(cp);
				//g.lineTo(cp.x,cp.y);
				drawLine(g,cp,dx,dy);
				
				head = head2;
				end = end2;
			}
			
			p = cw.isHead?end:head;
			points.push(p);
			//g.lineTo(p.x,p.y);
			drawLine(g,p,dx,dy);
			
			if(tableData.endCabinet || cw.localEnd.x-x1<1)
			{
				if(tableData.endCabinet)
				{
					tp = cw.wall.globalToLocal2(p);
					tp.y += 50;
					cw.wall.localToGlobal2(tp,tp);
					p = tp;
				}
				dangshui.push(p);//台面外沿，挡水起始坐标
			}
			
			p = cc.turnPoint3d(cw.isHead?cw.wall.localToGlobal(e):cw.wall.localToGlobal(h));
			points.push(p);
			//g.lineTo(p.x,p.y);
			drawLine(g,p,dx,dy);
			
			dangshui.push(p);//台面内沿起始点，挡水坐标点
			//dangshui.unshift(p);
			
			for(j=tlen2-2;j>=0;j--)
			{
				tableData = tables[j];
				
				cw = tableData.cw;
				x0 = tableData.x0;
				x1 = tableData.x1;
				
				if(tableData.headCabinet)x0+=tableData.headCabinet.objectInfo.width;
				if(tableData.endCabinet)x1-=tableData.endCabinet.objectInfo.width;
				
				h = cw.localHead.clone();
				h.x = x0;
				e = h.clone();
				e.x = x1;
				
				p = cc.turnPoint3d(cw.isHead?cw.wall.localToGlobal(e):cw.wall.localToGlobal(h));
				points.push(p);
				//g.lineTo(p.x,p.y);
				drawLine(g,p,dx,dy);
				
				dangshui.push(p);//台面内沿拐角点，挡水坐标点
				//dangshui.unshift(p);
			}
			
			p = cc.turnPoint3d(cw.isHead?cw.wall.localToGlobal(h):cw.wall.localToGlobal(e));
			points.push(p);
			//g.lineTo(p.x,p.y);
			drawLine(g,p,dx,dy);
			//g.lineTo(hp.x,hp.y);
			drawLine(g,hp,dx,dy);
			
			dangshui.push(p);//台面内沿最后一个点，挡水坐标点
			//dangshui.unshift(p);
			
			if(resetFirstPoint)
			{
				dangshui.push(dangshui.shift());//将一开始取到点放到最后的位置，形成一个沿墙的逆时针挡水起止点
			}
			//trace("points:"+points);
			//trace("dangshui:"+dangshui);
			
			//trace(points);
			var yPos:int = tableData.tableY;
			if(cc.isDrainerArea(tables))//检测是否为放置水盆的区域
			{
				var holeWidth:int = cc.drainerProduct.objectInfo.width;
				var holeDepth:int = cc.drainerProduct.objectInfo.depth;
				
				var flag:WallObject = cc.drainerProduct.objectInfo;
				
				var wall:Wall = cc.drainerProduct.objectInfo.crossWall.wall;
				var ww:Number = wall.width*0.5 + depth*0.5;
				
				var x:int = flag.x-flag.width*0.5;
				var y:int = flag.crossWall.isHead?-ww:ww;
				
				var dx:int = holeWidth*0.5;
				var dy:int = holeDepth*0.5;
				
				var p1:Point = new Point(x+dx,y+dy);
				var p2:Point = new Point(x-dx,y+dy);
				var p3:Point = new Point(x-dx,y-dy);
				var p4:Point = new Point(x+dx,y-dy);
				
				wall.localToGlobal2(p1,p1);
				wall.localToGlobal2(p2,p2);
				wall.localToGlobal2(p3,p3);
				wall.localToGlobal2(p4,p4);
				
				var hole:Array = [p1,p2,p3,p4];
				//trace("hole:"+hole);
				
				//createTableMesh(dangshui,points,yPos,hole,30);
			}
			else
			{
				//createTableMesh(dangshui,points,yPos);
			}
		}
		
		private function countBound(tables:Array,depths:Array,max:Point,min:Point):void
		{
			max.x = 0;
			max.y = 0;
			min.x = 100000000;
			min.y = 100000000;
			
			var tableData:WallSubArea = tables[0];
			var cw:CrossWall = tableData.cw;
			
			var x0:Number = tableData.x0;
			var x1:Number = tableData.x1;
			
			if(tableData.headCabinet)x0+=tableData.headCabinet.objectInfo.width;
			if(tableData.endCabinet)x1-=tableData.endCabinet.objectInfo.width;
			
			var h:Point3D = cw.localHead.clone();
			h.x = x0;
			
			var e:Point3D = h.clone();
			e.x = x1;
			
			var head:Point = new Point();
			var end:Point = new Point();
			
			var depth:int=depths[0];
			cc.offsetCrossWall(cw,depth,head,end,h,e);
			
			var p:Point = cw.isHead?head:end;//台面外沿顺时针方向第一点
			resetBound(p,max,min);
			
			var tlen2:int = tables.length;
			for(var j:int=1;j<tlen2;j++)//组成台面的每个墙面
			{
				tableData = tables[j];
				cw = tableData.cw;
				x0 = tableData.x0;
				x1 = tableData.x1;
				
				if(tableData.headCabinet)x0+=tableData.headCabinet.objectInfo.width;
				if(tableData.endCabinet)x1-=tableData.endCabinet.objectInfo.width;
				
				h = cw.localHead.clone();
				h.x = x0;
				e = h.clone();
				e.x = x1;
				
				var head2:Point = new Point();
				var end2:Point = new Point();
				
				depth=depths[j];
				cc.offsetCrossWall(cw,depth,head2,end2,h,e);
				
				var cp:Point = Geom.intersection(head,end,head2,end2);//台面外沿顺时针方向相拐角交点坐标
				resetBound(cp,max,min);
				
				head = head2;
				end = end2;
			}
			
			p = cw.isHead?end:head;//台面外沿顺时针方向最后一点
			resetBound(p,max,min);
			
			p = cc.turnPoint3d(cw.isHead?cw.wall.localToGlobal(e):cw.wall.localToGlobal(h));//台面内沿逆时针方向第一点
			resetBound(p,max,min);
			
			for(j=tlen2-2;j>=0;j--)
			{
				tableData = tables[j];
				
				cw = tableData.cw;
				x0 = tableData.x0;
				x1 = tableData.x1;
				
				if(tableData.headCabinet)x0+=tableData.headCabinet.objectInfo.width;
				if(tableData.endCabinet)x1-=tableData.endCabinet.objectInfo.width;
				
				h = cw.localHead.clone();
				h.x = x0;
				e = h.clone();
				e.x = x1;
				
				p = cc.turnPoint3d(cw.isHead?cw.wall.localToGlobal(e):cw.wall.localToGlobal(h));//台面内沿逆时针方向拐角交点坐标
				resetBound(p,max,min);
			}
			
			p = cc.turnPoint3d(cw.isHead?cw.wall.localToGlobal(h):cw.wall.localToGlobal(e));//台面内沿逆时针方向最后一点
			resetBound(p,max,min);
		}
		
		private function resetBound(p:Point,max:Point,min:Point):void
		{
			if(p.x>max.x)max.x = p.x;
			if(p.y>max.y)max.y = p.y;
			if(p.x<min.x)min.x = p.x;
			if(p.y<min.y)min.y = p.y;
		}
		
		private function drawLine(g:Graphics,p:Point,dx:int,dy:int):void
		{
			turnPoint(p,dx,dy);
			g.lineTo(p.x,p.y);
		}
		
		private function turnPoint(p:Point,dx:int,dy:int):void
		{
			trace("point1:"+p);
			p.x = Base2D.sizeToScreen(p.x + dx);
			p.y = Base2D.sizeToScreen(dy - p.y);
			trace("point2:"+p);
		}
	}
}