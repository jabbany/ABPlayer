package org.kanoha.collections
{
	public class Node
	{
		public var next:Node;
		public var prev:Node;
		public var data:*;
		public function Node(data:* = null,next:Node = null, prev:Node = null)
		{
			this.prev = prev;
			this.next = next;
			this.data = data;
		}
	}
}