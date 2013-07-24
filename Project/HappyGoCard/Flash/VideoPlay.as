﻿package  {
	import flash.display.Sprite;     
    import flash.media.Video;     
    import flash.net.NetConnection;     
    import flash.net.NetStream;
	import flash.events.NetStatusEvent ;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.display.MovieClip;
	import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
	
	//import caurina.transitions.*; // import the tweener class for our transitions  
	//import caurina.transitions.properties.FilterShortcuts; //  import the tweener filter shortcuts class
	
	//
	// 可撥放 mp4, jpg, png   files repeatly
	public class VideoPlay extends Sprite {
		private var _parentVideoClip: MovieClip;
		private var _parentPictureClip: MovieClip;
        public var _videoObject:Video;
        private var connection:NetConnection = new NetConnection();
        public var _stream:NetStream;
        public var listener:Object = new Object();
        private var _duration:Number = 0; 
		private var _moviePaths: Array;
		private var _currentMovieIndex: int;
		private var _currentPicLoader: Loader;
		private var _currentIsVideo: Boolean;
		private var _adPlaySeconds: int;
		private var _now: Date;
		private var _adStartTime: Date;
		private var _pictureInit_W: int;
		private var _pictureInit_H: int;
			
		public function VideoPlay( videoClip: MovieClip, imageClip: MovieClip, w: int, h: int, sec: int) {
			// costreamtructor code
			_videoObject = new Video(w, h)
			_parentVideoClip = videoClip;
			_parentPictureClip = imageClip;
			_pictureInit_W = _parentPictureClip.width;
			_pictureInit_H = _parentPictureClip.height; 
			_adPlaySeconds = sec;
			_parentVideoClip.addChild(_videoObject);
        	connection.connect(null);
        	_stream = new NetStream(connection);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, myStatusHandler);  //  add a listener to the NetStream to listen for any changes that happen with the NetStream  
        	_videoObject.attachNetStream(_stream);
        	listener.onMetaData = metaDataHandler;
        	_stream.client = listener;
		}
		
        public function PlaySingleVideo(path:String):void{
			// remove old
			if ((!_currentIsVideo) && (_parentPictureClip != null) && (_currentPicLoader != null))
			{
				_parentPictureClip.removeChild(_currentPicLoader);
			}
			
			if(GlobalMethod.IsVideoFile(path)==true)
			{
				_stream.play(path);
				_currentIsVideo = true;
				_parentPictureClip.visible = false;
				_parentVideoClip.visible = true;
			}
			else if(GlobalMethod.IsPictureFile(path)==true)
			{
				_currentPicLoader = GlobalMethod.LoadMovieClipImage(_parentPictureClip, path, OnAdPictureLoaded);
				_adStartTime = new Date();
				_currentIsVideo = false;
				_parentPictureClip.visible = true;
				_parentVideoClip.visible = false;
			}
			else
			{
				_currentIsVideo = false;
				Next();
			}
        }
		
		public function PlayVideo(paths:Array):void{
			_moviePaths = paths;
			_currentMovieIndex = 0;
        	PlaySingleVideo( _moviePaths[_currentMovieIndex]);
        }
        public function StopVideo():void{
        	_stream.close();
			_currentMovieIndex = 0;
			_moviePaths.length = 0;
		}
		
		public function OnAdPictureLoaded(e: Event):void
		{
			e.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, OnAdPictureLoaded);
			var image: Bitmap = Bitmap(e.target.loader.content);

//			//調整圖片參數
			var w_h_ratio: Number = _pictureInit_H / _pictureInit_W;
			var newImageRatio: Number = image.height / image.width ;
			
			if(newImageRatio > w_h_ratio) //比例 相較預設尺吋, 偏高
			{
				image.height = _pictureInit_H;
				image.width = (_pictureInit_H / newImageRatio);
			}
			else //比例 相較預設尺吋, 偏寬
			{
				image.height = _pictureInit_W * newImageRatio;
				image.width = _pictureInit_W;	
			}
			
			//置中作業
			image.x = (_pictureInit_W  - image.width)/2 ;
			
			
			//image.y = (_pictureInit_H  - image.height)/2;
			//置底
			image.y = (_pictureInit_H  - image.height);
		}
		
        public function metaDataHandler(infoObject:Object):void {
            _duration = infoObject["duration"];
            trace (" Time:  " + infoObject["duration"]);
        }
        public function get duration00():Number {     
            return _duration; 
        }
		
		function myStatusHandler(event:NetStatusEvent):void  
		{  
			trace(event.info.code);
			
			switch(event.info.code)
			{
				case "NetStream.Buffer.Full":
				
				break;
				
				case "NetStream.Buffer.Empty":
				break;
				
				case "NetStream.Play.Start":
				break;
				 
				case "NetStream.Seek.Notify":
				break;
				
				case "NetStream.Seek.InvalidTime":
				break;
				
				case "NetStream.Play.StreamNotFound":
				case "NetStream.Play.Stop":
					//StopVideo();
					Next();
				break;
			}
    //trace(event.info.code);  // this will handle any events that are fired when the video is playing back  
 	   //switch(event.info.code)  //  switch statement to handle the various events with the NetConnection  
// 	   {  
//	        case "NetStream.Buffer.Full":  //  when our buffer is full fire the code below  
//	            _stream.bufferTime = 10;  // set buffer time to 10 seconds  
//	            Tweener.addTween(videoPreloader, {alpha:0, time:.3});  // tween videoPreloaders alpha to 0  
//	        break;  
//  	      case "NetStream.Buffer.Empty":  //  when our buffer is empty fire the code below  
// 	           _stream.bufferTime = 10;  // set buffer time to 10 seconds  
// 	           Tweener.addTween(videoPreloader, {alpha:1, time:.3});  // tween videoPreloaders alpha to 1  
// 	       break;  
// 	       case "NetStream.Play.Start":  //  when our video starts playing we fire the code below  
// 	           _stream.bufferTime = 10;  // set the buffer time to 10 seconds  
// 	           Tweener.addTween(videoPreloader, {alpha:1, time:.3});  //  tween videoPreloaders alpha to 1  
// 	       break;  
//  	      case "NetStream.Seek.Notify":  // when you seek with the scrubber it sends a notify signal of the time  
//   	         _stream.bufferTime = 10;  // set the buffer time to 10 seconds  
//   	         Tweener.addTween(videoPreloader, {alpha:1, time:.3});  //  tween videoPreloaders alpha to 1  
//    	    break;  
//    	    case "NetStream.Seek.InvalidTime":  // when you release the scrubber ahead of the video that has been loaded, you get this error.  it will jump you back to the last frame that has been loaded  
//     	       _stream.bufferTime = 10;  // set the buffer time to 10 seconds  
//     	       Tweener.addTween(videoPreloader, {alpha:1, time:.3});  //  tween videoPreloaders alpha to 1  
//     	   break;  
//     	   case "NetStream.Play.Stop":  // when you reach the end of the video  
//       	     Tweener.addTween(videoPreloader, {alpha:0, time:.3});  //  tween videoPreloaders alpha to 0  
//        	    _stream.pause();  // pause the video  
//        	    _stream.seek(1);  // seek the video to the first frame  
//       		 break;  
//    		}  
//		}
		}
		
		private function Next():void
		{
			if(_moviePaths.length == 0)
				return;
			_currentMovieIndex = (_currentMovieIndex + 1) % _moviePaths.length
			PlaySingleVideo( _moviePaths[ _currentMovieIndex ] );
		}
		
		// Everything in here will be called Every frame.
		public function Update(e:Event):void
		{
			if((!_currentIsVideo) && (_adStartTime != null))
			{
				_now = new Date();
				var millisecondDifference:int = _now.valueOf() - _adStartTime.valueOf();
				var seconds:int = millisecondDifference / 1000;
				if(seconds > _adPlaySeconds)
				{
					Next();
				}
			}
		}
	}
}