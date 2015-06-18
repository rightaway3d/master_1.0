package rightaway3d
{
	import away3d.textures.ATFTexture;

	public final class Common
	{
		[Embed(source="/normal.atf",mimeType="application/octet-stream")]
		private static var NormalTexture:Class;
		
		private var normalTexture:ATFTexture;
		
		public function getNormalTexture(useShared:Boolean=true):ATFTexture
		{
			if(useShared)
			{
				normalTexture ||= new ATFTexture(new NormalTexture());
				return normalTexture;
			}
			return new ATFTexture(new NormalTexture());
		}
		
		static private var instance:Common;
		
		static public function getInstance():Common
		{
			instance ||= new Common();
			return instance;
		}
		
		public function Common()
		{
		}
	}
}