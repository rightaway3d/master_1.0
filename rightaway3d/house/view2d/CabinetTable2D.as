package rightaway3d.house.view2d
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.engine.product.ProductObjectName;
	import rightaway3d.house.editor2d.CabinetCreator;
	import rightaway3d.house.editor2d.Scene2D;
	import rightaway3d.house.utils.Geom;
	import rightaway3d.house.utils.GlobalConfig;
	import rightaway3d.house.utils.Point3D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallObject;
	import rightaway3d.house.vo.WallSubArea;
	import rightaway3d.utils.BrokenLineDrawer;
	import rightaway3d.utils.MyMath;
	import rightaway3d.utils.Utils;

	public class CabinetTable2D extends Base2D
	{
		static private const POS_LEFT:String = "left";
		static private const POS_RIGHT:String = "right";
		static private const POS_TOP:String = "top";
		static private const POS_BOTTOM:String = "bottom";
		static private const POS_HEAD:String = "head";
		static private const POS_MIDDLE:String = "middle";
		static private const POS_END:String = "end";
		static private const POS_OUT:String = "out";
		static private const POS_IN:String = "in";
		
		private var cc:CabinetCreator = CabinetCreator.getInstance();
		
		private var view:Sprite;
		
		public function CabinetTable2D()
		{
			super();
			
			view = new Sprite();
			this.addChild(view);
		}
		
		private function resetPoints(points:Array,base:int):void
		{
			var len:int = points.length;
			for(var i:int=0;i<len;i++)
			{
				var n:int = points[i];
				points[i] = base - n;
			}
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
			
			getRoomPillars();
			
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
		
		private var pillars:Array;//房间里所有的立柱或烟道
		private var columns:Array;//房间里所有的立管
		
		//获取到房间里的所有立柱立管
		private function getRoomPillars():void
		{
			//trace("getRoomPillars");
			pillars = ProductManager.own.getRootProductsByName(ProductObjectName.ROOM_SQUARE_PILLAR);
			columns = ProductManager.own.getRootProductsByName(ProductObjectName.ROOM_CIRCULAR_COLUMN);
			//trace("pillars:"+pillars);
			//trace("columns:"+columns);
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
			
			//trace("---updateView:",max,min);
			
			view.removeChildren();
			
			var g:Graphics = view.graphics;
			g.clear();
			g.lineStyle(0,0);
			
			drawTable2D(tables,depths,g,dx,dy,min,max);
			drawWaterHoldingBorder(tables,depths,g,dx,dy);
			drawCabinetBorder(tables,depths,g,dx,dy);
			
			var w:Number = Base2D.sizeToScreen(tw);
			var h:Number = Base2D.sizeToScreen(th);
			fitView(w,h,0,0);
		}
		
		private function fitView(cw:Number,ch:Number,dx:Number,dy:Number):void
		{
			var sw:int = Scene2D.viewWidth;//stage.stageWidth;
			var sh:int = Scene2D.viewHeight;//stage.stageHeight;
			
			Utils.fitContainer(sw,sh,view,0.6,cw,ch);
			
			view.x = (sw - cw * view.scaleX) * 0.5 + dx;
			view.y = (sh - ch * view.scaleY) * 0.5 + dy;
//			view.x = (sw - view.width) * 0.5 + dx;
//			view.y = (sh - view.height) * 0.5 + dy;
		}
		
		private function addMarkPoint(wall:Wall,ps:Array,p:Point):void
		{
			p = wall.globalToLocal2(p);
			ps.push(p.x);
		}
		
		private function unPoints(ps:Array,s:String):Point
		{
			var max:Point = new Point();
			var len:int = ps.length;
			for(var i:int=0;i<len;i++)
			{
				var p:Point = ps[i];
				
				if(p.x>max.x)max.x = p.x;
				if(p.y>max.y)max.y = p.y;
				
				ps[i] = p[s];
			}
			//trace("upPoints:"+ps);
			return max;
		}
		
		private function drawMarking(cw:CrossWall,pos:String,min:Point,max:Point,base:Point,points:Array,drawSecondLayer:Boolean=true):void
		{
			var len:int = points.length;
			
			if(len>2 && drawSecondLayer)
			{
				drawMarking2(cw,pos,min,max,base,[points[0],points[len-1]],1);
			}
			
			drawMarking2(cw,pos,min,max,base,points);
		}
		
		private function drawMarking2(cw:CrossWall,pos:String,min:Point,max:Point,base:Point,points:Array,layerIndex:int=0):void
		{
			var markHeight:int = 180;
			var dx:Number=0,dy:Number=0;
			var wall:Wall = cw.wall;
			var name:String = wall.name;
			//trace("wall:"+name+" pos:"+pos,"\nmin:"+min,"\nmax:"+max,"\nbase:"+base,"\nps:"+points);
			var max0:Point;//当前点中的最大数据
			
			if(name=="A")
			{
				if(pos==POS_HEAD)
				{
					pos=POS_LEFT;
				}
				else if(pos==POS_END || pos==POS_MIDDLE)
				{
					pos=POS_RIGHT;
				}
				else if(pos==POS_OUT)
				{
					pos=POS_TOP;
				}
				else// if(pos==POS_IN)
				{
					pos=POS_BOTTOM;
				}
			}
			else if(name=="B")
			{
				if(pos==POS_HEAD)
				{
					pos = POS_TOP;
				}
				else if(pos==POS_END || pos==POS_MIDDLE)
				{
					pos=POS_BOTTOM;
				}
				else if(pos==POS_OUT)
				{
					pos=POS_RIGHT;
				}
				else// if(pos==POS_IN)
				{
					pos=POS_LEFT;
				}
			}
			else if(name=="C")
			{
				if(pos==POS_HEAD)
				{
					pos = POS_RIGHT;
				}
				else if(pos==POS_END || pos==POS_MIDDLE)
				{
					pos=POS_LEFT;
				}
				else if(pos==POS_OUT)
				{
					pos=POS_BOTTOM;
				}
				else// if(pos==POS_IN)
				{
					pos=POS_TOP;
				}
			}
			else// if(name=="D")
			{
				if(pos==POS_HEAD)
				{
					pos = POS_BOTTOM;
				}
				else if(pos==POS_END || pos==POS_MIDDLE)
				{
					pos=POS_TOP;
				}
				else if(pos==POS_OUT)
				{
					pos=POS_LEFT;
				}
				else// if(pos==POS_IN)
				{
					pos=POS_RIGHT;
				}
			}
			
			if(pos==POS_LEFT)
			{
				max0 = unPoints(points,"y");
				max0 = base;
				dx = max0.x - min.x - markHeight * layerIndex;
			}
			else if(pos==POS_RIGHT)
			{
				max0 = unPoints(points,"y");
				max0 = base;
				dx = max0.x - min.x + markHeight * layerIndex;
			}
			else if(pos==POS_TOP)
			{
				max0 = unPoints(points,"x");
				max0 = base;
				dy = max.y - max0.y - markHeight * layerIndex;
			}
			else// if(pos==POS_BOTTOM)
			{
				max0 = unPoints(points,"x");
				max0 = base;
				dy = max.y - max0.y + markHeight * layerIndex;
			}

			
			setSizeMark(pos,min,max.y,points,dx,dy);

		}
		
		//pos:left,right,top,bottom
		private function setSizeMark(pos:String,min:Point,maxY:int,points:Array,dx:int,dy:int):BaseMarking
		{
			//trace("setSizeMark:",pos,min,maxY,points,dx,dy);
			if(pos=="A")pos=POS_TOP;
			if(pos=="B")pos=POS_RIGHT;
			if(pos=="C")pos=POS_BOTTOM;
			if(pos=="D")pos=POS_LEFT;
			
			points.sort(Array.NUMERIC);
			
			var mark:BaseMarking = new BaseMarking();
			view.addChild(mark);
			
			if(pos==POS_LEFT || pos==POS_RIGHT)
			{
				points = points.reverse();
				resetPoints(points,maxY);
				
				mark.x = Base2D.sizeToScreen(dx);
				
				if(pos==POS_LEFT)
				{
					mark.updateView(points,"left",120,60,60);
				}
				else
				{
					mark.updateView(points,"left",60,120,-60-180);
				}
				
			}
			else
			{
				var x0:int = points[0]-min.x;
				mark.x = Base2D.sizeToScreen(x0);
				mark.y = Base2D.sizeToScreen(dy);
				if(pos==POS_TOP)
				{
					mark.updateView(points,"up",120,60,60);
				}
				else
				{
					mark.updateView(points,"up",60,120,-60-180);
				}
			}
			//trace("mark:",mark.x,mark.y);
			return mark;
		}
		
		//绘制整体台面及标识水盆灶台位置
		private function drawTable2D(tables:Array,depths:Array,g:Graphics,dx:int,dy:int,min:Point,max:Point):void
		{
			var drainer:ProductObject = cc.drainerProduct;
			var drainerInfo:WallObject = drainer.objectInfo;
			
			var flue:ProductObject = cc.flueProduct;
			var flueInfo:WallObject = flue.objectInfo;
			
			var drainerCenter:Point,flueCenter:Point;
			
			if(cc.isDrainerArea(tables))//检测是否为放置水盆的区域
			{
				var size:String = GlobalConfig.instance.getDrainerHoleSize();
				drainerCenter = drawDeviceCenter("水中心",drainer,g,dx,dy,size);
			}
			
			if(cc.isFlueArea(tables))
			{
				size = GlobalConfig.instance.getFlueHoleSize();
				flueCenter = drawDeviceCenter("灶中心",flue,g,dx,dy,size);
			}
			
			var points:Array = [];
			
			//绘制标注的坐标点
			
			var depth:int=depths[0];
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
			
			cc.offsetCrossWall(cw,depth,head,end,h,e);//计算台面外沿坐标
			
			var p:Point = cw.isHead?head:end;//台面外沿顺时针方向第一点
			var hp:Point = p.clone();
			points.push(p);
			
			var tlen:int = tables.length;
			for(var j:int=1;j<tlen;j++)//组成台面的每个墙面
			{
				depth=depths[j];
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
				
				cc.offsetCrossWall(cw,depth,head2,end2,h,e);
				
				var cp:Point = Geom.intersection(head,end,head2,end2);//台面外沿顺时针方向相拐角交点坐标
				points.push(cp);
				
				head = head2;
				end = end2;
			}
			
			p = cw.isHead?end:head;//台面外沿顺时针方向最后一点
			points.push(p);
			
			var ms:Array = [];//台面尾端标注数据
			ms.push(p);
			
			var ms1:Array = [];
			
			var ro:RoomObject,ro0:RoomObject,ro1:RoomObject;
			
			var cw0:CrossWall = null;
			for(j=tlen-1;j>=0;j--)
			{
				ro0 = null;
				ro1 = null;
				if(cw0)//存在前一个墙面
				{
					tableData = tables[j+1];
					
					var tx0:Number = tableData.x0;
					var tx1:Number = tableData.x1;
					
					var th:Point3D = cw0.localHead.clone();
					th.x = tx0;
					var te:Point3D = h.clone();
					te.x = tx1;
					
					var tp:Point = cc.turnPoint3d(cw0.isHead?th:te);
					
					ro0 = this.getRoomObject(cw0,tx0,tx1,RoomObject.HEAD);
				}
				
				if(ro0)
				{
					var tp1:Point = addPoint(points,cw0.wall,tp,0,ro0.holeWidth);
					addPoint(points,cw0.wall,tp,ro0.holeDepth,ro0.holeWidth);
					var tp2:Point = addPoint(points,cw0.wall,tp,ro0.holeDepth);
					
					ms1.push(tp1,tp2);
					drawMarking(cw0,POS_OUT,min,max,gh,ms1);//前一个墙面标注结束
					
					ms1 = [];
					ms1.push(tp1,tp2);
				}
				
				depth=depths[j];
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
				//trace("--wall:"+cw.wall.name);
				//trace("--localPoint:",h,e);
				
				var h0:Point = cc.turnPoint3d(h);
				var e0:Point = cc.turnPoint3d(e);
				
				p = e0.clone();//cc.turnPoint3d(cw.isHead?e:h);
				
				ro1 = this.getRoomObject(cw,x0,x1,RoomObject.END);
				if(ro1)
				{
					tp = addPoint(points,cw.wall,p,ro1.holeDepth);
					if(j==tlen-1)
					{
						ms.push(tp);//尾端点
					}
					addPoint(points,cw.wall,p,ro1.holeDepth,-ro1.holeWidth);
					tp1 = addPoint(points,cw.wall,p,0,-ro1.holeWidth);
					
					ms1.push(tp,tp1);
					if(cw0)
					{
						drawMarking(cw0,POS_OUT,min,max,gh,ms1);//前一个墙面标注结束
						
						ms1 = [];
						ms1.push(tp,tp1);
					}
				}
				
				if(!ro0 && !ro1)
				{
					tp = cw.wall.localToGlobal2(p);
					points.push(tp);
					
					ms1.push(tp);
					
					if(cw0)
					{
						drawMarking(cw0,POS_OUT,min,max,gh,ms1);//前一个墙面标注结束
						
						ms1 = [];
						ms1.push(tp);
					}
				}
				
				var gh:Point = cw.wall.localToGlobal2(h0);
				var ge:Point = cw.wall.localToGlobal2(e0);
				
				if(j==tlen-1)
				{
					if(!ro1)
					{
						points.push(cw.wall.localToGlobal2(p));//台面内沿逆时针方向第一点
					}
					
					ms.push(cw.wall.localToGlobal2(p));
					drawMarking(cw,POS_END,min,max,ge,ms,false);//绘制墙面尾端标注
				}
				
				ro = this.getRoomObject(cw,x0,x1,RoomObject.MIDDLE);
				if(ro)
				{
					p.x = ro.coordX;
					tp1 = addPoint(points,cw.wall,p,0);
					tp2 = addPoint(points,cw.wall,p,ro.holeDepth);
					addPoint(points,cw.wall,p,ro.holeDepth,-ro.holeWidth);
					var tp3:Point = addPoint(points,cw.wall,p,0,-ro.holeWidth);
					
					ms1.push(tp1,tp3);
					
					ms = [];
					ms.push(tp1,tp2);
					drawMarking(cw,POS_MIDDLE,min,max,tp2,ms,false);//标注进深
				}
				
				if(drainerInfo.crossWall==cw && flueInfo.crossWall==cw)//水盆和灶台处于同一台面区域内
				{
					//trace("-----drawDrainer-----------");
					ms = [];
					ms.push(gh,drainerCenter,flueCenter,ge);//水盆和灶台位置没有区分大小，后面会自动排序
					drawMarking(cw,POS_IN,min,max,drainerCenter,ms,false);
				}
				else if(drainerInfo.crossWall==cw)
				{
					ms = [];
					if(j==tlen-1)//在尾部区域
					{
						ms.push(drainerCenter,ge);
					}
					else if(j==0)//在头部区域
					{
						ms.push(gh,drainerCenter);
					}
					else//在中间区域
					{
						ms.push(gh,drainerCenter,ge);
					}
					drawMarking(cw,POS_IN,min,max,drainerCenter,ms,false);
				}
				else if(flueInfo.crossWall==cw)
				{
					ms = [];
					if(j==tlen-1)//在尾部区域
					{
						ms.push(flueCenter,ge);
					}
					else if(j==0)//在头部区域
					{
						ms.push(gh,flueCenter);
					}
					else//在中间区域
					{
						ms.push(gh,flueCenter,ge);
					}
					drawMarking(cw,POS_IN,min,max,flueCenter,ms,false);
				}
				
				cw0 = cw;
			}
			
			p = cc.turnPoint3d(cw.isHead?h:e);
			
			ms = [];//台面首端标注数据
			ms.push(cw.wall.localToGlobal2(p));
			
			ro = this.getRoomObject(cw,x0,x1,RoomObject.HEAD);
			
			if(ro)
			{
				tp = addPoint(points,cw.wall,p,0,ro.holeWidth);
				addPoint(points,cw.wall,p,ro.holeDepth,ro.holeWidth);
				tp1 = addPoint(points,cw.wall,p,ro.holeDepth);
				
				ms.push(tp1);
				ms1.push(tp,tp1);
			}
			else
			{
				tp = addPoint(points,cw.wall,p,0);//台面内沿逆时针方向最后一点
				ms1.push(tp);
			}
			
			drawMarking(cw,POS_OUT,min,max,ge,ms1);//绘制当前墙面台面标注
			
			ms.push(hp);
			drawMarking(cw,POS_HEAD,min,max,gh,ms,false);//绘制台面头端标注
			
			points.push(hp);
			drawPoints(g,points,dx,dy);
		}
		
		//绘制柜体外沿
		private function drawCabinetBorder(tables:Array,depths:Array,g:Graphics,dx:int,dy:int):void
		{
			var waiyan:Array = [];//厨柜外沿路径点序列（比台面外沿要缩进30mm）
			
			var dsWidth:int = 20;//挡水的宽度
			var cyWidth:int = 30;//台面出沿的宽度
			
			var depth:int=depths[0]-cyWidth;
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
			
			var head1:Point = new Point();
			var end1:Point = new Point();
			
			cc.offsetCrossWall(cw,depth,head1,end1,h,e);//计算柜体外沿坐标
			
			var p:Point = cw.isHead?head1:end1;
			
			var tp:Point = cw.wall.globalToLocal2(p);
			
			if(tableData.headCabinet || x0-cw.localHead.x<1)//台面起始端顶墙或中高柜
			{
				if(tableData.headCabinet)//台面起始端顶中高柜
				{
					addPoint(waiyan,cw.wall,tp,-50);//柜体外沿第一点
					addPoint(waiyan,cw.wall,tp,-50,40);//柜体外沿第二点
					addPoint(waiyan,cw.wall,tp,0,40);//柜体外沿第三点
				}
				else
				{
					addPoint(waiyan,cw.wall,tp,0);//柜体外沿第一点
				}
			}
			else
			{
				var ro:RoomObject = getRoomObject(cw,x0,x1,RoomObject.HEAD);
				if(ro)
				{
					addPoint(waiyan,cw.wall,tp,-depth+ro.holeDepth,cyWidth);//柜体外沿第一点
				}
				else
				{
					addPoint(waiyan,cw.wall,tp,-depth,cyWidth);//柜体外沿第一点
				}
				addPoint(waiyan,cw.wall,tp,0,cyWidth);//柜体外沿第二点
			}
			
			var tlen2:int = tables.length;
			for(var j:int=1;j<tlen2;j++)//组成台面的每个墙面
			{
				depth = depths[j]-cyWidth;
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
				
				var head3:Point = new Point();
				var end3:Point = new Point();
				
				cc.offsetCrossWall(cw,depth,head3,end3,h,e);
				p = Geom.intersection(head1,end1,head3,end3);//计算柜体外沿在拐角处的相交点坐标
				waiyan.push(p);
				
				head1 = head3;
				end1 = end3;
			}
			
			p = cw.isHead?end1:head1;
			
			tp = cw.wall.globalToLocal2(p);
			
			if(tableData.endCabinet || cw.localEnd.x-x1<1)
			{
				if(tableData.endCabinet)//台面尾端顶中高柜
				{
					addPoint(waiyan,cw.wall,tp,0,-40);//柜体外沿倒数第三点
					addPoint(waiyan,cw.wall,tp,-50,-40);//柜体外沿倒数第二点
					addPoint(waiyan,cw.wall,tp,-50);//柜体外沿倒数第一点
				}
				else
				{
					addPoint(waiyan,cw.wall,tp,0);//柜体外沿最后一点
				}
			}
			else
			{
				addPoint(waiyan,cw.wall,tp,0,-cyWidth);//柜体外沿倒数第二点
				
				ro = getRoomObject(cw,x0,x1,RoomObject.END);
				if(ro)
				{
					addPoint(waiyan,cw.wall,tp,-depth+ro.holeDepth,-cyWidth);//柜体外沿最后一点
				}
				else
				{
					addPoint(waiyan,cw.wall,tp,-depth,-cyWidth);//柜体外沿最后一点
				}
			}
			
			g.lineStyle(0,0x555555);
			drawPoints(g,waiyan,dx,dy,true);
		}
		
		private function addPoint(points:Array,wall:Wall,base:Point,offsetY:Number,offsetX:Number=0):Point
		{
			var p:Point = base.clone();
			offsetPoint(p,offsetY,offsetX);
			wall.localToGlobal2(p,p);
			points.push(p);
			return p;
		}
		
		//绘制挡水
		private function drawWaterHoldingBorder(tables:Array,depths:Array,g:Graphics,dx:int,dy:int):void
		{
			var dsWidth:int = 20;//挡水的宽度
			var dsWidth2:int = 40;//挡水的宽度
			var cyWidth:int = 30;//台面出沿的宽度
			
			var points:Array = [];
			var pss:Array = [];
			pss.push(points);
			
			var len:int = tables.length;
			
			var depth:int=depths[len-1];
			var tableData:WallSubArea = tables[len-1];
			
			var cw:CrossWall = tableData.cw;
			var x0:Number = tableData.x0;
			var x1:Number = tableData.x1;
			
			if(tableData.headCabinet)x0+=tableData.headCabinet.objectInfo.width;
			if(tableData.endCabinet)x1-=tableData.endCabinet.objectInfo.width;
			
			var h:Point3D = cw.localHead.clone();
			h.x = x0;
			
			var e:Point3D = h.clone();
			e.x = x1;
			
			var p:Point = cc.turnPoint3d(e);
			var tp:Point = p.clone();
			offsetPoint(tp,depth);
			
			if(tableData.endCabinet || cw.localEnd.x-x1<1)//台面尾端顶墙或中高柜
			{
				if(tableData.endCabinet)//台面尾端有中高柜
				{
					addPoint(points,cw.wall,tp,-cyWidth);
					addPoint(points,cw.wall,tp,-cyWidth,-dsWidth);
				}
				else
				{
					addPoint(points,cw.wall,tp,0);//台面外沿，挡水起始坐标
					addPoint(points,cw.wall,tp,0,-dsWidth);//台面外沿，挡水第二点坐标
				}
				
				var ro:RoomObject = this.getRoomObject(cw,x0,x1,RoomObject.END);
				if(ro)
				{
					if(ro.name == ProductObjectName.ROOM_SQUARE_PILLAR)
					{
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth,-dsWidth);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth,-ro.holeWidth-dsWidth);
						addPoint(points,cw.wall,p,dsWidth,-ro.holeWidth-dsWidth);
					}
					else
					{
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth2,-dsWidth);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth2,-ro.holeWidth-dsWidth2);
						addPoint(points,cw.wall,p,dsWidth,-ro.holeWidth-dsWidth2);
						
						var a:Array = [];
						pss.push(a);
						
						addPoint(a,cw.wall,p,ro.holeDepth+dsWidth);
						addPoint(a,cw.wall,p,ro.holeDepth+dsWidth,-ro.holeWidth-dsWidth);
						addPoint(a,cw.wall,p,0,-ro.holeWidth-dsWidth);
					}
				}
				else
				{
					addPoint(points,cw.wall,p,dsWidth,-dsWidth);
				}
			}
			else
			{
				ro = this.getRoomObject(cw,x0,x1,RoomObject.END);
				if(ro)
				{
					addPoint(points,cw.wall,p,ro.holeDepth+dsWidth);
					addPoint(points,cw.wall,p,ro.holeDepth+dsWidth,-ro.holeWidth-dsWidth);
					addPoint(points,cw.wall,p,dsWidth,-ro.holeWidth-dsWidth);
				}
				else
				{
					addPoint(points,cw.wall,p,dsWidth);
				}
			}
			
			ro = null;
			
			var cw0:CrossWall = null;
			for(var j:int=len-1;j>=0;j--)
			{
				depth = depths[j];
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
				
				p = cc.turnPoint3d(cw.isHead?e:h);
				
				//最末端的点已经在前面处理过，所以此处跳过
				if(j<len-1)ro = this.getRoomObject(cw,x0,x1,RoomObject.END);
				if(ro)
				{
					if(ro.name == ProductObjectName.ROOM_SQUARE_PILLAR)
					{
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth,-dsWidth);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth,-ro.holeWidth-dsWidth);
						addPoint(points,cw.wall,p,dsWidth,-ro.holeWidth-dsWidth);
					}
					else
					{
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth2,-dsWidth);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth2,-ro.holeWidth-dsWidth2);
						addPoint(points,cw.wall,p,dsWidth,-ro.holeWidth-dsWidth2);
						
						pss.push(a=[]);
						addPoint(a,cw.wall,p,ro.holeDepth+dsWidth);
						addPoint(a,cw.wall,p,ro.holeDepth+dsWidth,-ro.holeWidth-dsWidth);
						addPoint(a,cw.wall,p,0,-ro.holeWidth-dsWidth);
					}
				}
				else if(cw0)
				{
					tableData = tables[j+1];
					
					var tx0:Number = tableData.x0;
					var tx1:Number = tableData.x1;
					
					var th:Point3D = cw0.localHead.clone();
					th.x = tx0;
					var te:Point3D = h.clone();
					te.x = x1;
					
					var tp0:Point = cc.turnPoint3d(cw0.isHead?th:te);
					
					ro = this.getRoomObject(cw0,tx0,tx1,RoomObject.HEAD);
					if(ro)
					{
						if(ro.name == ProductObjectName.ROOM_SQUARE_PILLAR)
						{
							addPoint(points,cw0.wall,tp0,dsWidth,ro.holeWidth+dsWidth);
							addPoint(points,cw0.wall,tp0,ro.holeDepth+dsWidth,ro.holeWidth+dsWidth);
							addPoint(points,cw0.wall,tp0,ro.holeDepth+dsWidth,dsWidth);
						}
						else
						{
							addPoint(points,cw0.wall,tp0,dsWidth,ro.holeWidth+dsWidth2);
							addPoint(points,cw0.wall,tp0,ro.holeDepth+dsWidth2,ro.holeWidth+dsWidth2);
							addPoint(points,cw0.wall,tp0,ro.holeDepth+dsWidth2,dsWidth);
							
							pss.push(a=[]);
							addPoint(a,cw0.wall,tp0,0,ro.holeWidth+dsWidth);
							addPoint(a,cw0.wall,tp0,ro.holeDepth+dsWidth,ro.holeWidth+dsWidth);
							addPoint(a,cw0.wall,tp0,ro.holeDepth+dsWidth);
						}
					}
				}
				
				if(j<len-1 && !ro)addPoint(points,cw.wall,p,dsWidth,-dsWidth);
				
				ro = this.getRoomObject(cw,x0,x1,RoomObject.MIDDLE);
				if(ro)
				{
					p.x = ro.coordX;
					if(ro.name == ProductObjectName.ROOM_SQUARE_PILLAR)
					{
						addPoint(points,cw.wall,p,dsWidth,dsWidth);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth,dsWidth);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth,-ro.holeWidth-dsWidth);
						addPoint(points,cw.wall,p,dsWidth,-ro.holeWidth-dsWidth);
					}
					else
					{
						addPoint(points,cw.wall,p,dsWidth,dsWidth2);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth2,dsWidth2);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth2,-ro.holeWidth-dsWidth2);
						addPoint(points,cw.wall,p,dsWidth,-ro.holeWidth-dsWidth2);
						
						pss.push(a=[]);
						addPoint(a,cw.wall,p,0,dsWidth);
						addPoint(a,cw.wall,p,ro.holeDepth+dsWidth,dsWidth);
						addPoint(a,cw.wall,p,ro.holeDepth+dsWidth,-ro.holeWidth-dsWidth);
						addPoint(a,cw.wall,p,0,-ro.holeWidth-dsWidth);
					}
				}
				
				cw0 = cw;
				ro = null;
			}
			
			p = cc.turnPoint3d(h);//cw.isHead?h:e);
			
			if(tableData.headCabinet || x0-cw.localHead.x<1)//台面头端顶墙或中高柜
			{
				ro = this.getRoomObject(cw,x0,x1,RoomObject.HEAD);
				if(ro)
				{
					if(ro.name == ProductObjectName.ROOM_SQUARE_PILLAR)
					{
						addPoint(points,cw.wall,p,dsWidth,ro.holeWidth+dsWidth);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth,ro.holeWidth+dsWidth);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth,dsWidth);
					}
					else
					{
						addPoint(points,cw.wall,p,dsWidth,ro.holeWidth+dsWidth2);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth2,ro.holeWidth+dsWidth2);
						addPoint(points,cw.wall,p,ro.holeDepth+dsWidth2,dsWidth);
						
						pss.push(a=[]);
						addPoint(a,cw.wall,p,0,ro.holeWidth+dsWidth);
						addPoint(a,cw.wall,p,ro.holeDepth+dsWidth,ro.holeWidth+dsWidth);
						addPoint(a,cw.wall,p,ro.holeDepth+dsWidth,0);
					}
				}
				else
				{
					addPoint(points,cw.wall,p,dsWidth,dsWidth);
				}
				
				tp = p.clone();
				offsetPoint(tp,depth);
				if(tableData.headCabinet)//台面头端有中高柜
				{
					addPoint(points,cw.wall,tp,-cyWidth,dsWidth);
					addPoint(points,cw.wall,tp,-cyWidth);
				}
				else
				{
					addPoint(points,cw.wall,tp,0,dsWidth);//台面外沿，挡水第二点坐标
					addPoint(points,cw.wall,tp,0);//台面外沿，挡水起始坐标
				}
			}
			else
			{
				ro = this.getRoomObject(cw,x0,x1,RoomObject.HEAD);
				if(ro)
				{
					addPoint(points,cw.wall,p,dsWidth,ro.holeWidth+dsWidth);
					addPoint(points,cw.wall,p,ro.holeDepth+dsWidth,ro.holeWidth+dsWidth);
					addPoint(points,cw.wall,p,ro.holeDepth+dsWidth);
				}
				else
				{
					addPoint(points,cw.wall,p,dsWidth);
				}
			}
			
			//drawPoints(g,points,dx,dy);
			drawPointsArray(g,pss,dx,dy);
		}
		
		private function offsetPoint(p:Point,offsetY:Number,offsetX:Number=0):void
		{
			p.x += offsetX;
			p.y = p.y>0 ? p.y+offsetY : p.y-offsetY;
		}
		
		private function drawPointsArray(g:Graphics,pointsArray:Array,dx:int,dy:int,isBrokenLine:Boolean=false):void
		{
			var len:int = pointsArray.length;
			for(var i:int=0;i<len;i++)
			{
				var points:Array = pointsArray[i];
				drawPoints(g,points,dx,dy,isBrokenLine);
			}
		}
		
		private function drawPoints(g:Graphics,points:Array,dx:int,dy:int,isBrokenLine:Boolean=false):void
		{
			//trace("drawPoints:"+points);
			var len:int = points.length;
			if(!isBrokenLine)
			{
				var p0:Point = points[0];
				turnPoint(p0,dx,dy);
				g.moveTo(p0.x,p0.y);
				
				for(var i:int=1;i<len;i++)
				{
					var p1:Point = points[i];
					drawLine(g,p1,dx,dy);
				}
			}
			else
			{
				p0 = points[0];
				turnPoint(p0,dx,dy);
				
				for(i=1;i<len;i++)
				{
					p1 = points[i];
					turnPoint(p1,dx,dy);
					BrokenLineDrawer.draw2(g,p0,p1,3,2);
					p0 = p1;
				}
			}
		}
		
		private function drawDeviceCenter(name:String,device:ProductObject,g:Graphics,dx:int,dy:int,holeSize:String):Point
		{
			var wo:WallObject = device.objectInfo;
			
			var holeWidth:int = wo.width;
			var holeDepth:int = wo.depth;
			
			var wall:Wall = wo.crossWall.wall;
			var ww:Number = wall.width*0.5 + 300;
			
			var p:Point = new Point();
			p.x = wo.x-wo.width*0.5;
			p.y = wo.crossWall.isHead?-ww:ww;
			
			var tp:Point = p.clone();//将转换前的坐标点返回，用于绘制标注
			tp.y -= 300;//台面边沿位置
			wall.localToGlobal2(tp,tp);
			
			wall.localToGlobal2(p,p);
			
			turnPoint(p,dx,dy);
			
			g.drawCircle(p.x,p.y,2);
			g.drawCircle(p.x,p.y,0.1);
			
			var bmp:Bitmap = Utils.getTextBitmap(name);
			view.addChild(bmp);
			bmp.x = p.x - bmp.width*0.5;
			bmp.y = p.y - bmp.height - 1;
			
			if(holeSize)
			{
				bmp = Utils.getTextBitmap(holeSize);
				view.addChild(bmp);
				bmp.x = p.x - bmp.width*0.5;
				bmp.y = p.y + 1;
			}
			
			return tp;
		}
		
		//计算台面二维坐标值范围
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
			
			var depth:int=0;
			cc.offsetCrossWall(cw,depth,head,end,h,e);
			
			var p:Point = cw.isHead?head:end;//台面内沿顺时针方向最后一点
			resetBound(p,max,min);
			
			depth=depths[0];
			cc.offsetCrossWall(cw,depth,head,end,h,e);
			
			p = cw.isHead?head:end;//台面外沿顺时针方向第一点
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
		
		/**
		 * 将场景右手系坐标，转换为屏幕坐标
		 * @param p
		 * @param dx
		 * @param dy
		 * 
		 */
		private function turnPoint(p:Point,dx:int,dy:int):void
		{
			//trace("point1:"+p);
			p.x = Base2D.sizeToScreen(p.x + dx);
			p.y = Base2D.sizeToScreen(dy - p.y);
			//trace("point2:"+p);
		}
		
		private var pillarDistTable:int = 20;//立管与包管之间的净空
		private var pillarDistWall:int = 300;//立管与某一墙面之间净空大于此值时，要使用U型包管，否则使用L型包管
		
		private function getRoomObject(cw:CrossWall,x0:Number,x1:Number,position:String):RoomObject
		{
			//trace("getRoomObject position:"+position);
			var ro:RoomObject;
			
			var len:int = this.pillars.length;
			for(var i:int=0;i<len;i++)
			{
				var po:ProductObject = pillars[i];
				var wo:WallObject = po.objectInfo;
				if(cw==wo.crossWall)
				{
					var d0:int = wo.x - wo.width;
					var d1:int = wo.x;
					if(isOverArea(x0,x1,d0,d1))
					{
						//trace("---x0,x1,d0,d1:",x0,x1,d0,d1);
						if(position==RoomObject.HEAD && d0-x0<1)
						{
							ro = new RoomObject(po);
							ro.position = RoomObject.HEAD;
							ro.holeWidth = d1 - x0;
							ro.coordX = wo.x;
							ro.holeDepth = wo.depth;
							
							//pillars.splice(i,1);
							
							return ro;
						}
						
						if(position==RoomObject.END && x1-d1<1)
						{
							ro = new RoomObject(po);
							ro.position = RoomObject.END;
							ro.holeWidth = x1 - d0;
							ro.coordX = x1;
							ro.holeDepth = wo.depth;
							
							//pillars.splice(i,1);
							
							return ro;
						}
						
						if(position==RoomObject.MIDDLE && d0-x0>=1 && x1-d1>=1)
						{
							ro = new RoomObject(po);
							ro.position = RoomObject.MIDDLE;
							ro.holeWidth = wo.width;
							ro.coordX = wo.x;
							ro.holeDepth = wo.depth;
							
							//pillars.splice(i,1);
							
							return ro;
						}
						
					}
				}
			}
			
			len = columns.length;
			for(i=0;i<len;i++)
			{
				po = columns[i];
				wo = po.objectInfo;
				if(cw==wo.crossWall)
				{
					d0 = wo.x - wo.width;
					d1 = wo.x;
					if(isOverArea(x0,x1,d0,d1))
					{
						if(position==RoomObject.HEAD && d0-cw.localHead.x<pillarDistWall)
						{
							ro = new RoomObject(po);
							ro.position = RoomObject.HEAD;
							ro.coordX = d1 + pillarDistTable;
							ro.holeWidth = ro.coordX - x0;
							ro.holeDepth = wo.z + wo.depth + pillarDistTable;
							
							//columns.splice(i,1);
							
							return ro;
						}
						
						if(position==RoomObject.END && cw.localEnd.x-d1<pillarDistWall)
						{
							ro = new RoomObject(po);
							ro.position = RoomObject.END;
							ro.coordX = x1;
							ro.holeWidth = ro.coordX - d0 + pillarDistTable;
							ro.holeDepth = wo.z + wo.depth + pillarDistTable;
							
							//columns.splice(i,1);
							
							return ro;
						}
						
						if(position==RoomObject.MIDDLE && d0-cw.localHead.x>=pillarDistWall && cw.localEnd.x-d1>=pillarDistWall)
						{
							ro = new RoomObject(po);
							ro.position = RoomObject.MIDDLE;
							ro.coordX = d1 + pillarDistTable;
							ro.holeWidth = wo.width + pillarDistTable + pillarDistTable;
							ro.holeDepth = wo.z + wo.depth + pillarDistTable;
							
							//columns.splice(i,1);
							
							return ro;
						}
						
					}
				}
			}
			
			return null;
		}
		
		private function isOverArea(x00:Number,x01:Number,x10:Number,x11:Number):Boolean
		{
			if(MyMath.isGreaterEqual(x10,x01))return false;
			if(MyMath.isLessEqual(x11,x00))return false;
			return true;
		}
	}
}

import rightaway3d.engine.product.ProductObject;

class RoomObject
{
	static public const END:String = "end";
	static public const HEAD:String = "head";
	static public const MIDDLE:String = "middle";
	
	public var object:ProductObject;
	public var position:String;
	
	public var holeWidth:int;
	public var holeDepth:int;
	
	public var coordX:int;
	
	public function get name():String
	{
		return object.name;
	}
	
	public function RoomObject(obj:ProductObject)
	{
		object = obj;
	}
}