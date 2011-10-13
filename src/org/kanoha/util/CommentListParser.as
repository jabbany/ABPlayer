package org.kanoha.util
{
	import com.adobe.serialization.json.JSON;
	public class CommentListParser
	{
		public function CommentListParser()
		{
		}
		public static function parse(input:XML,mode:int = 0):Array{
			if(mode==0){
				return CommentListParser.AvXML2Comment(input);
			}
			return new Array();
		}
		public static function AvXML2Comment(input:XML):Array{
			var ret:Array=new Array();
			var tmp:XMLList = input.d;
			var id:int = 0;
			for each(var nd:XML in tmp){
				var p:Array = String(nd.@p).split(',');
				var text:String = String(nd);
				var obj:Object = {};
				obj.stime = uint(parseFloat(p[0])*1000);
				obj.size = uint(p[2]);
				obj.color = uint(p[3]);
				obj.mode = uint(p[1]);
				obj.date = new Date(p[4] * 1000);
				obj.border = false;
				obj.id  = id ++;
				if(obj.mode<7){
					obj.text = text.replace(/(\/n|\\n|\n|\r\n)/g, "\r");
				}else{
					if(obj.mode==7){
						try{
							var json:Object = JSON.decode(text,false);
							obj.x = Number(json[0]);
							obj.y = Number(json[1]);
							obj.text = String(json[4]).replace(/(\/n|\\n|\n|\r\n)/g, "\r");
							obj.rZ = 0;
							obj.rY = 0;
							if(json.length >= 7){
								obj.rZ = Number(json[5]);
								obj.rY = Number(json[6]);
							}
							obj.adv = false;
							//insert advanced mode here
							if(json.length >=11){
								trace('Advanced mode! Movable!');
							}
							obj.duration = 2.5;
							if(json[3] < 12 && json[3] != 1){
								obj.duration = Number(json[3]);
							}
							obj.inAlpha = 1;
							obj.outAlpha = 1;
							var a:Array = String(json[2]).split('-');
							if(a.length >=2){
								obj.inAlpha = Number(a[0]);
								obj.outAlpha = Number(a[1]);
							}
						}catch(e:Error){
							trace('JSON Failed!?');
							trace(text);
						}
					}else{
						obj.text = 'Advanced not supported!';
					}
				}
				ret.push(obj);
			}
			return ret;
		}
	}
}