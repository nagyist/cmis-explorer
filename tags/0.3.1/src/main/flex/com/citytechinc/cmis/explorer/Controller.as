package com.citytechinc.cmis.explorer
{
	import com.citytechinc.cmis.client.event.RepositoryInfoEvent;
	import com.citytechinc.cmis.client.model.Repository;
	import com.citytechinc.cmis.client.service.RepositoryInfoService;
	import com.citytechinc.cmis.explorer.event.SignInEvent;
	import com.citytechinc.cmis.util.Encoder;
	
	import flash.events.EventDispatcher;
	
	public class Controller extends EventDispatcher
	{
		[Bindable] public var auth:String;
		
		[Bindable] public var repository:Repository;
		
		public function Controller()
		{
		}
		
		public function setAuth(user:String, pass:String, url:String):void
		{
			auth = Encoder.getAuth(user, pass);
			
			var repoInfoClient:RepositoryInfoService = new RepositoryInfoService(auth);
			
			repoInfoClient.addEventListener(RepositoryInfoEvent.INFO, setRepository);
			
			repoInfoClient.getRepositoryInfo(url);
		}
		
		private function setRepository(event:RepositoryInfoEvent):void
		{
			repository = event.repository;
			
			this.dispatchEvent(new SignInEvent(SignInEvent.SUCCESS, true));
		}

	}
	
}