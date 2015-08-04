package rightaway3d.house.editor2d
{
	import com.greensock.TweenMax;
	
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import rightaway3d.house.view2d.Base2D;
	import rightaway3d.house.view2d.Room2D;
	import rightaway3d.house.view2d.ScaleRuler2D;
	import rightaway3d.house.view2d.Wall2D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.Floor;
	import rightaway3d.house.vo.House;
	import rightaway3d.house.vo.Room;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallHole;

	public class SceneController2D
	{
		private var scene:Scene2D;
		
		private var masker:Shape;
		
		private var ruler:ScaleRuler2D;
		
		//--------------------------------------------
		public var viewWidth:int = 800;
		public var viewHeight:int = 600;
		
		//public var menuWidth:int = 0;
		
		public var action:String = ACTION_DRAG_SCENE;
		
		public const ACTION_DRAG_SCENE:String = "drag_scene";
		public const ACTION_DRAW_WALL:String = "draw_wall";
		public const ACTION_DRAW_ROOM:String = "draw_room";
		public const ACTION_ADD_DOOR:String = "add_door";
		public const ACTION_ADD_WINDOW:String = "add_window";
		
		private var mouseX0:Number;
		private var mouseY0:Number;
		
		private var sceneX0:Number;
		private var sceneY0:Number;
		
		//--------------------------------------------------------------------------------
		private var currWall:Wall2D;
		//private var firstFloor:Floor;
		private var isMoved:Boolean;
		
		private var wallCtr:WallController = WallController.getInstance();
		
		private var roomProxy:Shape = new Shape();
		
		private var onMouseMoveFun:Function;
		private var onMouseUpFun:Function;
		
		public function SceneController2D(scene_:Scene2D,masker_:Shape,ruler_:ScaleRuler2D)
		{
			wallCtr.scene = scene_;			
			
			scene = scene_;
			masker = masker_;
			ruler = ruler_;
			
			//scene_.addEventListener(MouseEvent.MOUSE_OVER,on2DSceneMouseOver);
			//scene_.addEventListener(MouseEvent.MOUSE_OUT,on2DSceneMouseOut);
			scene_.addEventListener(MouseEvent.MOUSE_WHEEL,on2DSceneMouseWheel);
			scene_.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN,onDragStart);
			scene_.backGrid.addEventListener(MouseEvent.MOUSE_DOWN,onSceneMouseDown);
			
			updateBackGridView();
		}
		
		public function updateBackGridView():void
		{
			scene.backGrid.updateView(Scene2D.sceneWidth,Scene2D.sceneHeight,scene.scaleX);
		}
		
		//=========================================================================================================================
		protected function onDragStart(event:MouseEvent):void
		{
			scene.addEventListener(MouseEvent.MOUSE_MOVE,onDragingScene);
			scene.addEventListener(MouseEvent.MIDDLE_MOUSE_UP,onEndDraging);
			
			startDragScene();
		}
		
		private function startDragScene():void
		{
			mouseX0 = scene.stage.mouseX;
			mouseY0 = scene.stage.mouseY;
			
			sceneX0 = scene.x;
			sceneY0 = scene.y;
		}
		
		private function onDragingScene(event:MouseEvent):void
		{
			dragingScene();
		}
		
		private function dragingScene():void
		{
			var sw:Number = viewWidth/(Scene2D.sceneWidth + gridBorder*2);
			var sh:Number = viewHeight/(Scene2D.sceneHeight + gridBorder*2);
			var scale:Number = scene.scaleX;
			var dx:Number = scene.stage.mouseX - mouseX0;
			var dy:Number = scene.stage.mouseY - mouseY0;
			if(scale>sw)scene.x = fixSceneX(sceneX0+dx,scale);
			if(scale>sh)scene.y = fixSceneY(sceneY0+dy,scale);
		}
				
		private function onEndDraging(event:MouseEvent):void
		{
			scene.removeEventListener(MouseEvent.MOUSE_MOVE,onDragingScene);
			scene.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP,onEndDraging);
		}
		
		//=========================================================================================================================
		private function onSceneMouseDown(event:MouseEvent):void
		{
			scene.addEventListener(MouseEvent.MOUSE_MOVE,onSceneMouseMove);
			scene.addEventListener(MouseEvent.MOUSE_UP,onSceneMouseUp);
			
			isMoved = false;
			onMouseMoveFun = null;
			onMouseUpFun = null;
			
			if(action==ACTION_DRAG_SCENE)
			{
				startDragScene();
				onMouseMoveFun = dragingScene;
			}
			else if(action==ACTION_DRAW_WALL)
			{
				startDrawWall();
				onMouseMoveFun = drawingWall;
				onMouseUpFun = endDrawWall;
			}
			else if(action==ACTION_DRAW_ROOM)
			{
				mouseX0 = scene.mouseX;
				mouseY0 = scene.mouseY;

				scene.addChild(roomProxy);
				
				onMouseMoveFun = drawingRoom;
				onMouseUpFun = endDrawRoom;
			}
			else if(action==ACTION_ADD_DOOR)
			{
				//createWindoor(101,800,1800,80);
			}
			else if(action==ACTION_ADD_WINDOW)
			{
				//createWindoor(201,800,1000,80);
			}
		}
		
		private function onSceneMouseMove(event:MouseEvent):void
		{
			isMoved = true;
			if(onMouseMoveFun!=null)onMouseMoveFun();
		}
		
		private function onSceneMouseUp(event:MouseEvent):void
		{
			scene.removeEventListener(MouseEvent.MOUSE_MOVE,onSceneMouseMove);
			scene.removeEventListener(MouseEvent.MOUSE_UP,onSceneMouseUp);
			
			if(onMouseUpFun!=null)onMouseUpFun();
		}
		
		//=========================================================================================================================
		public var sceneScaleEnable:Boolean = true;
		
		private function on2DSceneMouseWheel(e:MouseEvent):void
		{
			var mouseX:Number = this.scene.mouseX;
			var mouseY:Number = this.scene.mouseY;
			
			var deltaScale:Number = e.delta*0.05;
			_setSceneScale(deltaScale,mouseX,mouseY,0,0,true);
		}
		
		private var gridBorder:int = 50;
		
		private function _setSceneScale(deltaScale:Number,mouseX:Number,mouseY:Number,dx:Number,dy:Number,isTween:Boolean):void
		{
			if(!sceneScaleEnable)return;
			//trace("setSceneScale deltaScale:"+deltaScale);
			
			var scale:Number = this.scene.scaleX + deltaScale;
			
			var sw:Number = viewWidth/(Scene2D.sceneWidth + gridBorder*2);
			var sh:Number = viewHeight/(Scene2D.sceneHeight + gridBorder*2);
			
			var minScale:Number = sh<sw?sh:sw;
			var maxScale:Number = 20;
			
			if(scale > maxScale)
			{
				scale = maxScale;
			}
			else if(scale < minScale)
			{
				scale = minScale;
			}
			
			if(Math.abs(scene.scaleX-scale)<0.01 && dx==0 && dy==0)return;
			
			deltaScale = scale - this.scene.scaleX;
			//trace("deltaScale:"+deltaScale);
			
			var tx:Number = this.scene.x - mouseX * deltaScale + dx;			
			var ty:Number = this.scene.y - mouseY * deltaScale + dy;
			//trace("txy:"+tx+"x"+ty);
			
			if(scale == minScale)
			{
				scene.backGrid.mouseEnabled = false;
				tx = (viewWidth-Scene2D.sceneWidth*scale)/2;
				ty = (viewHeight-Scene2D.sceneHeight*scale)/2;
			}
			else
			{
				scene.backGrid.mouseEnabled = true;
				if(scale>sw)tx = fixSceneX(tx,scale);
				if(scale>sh)ty = fixSceneY(ty,scale);
			}
			//trace("txy2:"+tx+"x"+ty);
			
			if(isTween)
			{
				TweenMax.to(this.scene,0.4,{scaleX:scale, scaleY:scale, x:tx, y:ty, onComplete:onScaleComplete});
			}
			else
			{
				this.scene.scaleX = scale;
				this.scene.scaleY = scale;
				this.scene.x = tx;
				this.scene.y = ty;
				
				onScaleComplete();
			}
		}
		
		private function onScaleComplete():void
		{
			scene.backGrid.updateView(Scene2D.sceneWidth,Scene2D.sceneHeight,scene.scaleX);
			ruler.updateView(scene.scaleX);
			//SizeMarking2D.sceneScale = scene.scaleX;
			//SizeMarking2D.updateAllMarks();
		}
		
		private function fixSceneX(tx:Number,scale:Number):Number
		{
			var border:Number = gridBorder*scale;
			if(tx-masker.x>border)
			{
				tx = masker.x+border;
			}
			else if(tx+Scene2D.sceneWidth*scale+border<masker.x+masker.width)
			{
				tx = masker.x+masker.width-Scene2D.sceneWidth*scale-border;
			}
			return tx;
		}
		
		private function fixSceneY(ty:Number,scale:Number):Number
		{
			var border:Number = gridBorder*scale;
			if(ty-masker.y>border)
			{
				ty = masker.y+border;
			}
			else if(ty+Scene2D.sceneHeight*scale+border<masker.y+masker.height)
			{
				ty = masker.y+masker.height-Scene2D.sceneHeight*scale-border;
			}
			return ty;
		}
		
		//=========================================================================================================================		
		public function updateView(w:int,h:int):void
		{
			this.viewWidth = w;
			this.viewHeight = h;
			/*updateMask(w,h);
			
			ruler.y = h - ruler.height - 20;*/
			
			var sw:Number = viewWidth/(Scene2D.sceneWidth + gridBorder*2);
			var sh:Number = viewHeight/(Scene2D.sceneHeight + gridBorder*2);
			var s:Number = sh<sw?sh:sw;
			var scale:Number = scene.scaleX;
			if(scale<s)
			{
				scene.backGrid.mouseEnabled = false;
				scene.scaleX = s;
				scene.scaleY = s;
				scene.x = (viewWidth-Scene2D.sceneWidth*s)/2;
				scene.y = (viewHeight-Scene2D.sceneHeight*s)/2;
			}
			else
			{
				if(scale>sw)scene.x = fixSceneX(scene.x,scale);
				if(scale>sh)scene.y = fixSceneY(scene.y,scale);
				scene.backGrid.mouseEnabled = true;
			}
		}
		//=========================================================================================================================
		
		private var gridSize:int;
		
		public var isCatchGridPoint:Boolean = true;
		
		private function startDrawWall():void
		{
			mouseX0 = scene.mouseX;
			mouseY0 = scene.mouseY;
			
			gridSize = scene.backGrid.gridSize;
			
			if(isCatchGridPoint)
			{
				var n:int = (mouseX0+gridSize*0.5)/gridSize;
				mouseX0 = gridSize * n;
				
				n = (mouseY0+gridSize*0.5)/gridSize;
				mouseY0 = gridSize * n;
			}
			
			currWall = wallCtr.createWall(scene.currFloor.vo,mouseX0,mouseY0,0.1,0,scene.scaleX);
			currWall.enable = false;
			scene.addWall(currWall);
			currWall.updateView();
		}
		
		private function drawingWall():void
		{
			var tx:Number = scene.mouseX;
			var ty:Number = scene.mouseY;
			
			if(isCatchGridPoint)
			{
				var n:int = (tx+gridSize*0.5)/gridSize;
				tx = gridSize * n;
				
				n = (ty+gridSize*0.5)/gridSize;
				ty = gridSize * n;
			}
			
			var dx:Number = tx - mouseX0;
			var dy:Number = ty - mouseY0;
			
			currWall.vo.update(mouseX0,mouseY0,dx,dy);
			currWall.updateView();
		}
		
		private function endDrawWall():void
		{
			if(!isMoved)
			{
				scene.removeWall(currWall);
				currWall.dispose();
			}
			else
			{
				currWall.enable = true;
			}
		}
		
		//-------------------------------------------------------------------------------- 
		private var groundMaterialName:String;
		private var ceilingMaterialName:String;
		private var wallMaterialName:String;
		
		public function setGroundMaterial(matName:String):void
		{
			groundMaterialName = matName;
			var rooms:Vector.<Room> = scene.currFloor.vo.rooms;
			for each(var room:Room in rooms)
			{
				room.groundMaterialName = matName;
			}
		}
		
		public function setCeilingMaterial(matName:String):void
		{
			ceilingMaterialName = matName;
			var rooms:Vector.<Room> = scene.currFloor.vo.rooms;
			for each(var room:Room in rooms)
			{
				room.ceilingMaterialName = matName;
			}
		}
		
		public function setWallMaterial(matName:String):void
		{
			wallMaterialName = matName;
			var rooms:Vector.<Room> = scene.currFloor.vo.rooms;
			for each(var room:Room in rooms)
			{
				var walls:Vector.<CrossWall>  = room.walls;
				for each(var cw:CrossWall in walls)
				{
					cw.materialName = matName;
				}
			}
		}
		
		//--------------------------------------------------------------------------------
		public function createRoom2(room:Room):void
		{
			scene.house.vo.currRoom = room;
			
			groundMaterialName = room.groundMaterialName;
			ceilingMaterialName = room.ceilingMaterialName;
			
			var floor:Floor = room.floor;
			var scale:Number = scene.scaleX;
			
			
			var room2d:Room2D = _createRoom(room);
			
			var windoorCtr:WindoorController = WindoorController.getInstance();
			
			var walls:Vector.<CrossWall> = room.walls;
			for each(var cw:CrossWall in walls)
			{
				var wall:Wall = cw.wall;
				var wall2d:Wall2D = wallCtr.createWall2D(wall);
				scene.addWall(wall2d);
				cw.wall.countCrossWall();
				room2d.walls[wall2d] = cw;
				
				for each(var hole:WallHole in wall.holes)
				{
					windoorCtr.createWindoor2(hole,wall2d);
				}
			}
			
			wallMaterialName = cw.materialName;
			
			//room2d.loadGroundImage("assets/map/12034.png");
			
			scene.render();
		}
		
		public function createRoom(x:Number,y:Number,w:Number,h:Number):void
		{
			var floor:Floor = scene.currFloor.vo;
			var scale:Number = scene.scaleX;
			
			var room:Room = new Room();
			floor.addRoom(room);
			scene.house.vo.currRoom = room;
			
			room.groundMaterialName = groundMaterialName;
			room.ceilingMaterialName = ceilingMaterialName;
			/*floor.rooms.push(room);
			
			room.floor = floor;
			room.index = Room.getNextIndex();*/
			
			var room2d:Room2D = _createRoom(room);
			
			var wall:Wall2D = wallCtr.createWall(floor,x,y,w,0);
			wall.vo.name = "A";
			//wall.vo.findCrossWall();
			scene.addWall(wall);
			
			var cw:CrossWall = wall.vo.frontCrossWall;//new CrossWall(wall.vo,true);
			room.walls.push(cw);
			//wall.vo.rooms.push(room);
			cw.room = room;
			room2d.walls[wall] = cw;
			cw.materialName = wallMaterialName;
			
			//trace("wall angles:"+(wall.vo.angles));
			
			wall = wallCtr.createWall(floor,x+w,y,0,h);
			wall.vo.name = "B";
			wall.vo.findCrossWall();
			wall.vo.countCrossWall();
			scene.addWall(wall);
			
			cw = wall.vo.frontCrossWall;//new CrossWall(wall.vo,true);
			room.walls.push(cw);
			//wall.vo.rooms.push(room);
			cw.room = room;
			room2d.walls[wall] = cw;
			cw.materialName = wallMaterialName;
			//trace("wall angles:"+(wall.vo.angles));
			
			wall = wallCtr.createWall(floor,x+w,y+h,-w,0);
			wall.vo.name = "C";
			wall.vo.findCrossWall();
			wall.vo.countCrossWall();
			scene.addWall(wall);
			
			cw = wall.vo.frontCrossWall;//new CrossWall(wall.vo,true);
			room.walls.push(cw);
			//wall.vo.rooms.push(room);
			cw.room = room;
			room2d.walls[wall] = cw;
			cw.materialName = wallMaterialName;
			//trace("wall angles:"+(wall.vo.angles));
			
			wall = wallCtr.createWall(floor,x,y+h,0,-h);
			wall.vo.name = "D";
			wall.vo.findCrossWall();
			wall.vo.countCrossWall();
			scene.addWall(wall);
			
			cw = wall.vo.frontCrossWall;//new CrossWall(wall.vo,true);
			room.walls.push(cw);
			//wall.vo.rooms.push(room);
			cw.room = room;
			room2d.walls[wall] = cw;
			cw.materialName = wallMaterialName;
			//trace("wall angles:"+(wall.vo.angles));
			
			//room2d.loadGroundImage("assets/map/12034.png");
			//room2d.loadGroundImage("assets/map/12034.png");
			
			scene.render();
			
			//trace("sceneData:"+scene.toJsonString());
		}
		
		private var roomDict:Dictionary = new Dictionary();
		
		private function _createRoom(vo:Room):Room2D
		{
			var room2d:Room2D = new Room2D(vo);
			scene.addRoom(room2d);
			
			vo.addEventListener("dispose",onRoomDisposed);
			roomDict[vo] = room2d;
			
			return room2d;
		}
		
		private function onRoomDisposed(e:Event):void
		{
			var vo:Room = e.currentTarget as Room;
			vo.removeEventListener("dispose",onRoomDisposed);
			
			var room2d:Room2D = roomDict[vo];
			delete roomDict[vo];
			
			scene.removeRoom(room2d);
			room2d.dispose();
		}
		
		private function drawRoomProxy(x:Number,y:Number,dx:Number,dy:Number):void
		{
			var gra:Graphics = roomProxy.graphics;
			gra.clear();
			gra.lineStyle(Base2D.sizeToScreen(scene.currFloor.vo.wallWidth),Wall2D.normalColor,1,false,"normal",null,JointStyle.MITER);
			gra.beginFill(0xEEEEEE,0.8);
			gra.drawRect(x,y,dx,dy);
			gra.endFill();
		}
		
		//--------------------------------------------------------------------------------
		protected function drawingRoom():void
		{
			var dx:Number = scene.mouseX - mouseX0;
			var dy:Number = scene.mouseY - mouseY0;
			
			drawRoomProxy(mouseX0,mouseY0,dx,dy);
		}
		
		private function endDrawRoom():void
		{
			scene.removeChild(roomProxy);
			roomProxy.graphics.clear();
			
			var dx:Number = scene.mouseX - mouseX0;
			var dy:Number = scene.mouseY - mouseY0;
			
			var size:int = Base2D.sizeToScreen(scene.currFloor.vo.wallWidth)*2;
			if(dx>size && dy>size)
			{
				createRoom(mouseX0,mouseY0,dx,dy);
			}
		}
		
		//=========================================================================================================================
		public function setSceneScale(deltaScale:Number=0,stageMouseX:Number=-1,stageMouseY:Number=-1):void
		{
			if(!this.scene.visible)
			{
				return;
			}
			
			//if(stageMouseX<0)stageMouseX=(scene.stage.stageWidth-this.menuWidth)/2+this.menuWidth;
			if(stageMouseX<0)stageMouseX=viewWidth/2;
			if(stageMouseY<0)stageMouseY=viewHeight/2;
			
			var p:Point = new Point(stageMouseX,stageMouseY);
			
			p = this.scene.globalToLocal(p);
			
			_setSceneScale(deltaScale,p.x,p.y,0,0,true);
		}
		//=========================================================================================================================
		public function fitScreen(isTween:Boolean,space:Number,dx:int=0,dy:int=0):void
		{
			if(!scene.stage || !this.scene.visible)return;
			
			//trace("fitScreen");
			
			var houseVO:House = scene.house.vo;
			houseVO.updateBounds();
			
			space = space<0 ? 0 : (space>1 ? 1 : space);
			space = space * 2 + 1;
			//space = 3;
			var tdx:Number = Base2D.sizeToScreen(houseVO.width * space);
			var tdy:Number = Base2D.sizeToScreen(houseVO.depth * space);
			
			//房子的中心点
			var x0:Number = Base2D.sizeToScreen(houseVO.x);
			var y0:Number = Base2D.sizeToScreen(houseVO.z);
			
			y0 = Scene2D.sceneHeight - y0
			//trace("房子中心点:"+x0+","+y0);
			
			//计算视图中心点
			var p0:Point = new Point(viewWidth/2,viewHeight/2);
			//p0 = scene.backGrid.localToGlobal(p0);
			//p0 = scene.localToGlobal(p0);
			p0 = scene.parent.localToGlobal(p0);
			//trace("视图中心点:"+p0.x+","+p0.y);
			
			//计算适应视图后，x、y轴的缩放比例；
			var sx:Number = this.viewWidth/tdx;
			var sy:Number = this.viewHeight/tdy;
			
			//x、y轴的缩放比例取小值；再计算比例差值
			var scale:Number = (sx<sy)?(sx):(sy);
			var deltaScale:Number = scale - this.scene.scaleX;
			
			var p1:Point = new Point(x0,y0);
			
			//转换房子的中心点值到全局坐标，并计算与视图中心点的距离
			p1 = scene.backGrid.localToGlobal(p1);
			//trace("房子中心点Global:"+p1.x+","+p1.y);
			
			tdx = p0.x - p1.x + dx;
			tdy = p0.y - p1.y + dy;
			//trace("房子中心点到视图中心点距离:"+dx+","+dy);
			
			p1 = this.scene.globalToLocal(p1);
			//trace("房子中心点Local:"+p1.x+","+p1.y);
			
			_setSceneScale(deltaScale,p1.x,p1.y,tdx,tdy,isTween);
			
		}
		/*public function fitScreen():void
		{
			if(this.scene2D.visible == false)
			{
				return;
			}
			
			var dx:Number = houseVO.length + 100;
			var dy:Number = houseVO.width + 100;
			
			//房子的中心点
			var x0:Number = houseVO.x;
			var y0:Number = houseVO.y;
			
			y0 = this.leftToRightY(y0);
			
			//计算视图中心点
			var cx:Number = (stage.stageWidth-this.menuWidth)/2+this.menuWidth;
			var cy:Number = stage.stageHeight/2;
			
			//计算适应视图后，x、y轴的缩放比例；
			var sx:Number = (this.viewWidth-this.menuWidth)/dx;
			var sy:Number = this.viewHeight/dy;
			
			//x、y轴的缩放比例取小值；再计算比例差值
			var scale:Number = (sx<sy)?(sx):(sy);
			var deltaScale:Number = scale - this.scene2D.scaleX;
			
			var p:Point = new Point(x0,y0);
			
			//转换房子的中心点值到全局坐标，并计算与视图中心点的距离
			p = this.bgGridView.localToGlobal(p);
			dx = cx - p.x;
			dy = cy - p.y;
			
			p = this.scene2D.globalToLocal(p);
			
			_setCanvasScale(deltaScale,p.x,p.y,dx,dy);
			
		}*/
	}
}




