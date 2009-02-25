package com.citytechinc.cmis.util
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Encoder;
	
	public class Encoder
	{
		private static var MAX:int = 30000;
		
		public function Encoder()
		{
		}
		
		public static function getString(file:File):String 
		{
			var bytes:ByteArray = new ByteArray();
		
			var fileStream:FileStream = new FileStream();
			
			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(bytes, fileStream.position, fileStream.bytesAvailable);
			fileStream.close();
			
			var encoder:Base64Encoder = new Base64Encoder();
			
			var content:String = new String();
			
			var byteArrLen:int = bytes.length;
			var position:int = 0;
	
			while (position < byteArrLen) 
			{
				
				if (position + Encoder.MAX < byteArrLen) 
				{
					encoder.encodeBytes(bytes, position, position + Encoder.MAX);
				
					position = position + Encoder.MAX			}
				else 
				{
					encoder.encodeBytes(bytes, position, byteArrLen);
			
					position = byteArrLen;
				}
				
				content = content + encoder.toString();

			}
			
			return content;
		}

	}
	
}