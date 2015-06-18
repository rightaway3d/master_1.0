package rightaway3d.engine.scene
{
	import flash.display.Sprite;
	
	import away3d.containers.View3D;

	/**
	 * 
	 * Scene功能：3D场景的建立，实时渲染控制，模型的添加与删除，灯光的添加与删除
	 * 
	 * @author Jell
	 * 
	 */
	public class Scene
	{
		private var view:View3D;
		private var viewContainer:Sprite;
		
		public function Scene(viewContainer:Sprite)
		{
			this.viewContainer = viewContainer;
			this.view = new View3D();
			viewContainer.addChild(this.view);
		}
	}
}