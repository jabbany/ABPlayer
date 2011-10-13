package org.kanoha.collections
{
	public class SortedLinkedList extends LinkedList
	{
		private var compF:Function;
		public function SortedLinkedList(cf:Function)
		{
			this.compF = cf;
		}
		override public function push(item:*):void{
			var tn:Node = new Node(item);
			var next:Node = this.findPos(item);
			if(next == head){
				super.push(item);
			}else{
				tn.next = next;
				tn.prev = next.prev;
				next.prev.next = tn;
				next.prev = tn;
				length++;
			}
		}
		public function pushReverse(item:*):void{
			var tn:Node = new Node(item);
			var pre:Node = this.findPosReverse(item);
			if(pre == tail)
			{
				super.push(item);
			}
			else
			{
				tn.prev = pre;
				tn.next = pre.next;
				pre.next.prev = tn;
				pre.next = tn;
				length++;
			}
		}
		private function findPos(item:*):Node{
			this.reset();
			while(this.hasNext()){
				var ti:* = this.forward();
				if(this.compF.call(null,item,ti) < 0){
					break;
				}
			}
			if(pntr!=head && pntr.next == tail){
				//LAST ELEMENT
				if(this.compF.call(null,item,this.current()) >=0){
					return tail;
				}
			}
			return pntr;
		}
		private function findPosReverse(item:*):Node{
			this.goLast();
			while(this.hasPrev()){
				var ti:* = this.back();
				if(this.compF.call(null,item,ti)>=0){
					break;
				}
			}
			if(pntr!=tail && pntr.prev==head){
				if(this.compF.call(null,item,ti)<0){
					return head;
				}
			}
			return pntr;
		}
	}
}