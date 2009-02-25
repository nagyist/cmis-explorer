package com.citytechinc.cmis.event
{
	import flash.events.Event;
	
	public class AuthenticationEvent extends Event
	{
		public static const COMPLETE:String = "complete";
		
		public var authenticated:Boolean;
		
		public function AuthenticationEvent(type:String, authenticated:Boolean)
		{
			super(type);
			
			this.authenticated = authenticated;
		}
		
		override public function clone():Event
		{
			return new AuthenticationEvent(type, authenticated);
		}

	}
}