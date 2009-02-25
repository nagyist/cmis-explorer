package com.citytechinc.cmis
{
	import com.citytechinc.cmis.event.AuthenticationEvent;
	import com.citytechinc.cmis.event.SearchEvent;
	import com.citytechinc.cmis.event.SignInEvent;
	import com.citytechinc.cmis.model.Document;
	import com.citytechinc.cmis.model.Folder;
	import com.citytechinc.cmis.model.Property;
	import com.citytechinc.cmis.model.Type;
	import com.citytechinc.cmis.util.Encoder;
	import com.citytechinc.cmis.util.FileBuffer;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeDragOptions;
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.List;
	import mx.controls.Tree;
	import mx.events.DragEvent;
	import mx.events.ListEvent;
	import mx.events.TreeEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.Base64Encoder;
	
	public class Repository extends EventDispatcher
	{
		private namespace app = "http://www.w3.org/2007/app";
		private namespace atom = "http://www.w3.org/2005/Atom";
		private namespace cmis = "http://www.cmis.org/2008/05";
		
		use namespace app;
        use namespace atom;
        use namespace cmis;
        
		private var queryURL:String;
		private var typesURL:String;
		private var rootFolderURL:String;
		
		private var auth:String;
		
		private var currentFolder:Folder;
		
		private var tree:Tree;
		
		private var docs:Array;
		
		[Bindable] public var properties:ArrayCollection;
		[Bindable] public var capabilities:ArrayCollection;
		[Bindable] public var types:ArrayCollection;
		[Bindable] public var folders:ArrayCollection;
		[Bindable] public var queryResults:ArrayCollection;
		
		public function Repository()
		{
			properties = new ArrayCollection();
			capabilities = new ArrayCollection();
			types = new ArrayCollection();			
		}
		
		public function authenticate(event:SignInEvent):void
		{
			this.auth = getAuth(event.user, event.pass);
			
			var service:HTTPService = new HTTPService();

			service.url = event.url;
			service.resultFormat = "e4x";
			service.addEventListener(ResultEvent.RESULT, setRepositoryInfo)
			service.headers["Authorization"] = "Basic " + this.auth;
			
			service.send();
		}
		
		private function getAuth(user:String, pass:String):String
		{
			var encoder:Base64Encoder = new Base64Encoder();

			encoder.encode(user + ":" + pass);
			
			var auth:String = encoder.toString();
			
			return auth;
		}
		
		private function setRepositoryInfo(event:ResultEvent):void
		{
			for each(var p:XML in event.result.workspace.repositoryInfo.children())
				if (p.hasSimpleContent())
					this.properties.addItem(Property.getProperty(p));
			
			for each(var c:XML in event.result.workspace.repositoryInfo.capabilities.children()) 
				this.capabilities.addItem(Property.getProperty(c));
				
			this.queryURL = event.result.workspace.collection.(@collectionType=='query').@href;
			
			this.rootFolderURL = event.result.workspace.collection.(@collectionType=='root-children').@href;
			this.typesURL = event.result.workspace.collection.(@collectionType=='types-descendants').@href;
			
			this.getTypes();
			this.getFolder(rootFolderURL);
			
			this.dispatchEvent(new AuthenticationEvent(AuthenticationEvent.COMPLETE, true));
		}
		
		private function getTypes():void 
		{
			var service:HTTPService = new HTTPService();

			service.url = this.typesURL;
			service.resultFormat = "e4x";
			service.addEventListener(ResultEvent.RESULT, this.setTypes)
			service.headers["Authorization"] = "Basic " + this.auth;
			
			service.send();
		}
		
		private function setTypes(event:ResultEvent):void 
		{
			
			for each(var t:XML in event.result.entry) 
			{
				var type:Type = new Type();
				
				type.name = t.title;
					
				for each(var dp:XML in t.documentType.children())
					type.properties.addItem(Property.getProperty(dp));
				
				for each(var fp:XML in t.folderType.children())
					type.properties.addItem(Property.getProperty(fp));
				
				for each(var rp:XML in t.relationshipType.children())
					type.properties.addItem(Property.getProperty(rp));
				
				types.addItem(type);
			}
			
		}
		
		public function getCurrentFolder():void
		{
			getFolder(Folder(tree.selectedItem).childrenURL);
		}
		
		public function getFolders(event:TreeEvent):void 
		{
			tree = Tree(event.target);
			currentFolder = Folder(event.item);
				
			if (!currentFolder.opened)
				getFolder(currentFolder.childrenURL);
		}
		
		public function getDocuments(event:ListEvent):void 
		{
			tree = Tree(event.currentTarget);
			currentFolder = Folder(tree.selectedItem);
				
			if (!currentFolder.opened)
				getFolder(currentFolder.childrenURL);
		}
		
		private function getFolder(url:String):void
		{
			var service:HTTPService = new HTTPService();

			service.url = url;
			service.resultFormat = "e4x";
			service.addEventListener(ResultEvent.RESULT, setFolder);
			service.headers["Authorization"] = "Basic " + auth;
			
			service.send();
		}
		
		private function setFolder(event:ResultEvent):void 
		{
			var tmpFolders:ArrayCollection = new ArrayCollection();
			var tmpDocs:ArrayCollection = new ArrayCollection();
			
			for each (var f:XML in event.result.entry) 
			{
				if (f.object.properties.propertyString.(@name=='BaseType').value == "folder") 
					tmpFolders.addItem(Folder.getFolder(f));
				else
					tmpDocs.addItem(Document.getDocument(f));
			}
			
			if (folders == null)
				folders = tmpFolders;			
			else 
			{			
				currentFolder.opened = true;
				
				// interesting.
				// when i add the folders using currentFolder.children.addItem, the tree does not reflect the changes.
				// when i add the folder by setting the entire collection ,the tree does reflect the changes.
				currentFolder.children = tmpFolders;
				currentFolder.documents = tmpDocs;
			}
			
		}
		
		public function getQueryResults(event:SearchEvent):void 
		{			
			var queryStmt:String = event.query;
		
			var query:XML = 
				<cmis:query xmlns:cmis="http://www.cmis.org/2008/05" 
						xmlns:p="http://www.w3.org/1999/xhtml" 
						xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
						xsi:schemaLocation="http://www.cmis.org/2008/05 CMIS.xsd ">
		  			<cmis:statement>{queryStmt}</cmis:statement>
		  			<cmis:searchAllVersions>true</cmis:searchAllVersions>
		  			<cmis:pageSize>0</cmis:pageSize>
		  			<cmis:skipCount>0</cmis:skipCount>
		  			<cmis:returnAllowableActions>false</cmis:returnAllowableActions>
				</cmis:query>;
			
			var request:URLRequest = new URLRequest(this.queryURL);

			request.data = query;
			request.contentType = "application/cmisquery+xml";
			request.method = URLRequestMethod.POST;
			
			var header:URLRequestHeader;

            header = new URLRequestHeader("Authorization", "Basic " + this.auth);
            
            request.requestHeaders.push(header);

			var loader:URLLoader = new URLLoader();

			loader.addEventListener(Event.COMPLETE, setQueryResults);
			loader.load(request); 
		}
		
		private function setQueryResults(event:Event):void 
		{
			var loader:URLLoader = URLLoader(event.target);

			var resultXML:XML = new XML(loader.data);
			
			var results:ArrayCollection = new ArrayCollection();
			
			for each (var d:XML in resultXML.entry)
				results.addItem(Document.getDocument(d));
				
			this.queryResults = results;
		}
		
		public function downloadFiles(event:DragEvent):void 
		{
			this.docs = List(event.target).selectedItems;
				
			var clip:Clipboard = new Clipboard();

			clip.setDataHandler(ClipboardFormats.FILE_LIST_FORMAT, getDownloadFiles);

			var dragOptions:NativeDragOptions = new NativeDragOptions();

			dragOptions.allowCopy = true;
			dragOptions.allowLink = true;
			dragOptions.allowMove = false;

			NativeDragManager.doDrag(event.currentTarget as InteractiveObject, clip, null, null, dragOptions);
		}
		
		private function getDownloadFiles():Array 
		{
			var files:Array = new Array();
			
			for (var i:int = 0; i < this.docs.length; i++) 
			{
				var doc:Document = Document(this.docs[i]);
			
				var request:URLRequest = new URLRequest(doc.url);
				
				var header:URLRequestHeader;
	
	            header = new URLRequestHeader("Authorization", "Basic " + this.auth);
	            
	            request.requestHeaders.push(header);
	            
	            var file:File = File.createTempDirectory().resolvePath(doc.fileName);
	            
	            var buffer:FileBuffer = new FileBuffer(file);
	
				var loader:URLLoader = new URLLoader();
				
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, buffer.write);
				loader.load(request);
	
				files.push(file);
			}
			
			return files;
		}
		
		public function getUploadFiles(event:NativeDragEvent):void 
		{
			if (event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
				NativeDragManager.acceptDragDrop(event.currentTarget as InteractiveObject);
		}
		
		public function uploadFiles(event:NativeDragEvent):void 
		{
			var bytes:ByteArray = new ByteArray();

			var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			
			for (var i:int = 0; i < files.length; i++) 
			{
				var file:File = files[i] as File;
	
				var content:String = Encoder.getString(file);
				
				var msg:XML = 
					<entry xmlns="http://www.w3.org/2005/Atom" xmlns:cmis="http://www.cmis.org/2008/05">
						<title>{file.name}</title>
						<content type="application/octet-stream">{content}</content>
						<cmis:object>
							<cmis:properties>
								<cmis:propertyString cmis:name="ObjectTypeId"><cmis:value>document</cmis:value></cmis:propertyString>
							</cmis:properties>
						</cmis:object>
					</entry>
				
				var request:URLRequest = new URLRequest(Folder(this.tree.selectedItem).childrenURL);
	
				request.data = msg;
				request.contentType = "application/atom+xml;type=entry";
				request.method = URLRequestMethod.POST;
				
				var header:URLRequestHeader;
	
	            header = new URLRequestHeader("Authorization", "Basic " + this.auth);
	            
	            request.requestHeaders.push(header);
	
				var loader:URLLoader = new URLLoader();
	
				loader.addEventListener(Event.COMPLETE, this.getCurrentFolder);
				loader.load(request);
			}
			
		}

	}
	
}