package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	import flash.text.TextFormatAlign;
	
	import rightaway3d.utils.MyTextField;

	/**
	 * 绘制标高
	 * @author Jell
	 * 
	 */
	public class LevelMark2D extends Base2D
	{
		private var level_txt:MyTextField;
		
		public function LevelMark2D()
		{
			level_txt = new MyTextField();
			level_txt.textSize = 6;
			level_txt.textColor = WallFace2D.lineColor;
			
			this.addChild(level_txt);
		}
		
		/**
		 * 更新视图
		 * @param level：标高
		 * @param direct：尾巴方向:left,right
		 * @param offset：标高文本是尾巴方向上的偏移量
		 * 
		 */
		public function updateView(level:int,direct:String,xPos:int,yPos:int,offSetSize:int=0,memo:String=""):void
		{
			this.x = Base2D.sizeToScreen(xPos);
			this.y = -Base2D.sizeToScreen(yPos);
			
			var mw:int = 8;//箭头宽度
			var mh:int = 4;//箭头高度
			var ax:Number = mw*0.5;
			var ox:Number = Base2D.sizeToScreen(offSetSize);
			
			setSizeText(level,memo);
			var tw:Number = level_txt.width + ox//尾巴长度
			var th:Number = level_txt.height;
			level_txt.y = -th-mh+2;

			var lineColor:uint = WallFace2D.lineColor;
			var g:Graphics = this.graphics;
			g.clear();
			g.lineStyle(0,lineColor);
			
			var fillColor:uint = 0xffffff;
			//g.beginFill(fillColor);
			
			if(direct=="left")
			{
				var tx:Number = -(tw+ax);
				level_txt.x = tx;
				
				g.moveTo(tx,-mh);
				g.lineTo(-ax,-mh);
				
				g.lineTo(ax,-mh);
				g.lineTo(0,0);
				g.lineTo(-ax,-mh);
				
				g.moveTo(ax,0);
				g.lineTo(-ax,0);
			}
			else
			{
				level_txt.x = ax + ox;
				
				g.moveTo(tw+ax,-mh);
				g.lineTo(ax,-mh);
				
				g.lineTo(-ax,-mh);
				g.lineTo(0,0);
				g.lineTo(ax,-mh);
				
				g.moveTo(-ax,0);
				g.lineTo(ax,0);
			}
			//g.endFill();
		}
		
		private function setSizeText(level:int,memo:String):void
		{
			level_txt.text = String(level)+memo;
			var tmp:Number = level_txt.textWidth;
			tmp = level_txt.textHeight;
			tmp = level_txt.width;
			tmp = level_txt.height;
			level_txt.width = level_txt.textWidth + 5;
			level_txt.height = level_txt.textHeight + 4;
			level_txt.textColor = WallFace2D.lineColor;
			level_txt.align = TextFormatAlign.CENTER;
		}
	}
}














