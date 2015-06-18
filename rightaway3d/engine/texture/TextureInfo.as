package rightaway3d.engine.texture
{
	import flash.display.Bitmap;
	import flash.utils.ByteArray;
	
	import away3d.textures.ATFTexture;
	import away3d.textures.BitmapTexture;
	
	import rightaway3d.engine.material.MaterialInfo;
	import rightaway3d.engine.utils.BMP;

	public class TextureInfo
	{
		public var fileURL:String;
		public var fileData:ByteArray;
		public var fileType:String;
		public var bitmap:Bitmap;
		
		public var textureType:String;
		
		public var materialInfo:MaterialInfo;
		
		public function onReady():void
		{
			if(fileType=="bitmap")
			{
				materialInfo.material[textureType] = new BitmapTexture(BMP.scaleBmpData(bitmap.bitmapData));
			}
			else if(fileType=="atf")
			{
				materialInfo.material[textureType] = new ATFTexture(fileData);
			}
		}
		
		public function TextureInfo()
		{
		}
	}
}