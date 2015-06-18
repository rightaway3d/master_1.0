package rightaway3d.engine.material
{
	import away3d.materials.MaterialBase;
	
	import rightaway3d.engine.texture.TextureInfo;
	import rightaway3d.engine.texture.TextureLoader;

	public class MaterialInfo
	{
		public var material:MaterialBase;
		
		public function MaterialInfo(material:MaterialBase,textureURL:String,normalMapURL:String=null,specularMapURL:String=null)
		{
			this.material = material;
			
			var loader:TextureLoader = TextureLoader.own;
			loader.addTextureInfo(getTextureInfo(textureURL,"texture"));
			if(normalMapURL)loader.addTextureInfo(getTextureInfo(normalMapURL,"normalMap"));
			if(specularMapURL)loader.addTextureInfo(getTextureInfo(specularMapURL,"specularMap"));
			loader.startLoad();
		}
		
		private function getTextureInfo(url:String,type:String):TextureInfo
		{
			var t:TextureInfo = new TextureInfo();
			t.fileURL = url;
			t.textureType = type;
			t.materialInfo = this;
			if(url.slice(-4).toLocaleLowerCase()==".atf")
			{
				t.fileType = "atf";
			}
			else
			{
				t.fileType = "bitmap";
			}
			return t;
		}
	}
}