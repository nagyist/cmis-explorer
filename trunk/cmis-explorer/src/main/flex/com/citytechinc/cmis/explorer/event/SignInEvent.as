package com.citytechinc.cmis.explorer.event
{
	import flash.events.Event;
	
	public class SignInEvent extends Event
	{
		public static const SUCCESS:String = "signInSuccess";
		public static const FAILURE:String = "signInFailure";
		
		public var authenticated:Boolean;
		
		public function SignInEvent(type:String, authenticated:Boolean)
		{
			super(type);
			
			this.authenticated = authenticated;
		}
		
		override public function clone():Event
		{
			return new SignInEvent(type, authenticated);
		}

	}
}