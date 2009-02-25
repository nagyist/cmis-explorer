package com.citytechinc.cmis.model
{
	
	public class Property
	{	
		public var name:String;
		public var value:String;
		
		public function Property()
		{
		}
		
		public static function getProperty(n:XML):Property
		{
			// not sure if I want this method on the Property class or not
			var prop:Property = new Property();
			
			prop.name = n.localName();
			prop.value = n.text();
			
			return prop;
		}

	}
	
}