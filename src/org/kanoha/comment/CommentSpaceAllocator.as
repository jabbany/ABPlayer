package org.kanoha.comment
{
	/**
	 * A Very Good Comment Space Allocator
	 * @aristotle9 package mukioplayerplus
	 * ported and edited for ABPlayer
	 **/
	public class CommentSpaceAllocator
	{
		protected var pools:Array = new Array();
		protected var Width:int;
		protected var Height:int;
		public function CommentSpaceAllocator()
		{
		}
		public function setBounds(w:int,h:int):void{
			this.Width = w;
			this.Height = h;
		}
		public function add(cmt:Comment):void{
			cmt.x = (this.Width - cmt.width)/2;
			if(cmt.height >= this.Height){
				cmt.setY(0,-1,transformY);
			}else{
				//This needs calculation
				this.setY(cmt);
			}
		}
		public function setY(cmt:Comment,index:int = 0):void{
			var y:int =0;
			if(this.pools.length <= index){
				this.pools.push(new Array());
			}
			var pool:Array = this.pools[index];
			if(pool.length == 0){
				cmt.setY(0,index,transformY);
				pool.push(cmt);
				return;
			}
			if(this.vCheck(0,cmt,index)){
				cmt.setY(0,index,transformY);
				CommentManager.binsert(pool,cmt,bottom_cmp);
				return;
			}
			for each(var c:Comment in pool){
				y = c.bottom + 1;
				if(y + cmt.height > this.Height){
					break;
				}
				if(this.vCheck(y,cmt,index)){
					cmt.setY(y,index,transformY);
					CommentManager.binsert(pool,cmt,bottom_cmp);
					return;
				}
			}
			this.setY(cmt,index +1);
		}
		protected function transformY(y:int,c:Comment):int{
			return y;
		}
		protected function bottom_cmp(a:Comment,b:Comment):int{
			if(a.bottom<b.bottom){
				return -1;
			}
			else if(a.bottom==b.bottom){
				return 0;
			}else{
				return 1;
			}
		}
		protected function vCheck(y:int,cmt:Comment,index:int):Boolean{
			var bottom:int = y + cmt.height;
			for each(var c:Comment in this.pools[index]){
				if(c.y > bottom || c.bottom < y){
					continue;
				}else{
					return false;
				}
			}
			return true;
		}
		public function remove(cmt:Comment):void{
			if(cmt.index != -1){
				var pool:Array = this.pools[cmt.index];
				var n:int = pool.indexOf(cmt);
				pool.splice(n,1);
			}
		}
	}
}