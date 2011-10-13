package org.kanoha.comment
{
	public class CommentDataList
	{
		private var dataArray:Array;
		private var lastTime:int;
		public function CommentDataList(lst:Array)
		{
			init(lst);
		}
		public function init(lst:Array):void{
			dataArray = lst;
			lastTime = 0;
			dataArray.sortOn("time",16);
			for(var i:int =0;i<dataArray.length;i++){
				trace(dataArray[i].time + " " + dataArray[i].text);
			}
		}
		public function resetIndex(time:int):void{
			this.lastTime = time;
		}
		public function get size():uint{
			return this.dataArray.length;
		}
		public function addComment(cd:CommentData):void{
			dataArray.push(cd);
			dataArray.sortOn("time",16);
		}
		public function loadTime(time:int):Array{
			if(lastTime>time){
				lastTime = time;
				return new Array();
			}else{
				var ret:Array = new Array();
				for(var i:uint = 0;i<=dataArray.length;i++){
					if(dataArray[i].time <= lastTime){
						continue;
					}
					if(dataArray[i].time>lastTime && dataArray[i].time<=time){
						ret.push(dataArray[i]);
					}else if(dataArray[i].time > time){
						break;
					}
				}
				return ret;
			}
			return new Array();
		}
	}
}