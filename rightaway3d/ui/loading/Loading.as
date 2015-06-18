package rightaway3d.ui.loading
{
	import flash.display.MovieClip;
	import flash.text.TextField;

	public class Loading extends MovieClip implements ILoading
	{
		public var bg_mc:MovieClip;
		public var progress_mc:MovieClip;
		
		public var progress_txt:TextField;
		public var info_txt:TextField;
		
		private var _progress:Number;
		
		public function Loading()
		{
		}
		
		public function showInfo(str:String,mode:String="add"):void
		{
			if(info_txt)
			{
				if(mode=="add")
				{
					info_txt.appendText(str+"\n");
				}
				else
				{
					info_txt.text = str;
				}
			}
		}
		
		public function get progress():Number
		{
			return _progress;
		}
		
		public function set progress(percent:Number):void
		{
			var n:Number = percent<0?0:percent>100?100:percent;
			_progress = n;
			//trace("setProgress:"+n);
			if(progress_txt)progress_txt.text = n.toFixed(1)+"%";
			if(progress_mc)progress_mc.gotoAndStop(int(n)+1);
		}
		
		public function showBackground(value:Boolean):void
		{
			if(bg_mc)bg_mc.visible = value;
		}
		
		public function startProgress():void
		{
		}
		
		public function endProgress():void
		{
		}
		
		public function setViewSize(w:int,h:int):void
		{
			if(bg_mc)
			{
				bg_mc.width = w;
				bg_mc.height = h;
			}
			
			if(progress_txt)
			{
				progress_txt.x = (w-progress_txt.width)/2;
				progress_txt.y = (h-progress_txt.height)/2;
				if(progress_mc)
				{
					progress_mc.x = (w-progress_mc.width)/2;
					progress_mc.y = progress_txt.y + progress_txt.height * 1.5;
				}
			}			
			else if(progress_mc)
			{
				progress_mc.x = (w-progress_mc.width)/2;
				progress_mc.y = (h-progress_mc.height)/2;
			}
		}
	}
}