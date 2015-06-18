package rightaway3d.house.editor2d
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import rightaway3d.engine.utils.GlobalEvent;
	import rightaway3d.engine.utils.Tips;
	import rightaway3d.house.view2d.NodeController2D;
	import rightaway3d.house.view2d.Wall2D;
	import rightaway3d.house.view2d.WallAreaSelector;
	import rightaway3d.house.vo.Floor;
	import rightaway3d.house.vo.Wall;
	
	public class WallController
	{
		//==============================================================================================		
		/**
		 * 创建墙体
		 * @param floor 墙体所在楼层
		 * @param startX 墙体在屏幕场景中的起点坐标x值
		 * @param startY 墙体在屏幕场景中的起点坐标y值
		 * @param dx 墙体在屏幕场景中的终点坐标x偏移值
		 * @param dy 墙体在屏幕场景中的终点坐标y偏移值
		 * @param viewScale 墙体所在场景的视图缩放比例
		 * @param wallWidth 墙体的宽度，默认使用楼层的全局宽度
		 * @return 返回所创建墙体的二维视图
		 * 强者之强，在于心之强、性格之强、作风之强！
		 */
		public function createWall(floor:Floor,startX:Number,startY:Number,dx:Number,dy:Number,wallWidth:int=0):Wall2D
		{
			//trace("createWall:",startX,startY,dx,dy);
			
			var vo:Wall = new Wall();
			vo.index = Wall.getNextIndex();
			
			floor.addWall(vo);
			
			vo.update(startX,startY,dx,dy,wallWidth);
			
			return createWall2D(vo);
		}
		
		private var wallDict:Dictionary = new Dictionary();
		
		public function createWall2D(vo:Wall):Wall2D
		{
			//trace("createWall2:",vo.toJsonString());
			var wall:Wall2D = new Wall2D();			
			wall.vo = vo;
			
			wall.sizeMark.vo = vo;
			
			wall.background.addEventListener(MouseEvent.CLICK,onWallClick);
			wall.background.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			wall.background.addEventListener(MouseEvent.DOUBLE_CLICK,onDClick);
			wall.background.doubleClickEnabled = true;
			wall.background.mouseChildren = false;
			
			wall.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			wall.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			
			wallDict[vo] = wall;
			vo.addEventListener("dispose",onWallDisposed);
			
			return wall;
		}
		
		private var tipsID:int = -1;
		private var isOverWall:Boolean = false;
		
		private function onRollOver(event:MouseEvent):void
		{
			var areas:WallAreaSelector = scene.house.currFloor.wallAreaSelector;
			if(areas.isLock)return;
			
			if(areas.getSelectWallNum()<3)
			{
				isOverWall = true;
				flash.utils.setTimeout(showTips,100);
			}
			
			var wall2d:Wall2D = event.currentTarget as Wall2D; 
			if(wall2d.isLock || wall2d.selected)return;
			
			wall2d.fillColor = Wall2D.overColor;			
			wall2d.updateView();
		}
		
		private function showTips():void
		{
			if(isOverWall)tipsID = Tips.show("双击设置厨柜范围",scene.stage.mouseX,scene.stage.mouseY);
		}
		
		private function onRollOut(event:MouseEvent):void
		{
			isOverWall = false;
			
			var areas:WallAreaSelector = scene.house.currFloor.wallAreaSelector;
			if(areas.isLock)return;
			
			if(tipsID>-1)
			{
				Tips.hide(tipsID);
				tipsID = -1;
			}
			
			var wall2d:Wall2D = event.currentTarget as Wall2D; 
			if(wall2d.isLock || wall2d.selected)return;
			
			wall2d.fillColor = Wall2D.normalColor;			
			wall2d.updateView();
		}
		
		protected function onDClick(event:MouseEvent):void
		{
			//trace("onWallDClick");
			var wall2d:Wall2D = event.currentTarget.parent; 
			var areas:WallAreaSelector = scene.house.currFloor.wallAreaSelector;
			if(areas.isLock)return;
			
			areas.createWallArea(wall2d.vo);
		}
		
		private function onWallDisposed(e:Event):void
		{
			var vo:Wall = e.currentTarget as Wall;
			vo.removeEventListener("dispose",onWallDisposed);
			
			var wall:Wall2D = wallDict[vo];
			delete wallDict[vo];
			
			wall.background.removeEventListener(MouseEvent.CLICK,onWallClick);
			wall.background.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			wall.background.removeEventListener(MouseEvent.DOUBLE_CLICK,onDClick);
			
			wall.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
			wall.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
			
			scene.removeWall(wall);
			
			wall.dispose();
			
			nodeCtr.hideNode();
		}
		
		private var nodeCtr:NodeController2D = NodeController2D.getInstance();
		
		public function deleteWall(wall:Wall2D):void
		{
			//if(wall.vo.rooms.length>0)return;
			var vo:Wall = wall.vo;//此墙面是某个房间的组成部分，则不能删除此墙
			if(vo.frontCrossWall.room || vo.backCrossWall.room)return;
			
			//wall.vo.floor.removeWall(wall.vo);
			vo.dispose();
		}
		
		public function deleteCurrentWall():void
		{
			if(this.currWall)
			{
				deleteWall(this.currWall);
				this.currWall = null;
			}
		}
		
		//==============================================================================================
		public var scene:Scene2D;
		
		//==============================================================================================
		public var currWall:Wall2D;
		
		/**
		 * 是否允许拖动墙体
		 */
		public var dragEnable:Boolean = true;
		
		private var mouseX0:Number;
		private var mouseY0:Number;
		private var wallX0:Number;
		private var wallY0:Number;
		
		private var isHorizontalMove:Boolean;
		
		protected function onMouseDown(event:MouseEvent):void
		{
			var wall2d:Wall2D = event.currentTarget.parent; 
			if(wall2d.isLock)return;
			
			currWall = wall2d;
			//trace(currWall.rotation%180);
			//trace(currWall.rotation%90);
			
			if(!dragEnable)return;
			
			isHorizontalMove = currWall.rotation%180==0?false:true;
			
			scene.addEventListener(MouseEvent.MOUSE_MOVE,onStageMove);
			scene.addEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
			
			mouseX0 = scene.mouseX;
			mouseY0 = scene.mouseY;
			wallX0 = currWall.x;
			wallY0 = currWall.y;
			
			wallNodes.hideNode();
			
			GlobalEvent.event.dispatchWallMouseDownEvent(currWall.vo);
		}
		
		protected function onStageMove(event:MouseEvent):void
		{
			var dx:Number = isHorizontalMove ? scene.mouseX - mouseX0 : 0;
			var dy:Number = isHorizontalMove ? 0 : scene.mouseY - mouseY0;
			//trace("onstagemove:",dx,dy);
			
			currWall.vo.updatePosition(wallX0+dx,wallY0+dy);
			
			scene.currFloor.render();
		}
		
		public var wallNodes:NodeController2D = NodeController2D.getInstance();
		
		protected function onStageMouseUp(event:MouseEvent):void
		{
			scene.removeEventListener(MouseEvent.MOUSE_MOVE,onStageMove);
			scene.removeEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
			
			/*if(currWall.selected)//屏蔽事件20150121
			{
				//wallNodes.showNode(currWall.vo);
				GlobalEvent.event.dispatchWallMouseUpEvent(currWall.vo);
			}*/
		}
		
		/*private function onWallRollOver(event:MouseEvent):void
		{
			var wall:Wall2D = event.currentTarget as Wall2D;
			
			if(wall.selected)return;
			
			this.updateWallView(wall,Wall2D.lineColor,Wall2D.overColor);
		}*/
		
		/*private function onWallRollOut(event:MouseEvent):void
		{
			var wall:Wall2D = event.currentTarget as Wall2D;
			
			if(wall.selected)return;
			
			this.updateWallView(wall,Wall2D.lineColor,Wall2D.normalColor);
		}*/
		
		private function onWallClick(event:MouseEvent):void
		{
			var wall:Wall2D = event.currentTarget.parent;
			if(wall!=currWall)
			{
				currWall = null;
				return;
			}
			
			currWall.selected = !currWall.selected;
			
			if(!currWall.selected)
			{
				currWall = null;
			}
		}
		
		//==============================================================================================
		public function WallController(value:InstanceClass)
		{
			if(!value)
			{
				throw new Error("WallController是一个单例类，请用静态方法getInstance来获得类的实例。");
			}
		}
		
		//==============================================================================================
		static private var instance:WallController;
		
		static public function getInstance():WallController
		{
			instance ||= new WallController(new InstanceClass());
			return instance;
		}
		
		//==============================================================================================
	}
}

class InstanceClass{}




