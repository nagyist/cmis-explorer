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
			var prop:Property = new Property();
			
			prop.name = n.localName();
			prop.value = n.text();
			
			return prop;
		}

	}
	
}