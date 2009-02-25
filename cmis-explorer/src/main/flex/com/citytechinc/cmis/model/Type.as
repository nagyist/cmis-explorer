package com.citytechinc.cmis.model
{
	import mx.collections.ArrayCollection;
	
	public class Type
	{
		public var name:String;
		
		[Bindable] public var properties:ArrayCollection;
		
		public function Type()
		{
			properties = new ArrayCollection();
		}

	}
	
}