package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFormatAlign;
	
	import rightaway3d.engine.core.ModelAlign;
	import rightaway3d.engine.product.ProductInfo;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.cabinet.CabinetType;
	import rightaway3d.house.editor2d.CabinetCreator;
	import rightaway3d.house.editor2d.TableBuilder;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.WallObject;
	import rightaway3d.house.vo.WallSubArea;
	import rightaway3d.utils.BrokenLineDrawer;
	import rightaway3d.utils.MyTextField;
	
	import ztc.meshbuilder.room.MaterialLibrary;

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
		
		private var matIndex:int = 0;
		private var matObject:Object = {};
		private var currFaceMats:Object;
		
		public function resetMatData():void
		{
			matIndex = 0;
			matObject = {};
		}
		
		private function getMatFlag(mat:String):String
		{
			var s:String;
			if(matObject[mat]==undefined)
			{
				trace("getMatFlag:",mat,matIndex);
				
				matObject[mat] = matIndex++;
			}
			
			var n:String = matObject[mat];
			if(currFaceMats[n]==undefined)
			{
				currFaceMats[n] = mat;
			}
			
			return "C" + n;
		}
		
		private var matTips:Sprite;
		private function drawMatTips():void
		{
			matTips.removeChildren();
			
			this.setText2("材质说明",matTips,0,0);
			
			var lib:MaterialLibrary = MaterialLibrary.instance;
			
			var i:int = 1;
			for(var s:String in currFaceMats)
			{
				var matName:String = currFaceMats[s];
				
				var materialDscp:String = lib.getMaterialAttribute(matName,"materialDscp");
				if(materialDscp)materialDscp = "(" + materialDscp + ")";
				
				this.setText2("C"+s+":"+matName+materialDscp,matTips,0,i++ * 10);
			}
		}
		
		//绘制台面及踢脚线
		private function drawTable(cw:CrossWall,g:Graphics):void
		{
			var cabCreator:CabinetCreator = CabinetCreator.getInstance();
			var tabless:Array = cabCreator.cabinetTabless;
			var depthss:Array = cabCreator.tableDepthss;
			
			if(!tabless || !depthss)return;
			
			var tb:TableBuilder = TableBuilder.own;
			var isCabinetHead:Boolean,isCabinetEnd:Boolean;//定义厨柜分区的头部标志，尾部标志
			var ty:Number = -Base2D.sizeToScreen(840);
			var th:Number = Base2D.sizeToScreen(40);
			var th2:Number = Base2D.sizeToScreen(80);
			
			var len:int = tabless.length;
			for(var i:int=0;i<len;i++)
			{
				var tables:Array = tabless[i];//每个独立台面分区
				var depths:Array = depthss[i];
				
				var tlen:int = tables.length;
				for(var j:int=0;j<tlen;j++)
				{
					var sa:WallSubArea = tables[j];
					if(cw==sa.cw)
					{
						isCabinetHead = j==0?true:false;
						isCabinetEnd = j==tlen-1?true:false;
						
						var x0:Number = sa.x0;
						var x1:Number = sa.x1;
						
						if(sa.headCabinet)x0+=sa.headCabinet.objectInfo.width;
						if(sa.endCabinet)x1-=sa.endCabinet.objectInfo.width;
						
						var tx:Number = Base2D.sizeToScreen(x0-cw.localHead.x);
						var tw:Number = Base2D.sizeToScreen(x1-x0);
						
						g.drawRect(tx,ty,tw,th);//绘制台面
						
						/*计算踢脚线数据*/
						var cabinets:Array = sa.groundObjects;
						var p10:ProductObject = cabinets[0];
						var p11:ProductObject = cabinets[cabinets.length-1];
						
						var w10:WallObject = p10.objectInfo;
						var w11:WallObject = p11.objectInfo;
						
						if(isCabinetHead)
						{
							var isHeadPlate:Boolean = tb.isNeedHeadPlate(cw,w10);//柜子左侧是否需要封板
							var tx0:Number = isHeadPlate ? w10.x - w10.width + 30 : cw.localHead.x;
							tx0 -= cw.localHead.x;
						}
						else
						{
							var tsa:WallSubArea = tables[j-1];
							var w00:WallObject = tsa.groundObjects[0].objectInfo;
							tx0 = tb.getGroundPlateDepth(w00);
						}
						
						if(isCabinetEnd)
						{
							var isEndPlate:Boolean = tb.isNeedEndPlate(cw,w11);
							var tx1:Number = isEndPlate ? w11.x - 30 : cw.localEnd.x;
							tx1 -= cw.localHead.x;
						}
						else
						{
							tsa = tables[j+1];
							w00 = tsa.groundObjects[0].objectInfo;
							tx1 = cw.localEnd.x - tb.getGroundPlateDepth(w00);
						}
						
						tx = Base2D.sizeToScreen(tx0);
						tw = Base2D.sizeToScreen(tx1-tx0);
						
						g.drawRect(tx,-th2,tw,th2);//绘制踢脚线
					}
				}
			}
		}
		
		public function updateView(cw:CrossWall):void
		{
			currFaceMats = {};
			
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
			
			drawTable(cw,g);
			
			if(!matTips)
			{
				matTips = new Sprite();
				this.addChild(matTips);
			}
			matTips.x = w + 40;
			matTips.y = -h;
			
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
					var ty:Number = 500;
					var my:Number = ty - 50;
					
					switch(style)
					{
						case CabinetType.DRAINER_CABINET:
							var tx2:Number = wox-wo.width+50;
							gs.push(tx2);
							
							var tx:Number = wox-wo.width*0.5;
							gs.push(tx);
							
							//var n:int = 500;
							setWallSocket(tx2+50,my);
							setWallSocket(tx2+160,my);
							//setLevelMark(ty,"right",tx+250,ty);
							/*if(tx>cw.validLength*0.5)
							{
							setLevelMark(ty,"right",cw.validLength+80,ty);
							}
							else
							{
							setLevelMark(ty,"left",-80,ty);
							}*/
							setLevelMark(ty,"right",cw.validLength+80,ty,0,"-插座");//ty);
							
							//n = 500;
							drawWaterPipe(g,tx-75,-ty);
							drawWaterPipe(g,tx+75,-ty);
							setLevelMark(ty,"left",-80,ty,0,"-冷热水");
							
							g.drawRect(Base2D.sizeToScreen(tx-30),
								Base2D.sizeToScreen(-280),
								Base2D.sizeToScreen(60),
								Base2D.sizeToScreen(200)
							);
							
							break;
						case CabinetType.ELECTRIC_HEIGHT:
						case CabinetType.ELECTRIC_MIDDLE://电器高柜中高柜下方增加插座
							tx = wox-wo.width*0.5;
							gs.push(tx);
							
							setWallSocket(tx-55,my);
							setWallSocket(tx+55,my);
							setLevelMark(ty,"right",cw.validLength+80,ty,0,"-插座");
							
							break;
						case CabinetType.ELECTRIC_GROUND:
							if(i<len-1)
							{
								tx = wox + 50;
								gs.push(tx);
								
								setWallSocket(tx+50,my);
								setWallSocket(tx+160,my);
								
								//setLevelMark(ty,"right",tx+350,ty);
								//setLevelMark(ty,"right",cw.validLength+80,ty);
							}
							else
							{
								tx = wox - wo.width - 50;
								gs.push(tx);
								
								setWallSocket(tx-50,my);
								setWallSocket(tx-160,my);
								//setLevelMark(ty,"left",tx-350,ty);
								//setLevelMark(ty,"left",-80,ty);
							}
							setLevelMark(ty,"right",cw.validLength+80,ty,0,"-插座");
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
							
							ty = 2250;//wo.y+wo.height-oy+100;
							setWallSocket(tx-55,ty-50);
							setWallSocket(tx+55,ty-50);
							setLevelMark(ty,"right",cw.validLength+80,ty,0,"-插座");
							break;
					}
				}
			}
			
			updateSizeMark(gs,groundMark,x1);
			groundMark.y = -43;
			
			updateSizeMark(ws,hoodMark,x1);
			hoodMark.y = -125;//-56;
			
			drawMatTips();
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
			var tx:Number = dx + 400 + 50;
			var ty:Number = 1100;
			setWallSocket(tx,ty);
			setWallSocket(tx+110,ty);
			setWallSocket(tx+220,ty);
			//setLevelMark(ty,"left",tx-200,ty);
			//setLevelMark(ty,"left",-80,ty);
			setLevelMark(ty,"right",cw.validLength+80,ty+50,0,"-插座");
			
			return tx - 50;
		}
		
		public function drawEndSocket(cw:CrossWall,dx:int):Number
		{
			var tx:Number = cw.localEnd.x - cw.localHead.x - dx - 400 - 50;
			var ty:Number = 1100;
			//setLevelMark(ty,"right",tx+100,ty);
			setLevelMark(ty,"right",cw.validLength+80,ty+50,0,"-插座");
			
			//ty -= 50;
			setWallSocket(tx,ty);
			setWallSocket(tx-110,ty);
			setWallSocket(tx-220,ty);
			
			return tx + 50;
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
		
		private function setLevelMark(level:int,direct:String,xPos:int,yPos:int,offSetSize:int=0,memo:String=""):void
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
			
			levelMark.updateView(level,direct,xPos,yPos,offSetSize,memo);
			
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
				var m:Sprite = inCabinetShapes.pop();
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
				var s:Sprite = new Sprite();
				s.mouseChildren = s.mouseEnabled = false;
			}
			inCabinetShapes.push(s);
			
			this.addChild(s);
			
			updateCabinetShape(s,wo,x0,wallHeight);
		}
		
		private var p0:Point = new Point();
		private var p1:Point = new Point();
		
		private function updateCabinetShape(s:Sprite,wo:WallObject,x0:Number,wallHeight:Number):void
		{
			//var lineColor:uint =0xffffff;
			
			s.removeChildren();
			
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
								//trace("----customMaterialName:"+doorPlank.customMaterialName);
								//g.lineStyle(0,0xff0000);
								g.drawRect(x,y,tw,th);
								var n1:Number = 1;
								var n2:Number = 4;
								
								if(file.indexOf("left")>-1)//左开门
								{
									/*g.moveTo(x+tw,y);
									g.lineTo(x,y+th*0.5);
									g.lineTo(x+tw,y+th);*/
									
									p1.x = x+tw;
									p1.y = y;
									p0.x = x;
									p0.y = y+th*0.5;
									BrokenLineDrawer.draw2(g,p1,p0,n1,n2);
									
									p1.x = x+tw;
									p1.y = y+th;
									BrokenLineDrawer.draw2(g,p0,p1,n1,n2);
								}
								else if(file.indexOf("right")>-1)//右开门
								{
									/*g.moveTo(x,y);
									g.lineTo(x+tw,y+th*0.5);
									g.lineTo(x,y+th);*/
									
									p1.x = x;
									p1.y = y;
									p0.x = x+tw;
									p0.y = y+th*0.5;
									BrokenLineDrawer.draw2(g,p1,p0,n1,n2);
									
									p1.x = x;
									p1.y = y+th;
									BrokenLineDrawer.draw2(g,p0,p1,n1,n2);
								}
								else if(file.indexOf("upturn")>-1)//上翻门
								{
									p1.x = x+tw;
									p1.y = y+th;
									p0.x = x+tw*0.5;
									p0.y = y;
									BrokenLineDrawer.draw2(g,p1,p0,n1,n2);
									
									p1.x = x;
									p1.y = y+th;
									BrokenLineDrawer.draw2(g,p0,p1,n1,n2);
								}
								else if(file.indexOf("basket")>-1)//拉篮
								{
									setText1("拉篮",s,x+tw*0.5,y+th);
								}
								else if(file.indexOf("drawer")>-1)//抽屉
								{
									setText1("抽屉",s,x+tw*0.5,y+th);
								}
								
								setText1(getMatFlag(doorPlank.customMaterialName),s,x+tw*0.5,y+10,true);
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
		
		private function setText1(str:String,parent:Sprite,cx:Number,cy:Number,force:Boolean=false):void
		{
			//trace("----------cy:",cy);
			if(cy<-1 && !force)return;//控制每个柜子里只显示一个名称
			
			var txt:MyTextField = setText(str,parent);
			txt.x = cx - txt.width * 0.5;
			txt.y = cy - txt.height;
		}
		
		private function setText2(str:String,parent:Sprite,tx:Number,ty:Number):void
		{
			var txt:MyTextField = setText(str,parent);
			txt.x = tx;
			txt.y = ty;
		}
		
		private function setText(str:String,parent:Sprite):MyTextField
		{
			var txt:MyTextField = new MyTextField();
			txt.align = TextFormatAlign.CENTER;
			txt.textSize = 6;
			txt.textColor = 0x0;
			txt.text = str;
			
			var tmp:Number = txt.textWidth;
			tmp = txt.textHeight;
			tmp = txt.width;
			tmp = txt.height;
			
			txt.width = txt.textWidth + 5;
			txt.height = txt.textHeight + 4;
			
			parent.addChild(txt);
			
			return txt;
		}
	}
}











