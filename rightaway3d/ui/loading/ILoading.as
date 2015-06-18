package rightaway3d.ui.loading
{
	public interface ILoading
	{
		function showInfo(str:String,mode:String="add"):void;
		
		function get progress():Number;
		
		function set progress(percent:Number):void;
		
		function showBackground(value:Boolean):void;
		
		function startProgress():void;
		
		function endProgress():void;
				
		function setViewSize(w:int,h:int):void;
	}
}