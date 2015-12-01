package rightaway3d.house.editor2d
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import rightaway3d.house.view2d.Base2D;
	import rightaway3d.house.view2d.WallFace2D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.WallObject;

	public class WallFaceViewer extends Sprite
	{
		//private var _container:Sprite;
		private var _cws:Vector.<CrossWall>;
		
		private var wallFace:WallFace2D;
		
		public function WallFaceViewer(cws:Vector.<CrossWall>)
		{
			//_container = container;
			_cws = cws;
			
			wallFace = new WallFace2D();
			this.addChild(wallFace);
		}
		
		public function reset():void
		{
			index = 0;
			wallFace.resetMatData();
		}
		
		private var index:int = 0;
		public function update():Boolean
		{
			var len:int = _cws.length;
			if(len>0)
			{
				if(index<len)
				{
					var cw:CrossWall = _cws[index++];
					show(cw,wallFace);
					
					var gos:Array = cw.groundObjects;
					if(!isAllHeightCabinet(gos))
					{
						var x0:Number = cw.localHead.x;
						var x1:Number = cw.localEnd.x;
						var dx0:int = getHeadStartPos(gos);
						var dx1:int = getEndStartPos(gos);
						
						var a:Array = [0];
						var n:Number = wallFace.drawHeadSocket(cw,dx0);//放置墙面首端插座
						a.push(n);
						
						if(x1-dx1-dx0-x0>2000)//墙面空白长度大于2米时，尾端也要放置插座
						{
							n = wallFace.drawEndSocket(cw,dx1);
							a.push(n);
						}
						
						wallFace.updateSizeMark(a,wallFace.wallMark,x1-x0);
						wallFace.wallMark.y = -60;
					}
					
					return true;
				}
				
				//index = 0;//当索引超出范围时，归零并返回false，待下一次调用时，重新循环显示立面图
				//reset();
			}
			
			return false;
		}
		
		//地柜中是否都是高柜
		private function isAllHeightCabinet(gos:Array):Boolean
		{
			for each(var wo:WallObject in gos)
			{
				if(wo.height<CrossWall.GROUND_OBJECT_HEIGHT)
				{
					return false;
				}
			}
			return true;
		}
		
		//地柜头端错开高柜的起始位置
		private function getHeadStartPos(gos:Array):int
		{
			var len:int = gos.length;
			var pos:int = 0;
			for(var i:int=0;i<len;i++)
			{
				var wo:WallObject = gos[i];
				if(wo.height>CrossWall.GROUND_OBJECT_HEIGHT)
				{
					pos += wo.width;
				}
				else
				{
					return pos;//遇到非高柜，立即返回之前的位置值
				}
			}
			return pos;
		}
		
		//地柜尾端错开高柜的起始位置
		private function getEndStartPos(gos:Array):int
		{
			var len:int = gos.length;
			var pos:int = 0;
			for(var i:int=len-1;i>=0;i--)
			{
				var wo:WallObject = gos[i];
				if(wo.height>CrossWall.GROUND_OBJECT_HEIGHT)
				{
					pos += wo.width;
				}
				else
				{
					return pos;//遇到非高柜，立即返回之前的位置值
				}
			}
			return pos;
		}
		
		private function show(cw:CrossWall,face:WallFace2D):void
		{
			updateBG();
			face.updateView(cw);
			
			/*flash.utils.setTimeout(updateFace,1,face);
		}
		
		private function updateFace(face:WallFace2D):void
		{			*/
			var n:Number = 0.8;
			var s:Number = 1;
			
			face.scaleX = s;
			face.scaleY = s;
			
			var sw:int = Scene2D.viewWidth;//stage.stageWidth;
			var sh:int = Scene2D.viewHeight;//stage.stageHeight;
			var w:Number = Base2D.sizeToScreen(cw.validLength+500);//face.width;
			var h:Number = face.height;
			
			//trace("face.width,w:",face.width,w);
			
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
			//w = face.width;
			w *= s;
			h = face.height;
			
			face.x = 250;//(sw-w)/2;
			face.y = h+(sh-h)/2 - sh*0.16;
		}
		
		private function updateBG(color:uint=0xffffff):void
		{
			var sw:int = Scene2D.viewWidth;//stage.stageWidth;
			var sh:int = Scene2D.viewHeight;//stage.stageHeight;
			
			var g:Graphics = this.graphics;
			g.clear();
			g.beginFill(color,1);
			g.drawRect(0,0,sw,sh);
			g.endFill();
		}
	}
}








