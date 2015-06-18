package rightaway3d.engine.animation
{
	import rightaway3d.engine.model.ModelObject;

	public class AnimationAction
	{
		public var name:String;
		public var tips:String;
		public var loop:int;
		public var startFrame:int;
		public var endFrame:int;
		public var dscp:String;
		
		public var modelObject:ModelObject;
		
		public function AnimationAction(xml:XML=null)
		{
			if(xml)
			{
				name = xml.name;
				tips = xml.tips;
				loop = xml.loop;
				startFrame = xml.frame.start;
				endFrame = xml.frame.end;
				dscp = xml.dscp?xml.dscp:"";
			}
		}
		
		public function clone():AnimationAction
		{
			var a:AnimationAction = new AnimationAction();
			a.name = name;
			a.tips = tips;
			a.loop = loop;
			a.startFrame = startFrame;
			a.endFrame = endFrame;
			a.dscp = dscp;
			
			return a;
		}
	}
}