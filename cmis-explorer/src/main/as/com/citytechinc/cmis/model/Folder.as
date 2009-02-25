package com.citytechinc.cmis.model
{
	import mx.collections.ArrayCollection;
	
	public class Folder
	{
		private namespace app = "http://www.w3.org/2007/app";
		private namespace atom = "http://www.w3.org/2005/Atom";
		private namespace cmis = "http://www.cmis.org/2008/05";
		
		use namespace app;
        use namespace atom;
        use namespace cmis;
		
		public var name:String;
		public var childrenURL:String;
		
		public var opened:Boolean = false;
		
		[Bindable] public var children:ArrayCollection;
		[Bindable] public var documents:ArrayCollection;
		
		public function Folder()
		{
			children = new ArrayCollection();
			documents = new ArrayCollection();
		}
		
		public static function getFolder(f:XML):Folder 
		{
			var folder:Folder = new Folder();
			
			folder.name = f.title;
			folder.childrenURL = f.link.(@rel=='cmis-children').@href;
			
			return folder;
		}

	}
	
}