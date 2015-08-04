package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.WallUtils;
	import rightaway3d.utils.MyTextField;

	public class WallFaceMarking extends Sprite
	{
		private var groundMark:BaseMarking;
		private var wallMark:BaseMarking;
		
		private var title_txt:MyTextField;
		
		public function WallFaceMarking()
		{
			groundMark = new BaseMarking();
			this.addChild(groundMark);
			
			wallMark = new BaseMarking();
			this.addChild(wallMark);
			
			title_txt = new MyTextField();
			this.addChild(title_txt);
			title_txt.textSize = 7;
			title_txt.align = TextFormatAlign.LEFT;
			title_txt.textColor = BaseMarking.lineColor;
			title_txt.height = title_txt.textHeight + 2;
			//title_txt.border = true;
			title_txt.borderColor = 0xff0000;
		}
		
		public function updateView(cw:CrossWall):void
		{
			var wps:Array = WallUtils.sortWallObject(cw.localHead.x,cw.localEnd.x,cw.wallObjects);
			wallMark.updateView(wps);
			wallMark.y = -Base2D.sizeToScreen(cw.wall.height) - 2;
			
			var gps:Array = WallUtils.sortWallObject(cw.localHead.x,cw.localEnd.x,cw.groundObjects);
			groundMark.updateView(gps,"down",200);
			groundMark.y = 2;
			
			setTitle(cw);
		}
		
		private function setTitle(cw:CrossWall):void
		{
			title_txt.text = cw.wall.name + "墙立面图";
			title_txt.y = groundMark.y + groundMark.height + 5;
			title_txt.width = title_txt.textWidth + 4;
			title_txt.height = title_txt.textHeight + 4;
			
			var len:Number = Base2D.sizeToScreen(cw.localEnd.x - cw.localHead.x);
			title_txt.x = (len - title_txt.width) * 0.5;
			
			var g:Graphics = this.graphics;
			g.clear();
			g.lineStyle(1,BaseMarking.lineColor);
			
			var tlen:Number = title_txt.width * 1.5;
			var tx0:Number = (len - tlen) * 0.5;
			var tx1:Number = tx0 + tlen;
			var ty:Number = title_txt.y + title_txt.height;
			
			g.moveTo(tx0,ty);
			g.lineTo(tx1,ty);
		}
	}
}