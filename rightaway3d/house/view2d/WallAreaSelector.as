package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import rightaway3d.engine.utils.Tips;
	import rightaway3d.house.editor2d.Scene2D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.ObstacleType;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallArea;
	import rightaway3d.house.vo.WallHole;
	import rightaway3d.house.vo.WallObject;
	import rightaway3d.utils.MyMath;

	public class WallAreaSelector extends Base2D
	{
		private var wallAreaSpt:Sprite;
		private var selectorSpt:Sprite;
		
		private var headSelector:Sprite;
		private var endSelector:Sprite;
		
		public function WallAreaSelector()
		{
			init();
		}
		
		private function init():void
		{
			wallAreaSpt = new Sprite();
			this.addChild(wallAreaSpt);
			
			selectorSpt = new Sprite();
			this.addChild(selectorSpt);
			
			headSelector = new Sprite();
			selectorSpt.addChild(headSelector);
			headSelector.addEventListener(MouseEvent.MOUSE_DOWN,onSelectorStartMove);
			
			endSelector = new Sprite();
			selectorSpt.addChild(endSelector);
			endSelector.addEventListener(MouseEvent.MOUSE_DOWN,onSelectorStartMove);
		}
		
		private var currSelector:Sprite;
		
		private var _isLock:Boolean = false;

		/**
		 * 是否锁定选择区域
		 */
		public function get isLock():Boolean
		{
			return _isLock;
		}

		/**
		 * @private
		 */
		public function set isLock(value:Boolean):void
		{
			_isLock = value;
			if(value)
			{
				headSelector.visible = false;
				endSelector.visible = false;
			}
		}

		
		protected function onSelectorStartMove(event:MouseEvent):void
		{
			if(isLock)return;
			
			currSelector = event.currentTarget as Sprite;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onSelectorMoving);
			stage.addEventListener(MouseEvent.MOUSE_UP,onSelectorEndMove);
			
			wall = currArea.wall;
			cw = wall.frontCrossWall;
			
			sceneHeightSize = Scene2D.sceneHeightSize;
			
			//length0 = currArea.length;
			var x0:Number = currSelector==headSelector?currArea.x0:currArea.x1 - sw;
			
			mdx = getLocalMouseX(wall) - x0;
			//trace("mdx:"+mdx);
		}
		
		private function getLocalMouseX(wall:Wall):Number
		{
			mousePoint.x = stage.mouseX;
			mousePoint.y =stage.mouseY;
			mousePoint = scene.globalToLocal(mousePoint);
			mousePoint.x = Base2D.screenToSize(mousePoint.x);
			mousePoint.y = sceneHeightSize - Base2D.screenToSize(mousePoint.y);
			
			wall.globalToLocal2(mousePoint,mousePoint);
			return mousePoint.x;
		}
		
		public var scene:Scene2D;
		
		private var sceneHeightSize:int;
		
		private var mousePoint:Point = new Point();
		
		private var footPoint:Point = new Point();
		
		private var wall:Wall;
		private var cw:CrossWall;
		
		//private var x0:Number;
		private var mdx:Number;//鼠标相对于滑块起始位置x轴偏移量
		//private var length0:Number;
		
		private var sw:int = 150;//滑块的宽度
		
		protected function onSelectorMoving(event:MouseEvent):void
		{
			mousePoint.x = stage.mouseX;
			mousePoint.y =stage.mouseY;
			
			mousePoint = scene.globalToLocal(mousePoint);
			
			mousePoint.x = Base2D.screenToSize(mousePoint.x);
			mousePoint.y = sceneHeightSize - Base2D.screenToSize(mousePoint.y);
			
			wall.distToPoint(mousePoint,footPoint);//计算当前点到墙体的垂足坐标
			
			//trace("dist:"+dist,footPoint);
			wall.globalToLocal2(footPoint,footPoint);
			
			footPoint.x -= mdx;
			
			if(currSelector==headSelector)
			{
				//trace("selector1");
				if(currArea.x1 - footPoint.x < WallArea.MinLength)
				{
					footPoint.x = currArea.x1 - WallArea.MinLength;
				}
				if(footPoint.x<currArea.minX || footPoint.x-currArea.minX<WallArea.MinDist)
				{
					footPoint.x = currArea.minX;
				}
				
				var wo:WallObject = cw.getGroundObject(footPoint.x);//滑块位置是否有障碍物
				if(wo)//检测目标位置有障碍物
				{
					if(footPoint.x>wo.x-wo.width*0.5)//滑块位置在障碍物中心点之后
					{
						footPoint.x = wo.x;//滑块避开障碍物
					}
					else
					{
						footPoint.x = wo.x - wo.width;
					}
				}
				//var dx:Number = footPoint.x - x0;
				currArea.x0 = footPoint.x;
				//currArea.length = length0 - dx;
			}
			else
			{
				if(footPoint.x+sw-currArea.x0<WallArea.MinLength)
				{
					footPoint.x = currArea.x0 + (WallArea.MinLength-sw);
				}
				if(footPoint.x+sw>currArea.maxX || currArea.maxX-(footPoint.x+sw)<WallArea.MinDist)
				{
					footPoint.x = currArea.maxX-sw;
				}
				
				wo = cw.getGroundObject(footPoint.x+sw);
				if(wo)//检测目标位置有障碍物
				{
					if(footPoint.x+sw>wo.x-wo.width*0.5)
					{
						footPoint.x = wo.x - sw;
					}
					else
					{
						footPoint.x = wo.x - wo.width - sw;
					}
				}
				//dx = footPoint.x + sw - (currArea.x + length0);
				currArea.x1 = footPoint.x + sw;
			}
			
			wall.localToGlobal2(footPoint,footPoint);
			
			mousePoint.x = Base2D.sizeToScreen(footPoint.x);
			mousePoint.y = Base2D.sizeToScreen(sceneHeightSize - footPoint.y);
			
			currSelector.x = mousePoint.x;
			currSelector.y = mousePoint.y;
			
			currAreaView.updateView();
			
			currArea.wall.dispatchSizeChangeEvent();
			
			//footPoint.x -= currWindoor.vo.width * 0.5;
			//currWindoor.vo.x = footPoint.x;
			//footPoint.x = currWindoor.vo.objectInfo.x - currWindoor.vo.width;
			//currWindoor.vo.x = footPoint.x;
			
			//wall.localToGlobal2(footPoint,footPoint);
			
			//trace("footPoint1:"+mousePoint);
			
			//mousePoint = scene.localToGlobal(mousePoint);
			//trace("footPoint2:"+mousePoint);
		}
		
		protected function onSelectorEndMove(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,onSelectorMoving);
			stage.removeEventListener(MouseEvent.MOUSE_UP,onSelectorEndMove);
		}
		
		public function clearWallArea():void
		{
			for each(var a:Array in wallDict)
			{
				for each(var wa:WallArea2D in a)
				{
					disposeWallArea(wa);
				}
				a.length = 0;
			}
			
			for(var w:Wall in wallDict)
			{
				w.selectorArea = null;
				delete wallDict[w];
			}
			
			headSelector.visible = false;
			endSelector.visible = false;
			
			currAreaView = null;
		}
		
		public function clearCabinetFlag():void
		{
			for each(var a:Array in wallDict)
			{
				for each(var wa:WallArea2D in a)
				{
					wa.vo.clearCabinetFlag();
				}
			}
		}
		
		public function hasWallArea():Boolean
		{
			for each(var a:Array in wallDict)
			{
				//trace("a:"+a);
				for each(var wa:WallArea2D in a)
				{
					//trace("wa:"+wa);
					if(wa.vo.enable)return true;
				}
			}
			return false;
		}
		
		private var wallDict:Dictionary = new Dictionary();
		
		public function createWallArea(wall:Wall):void
		{
			var areas:Array;
			if(wallDict[wall])
			{
				var n:Number = getLocalMouseX(wall);
				areas = wallDict[wall];
				for each(var wa:WallArea2D in areas)
				{
					var vo:WallArea = wa.vo;
					if(n>vo.x0 && n<vo.x1)
					{
						wa.visible = true;
						
						if(vo.x1-vo.x0>=WallArea.MinLength)
						{
							vo.enable = true;
							wa.updateView();
							wa.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
						}

						break;
					}
				}
			}
			else if(getSelectWallNum()<3)
			{
				areas = [];
				wallDict[wall] = areas;
				_createWallArea(wall,areas);
				wall.selectorArea = areas;
			}
			
			wall.dispatchSizeChangeEvent();
		}
		
		public function getSelectWallNum():int
		{
			var n:int = 0;
			for each(var w:* in wallDict)
			{
				n++;
			}
			return n;
		}
		
		private function _createWallArea(wall:Wall,areas:Array):void
		{
			var headEnable:Boolean = true;
			var endEnable:Boolean = true;
			
			var wa0:WallArea;
			var wa1:WallArea;
			
			var w1:Wall = wall.frontCrossWall.headCrossWall.wall;
			if(w1.selectorArea)//计算与当前墙体首端相连的墙体是否存在选择区域
			{
				var a:Array = w1.selectorArea;
				var wa2d:WallArea2D = a[a.length-1];
				wa0 = wa2d.vo;
				if(wa0.enable)
				{
					wa0.x1 = w1.groundFrontEnd.x;
					wa0.endEnable = false;
					wa0.endType1 = null;
					
					wa2d.updateView();
					headEnable = false;
					w1.dispatchSizeChangeEvent();
				}
			}
			
			var w2:Wall = wall.frontCrossWall.endCrossWall.wall;
			if(w2.selectorArea)//计算与当前墙体尾端相连的墙体是否存在选择区域
			{
				a = w2.selectorArea;
				wa2d = a[0];
				wa1 = wa2d.vo;
				if(wa1.enable)
				{
					var tx:Number = wa1.x0;
					wa1.x0 = w2.groundFrontHead.x;
					wa1.headEnable = false;
					wa1.headType1 = null;
					
					wa2d.updateView();
					endEnable = false;
					w2.dispatchSizeChangeEvent();
				}
			}
			
			var x0:Number = wall.groundFrontHead.x;
			var x1:Number = wall.groundFrontEnd.x;
			
			var doors:Array = wall.getDoorsOfWall();
			var len:int = doors.length;
			if(len==0)
			{
				var wallArea2d:WallArea2D = __createWallArea(wall,x0,x1,areas,headEnable,endEnable,w1,w2);
			}
			else
			{
				var hole:WallHole = doors[0];
				var tx0:Number = x0;
				var tx1:Number = hole.x;
				__createWallArea(wall,tx0,tx1,areas,headEnable,true,w1,null);
				
				for(var i:int=1;i<len;i++)
				{
					tx0 = hole.x + hole.width;
					hole = doors[i];
					tx1 = hole.x;
					__createWallArea(wall,tx0,tx1,areas,true,true,null,null);
				}
				
				tx0 = hole.x + hole.width;
				tx1 = x1;
				wallArea2d = __createWallArea(wall,tx0,tx1,areas,true,endEnable,null,w2);
			}
			
			if(wallArea2d.vo.enable)wallArea2d.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		//计算墙体某区域内是否有门存在
		private function getDoor(wall:Wall,x0:Number,x1:Number):WallHole
		{
			//trace("getDoor:",x0,x1);
			var doors:Array = wall.getDoorsOfWall();
			var len:int = doors.length;
			for(var i:int=0;i<len;i++)
			{
				var wh:WallHole = doors[i];
				//trace("hole:"+wh.x,wh.width);
				if((MyMath.isGreaterEqual(wh.x,x0) && MyMath.isLess(wh.x,x1))
					|| (MyMath.isGreater(wh.x+wh.width,x0) && MyMath.isLessEqual(wh.x+wh.width,x1)))//有重叠就存在
				{
					return wh;
				}
			}
			return null;
		}
		
		private function __createWallArea(wall:Wall,x0:Number,x1:Number,areas:Array,headEnable:Boolean,endEnable:Boolean,headWall:Wall,endWall:Wall):WallArea2D
		{
			var wa:WallArea = new WallArea();
			wa.wall = wall;
			
			var tableWidth:int = 600;//台面宽度
			var doorTableDist:int = 100;//台面挡门时，台面避让门的距离为门洞宽度加上此距离
			
			if(headWall)//区域头部连着另一面墙
			{
				var tx:Number = headWall.groundFrontEnd.x;
				var hole:WallHole = getDoor(headWall,tx-tableWidth,tx);//检测此墙指定范围内是否有门
				//trace("----headWallHole:"+hole);
				if(hole)//如果有门，厨柜要避让此门
				{
					if(hole.modelType>0)//门洞里要有门，才要避让
					{
						var tx0:Number = x0 + hole.width + doorTableDist;
						if(tx0>=x1)//选择区域范围不够避让门，则此区域不可用
						{
							wa.enable = false;
						}
						else
						{
							x0 = tx0
						}
					}
					
					headEnable = true;
					
					wa.headCorner = false;
					wa.headType0 = wa.headType1 = ObstacleType.NULL;
				}
				else if(headEnable)//区域头部连墙
				{
					wa.headCorner = false;
					wa.headType0 = wa.headType1 = ObstacleType.WALL;
				}
				else//有相关连区域，没有门
				{
					wa.headType0 = ObstacleType.WALL;
					wa.headType1 = null;
				}
			}
			else//区域头部连着门洞
			{
				wa.headCorner = false;
				wa.headType0 = wa.headType1 = ObstacleType.HOLE;
			}
			
			if(endWall)//区域尾部连着另一面墙
			{
				tx = endWall.groundFrontHead.x;
				hole = getDoor(endWall,tx,tx+tableWidth);
				//trace("----endWallHole:"+hole);
				if(hole)//厨柜避让门
				{
					if(hole.modelType>0)
					{
						var tx1:Number = x1 - hole.width - doorTableDist;
						if(x0>=tx1)//选择区域范围不够避让门，则此区域不可用
						{
							wa.enable = false;
						}
						else
						{
							x1 = tx1;
						}
					}

					endEnable = true;
					
					wa.endCorner = false;
					wa.endType0 = wa.endType1 = ObstacleType.NULL;
				}
				else if(endEnable)//区域尾部连墙
				{
					wa.endCorner = false;
					wa.endType0 = wa.endType1 = ObstacleType.WALL;
				}
				else//有相关连区域，没有门
				{
					wa.endType0 = ObstacleType.WALL;
					wa.endType1 = null;
				}
			}
			else//区域尾部连着门洞
			{
				wa.endCorner = false;
				wa.endType0 = wa.endType1 = ObstacleType.HOLE;
			}

			wa.x0 = x0;
			wa.x1 = x1;
			
			wa.minX = x0;
			wa.maxX = x1;
			
			wa.headEnable = headEnable;
			wa.endEnable = endEnable;
			
			var wa2d:WallArea2D = new WallArea2D();
			wa2d.addEventListener(MouseEvent.CLICK,onWallAreaSelected);
			wa2d.addEventListener(MouseEvent.DOUBLE_CLICK,onRemoveSelectArea);
			
			wa2d.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			wa2d.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			
			wa2d.doubleClickEnabled = true;
			wa2d.vo = wa;
			
			if(x1-x0<WallArea.MinLength)
			{
				wa.enable = false;
				wa2d.lineColor = wa2d.fillColor = 0x808080;
				wa2d.fillAlpha = 0.1;
			}
			wa2d.updateView();
			
			wallAreaSpt.addChild(wa2d);
			areas.push(wa2d);
			
			return wa2d;
		}
		
		private var tipsID:int = -1;
		private var isOverWall:Boolean = false;
		
		private function onRollOver(event:MouseEvent):void
		{
			if(isLock)return;
			
			isOverWall = true;
			flash.utils.setTimeout(showTips,100);
		}
		
		private function showTips():void
		{
			if(isOverWall)tipsID = Tips.show("双击取消厨柜范围",scene.stage.mouseX,scene.stage.mouseY);
		}
		
		private function onRollOut(event:MouseEvent):void
		{
			isOverWall = false;
			
			if(isLock)return;
			
			if(tipsID>-1)
			{
				Tips.hide(tipsID);
				tipsID = -1;
			}
		}
		
		//删除选择区域
		private function onRemoveSelectArea(event:MouseEvent):void
		{
			if(isLock)return;
			
			var wa:WallArea2D = event.currentTarget as WallArea2D;
			var vo:WallArea = wa.vo;
			var wall:Wall = vo.wall;
			var a:Array = wall.selectorArea;
			var len:int = a.length;
			if(len==1)//当前墙体只有一个选择区域，直接去掉
			{
				enableWallSelect(wall);
				delete wallDict[wall];
				wall.selectorArea = null;
				disposeWallArea(wa);
			}
			else
			{
				vo.enable = false;
				if(hasEnableArea(a))//如果当前墙上还有其它区域为可用状态，将当前区域范围隐藏
				{
					wa.visible = false;
					vo.x0 = vo.minX;
					vo.x1 = vo.maxX;
				}
				else//当前墙上所有区域不可用时，则全部销毁
				{
					enableWallSelect(wall);
					delete wallDict[wall];
					wall.selectorArea = null;
					for each(wa in a)
					{
						disposeWallArea(wa);
					}
				}
			}
			
			headSelector.visible = false;
			endSelector.visible = false;
			currAreaView = null;
			
			wall.dispatchSizeChangeEvent();
		}
		
		private function enableWallSelect(wall:Wall):void
		{
			var w1:Wall = wall.frontCrossWall.headCrossWall.wall;
			if(w1.selectorArea)
			{
				var a:Array = w1.selectorArea;
				var wa2d:WallArea2D = a[a.length-1];
				var vo:WallArea = wa2d.vo;
				vo.endEnable = true;
				vo.endType1 = vo.endType0;
			}
			
			var w2:Wall = wall.frontCrossWall.endCrossWall.wall;
			if(w2.selectorArea)
			{
				a = w2.selectorArea;
				wa2d = a[0];
				vo = wa2d.vo;
				vo.headEnable = true;
				vo.headType1 = vo.headType0;
			}
		}
		
		private function hasEnableArea(areas:Array):Boolean
		{
			for each(var w:WallArea2D in areas)
			{
				if(w.vo.enable)return true;
			}
			return false;
		}
		
		private var currAreaView:WallArea2D;
		private var currArea:WallArea;
		
		private function onWallAreaSelected(event:MouseEvent):void
		{
			if(isLock)return;
			
			//trace("onWallAreaSelected");
			var wa:WallArea2D = event.currentTarget as WallArea2D;
			
			if(!wa.vo.enable)return;
			
			if(wa==currAreaView)return;
			
			if(currAreaView)
			{
				currAreaView.selected = false;
			}
			
			wa.selected = true;
			currAreaView = wa;
			currArea = wa.vo;
			
			updateSelector(wa);
		}
		
		private function updateSelector(wa:WallArea2D):void
		{
			var vo:WallArea = wa.vo;
			var wall:Wall = vo.wall;
			
			headSelector.visible = vo.headEnable;
			endSelector.visible = vo.endEnable;
			
			if(vo.headEnable)drawSelector(headSelector,wall,vo.x0);
			if(vo.endEnable)drawSelector(endSelector,wall,vo.x1-sw);
		}
			
		private function drawSelector(s:Sprite,wall:Wall,xPos:Number):void
		{
			var p:Point = new Point(xPos,0);
			wall.localToGlobal2(p,p);
			
			var x1:Number = Base2D.sizeToScreen(p.x);//将场景坐标值转换为屏幕坐标值
			var y1:Number = Base2D.sizeToScreen(Scene2D.sceneWidthSize - p.y);
			s.x = x1;
			s.y = y1;
			
			var a:Number = 360 - wall.angles;
			s.rotation = a;//屏幕坐标系下的墙体角度
			
			var w:Number = Base2D.sizeToScreen(sw);
			var h:Number = Base2D.sizeToScreen(wall.width) * 0.5;
			
			var g:Graphics = s.graphics;
			g.clear();
			g.lineStyle(0,0,0.2);
			g.beginFill(0,0);
			g.drawRect(0,-h,w,h*2);
			g.endFill();
			
			var w2:Number = w * 0.3;
			var h2:Number = h * 0.5;
			g.lineStyle(0,WallArea2D.LineColor);
			g.moveTo(w2,-h2);
			g.lineTo(w2,h2);
			g.moveTo(w2*2,-h2);
			g.lineTo(w2*2,h2);
		}
		
		private function disposeWallArea(wa:WallArea2D):void
		{
			wa.removeEventListener(MouseEvent.CLICK,onWallAreaSelected);
			wa.removeEventListener(MouseEvent.DOUBLE_CLICK,onRemoveSelectArea);
			wa.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
			wa.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
			wa.dispose();
			
			wallAreaSpt.removeChild(wa);
		}
	}
}


















