/*************************
 * LinkedList Modified from tamaki.collection.LinkedList
 * ***********************/

package org.kanoha.collections
{
	public class LinkedList
	{
		protected var head:Node;
		protected var tail:Node;
		protected var pntr:Node;
		protected var length:uint = 0;
		public function LinkedList()
		{
			head = new Node();
			tail = new Node();
			pntr = head;
			head.next = tail;
			tail.prev = head;
		}
		public function push(item:*):void{
			var newNode:Node = new Node(item);
			tail.prev.next = newNode;
			newNode.prev = tail.prev;
			newNode.next = tail;
			tail.prev = newNode;
			length++;
		}
		public function shift():*{
			pntr = head;
			if(head.next == tail){
				return null;//nothing left!
			}
			var tn:Node = head.next;
			head.next = head.next.next;
			head.next.prev = head;
			length--;
			return tn.data;
		}
		public function pop():*{
			pntr = head;
			if(tail.prev == head){
				return null;//nothing to pop
			}
			var tn:Node = tail.prev;
			tail.prev = tail.prev.prev;
			tail.prev.next = tail;
			length--;
			return tn.data;
		}
		public function current():*{
			if(!pntr){
				return null;
			}
			return pntr.data;
		}
		public function forward():*{
			if(pntr.next == tail){
				return null;//already at the end
			}
			var tn:Node = pntr.next;
			pntr = pntr.next;
			return tn.data;
		}
		public function back():*{
			if(pntr.prev == head){
				return null;//already at the beginning
			}
			var tn:Node = pntr.prev;
			pntr = pntr.prev;
			return tn.data;
		}
		public function hasNext():Boolean{
			if(pntr.next == tail){
				return false;
			}
			return true;
		}
		public function hasPrev():Boolean{
			if(pntr.prev == head){
				return false;
			}
			return true;
		}
		public function reset():void{
			this.pntr = this.head;
		}
		public function peek():*{
			if(pntr.next==tail)
				return null;
			return pntr.next.data;
		}
		public function peekback():*{
			if(pntr.prev==head)
				return null
			return pntr.prev.data;
		}
		public function goLast():void{
			this.pntr = this.tail;
		}
		public function visit(f:Function, target:*=null):void{
			this.reset();
			while(this.hasNext()){
				var item:* = this.forward();
				f.call(target,item);
			}
		}
		public function filter(f:Function, target:*=null):void{
			this.reset();
			while(this.hasNext()){
				var item:* = this.forward();
				if(!f.call(target,item)){
					this.removeCurrent();
				}
			}
		}
		public function remove(item:*):Boolean{
			this.reset();
			while(this.hasNext()){
				var ti:* = this.forward();
				if(ti==item){
					this.removeCurrent();
					return true;
				}
			}
			return false;
		}
		public function removeCurrent():void{
			if(pntr!= head && pntr != tail){
				pntr.prev.next = pntr.next;
				pntr.next.prev = pntr.prev;
				pntr = pntr.prev;
				length--;
			}
		}
		public function insertAfterCurrent(item:*):void{
			if(pntr !=tail){
				var tn:Node = new Node(item);
				tn.prev = pntr;
				tn.next = pntr.next;
				pntr.next.prev = tn;
				pntr.next = tn;
			}
		}
		public function get size():uint{
			return this.length;
		}
	}
}