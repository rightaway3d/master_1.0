package rightaway3d.house.editor2d
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import rightaway3d.engine.utils.GlobalEvent;
	import rightaway3d.house.view2d.Base2D;
	import rightaway3d.house.view2d.Wall2D;
	import rightaway3d.house.view2d.WinDoor2D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallHole;
	import rightaway3d.house.vo.WallObject;
	
	public class WindoorController
	{
		public var scene:Scene2D;
		
		//=========================================================================================================================
		public var currWindoor:WinDoor2D;
		
		private var stage:Stage;
		
		private var isMoved:Boolean = false;
		
		public function createWindoor(type:int,width:int,height:int,sillHeight:int,thickness:int=80):void
		{
			//trace("createWindoor");
			stage = scene.stage;
			stage.addEventListener(MouseEvent.MOUSE_MOVE,movingWindoor);
			stage.addEventListener(MouseEvent.CLICK,endMoveWindoor);
			mdx = width * 0.5;
			
			var windoor:WinDoor2D = _createWindoor(type,width,height,sillHeight,thickness);
			setCurrWindoor(windoor);
			
			//initWindoor();
			initWindoor2();
		}
		
		public function createWindoor2(hole:WallHole,wall2d:Wall2D):void
		{
			var windoor:WinDoor2D = createWindoor2d(hole);
			
			windoor.x = Base2D.sizeToScreen(hole.x);
			windoor.y = 0;
			
			wall2d.addWindoor(windoor);
			
			windoor.updateView();
		}
		
		private function initWindoor2():void
		{
			//rooms = scene.currFloor.rooms;
			
			sceneHeightSize = Scene2D.sceneHeightSize;
			
			/*initWindoor();
		}
		
		private function initWindoor():void
		{*/
			isMoved = false;
			this.scene.enable = false;
			currWindoor.enable = false;
			
			if(!currWindoor.stage)
			{
				stage.addChild(currWindoor);
				
				var mouseX0:Number = stage.mouseX;
				var mouseY0:Number = stage.mouseY;
				
				currWindoor.scaleX = scene.scaleX;
				currWindoor.scaleY = scene.scaleY;			
				
				currWindoor.updateView();
				currWindoor.x = mouseX0 - currWindoor.width*0.5;
				currWindoor.y = mouseY0;
			}
		}
		
		//private var rooms:Vector.<Room2D>;
		
		private var footPoint:Point = new Point();
		
		//private var currCrossWall:CrossWall;
		
		private var sceneHeightSize:int;
		
		private function movingWindoor(e:MouseEvent=null):void
		{
			if(e)isMoved = true;
			
			var mouseX0:Number = stage.mouseX;
			var mouseY0:Number = stage.mouseY;
			
			if(!currHitWall)currHitWall = hitWallsTest();//如果没有碰撞到的墙体，进行检测当前是否有碰撞到的墙体
			
			if(currHitWall)
			{
				var wall:Wall = currHitWall.vo;
				var windoor:WallHole = currWindoor.vo;
				if(!windoor.wall)
				{
					stage.removeChild(currWindoor);
					
					currWindoor.y = 0;
					currHitWall.addWindoor(currWindoor);
					wall.addHole(windoor);
					
					currWindoor.updateView();
					scene.render();
				}
				
				mousePoint.x = mouseX0;
				mousePoint.y = mouseY0;
				
				mousePoint = scene.globalToLocal(mousePoint);
				
				mousePoint.x = Base2D.screenToSize(mousePoint.x);
				mousePoint.y = sceneHeightSize - Base2D.screenToSize(mousePoint.y);
				
				var dist:Number = wall.distToPoint(mousePoint,footPoint);//计算当前点到墙体的垂直距离，及当前垂足坐标
				if(dist<600)
				{
					wall.globalToLocal2(footPoint,footPoint);
					footPoint.x -= mdx;
					windoor.x = footPoint.x;
					
					wall.removeHole(windoor);
					var result:Boolean = wall.frontCrossWall.testAddObject(windoor.objectInfo);//检测墙体正面是否可以放置门窗
					wall.addHole(windoor);
					
					if(result)
					{
						footPoint.x = windoor.objectInfo.x - windoor.width;
						windoor.x = footPoint.x;
						
						//mousePoint = currHitWall.globalToLocal(footPoint);
						mousePoint.x = Base2D.sizeToScreen(footPoint.x);
						currWindoor.x = mousePoint.x;
						
						scene.render();
					}
					else
					{
						noHitWall();
					}
				}
				else
				{
					noHitWall();
				}
			}
			
			if(!currHitWall)
			{
				if(!currWindoor.stage)
				{
					currWindoor.scaleX = scene.scaleX;
					currWindoor.scaleY = scene.scaleY;			
					
					stage.addChild(currWindoor);
					
					currWindoor.updateView();
					currWindoor.x = mouseX0 - currWindoor.width*0.5;
					currWindoor.y = mouseY0;
					
					scene.render();
				}
				
				currWindoor.x = mouseX0 - currWindoor.width*0.5;
				currWindoor.y = mouseY0;
			}
		}
		
		/*private function movingWindoor2(e:MouseEvent=null):void
		{
			if(e)isMoved = true;
			
			var mouseX0:Number = stage.mouseX;
			var mouseY0:Number = stage.mouseY;
			
			if(!currHitWall)currHitWall = hitWallsTest();//如果没有碰撞到的墙体，进行检测当前是否有碰撞到的墙体
			
			if(currHitWall)
			{
				var wall:Wall = currHitWall.vo;
				
				if(!currWindoor.vo.wall)
				{
					currWindoor.rotation = currHitWall.rotation;
					currWindoor.vo.wall = wall;
					wall.frontCrossWall.initTestObject();
					
					currWindoor.updateView();
				}
				
				mousePoint.x = mouseX0;
				mousePoint.y = mouseY0;
				
				mousePoint = scene.globalToLocal(mousePoint);
				
				mousePoint.x = Base2D.screenToSize(mousePoint.x);
				mousePoint.y = sceneHeightSize - Base2D.screenToSize(mousePoint.y);
				
				var dist:Number = wall.distToPoint(mousePoint,footPoint);//计算当前点到墙体的垂直距离，及当前垂足坐标
				if(dist<600)
				{
					wall.globalToLocal2(footPoint,footPoint);
					//footPoint.x -= currWindoor.vo.width * 0.5;
					footPoint.x -= mdx;
					currWindoor.vo.x = footPoint.x;
					
					var result:Boolean = wall.frontCrossWall.testAddObject(currWindoor.vo.objectInfo);//检测墙体正面是否可以放置门窗
					//if(result)result = wall.backCrossWall.testAddObject(currWindoor.vo.objectInfo2);//检测墙体背面是否可以放置门窗
					if(result)
					{
						footPoint.x = currWindoor.vo.objectInfo.x - currWindoor.vo.width;
						currWindoor.vo.x = footPoint.x;
						
						wall.localToGlobal2(footPoint,footPoint);
						
						mousePoint.x = Base2D.sizeToScreen(footPoint.x);
						mousePoint.y = Base2D.sizeToScreen(sceneHeightSize - footPoint.y);
						
						mousePoint = scene.localToGlobal(mousePoint);
						
						currWindoor.x = mousePoint.x;
						currWindoor.y = mousePoint.y;
					}
					else
					{
						noHitWall();
					}
				}
				else
				{
					noHitWall();
				}
			}
			
			if(!currHitWall)
			{
				currWindoor.x = mouseX0 - currWindoor.width*0.5;
				currWindoor.y = mouseY0;
			}
		}*/
		
		public function setWindoor(hole:WallHole,width:uint,height:uint,xPos:uint):Boolean
		{
			if(hole.y + height >= hole.wall.floor.ceilingHeight)return false;
			
			var wo:WallObject = new WallObject();
			wo.x = hole.wall.groundFrontHead.x + xPos + width;
			wo.y = hole.objectInfo.y;
			wo.z = hole.objectInfo.z;
			wo.width = width;
			wo.depth = hole.objectInfo.depth;
			wo.height = height;
			//trace("setWindoor wo.x:"+wo.x);
			
			var windoor:WinDoor2D = windoorDict[hole];
			var wall2d:Wall2D = windoor.wall;
			wall2d.removeWindoor(windoor);
			
			var cw:CrossWall = hole.objectInfo.crossWall;
			var wall:Wall = hole.wall;
			wall.removeHole(hole);
			//cw.removeWallObject(hole.objectInfo);
			//trace("isChanged:"+vo.isChanged);
			var result:Boolean = cw.testAddObject(wo);
			if(result)
			{
				hole.width = width;
				hole.height = height;
				hole.x = wo.x - width;
				//trace("isChanged2:"+vo.isChanged);
			}
			
			wall2d.addWindoor(windoor);
			wall.addHole(hole);
			
			if(hole.isChanged)
			{
				hole.dispatchChangeEvent();
				//trace("isChanged3:"+vo.isChanged);
			}
			//cw.addWallObject(hole.objectInfo);
			//trace("result:"+result);
			
			//cw.initTestObject();
			windoor.updateView();
//			windoor.wall.updateView();
			scene.render();
			
			return result;
		}
		
		private var currHitWall:Wall2D;
		private var mousePoint:Point = new Point();
		
		private function noHitWall():void
		{
			if(currHitWall)
			{
				currHitWall.removeWindoor(currWindoor);
				currWindoor.vo.wall.removeHole(currWindoor.vo);
				
				currWindoor.vo.wall = null;
				currWindoor.rotation = 0;
				currWindoor.updateView();
				
				//currHitWall.vo.removeHole(currWindoor.vo);
				currHitWall = null;
			}
		}
		
		private function endMoveWindoor(e:MouseEvent):void
		{
			//trace("endMoveWindoor");
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,movingWindoor);
			stage.removeEventListener(MouseEvent.CLICK,endMoveWindoor);
			stage.removeEventListener(MouseEvent.MOUSE_UP,endMoveWindoor);
			
			this.scene.enable = true;
			
			if(currHitWall)
			{
				/*mousePoint.x = currWindoor.x;
				mousePoint.y = currWindoor.y;
				mousePoint = currHitWall.globalToLocal(mousePoint);
				
				currWindoor.x = mousePoint.x;
				currWindoor.y = 0;
				
				currHitWall.addWindoor(currWindoor);
				
				currHitWall.vo.addHole(currWindoor.vo);*/
				
				currWindoor.enable = true;
				
				currHitWall = null;
				
				scene.render();
				
				if(!isMoved)
				{
					trace("windoor mouse up");
					GlobalEvent.event.dispatchWindoorMouseUpEvent(currWindoor.vo);
				}
			}
			else
			{
				stage.removeChild(currWindoor);
				
				currWindoor.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
				currWindoor.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
				currWindoor.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				
				currWindoor.vo.dispose();
				
				currWindoor = null;
			}
		}
		
		//==============================================================================================
		public function clearAllWindoor():void
		{
			for(var hole:WallHole in windoorDict)
			{
				hole.dispose();
			}
		}
		
		//==============================================================================================
		private function _createWindoor(type:int,width:int,height:int,sillHeight:int,thickness:int):WinDoor2D
		{
			var hole:WallHole = new WallHole();
			hole.modelType = type;
			hole.width = width;
			hole.height = height;
			hole.y = sillHeight;
			hole.modelThickness = thickness;
			
			return createWindoor2d(hole);
		}
		
		private var windoorDict:Dictionary = new Dictionary();
		
		private function createWindoor2d(hole:WallHole):WinDoor2D
		{
			var wind:WinDoor2D = new WinDoor2D();
			wind.vo = hole;
			
			wind.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			wind.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			wind.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			
			hole.addEventListener("dispose",onWindoorDisposed);
			hole.addEventListener("changed",onHoleChange);
			
			windoorDict[hole] = wind;
			
			return wind;
		}
		
		private function onHoleChange(e:Event):void
		{
			//trace("onHoleChange");
			var hole:WallHole = e.currentTarget as WallHole;
			if(hole.wall)
			{
				var windoor:WinDoor2D = windoorDict[hole];
				windoor.x = Base2D.sizeToScreen(hole.x);
//				//trace("onHoleChange:"+windoor.x,windoor.y);
//				windoor.updateView();
//				windoor.wall.updateView();
			}
		}
		
		private function onWindoorDisposed(e:Event):void
		{
			var hole:WallHole = e.currentTarget as WallHole;
			hole.removeEventListener("dispose",onWindoorDisposed);
			hole.removeEventListener("changed",onHoleChange);
			
			var windoor:WinDoor2D = windoorDict[hole];
			delete windoorDict[hole];
			
			windoor.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
			windoor.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
			windoor.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			
			windoor.dispose();
			
			currWindoor = null;
		}
		
		protected function onRollOver(event:MouseEvent):void
		{
			var wind:WinDoor2D = event.currentTarget as WinDoor2D;
			if(wind.selected)return;
			
			wind.lineColor = Wall2D.overColor;
			wind.updateView();
		}
		
		protected function onRollOut(event:MouseEvent):void
		{
			var wind:WinDoor2D = event.currentTarget as WinDoor2D;
			if(wind.selected)return;
			
			wind.lineColor = WinDoor2D.lineColor;
			wind.updateView();
		}
		
		private function setCurrWindoor(windoor:WinDoor2D):void
		{
			if(currWindoor)
			{
				currWindoor.selected = false;
				currWindoor.lineColor = WinDoor2D.lineColor;
				currWindoor.updateView();
			}
			
			currWindoor = windoor;
			currWindoor.lineColor = Wall2D.selectColor;
			currWindoor.selected = true;
			currWindoor.updateView();
		}
		
		/**
		 * 是否允许拖动门窗
		 */
		public var dragEnable:Boolean = true;
		
		private var mdx:Number = 0;
		
		protected function onMouseDown(event:MouseEvent):void
		{
			if(!dragEnable)return;
			
			var windoor:WinDoor2D = event.currentTarget as WinDoor2D;
			setCurrWindoor(windoor);
			
			stage = scene.stage;
			stage.addEventListener(MouseEvent.MOUSE_MOVE,movingWindoor);
			stage.addEventListener(MouseEvent.MOUSE_UP,endMoveWindoor);
			
			currHitWall = windoor.wall;
			
			mdx = getLocalMouseX(currHitWall.vo) - windoor.vo.x;
			
			//currHitWall.removeWindoor(windoor);
			
			//windoor.vo.wall.removeHole(windoor.vo);
			
			initWindoor2();
			
			movingWindoor();
			
			scene.render();
			
			GlobalEvent.event.dispatchWindoorMouseDownEvent(windoor.vo);
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
		
		//==============================================================================================
		private function hitWallsTest():Wall2D
		{
			var ws:Vector.<Wall2D> = scene.currFloor.walls;
			for each(var w:Wall2D in ws)
			{
				if(currWindoor.testArea.hitTestObject(w.background))
				{
					return w;
				}
			}
			return null;
		}
		
		//==============================================================================================
		public function WindoorController(value:InstanceClass)
		{
			if(!value)
			{
				throw new Error("WallController是一个单例类，请用静态方法getInstance来获得类的实例。");
			}
		}
		
		//==============================================================================================
		static private var instance:WindoorController;
		
		static public function getInstance():WindoorController
		{
			instance ||= new WindoorController(new InstanceClass());
			return instance;
		}
		
		//==============================================================================================
	}
}

class InstanceClass{}
