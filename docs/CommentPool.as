package org.kanoha.comment
{
	import org.kanoha.collections.LinkedList;
	
	public class CommentPool
	{
		private var _$pool:LinkedList;
		private var _$size:uint;
		
		public function CommentPool(size:uint)
		{
			this._$pool = new LinkedList();
			this._$size = size;
			for(var i:int=0;i<this._$size;i++){
				_$pool.push(new Comment());
			}
		}
		public function getInstance():Comment{
			if(_$pool.hasNext())
				return _$pool.shift();
			else 
				return new Comment();
		}
		public function dumpComment(cmnt:Comment):Boolean{
			if(!cmnt.managed){
				return false;
			}
			_$pool.push(cmnt);
			return true;
		}
		public function get size():uint{
			return this._$size;
		}
		public function get freeSize():uint{
			return this._$pool.size;
		}
	}
}