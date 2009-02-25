package com.citytechinc.cmis.event
{
	import flash.events.Event;

	public class SearchEvent extends Event
	{
		public static const SUBMIT:String = "search";
		
		public var query:String;
		
		public function SearchEvent(type:String, query:String)
		{
			super(type);
			
			this.query = query;
		}
		
		override public function clone():Event 
		{
			return new SearchEvent(type, query);
		}
		
	}
	
}