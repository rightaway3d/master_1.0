package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Point;
	
	import rightaway3d.engine.core.ModelAlign;
	import rightaway3d.engine.product.ProductInfo;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.cabinet.CabinetType;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.WallObject;

	public class WallFace2D extends Base2D
	{
		static public const lineColor:uint = 0x0;
		
		private var sizeMark:WallFaceMarking;
		
		private var groundMark:BaseMarking;//地柜插座位置数据
		private var hoodMark:BaseMarking;//烟机插座位置数据
		public var wallMark:BaseMarking;//中间墙面插座位置数据
		
		public function WallFace2D()
		{
			sizeMark = new WallFaceMarking();
			this.addChild(sizeMark);
			
			groundMark = new BaseMarking();
			this.addChild(groundMark);
			groundMark.visible = false;
			
			wallMark = new BaseMarking();
			this.addChild(wallMark);
			wallMark.visible = false;
			
			hoodMark = new BaseMarking();
			this.addChild(hoodMark);
			hoodMark.visible = false;
		}
		
		public function updateView(cw:CrossWall):void
		{
			sizeMark.updateView(cw);
			
			//trace("WallFace2D updateView");
			clearCabinetShapes();
			clearLevelMarks();
			clearWallSockets();
			
			var g:Graphics = this.graphics;
			g.clear();
			
			var wallHeight:Number = cw.wall.height;
			var w:Number = Base2D.sizeToScreen(cw.validLength);
			var h:Number = Base2D.sizeToScreen(wallHeight);
			var x0:Number = cw.localHead.x;
			var x1:Number = cw.localEnd.x-x0;
			
			var gs:Array = [];//地柜插座位置数据
			gs.push(0);
			
			var ws:Array = [];//烟机插座位置数据
			ws.push(0);
			
			var bgColor:uint = 0xffffff;
			//g.beginFill(bgColor);
			g.lineStyle(0.55,lineColor);
			g.drawRect(0,-h,w,h);
			//g.endFill();
			g.lineStyle(0,lineColor);
			
			var gos:Array = cw.groundObjects;
			var len:int = gos.length;
			
			for(var i:int=0;i<len;i++)
			{
				var wo:WallObject = gos[i];
				drawCabinetShape(wo,x0,wallHeight);
				
				var wox:Number = wo.x - x0;
				
				//trace(i+" wallObject:"+wo.object);
				if(wo.object is ProductObject)
				{
					var po:ProductObject = wo.object;
					var style:String = po.productInfo.style;
					//trace(style);
					var ty:Number = 300;
					
					switch(style)
					{
						case CabinetType.DRAINER_CABINET:
							var tx:Number = wox-wo.width*0.5;
							gs.push(tx);
							
							setWallSocket(tx-55,ty);
							setWallSocket(tx-165,ty);
							//setLevelMark(ty,"right",tx+250,ty);
							/*if(tx>cw.validLength*0.5)
							{
							setLevelMark(ty,"right",cw.validLength+80,ty);
							}
							else
							{
							setLevelMark(ty,"left",-80,ty);
							}*/
							setLevelMark(ty,"right",cw.validLength+80,ty);
							drawWaterPipe(g,tx+60,-500);
							drawWaterPipe(g,tx+210,-500);
							g.drawRect(Base2D.sizeToScreen(tx+135-30),
								Base2D.sizeToScreen(-280),
								Base2D.sizeToScreen(60),
								Base2D.sizeToScreen(200));
							
							break;
						case CabinetType.ELECTRIC_HEIGHT:
						case CabinetType.ELECTRIC_MIDDLE://电器高柜中高柜下方增加插座
							tx = wox-wo.width*0.5;
							gs.push(tx);
							
							setWallSocket(tx-55,ty);
							setWallSocket(tx+55,ty);
							setLevelMark(ty,"right",cw.validLength+80,ty);
							
							break;
						case CabinetType.ELECTRIC_GROUND:
							if(i<len-1)
							{
								tx = wox + 30;
								gs.push(tx);
								
								setWallSocket(tx+50,ty);
								setWallSocket(tx+160,ty);
								
								//setLevelMark(ty,"right",tx+350,ty);
								//setLevelMark(ty,"right",cw.validLength+80,ty);
							}
							else
							{
								tx = wox - wo.width - 30;
								gs.push(tx);
								
								setWallSocket(tx-50,ty);
								setWallSocket(tx-160,ty);
								//setLevelMark(ty,"left",tx-350,ty);
								//setLevelMark(ty,"left",-80,ty);
							}
							setLevelMark(ty,"right",cw.validLength+80,ty);
							break;
					}
				}
			}
			
			var wos:Array = cw.wallObjects;
			len = wos.length;
			
			for(i=0;i<len;i++)
			{
				wo = wos[i];
				var oy:int = 0;
				
				wox = wo.x - x0;
				drawCabinetShape(wo,x0,wallHeight);
				
				if(wo.object is ProductObject)
				{
					po = wo.object;
					oy = po.productInfo.alignOffset.y;
					style = po.productInfo.style;
					
					switch(style)
					{
						case CabinetType.HOOD:
							tx = wox-wo.width*0.5;
							ws.push(tx);
							
							ty = wo.y+wo.height-oy+100;
							setWallSocket(tx-55,ty);
							setWallSocket(tx+55,ty);
							setLevelMark(ty,"right",tx+250,ty);
							break;
					}
				}
			}
			
			updateSizeMark(gs,groundMark,x1);
			groundMark.y = -42;
			
			updateSizeMark(ws,hoodMark,x1);
			hoodMark.y = -125;//-56;
		}
		
		public function updateSizeMark(points:Array,mark:BaseMarking,x1:Number):void
		{
			if(points.length>1)
			{
				points.push(x1);
				mark.updateView(points);
				mark.visible = true;
			}
			else
			{
				mark.visible = false;
			}
		}
		
		private function drawWaterPipe(g:Graphics,x:Number,y:Number):void
		{
			var r:int = 50;//半径
			var x0:Number = Base2D.sizeToScreen(x-r);
			var x1:Number = Base2D.sizeToScreen(x+r);
			var y0:Number = Base2D.sizeToScreen(y-r);
			var y1:Number = Base2D.sizeToScreen(y+r);
			
			x = Base2D.sizeToScreen(x);
			y = Base2D.sizeToScreen(y);
			
			g.moveTo(x0,y);
			g.lineTo(x1,y);
			
			g.moveTo(x,y0);
			g.lineTo(x,y1);
			
			g.drawCircle(x,y,Base2D.sizeToScreen(r-25));
		}
		
		public function drawHeadSocket(cw:CrossWall,dx:int):Number
		{
			var tx:Number = dx + 400;
			var ty:Number = 1100;
			setWallSocket(tx,ty);
			setWallSocket(tx+110,ty);
			setWallSocket(tx+220,ty);
			//setLevelMark(ty,"left",tx-200,ty);
			//setLevelMark(ty,"left",-80,ty);
			setLevelMark(ty,"right",cw.validLength+80,ty);
			
			return tx;
		}
		
		public function drawEndSocket(cw:CrossWall,dx:int):Number
		{
			var tx:Number = cw.localEnd.x - cw.localHead.x - dx - 400;
			var ty:Number = 1100;
			//setLevelMark(ty,"right",tx+100,ty);
			setLevelMark(ty,"right",cw.validLength+80,ty);
			
			setWallSocket(tx,ty);
			setWallSocket(tx-110,ty);
			setWallSocket(tx-220,ty);
			
			return tx;
		}
		
		private var inLevelMarks:Array = [];
		private var outLevelMarks:Array = [];
		
		private function clearLevelMarks():void
		{
			while(inLevelMarks.length>0)
			{
				var m:LevelMark2D = inLevelMarks.pop();
				this.removeChild(m);
				outLevelMarks.push(m);
			}
		}
		
		private function setLevelMark(level:int,direct:String,xPos:int,yPos:int,offSetSize:int=0):void
		{
			if(outLevelMarks.length>0)
			{
				levelMark = outLevelMarks.pop();
			}
			else
			{
				var levelMark:LevelMark2D = new LevelMark2D();
			}
			inLevelMarks.push(levelMark);
			
			levelMark.updateView(level,direct,xPos,yPos);
			
			this.addChild(levelMark);
		}
		
		private var inWallSockets:Array = [];
		private var outWallSockets:Array = [];
		
		private function clearWallSockets():void
		{
			while(inWallSockets.length>0)
			{
				var s:WallSocket2D = inWallSockets.pop();
				this.removeChild(s);
				outWallSockets.push(s);
			}
		}
		
		private function setWallSocket(xPos:int,yPos:int):void
		{
			if(outWallSockets.length>0)
			{
				s = outWallSockets.pop();
			}
			else
			{
				var s:WallSocket2D = new WallSocket2D();
			}
			inWallSockets.push(s);
			
			s.updateView(xPos,yPos);
			
			this.addChild(s);
		}
		
		private var inCabinetShapes:Array = [];
		private var outCabinetShapes:Array = [];
		
		private function clearCabinetShapes():void
		{
			while(inCabinetShapes.length>0)
			{
				var m:Shape = inCabinetShapes.pop();
				this.removeChild(m);
				outCabinetShapes.push(m);
			}
		}
		
		private function drawCabinetShape(wo:WallObject,x0:Number,wallHeight:Number):void
		{
			if(outCabinetShapes.length>0)
			{
				s = outCabinetShapes.pop();
			}
			else
			{
				var s:Shape = new Shape();
			}
			inCabinetShapes.push(s);
			
			this.addChild(s);
			
			updateCabinetShape(s,wo,x0,wallHeight);
		}
		
		private function updateCabinetShape(s:Shape,wo:WallObject,x0:Number,wallHeight:Number):void
		{
			//var lineColor:uint =0xffffff;
			
			var g:Graphics = s.graphics;
			g.clear();
			
			var ww:Number = Base2D.sizeToScreen(wo.width);
			var wh:Number = Base2D.sizeToScreen(wo.height);
			var wx:Number = Base2D.sizeToScreen(wo.x-x0);
			var wy:Number = Base2D.sizeToScreen(wo.y==0&&wo.height==720?80:wo.y);
			
			s.x = wx;
			s.y = -wy;
			
			g.lineStyle(0,lineColor);
			g.drawRect(-ww,-wh,ww,wh);
			
			if(wo.object is ProductObject)
			{
				var po:ProductObject = wo.object;
				if(po.dynamicSubProductObjects)
				{
					var len:int = po.dynamicSubProductObjects.length;
					for(var i:int=0;i<len;i++)
					{
						var spo:ProductObject = po.dynamicSubProductObjects[i];
						var info:ProductInfo = spo.productInfo;
						if(info.type.indexOf(CabinetType.DOOR)>-1)
						{
							var tw:Number = Base2D.sizeToScreen(info.dimensions.x);
							var th:Number = Base2D.sizeToScreen(info.dimensions.y);
							var tx:Number = Base2D.sizeToScreen(spo.position.x);
							var ty:Number = Base2D.sizeToScreen(spo.position.y);
							var file:String = info.fileURL;
							//trace("fileURL,dimensions,tw,th,tx,ty:",file,info.dimensions,tw,th,tx,ty);
							
							var doorPlank:ProductObject = getSubProductByType(spo,CabinetType.DOOR_PLANK);
							if(doorPlank)
							{
								var p:Point = getProductOffset(doorPlank.productInfo);
								var x:Number = -tx-p.x;
								var y:Number = -(ty+th+p.y);
								//trace("p3:",x,y);
								
								//g.lineStyle(0,0xff0000);
								g.drawRect(x,y,tw,th);
								
								if(file.indexOf("left")>-1)//左开门
								{
									g.moveTo(x+tw,y);
									g.lineTo(x,y+th*0.5);
									g.lineTo(x+tw,y+th);
								}
								else if(file.indexOf("right")>-1)
								{
									g.moveTo(x,y);
									g.lineTo(x+tw,y+th*0.5);
									g.lineTo(x,y+th);
								}
							}
							
							var handle:ProductObject = getSubProductByType(spo,CabinetType.HANDLE);
							if(handle)
							{
								info = handle.productInfo;
								p = getProductOffset(info);
								tw = Base2D.sizeToScreen(info.dimensions.x);
								th = Base2D.sizeToScreen(info.dimensions.y);
								tx = Base2D.sizeToScreen(handle.position.x) + tx;
								ty = Base2D.sizeToScreen(handle.position.y) + ty;
								//trace("tw,th,tx,ty:",tw,th,tx,ty);
								x = -tx-p.x;
								y = -(ty+th+p.y);
								//trace("p4:",x,y);
								
								//g.lineStyle(0,0x00ff00);
								g.drawRect(x,y,tw,th);
							}
						}
					}
				}
			}
		}
		
		private function getProductOffset(info:ProductInfo):Point
		{
			var p:Point = new Point();
			var dw:Number = info.dimensions.x;
			var dh:Number = info.dimensions.y;
			
			p.x = dw * 0.5;
			p.y = dh * 0.5;
			
			var aligns:Array = info.aligns;
			for each(var s:String in aligns)
			{
				//trace("align:",s);
				if(s==ModelAlign.TOP)
				{
					p.y = -dh;
				}
				else if(s==ModelAlign.BOTTOM)
				{
					p.y = 0;
				}
				else if(s==ModelAlign.LEFT)
				{
					p.x = dw;
				}
				else if(s==ModelAlign.RIGHT)
				{
					p.x = 0;
				}
			}
			//trace("p0:",p);
			p.x -= info.alignOffset.x;
			p.y -= info.alignOffset.y;
			//trace("p1:",p);
			
			p.x = Base2D.sizeToScreen(p.x);
			p.y = Base2D.sizeToScreen(p.y);
			//trace("p2:",p);
			
			return p;
		}
		
		/*private function getDoorPlankProduct(po:ProductObject):ProductObject
		{
			return getSubProductByType(po,CabinetType.DOOR_PLANK);
		}*/
		
		private function getSubProductByType(po:ProductObject,type:String):ProductObject
		{
			if(po.productInfo.type.indexOf(type)>-1)return po;
			
			if(!po.dynamicSubProductObjects)return null;
			
			var len:int = po.dynamicSubProductObjects.length;
			for(var i:int=0;i<len;i++)
			{
				var spo:ProductObject = po.dynamicSubProductObjects[i];
				var info:ProductInfo = spo.productInfo;
				if(info.type.indexOf(type)>-1)
				{
					return spo;
				}
			}
			
			return null;
		}
	}
}











