package rightaway3d.engine.parser
{
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.textures.Texture2DBase;
	
	import rightaway3d.engine.model.ModelInfo;
	import rightaway3d.engine.model.ModelInfoLoader;
	import rightaway3d.engine.model.ModelLoader;
	import rightaway3d.engine.model.ModelType;
	import rightaway3d.engine.product.ProductInfoLoader;
	
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	
	import ztc.meshbuilder.room.CubeMesh;
	
	[Event(name="model_parsed", type="flash.events.Event")]
	
	[Event(name="all_model_parsed", type="flash.events.Event")]

	public class ModelParser extends EventDispatcher
	{
		private var needProgress:Boolean = false;//是否需要发布解析进度

		public var currModel:ModelInfo;
		
		private var parseQueue:Array = [];
		
		private var isParsing:Boolean = false;//是否正在解析中
		
		private var currIndex:int = -1;
		
		private var sea3d:SEA3D;
		
		private var modelParsedEvent:Event = new Event("model_parsed");
		
		private var allModelParsedEvent:Event = new Event("all_model_parsed");
		
		public function ModelParser()
		{
		}
		
		public function addModel(model:ModelInfo,autoParse:Boolean):void
		{
			//trace("ModelParser addModel:"+model.modelFileURL);
			parseQueue.push(model);
			
			if(autoParse && !isParsing)parseNext();
		}
		
		public function clear():void
		{
			isParsing = false;
			parseQueue.length = 0;
			currIndex = -1;
		}
		
		public function startParse():void
		{
			if(!isParsing)parseNext();
		}
		
		private function parseNext():void
		{
			//trace("ModelParser parseNext");
			var len:int = parseQueue.length;
			if(len>0 && currIndex+1<len)
			{
				if(!needProgress)//不需要发布解析进度
				{
					currIndex = -1;
					currModel = parseQueue.shift();
				}
				else//需要发布解析进度
				{
					currModel = parseQueue[++currIndex];
				}
				
				parse(currModel);
			}
			else if(!ProductInfoLoader.own.hasNotLoaded && !ModelInfoLoader.own.hasNotLoaded && !ModelLoader.own.hasNotLoaded)
			{
				trace("----------所有模型解析完成");
				//发布全部解析完成事件
				this.dispatchEvent(allModelParsedEvent);
			}
		}
		
		private var defcfg:DefaultConfig;
		
		private function parse(model:ModelInfo):void
		{
			//trace("ModelParser parse:"+model.modelFileURL);
			
			isParsing = true;
			var type:String = model.modelType;
			if(type==ModelType.SEA)
			{
				if(!sea3d)
				{
					sea3d = new SEA3D(defcfg||=new DefaultConfig());
					sea3d.addEventListener(SEAEvent.COMPLETE,onSeaComplete);
					sea3d.addEventListener(SEAEvent.PROGRESS,onSeaProgress);
					sea3d.addEventListener(SEAEvent.ERROR,onSeaError);
				}
				else
				{
					//sea3d.dispose();
				}
				
				sea3d.loadBytes(currModel.modelFileData);
			}
			else if(type==ModelType.BOX || type==ModelType.BOX_C)
			{
				parseBox();
			}
			else if(type==ModelType.CYLINDER || type==ModelType.CYLINDER_C)
			{
				parseCylinder();
			}
		}
		
		private function parseBox():void
		{
			//trace("parseBox");
			
			isParsing = false;
			var b:Vector3D = currModel.bounds;
			
			//var dc:int = 0x11 - Math.random()*0x22;
			//dc = currModel.color + dc;
			
			//var mesh:Mesh = new Mesh(new CubeGeometry(b.x,b.y,b.z,1,1,1,false));
			var mesh:Mesh = new CubeMesh(b.x,b.y,b.z);
			currModel.meshs = new Vector.<Mesh>(1);
			currModel.meshs[0] = mesh;
			
			/*if(currModel.materials)
			{
				mesh.material = currModel.materials[0];
			}
			else
			{*/
				var dc:int = currModel.color;
				var m:TextureMaterial = new TextureMaterial();
				m.color = m.ambientColor = dc;
				m.repeat = true;
				m.mipmap = false;
				
				if(currModel.ambient>-1)m.ambient = currModel.ambient;
				if(currModel.specular>-1)m.specular = currModel.specular;
				if(currModel.gloss>-1)m.gloss = currModel.gloss;
				//m.specularMethod
				
				currModel.materials = new Vector.<MaterialBase>(1);
				currModel.materials[0] = m;
				mesh.material = m;
				
				//var mesh:Mesh = new Mesh(new CubeGeometry(b.x,b.y,b.z),m);
			//}
			
			//trace("meshs:"+currModel.meshs.length);
			//trace("materials:"+currModel.materials.length);
			//currModel.seaAnimations = sea3d.animations;
			
			this.dispatchEvent(modelParsedEvent);
			
			parseNext();
		}
		
		private function parseCylinder():void
		{
			//trace("parseBox");
			
			isParsing = false;
			//var dc:int = 0x11 - Math.random()*0x22;
			//dc = currModel.color + dc;
			var dc:int = currModel.color;
			//dc = 0xcccc00;
			//trace("-----------box color:"+dc.toString(16));
			var m:TextureMaterial = new TextureMaterial();
			m.color = m.ambientColor = dc;
			if(currModel.ambient>-1)m.ambient = currModel.ambient;
			if(currModel.specular>-1)m.specular = currModel.specular;
			if(currModel.gloss>-1)m.gloss = currModel.gloss;
			//m.specularMethod
			
			var b:Vector3D = currModel.bounds;
			var r:Number = b.x * 0.5;
			var mesh:Mesh = new Mesh(new CylinderGeometry(r,r,b.y),m);
			
			var ro:Vector3D = currModel.rotation;
			mesh.rotationX = ro.x;
			mesh.rotationY = ro.y;
			mesh.rotationZ = ro.z;
			
			currModel.meshs = new Vector.<Mesh>(1);
			currModel.meshs[0] = mesh;
			
			currModel.materials = new Vector.<MaterialBase>(1);
			currModel.materials[0] = m;
			
			//trace("meshs:"+currModel.meshs.length);
			//trace("materials:"+currModel.materials.length);
			//currModel.seaAnimations = sea3d.animations;
			
			this.dispatchEvent(modelParsedEvent);
			
			parseNext();
		}
		
		protected function onSeaComplete(event:SEAEvent):void
		{
			//trace("onSeaComplete:"+currModel.modelFileURL);
			trace("------Model loaded:"+currModel.modelFileURL+" renderBothSides:"+currModel.renderBothSides);			
			isParsing = false;
			
			var mts:Vector.<MaterialBase> = sea3d.materials;
			
			currModel.meshs = sea3d.meshes;
			currModel.materials = mts;
			
			for each(var mat:MaterialBase in mts)
			{
				mat.smooth = true;
				mat.bothSides = currModel.renderBothSides;
				
				if(mat is SinglePassMaterialBase)
				{
					var spm:SinglePassMaterialBase = SinglePassMaterialBase(mat);
					//trace("specular:"+spm.specular);
					//trace("ambient:"+spm.ambient);
					//trace("gloss:"+spm.gloss);
					if(currModel.specular>-1)spm.specular = currModel.specular;
					if(currModel.ambient>-1)spm.ambient = currModel.ambient;
					if(currModel.gloss>-1)spm.gloss = currModel.gloss;
					//trace("specular2:"+spm.specular);
					//trace("ambient2:"+spm.ambient);
					//trace("gloss2:"+spm.gloss);
					//trace("normalMap:",spm.normalMap);
				}
			}
			
			currModel.seaAnimations = sea3d.animations;
			
			this.dispatchEvent(modelParsedEvent);
			
			parseNext();
		}
		
		protected function onSeaProgress(event:SEAEvent):void
		{
			
		}
		
		protected function onSeaError(event:SEAEvent):void
		{
			trace("---！！！---SEA文件解析失败："+currModel.modelFileURL);
			
			isParsing = false;
			parseNext();
		}
		
		//==================================================
		static private var _own:ModelParser;
		static public function get own():ModelParser
		{
			_own = _own || new ModelParser();
			return _own;
		}
	}
}