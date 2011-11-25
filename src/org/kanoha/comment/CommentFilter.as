package org.kanoha.comment
{
	public class CommentFilter
	{
		protected var filters:Array = new Array();
		protected var filterModes:Array = [true,true,true,true,true,true,true,true,true,true];
		public function CommentFilter()
		{
		}
		public function clear():void{
			this.filters = new Array();//deleted all filters
		}
		public function addFilter(filter:String):Object{
			//Parse this
			var entities:Array = filter.split(" ",3);
			if(entities.length<3)
				return {id:-1};//Not enough parameters
			var entMode:Array = String(entities[0]).split(".",2);
			var id:int=0;
			switch(entMode[0]){
				case '$':id=1;break;
				case 'T':id=5;break;
				case 'B':id=4;break;
				case 'P':id=7;break;
				case 'R':id=6;break;
				case '*':id=0;break;
				default:return {id:-2};//Undefined entity mode
			}
			if(filters[id]==null){
				filters[id]=new Array();
			}
			var objFilter:Object = {property:entMode[1],operator:entities[1],p:entities[2]};
			if(objFilter.operator != "region" && objFilter.operator != "subset")
				if(objFilter.property == "size" ||objFilter.property == "mode"|| objFilter.property == "stime" || objFilter.property == "width" || objFilter.property == "height" || objFilter.property == "color" && objFilter.p.charAt(0)!="#"){
					objFilter.p=int(objFilter.p);
				}
			filters[id].push(objFilter);
			return {id:(filters[id].length - 1),mode:id};
		}
		public function removeFilterAt(id:int,mode:int=0):Boolean{
			try{
				filters[mode].splice(id,1);
			}catch(e:Error){
				//do nothing
				return false;
			}
			return true;
		}
		public function removeFilter(filter:String):Number{
			//Parse this
			var entities:Array = filter.split(" ",3);
			if(entities.length<3)
				return -1;//Not enough parameters
			var entMode:Array = String(entities[0]).split(".",2);
			var id:int=0;
			switch(entMode[0]){
				case '$':id=1;break;
				case 'T':id=5;break;
				case 'B':id=4;break;
				case 'P':id=7;break;
				case 'R':id=6;break;
				case '*':id=0;break;
				default:return -2;//Undefined entity mode
			}
			if(filters[id]==null){
				return 0;
			}
			var objFilter:Object = {property:entMode[1],operator:entities[1],p:entities[2]};
			if(objFilter.operator != "region" && objFilter.operator != "subset")
				if(objFilter.property == "size" ||objFilter.property == "mode"|| objFilter.property == "stime" || objFilter.property == "width" || objFilter.property == "height" || objFilter.property == "color" && objFilter.p.charAt(0)!="#"){
					objFilter.p=int(objFilter.p);
				}
			for(var m:int=0;m<filters[id].length;m++){
				if(filters[id][m].property==objFilter.property && filters[id][m].p==objFilter.p && filters[id][m].operator==objFilter.operator){
					filters[id].splice(m,1);//delete this
				}
			}
			return 0;
		}
		public function filterMode(mode:uint,setTo:Boolean):void{
			filterModes[mode]=setTo;
		}
		public function validate(cdata:Object):Boolean{
			if(cdata==null || cdata.mode == null || cdata.stime==null)
				return false;//not valid data
			if(!filterModes[uint(cdata.mode)]){
				return false;//this mode cannot be run
			}
			if(filters[cdata.mode]!=null)
				for(var i:int=0;i<filters[cdata.mode].length;i++){
					if(!this.runFilter(cdata,filters[cdata.mode][i])){
						return false;
					}
				}
			if(filters[0]!=null){
				for(var j:int=0;j<filters[0].length;j++){
					if(!this.runFilter(cdata,filters[0][j])){
						return false;
					}
				}
			}
			return true;
		}
		private function runFilter(cdata:Object,fdata:Object):Boolean{
			switch(fdata.operator){
				case '=':
				case '==':
				case 'eq':{
					if(fdata.property=="width" || fdata.property=="height")
						return true;//cannot filter this in the pre-stage
					if(fdata.property=="color" && String(fdata.p).charAt(0)=="#"){
						//decode this color
						fdata.p = uint("0x" + String(fdata.p).substr(1,String(fdata.p).length));//numberd color
					}
					if(cdata[fdata.property]!=null && cdata[fdata.property]==fdata.p){
						return false;
					}
					return true;
				}break;
				case 'ineq':
				case '!=':{
					if(fdata.property=="width" || fdata.property=="height")
						return true;//cannot filter this in the pre-stage
					if(fdata.property=="color" && String(fdata.p).charAt(0)=="#"){
						//decode this color
						fdata.p = uint("0x" + String(fdata.p).substr(1,String(fdata.p).length));//numberd color
					}
					if(cdata[fdata.property]!=null && cdata[fdata.property]!=fdata.p){
						return false;
					}
					return true;
				}
				case 'matches':
				case 'regex':
				case '~':{
					if(fdata.property!='text' && fdata.property!='hash')
						return true;//cannot filter this type
						var reg:RegExp = new RegExp(String(fdata.p),"g");
					if(cdata[fdata.property]!=null && reg.test(cdata[fdata.property])){
						return false;
					}
					return true;
				}break;
				case '<':{
					if(fdata.property=="text" || fdata.property=="hash"){
						return true;//HA?
					}
					if(fdata.property=="color" && String(fdata.p).charAt(0)=="#"){
						//decode this color
						fdata.p = uint("0x" + String(fdata.p).substr(1,String(fdata.p).length));//numberd color
					}
					if(cdata[fdata.property]!=null && Number(cdata[fdata.property])<Number(fdata.p)){
						return false;
					}
					return true;
				}break;
				case '<':{
					if(fdata.property=="text" || fdata.property=="hash"){
						return true;//HA?
					}
					if(fdata.property=="color" && String(fdata.p).charAt(0)=="#"){
						//decode this color
						fdata.p = uint("0x" + String(fdata.p).substr(1,String(fdata.p).length));//numberd color
					}
					if(cdata[fdata.property]!=null && Number(cdata[fdata.property])>Number(fdata.p)){
						return false;
					}
					return true;
				}
				case 'subset':
				case 'region':{
					if(fdata.property=="text" || fdata.property=="hash"){
						return true;
					}
					if(fdata.property=="color" && String(fdata.p).charAt(0)=="#"){
						//decode this color
						fdata.p = uint("0x" + String(fdata.p).substr(1,String(fdata.p).length));//numberd color
					}
					var limits:Array = String(fdata.p).split(",");
					if(cdata[fdata.property]!=null && Number(cdata[fdata.property])>Number(limits[0]) && Number(cdata[fdata.property])<Number(limits[1])){
						return false;
					}
					return true;
				}
				default:return true;
			}
		}
	}
}