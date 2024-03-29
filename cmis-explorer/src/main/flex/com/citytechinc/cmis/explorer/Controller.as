package com.citytechinc.cmis.explorer
{
	import org.apache.chemistry.atompub.client.event.RepositoryInfoEvent;
	import org.apache.chemistry.atompub.client.model.Repository;
	import org.apache.chemistry.atompub.client.service.RepositoryInfoService;
	import org.apache.chemistry.util.Encoder;
	import com.citytechinc.cmis.explorer.event.SignInEvent;
	
	import flash.events.EventDispatcher;
	
	public class Controller extends EventDispatcher
	{
		[Bindable] public var auth:String;
		
		[Bindable] public var username:String;
		
		[Bindable] public var repository:Repository;
		
		public function Controller()
		{
		}
		
		public function setAuth(user:String, pass:String, url:String):void
		{
			auth = Encoder.getAuth(user, pass);
			username = user;
			
			var repoInfoClient:RepositoryInfoService = new RepositoryInfoService(auth);
			
			repoInfoClient.addEventListener(RepositoryInfoEvent.INFO, setRepository);
			repoInfoClient.addEventListener(RepositoryInfoEvent.ERROR, repositoryError);
			
			repoInfoClient.requestRepositoryInfo(url);
		}
		
		private function setRepository(event:RepositoryInfoEvent):void
		{
			repository = event.repository;
			
			this.dispatchEvent(new SignInEvent(SignInEvent.SUCCESS, true));
		}
		
		private function repositoryError(event:RepositoryInfoEvent):void
		{
			this.dispatchEvent(new SignInEvent(SignInEvent.FAILURE, true));
		}		

	}
	
}