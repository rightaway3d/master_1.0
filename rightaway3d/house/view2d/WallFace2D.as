package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.cabinet.CabinetType;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.WallObject;

	public class WallFace2D extends Base2D
	{
		public function WallFace2D()
		{
		}
		
		public function updateView(cw:CrossWall):void
		{
			//trace("WallFace2D updateView");
			
			var lineColor:uint = Wall2D.lineColor;
			
			clearLevelMarks();
			clearWallSockets();
			
			var g:Graphics = this.graphics;
			g.clear();
			g.lineStyle(0,lineColor);
			
			//cw.initTestObject();
			
			var w:Number = Base2D.sizeToScreen(cw.validLength);
			var h:Number = Base2D.sizeToScreen(cw.wall.height);
			var dx:Number = cw.localHead.x;
			//trace(w,h,dx);
			
			g.beginFill(0);
			g.drawRect(0,-h,w,h);
			g.endFill();
			
			var gos:Array = cw.groundObjects;
			var len:int = gos.length;
			
			for(var i:int=0;i<len;i++)
			{
				var wo:WallObject = gos[i];
				var ww:Number = Base2D.sizeToScreen(wo.width);
				var wh:Number = Base2D.sizeToScreen(wo.height);
				var wx:Number = Base2D.sizeToScreen(wo.x-dx)-ww;
				var wy:Number = Base2D.sizeToScreen(wo.y==0&&wo.height==720?80:wo.y);
				//trace(i,wx,wy,ww,wh);18911273446
				g.drawRect(wx,-(wy+wh),ww,wh);
				
				trace(i+" wallObject:"+wo.object);
				if(wo.object is ProductObject)
				{
					var po:ProductObject = wo.object;
					var style:String = po.productInfo.style;
					trace(style);
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
				trace(i+" wallObject:"+wo.object);
				if(wo.object is ProductObject)
				{
					po = wo.object;
					oy = po.productInfo.alignOffset.y;
					style = po.productInfo.style;
					trace(style);
					
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
				
				ww = Base2D.sizeToScreen(wo.width);
				wh = Base2D.sizeToScreen(wo.height);
				wx = Base2D.sizeToScreen(wo.x-dx)-ww;
				wy = Base2D.sizeToScreen(wo.y-oy);
				//trace(i,wx,wy,ww,wh);
				
				g.drawRect(wx,-(wy+wh),ww,wh);
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
		
		private function clearLevelMarks():void
		{
			while(inLevelMarks.length>0)
			{
				var m:LevelMark2D = inLevelMarks.pop();
				this.removeChild(m);
				outLevelMarks.push(m);
			}
		}
		
		private function clearWallSockets():void
		{
			while(inWallSockets.length>0)
			{
				var s:WallSocket2D = inWallSockets.pop();
				this.removeChild(s);
				outWallSockets.push(s);
			}
		}
		
		private var inLevelMarks:Array = [];
		private var outLevelMarks:Array = [];
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
	}
}











