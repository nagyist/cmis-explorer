package com.citytechinc.cmis.event
{
	import flash.events.Event;

	public class SignInEvent extends Event
	{
		public static const SUBMIT:String = "signIn";
		
		public var user:String;
		public var pass:String;
		public var url:String;
		
		public function SignInEvent(type:String, user:String, pass:String, url:String)
		{
			super(type);
			
			this.user = user;
			this.pass = pass;
			this.url = url;
		}
		
		override public function clone():Event 
		{
			return new SignInEvent(type, user, pass, url);
		}
		
	}
	
}