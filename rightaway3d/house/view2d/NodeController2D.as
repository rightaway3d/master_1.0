package rightaway3d.house.view2d
{
	import flash.events.MouseEvent;
	
	import rightaway3d.house.editor2d.Scene2D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.HousePoint;
	import rightaway3d.house.vo.Wall;

	public class NodeController2D extends Base2D
	{
		public var scene:Scene2D;
		
		private var headNode:WallNode2D;
		private var endNode:WallNode2D;
		
		//==============================================================================================
		private function init():void
		{
			headNode = createNode();
			endNode = createNode();
		}
		
		private function createNode():WallNode2D
		{
			var node:WallNode2D = new WallNode2D();
			node.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			node.visible = false;
			this.addChild(node);
			return node;
		}
		
		//==============================================================================================
		private var mouseX0:Number;
		private var mouseY0:Number;
		private var wallX0:Number;
		private var wallY0:Number;
		
		private var currNode:WallNode2D;
		
		private var gridSize:int;
		
		public var isCatchGridPoint:Boolean = true;
		
		private function onMouseDown(e:MouseEvent):void
		{
			currNode = e.currentTarget as WallNode2D;
			
			scene.addEventListener(MouseEvent.MOUSE_MOVE,onStageMove);
			scene.addEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
			
			mouseX0 = scene.mouseX;
			mouseY0 = scene.mouseY;
			wallX0 = currNode.x;
			wallY0 = currNode.y;
			
			gridSize = scene.backGrid.gridSize;
		}
		
		private function onStageMove(e:MouseEvent):void
		{
			var tx:Number = wallX0 + scene.mouseX - mouseX0;
			var ty:Number = wallY0 + scene.mouseY - mouseY0;
			
			if(isCatchGridPoint)
			{
				var n:int = (tx+gridSize*0.5)/gridSize;
				tx = gridSize * n;
				
				n = (ty+gridSize*0.5)/gridSize;
				ty = gridSize * n;
			}
			
			currNode.x = tx;
			currNode.y = ty;
			
			currNode.housePoint.point.x = Base2D.screenToSize(tx);
			currNode.housePoint.point.z = Base2D.screenToSize(Scene2D.sceneHeight-ty);
			
			updateCrossWall(currNode.housePoint);
			
			scene.render();
		}
		
		private function updateCrossWall(hp:HousePoint):void
		{
			var cws:Vector.<CrossWall> = hp.crossWalls;
			for each(var cw:CrossWall in cws)
			{
				var w:Wall = cw.wall;
				w.updateLength();
				w.countCrossWall();
				w.updateRooms();
				w.isChanged = true;
			}
		}
		
		private function onStageMouseUp(e:MouseEvent):void
		{
			scene.removeEventListener(MouseEvent.MOUSE_MOVE,onStageMove);
			scene.removeEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
			
		}
		
		//==============================================================================================
		public function showNode(wall:Wall):void
		{
			headNode.housePoint = wall.groundHeadPoint;
			endNode.housePoint = wall.groundEndPoint;
			
			headNode.updateView();
			endNode.updateView();
			
			headNode.visible = true;
			endNode.visible = true;
		}
		
		public function hideNode():void
		{
			headNode.visible = false;
			endNode.visible = false;
		}
		
		//==============================================================================================
		public function NodeController2D(value:InstanceClass)
		{
			if(!value)
			{
				throw new Error("WallController是一个单例类，请用静态方法getInstance来获得类的实例。");
			}
			
			init();
		}
		
		//==============================================================================================
		static private var instance:NodeController2D;
		
		static public function getInstance():NodeController2D
		{
			instance ||= new NodeController2D(new InstanceClass());
			return instance;
		}
		
		//==============================================================================================
	}
}

class InstanceClass{}
























