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
		
		public function WallFace2D()
		{
		}
		
		public function updateView(cw:CrossWall):void
		{
			//trace("WallFace2D updateView");
			clearCabinetShapes();
			clearLevelMarks();
			clearWallSockets();
			
			var g:Graphics = this.graphics;
			g.clear();
			g.lineStyle(0,lineColor);
			
			//cw.initTestObject();
			var wallHeight:Number = cw.wall.height;
			var w:Number = Base2D.sizeToScreen(cw.validLength);
			var h:Number = Base2D.sizeToScreen(wallHeight);
			var x0:Number = cw.localHead.x;
			//trace(w,h,dx);
			
			var bgColor:uint = 0xffffff;
			g.beginFill(bgColor);
			g.drawRect(0,-h,w,h);
			g.endFill();
			
			var gos:Array = cw.groundObjects;
			var len:int = gos.length;
			
			for(var i:int=0;i<len;i++)
			{
				var wo:WallObject = gos[i];
				var ww:Number = Base2D.sizeToScreen(wo.width);
				var wh:Number = Base2D.sizeToScreen(wo.height);
				var wx:Number = Base2D.sizeToScreen(wo.x-wo.width-x0);
				var wy:Number = Base2D.sizeToScreen(wo.y==0&&wo.height==720?80:wo.y);
				//trace(i,wx,wy,ww,wh);18911273446
				//g.drawRect(wx,-(wy+wh),ww,wh);
				drawCabinetShape(wo,x0,wallHeight);
				
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
							var tx:Number = wo.x-wo.width*0.5;
							setWallSocket(tx-110,ty);
							setWallSocket(tx+10,ty);
							setLevelMark(ty,"right",tx+200,ty);
							break;
						case CabinetType.ELECTRIC_GROUND:
							if(i<len-1)
							{
								tx = wo.x + 100;
								setLevelMark(ty,"right",tx+200,ty);
							}
							else
							{
								tx = wo.x - wo.width - 400;
								setLevelMark(ty,"left",tx-100,ty);
							}
							setWallSocket(tx,ty);
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
				
				ww = Base2D.sizeToScreen(wo.width);
				wh = Base2D.sizeToScreen(wo.height);
				wx = Base2D.sizeToScreen(wo.x-x0)-ww;
				wy = Base2D.sizeToScreen(wo.y-oy);
				//trace(i,wx,wy,ww,wh);
				
				//g.drawRect(wx,-(wy+wh),ww,wh);
				drawCabinetShape(wo,x0,wallHeight);
				//trace(i+" wallObject:"+wo.object);
				
				if(wo.object is ProductObject)
				{
					po = wo.object;
					oy = po.productInfo.alignOffset.y;
					style = po.productInfo.style;
					//trace(style);
					
					switch(style)
					{
						case CabinetType.HOOD:
							tx = wo.x-wo.width*0.5-50;
							ty = wo.y+wo.height-oy+100;
							setWallSocket(tx,ty);
							setLevelMark(ty,"right",tx+200,ty);
							break;
					}
				}
			}
			
			//setLevelMark(1100,"left",1300,1100);
			//setLevelMark(1100,"right",2000,1100);
			
			//setWallSocket(1500,1100);
			
			//drawHeadSocket(cw);
			//drawEndSocket(cw);
		}
		
		public function drawHeadSocket(cw:CrossWall):void
		{
			var tx:Number = cw.localHead.x + 300;
			var ty:Number = 1100;
			setWallSocket(tx,ty);
			setWallSocket(tx+110,ty);
			setWallSocket(tx+220,ty);
			setLevelMark(ty,"left",tx-200,ty);
		}
		
		public function drawEndSocket(cw:CrossWall):void
		{
			var tx:Number = cw.localEnd.x - 400;
			var ty:Number = 1100;
			setLevelMark(ty,"right",tx+100,ty);
			
			setWallSocket(tx-100,ty);
			setWallSocket(tx-210,ty);
			setWallSocket(tx-320,ty);
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











