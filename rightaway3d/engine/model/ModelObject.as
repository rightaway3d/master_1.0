package rightaway3d.engine.model
{
	import flash.utils.Dictionary;
	
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.sea3d.animation.MeshAnimation;
	
	import rightaway3d.engine.animation.AnimationAction;
	import rightaway3d.engine.product.ProductObject;
	
	import sunag.animation.Animation;
	import sunag.animation.AnimationPlayer;

	public class ModelObject
	{
		public var id:String = "0";
		
		public var objectID:String;
		
		public var modelInfo:ModelInfo;
		
		public var parentProductObject:ProductObject;
		
		//public var modelMesh:Mesh;
		public var meshs:Vector.<Mesh>;
		public var materials:Vector.<MaterialBase>;
		public var seaAnimations:Vector.<Animation>;
		public var animPlayer:AnimationPlayer;
		
		public var animationActions:Vector.<AnimationAction>;

		public function ModelObject()
		{
		}
		
		public function dispose():void
		{
			if(meshs)
			{
				for each(var mesh:Mesh in meshs)
				{
					mesh.disposeWithAnimatorAndChildren();
				}
				meshs = null;
			}
			
			materials = null;
			
			seaAnimations = null;
			animationActions = null;
			animPlayer = null;
			parentProductObject = null;
			
			modelInfo.removeModelObject(this);
			modelInfo = null;
		}
		
		public function getMeshByName(meshName:String):Mesh
		{
			if(meshs)
			{
				for each(var m:Mesh in meshs)
				{
					if(m.name==meshName)
					{
						return m;
					}
				}
			}
			return null;
		}
		
		public function getMaterialByName(materialName:String):MaterialBase
		{
			if(materials)
			{
				for each(var m:MaterialBase in materials)
				{
					if(m.name==materialName)
					{
						return m;
					}
				}
			}
			return null;
		}
		
		/*public function offsetMesh(offset:Vector3D):void
		{
			var len:int = meshs.length;
			for(var i:int=0;i<len;i++)
			{
				var m:Mesh = meshs[i];
				
				if(len>1)
				{
					m.x -= offset.x;
					m.y -= offset.y;
					m.z -= offset.z;
				}
				else
				{
					m.x = -offset.x;
					m.y = -offset.y;
					m.z = -offset.z;
				}
			}
		}*/
		
		
		private function cloneMeshs(modelInfo:ModelInfo):void
		{
			if(!modelInfo.meshs)return;
			
			//var offset:Vector3D = modelInfo.centerOffset;
			var resMeshs:Vector.<Mesh> = modelInfo.meshs;
			var len:int = resMeshs.length;
			
			var meshDict:Dictionary = new Dictionary();
			
			meshs = new Vector.<Mesh>(len);
			for(var i:int=0;i<len;i++)
			{
				var m1:Mesh = resMeshs[i];
				var m2:Mesh = m1.clone() as Mesh;
				meshs[i] = m2;
				meshDict[m1] = m2;
			}
			
			//offsetMesh(offset);
			
			if(modelInfo.seaAnimations && modelInfo.seaAnimations.length>0)
			{
				seaAnimations = new Vector.<Animation>();
				
				for each(var ani:Animation in modelInfo.seaAnimations)
				{
					if(ani is MeshAnimation)
					{
						var manm:MeshAnimation = ani as MeshAnimation;
						var m:Mesh = meshDict[manm.mesh];//找出相应Mesh所克隆出来的Mesh
						var anm:MeshAnimation = new MeshAnimation(manm.animationSet,m);
						anm.name = manm.name;
						anm.autoUpdate = manm.autoUpdate;
						anm.blendMethod = manm.blendMethod;
						anm.relative = manm.relative;
						seaAnimations.push(anm);
					}
				}
			}
		}
		
		
		private function cloneAnimationActions(modelInfo:ModelInfo):void
		{
			if(modelInfo.animationActions)
			{
				var len:int = modelInfo.animationActions.length;
				this.animationActions = new Vector.<AnimationAction>(len);
				for(var i:int=0;i<len;i++)
				{
					animationActions[i] = modelInfo.animationActions[i].clone();
					animationActions[i].modelObject = this;
				}
			}
		}
		
		public function initAnimationPlayer():void
		{
			if(seaAnimations && seaAnimations.length>0)
			{
				animPlayer = new AnimationPlayer();
				for each(var ani:Animation in seaAnimations)
				{
					animPlayer.addAnimation(ani);
				}
			}
			
		}
		
		public function cloneFromInfo():void
		{
			cloneMeshs(modelInfo);//复制模型到此实例中
			initAnimationPlayer();
			cloneAnimationActions(modelInfo);//复制动作到此实例中
			
			//当父产品没有自定义材质时，使用模型默认材质
			if(!this.parentProductObject.customMaterial)
			{
				materials = modelInfo.materials;
			}
			else
			{
				this.parentProductObject.setCustomMaterial();
			}
			//meshs[0].material = materials[0];
		}
		
		
		/*private var aniCtrl:AnimationController = new AnimationController();
		
		private function play1():void
		{
			trace("play1");
			//var aniCtrl:AnimationController = new AnimationController();
			//aniCtrl.setCurrObject(this);
			aniCtrl.play(0,99,1,30,play2);
		}
		
		private function play2():void
		{
			trace("play2");
			//var aniCtrl:AnimationController = new AnimationController();
			//aniCtrl.setCurrObject(this);
			aniCtrl.play(100,1,1,30,play1);
		}*/
		
	}
}