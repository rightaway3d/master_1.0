package rightaway3d.house.editor2d
{
	import flash.display.Sprite;
	
	import rightaway3d.house.view2d.WallFace2D;
	import rightaway3d.house.vo.CrossWall;

	public class WallFaceViewer
	{
		private var _container:Sprite;
		private var _cws:Vector.<CrossWall>;
		
		private var wallFace:WallFace2D;
		
		public function WallFaceViewer(container:Sprite,cws:Vector.<CrossWall>)
		{
			_container = container;
			_cws = cws;
			
			wallFace = new WallFace2D();
			_container.addChild(wallFace);
		}
		
		public function reset():void
		{
			index = 0;
		}
		
		private var index:int = 0;
		public function update():Boolean
		{
			var len:int = _cws.length;
			if(len>0)
			{
				if(index<len)
				{
					var cw:CrossWall = _cws[index];
					
					show(cw,wallFace);
					wallFace.drawHeadSocket(cw);
					
					index++;
					if(index==len)
					{
						wallFace.drawEndSocket(cw);
					}
					return true;
				}
				
				index = 0;//当索引超出范围时，归零并返回false，待下一次调用时，重新循环显示立面图
			}
			
			return false;
		}
		
		private function show(cw:CrossWall,face:WallFace2D):void
		{
			face.updateView(cw);
			
			var n:Number = 0.8;
			var s:Number = 1;
			
			face.scaleX = s;
			face.scaleY = s;
			
			var sw:int = face.stage.stageWidth;
			var sh:int = face.stage.stageHeight;
			var w:Number = face.width;
			var h:Number = face.height;
			
			//trace(sw,sh,w,h);
			
			if(sw/sh > w/h)//内容比较窄
			{
				s = sh*n/h;
			}
			else
			{
				s = sw*n/w;
			}
			
			face.scaleX = s;
			face.scaleY = s;
			w = face.width;
			h = face.height;
			
			face.x = (sw-w)/2;
			face.y = h+(sh-h)/2;
		}
	}
}








