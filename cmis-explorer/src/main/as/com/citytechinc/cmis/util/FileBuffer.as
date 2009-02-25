package com.citytechinc.cmis.util
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	
	public class FileBuffer
	{
		
		private var file:File;
		
		public function FileBuffer(file:File)
		{
			this.file = file;
		}
		
		public function write(event:Event):void 
		{
			var loader:URLLoader = URLLoader(event.target);
			
			var fileStream:FileStream = new FileStream();

			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(loader.data);			
			fileStream.close();
		}

	}
	
}