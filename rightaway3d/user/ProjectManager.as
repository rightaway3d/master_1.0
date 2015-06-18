package rightaway3d.user
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import rightaway3d.URLTool;
	
	[Event(name="project_list_loaded", type="flash.events.Event")]
	
	[Event(name="save_complete", type="flash.events.Event")]

	public class ProjectManager extends EventDispatcher
	{
		public var user:User;
		
		private var projects:Vector.<Project> = new Vector.<Project>();
		
		public var currProject:Project;
		
		//=========================================================================================
		public function createProject(name:String,data:String,bmd2d:BitmapData,bmd3d:BitmapData):void
		{
			currProject = new Project();
			currProject.name = name;
			
			projects.push(currProject);
			
			saveProject(data,bmd2d,bmd3d);
		}
		
		public function saveProject(data:String,bmd2d:BitmapData,bmd3d:BitmapData):void
		{
			currProject.projectData = data;
			currProject.setImage2D(bmd2d);
			currProject.setImage3D(bmd3d);
			
			uploadImage(currProject.image2dData);
		}
		
		private function uploadImage(data:ByteArray):void
		{
			URLTool.CallRemote("upload",null,onUploaded,onUploadError,data);
		}
		
		private function onUploadError(result:*):void
		{
			trace("UploadError:"+result);
		}
		
		private function onUploaded(result:*):void
		{
			trace("onUploaded");
			
			var id:String = String(result);
			
			if(currProject.image2dData)
			{
				currProject.image2dID = id;
				currProject.image2dData = null;
				
				uploadImage(currProject.image3dData);
			}
			else if(currProject.image3dData)
			{
				currProject.image3dID = id;
				currProject.image3dData = null;
				
				updateProject();
			}
		}
		
		private function updateProject():void
		{
			var o:Object = {
				casename:currProject.name,
				casedata:currProject.projectData,
				image2did:currProject.image2dID,
				image3did:currProject.image3dID};
			
			if(currProject.id)
			{
				o.caseid = currProject.id;
				URLTool.CallRemote("saveCase",o,onSaveProject,onSaveError);
			}
			else
			{
				o.userid = user.userID;
				URLTool.CallRemote("createCase",o,onCreateProject,onSaveError);
			}
		}
		
		private function onSaveError(result:*):void
		{
			trace("SaveError:"+result);
		}
		
		private function onSaveProject(result:*):void
		{
			trace("onSaveProject:"+result);
			
			if(this.hasEventListener("save_complete"))this.dispatchEvent(new Event("save_complete"));
		}
		
		private function onCreateProject(result:*):void
		{
			//trace("onCreateProject:"+result);
			currProject.id = result;
			
			onSaveProject(result);
		}
		
		
		/*public function saveProject(data:String,bmd2d:BitmapData,bmd3d:BitmapData):void
		{
			_saveProject(data,bmd2d,bmd3d);
		}*/
		
		public function deleteProject():void
		{
			
		}
		
		//=========================================================================================
		public function loadProjectList():void
		{
			var o:Object = {userid:user.userID};
			//var o:Object = {userid:1};
			URLTool.CallRemote("getCaseList",o,onGetProjectList,onError);
		}
		
		//[{"id":"1","userid":"1","casename":"asdfasdf","image2did":"7","image3did":"8",
		//"image2dURL":"\/Public\/2015-01-08\/14207141667422.jpg",
		//"image3dURL":"\/Public\/2015-01-08\/14207143064808.png"}]
		private function onGetProjectList(result:*):void
		{
			trace("onGetProjectList:"+result);
			var o:Object = JSON.parse(result);
			
			var list:Array = o as Array;
			trace(list);
			
			for each(var p:Object in list)
			{
				//caseID,image2dURL,image3dURL
				var id:String = p.caseID;
				if(!currProject || currProject.id!=id)
				{
					var pj:Project = new Project();
					pj.id = id;
					pj.image2dURL = String(p.image2dURL).slice(1);
					pj.image3dURL = String(p.image3dURL).slice(1);
					trace("image2dURL:"+pj.image2dURL);
					trace("image3dURL:"+pj.image3dURL);
				}
			}
			
			if(this.hasEventListener("project_list_loaded"))this.dispatchEvent(new Event("project_list_loaded"));
		}
		
		//=========================================================================================
		
		private function onError(result:Object):void
		{
			//showTips("调用接口失败");
			trace("ProjectManager onError:"+result);
		}
		
		//--------------------------------------------------------------------------
		private function showTips(s:String):void
		{
			trace(s);
		}
		
		//=========================================================================================
		/*private static var _own:ProjectManager;
		//--------------------------------------------------------------------------
		public static function get own():ProjectManager
		{
			return _own ||= new ProjectManager();
		}*/
		
		//--------------------------------------------------------------------------
		public function ProjectManager(user:User)
		{
			this.user = user;
		}
		//=========================================================================================
	}
}