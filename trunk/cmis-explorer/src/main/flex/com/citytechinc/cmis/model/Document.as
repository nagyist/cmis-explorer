package com.citytechinc.cmis.model
{
	import mx.collections.ArrayCollection;
	
	public class Document
	{
		private namespace app = "http://www.w3.org/2007/app";
		private namespace atom = "http://www.w3.org/2005/Atom";
		private namespace cmis = "http://www.cmis.org/2008/05";
		
		use namespace app;
        use namespace atom;
        use namespace cmis;
		
		public var name:String;
		public var fileName:String;
		public var url:String;
		
		[Bindable] public var checkedOut:Boolean;
		
		[Bindable] public var properties:ArrayCollection;
		
		public function Document()
		{
			properties = new ArrayCollection();
		}
		
		public static function getDocument(d:XML):Document 
		{
			// not sure if I want this method on the Document class or not
			var doc:Document = new Document();
			
			doc.name = d.title;
			doc.fileName = d.object.properties.propertyString.(@name=='ContentStreamFilename').value;
			doc.url = d.object.properties.propertyString.(@name=='ContentStreamURI').value;
			
			var co:String = d.object.properties.propertyBoolean.(@name=='IsVersionSeriesCheckedOut').value;
			
			if (co == "true")
				doc.checkedOut = true;
			else
				doc.checkedOut = false;
			
			for each(var p:XML in d.object.properties.children()) 
			{
				var prop:Property = new Property();
			
				prop.name = p.@name;
				prop.value = p.value;
				
				doc.properties.addItem(prop);
			}
			
			return doc;
		}

	}
	
}