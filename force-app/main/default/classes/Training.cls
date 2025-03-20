public with sharing class Training {

    public String str ;
	public Decimal count = null;	
	public Date currentDate = System.today();
	public Datetime last7date = System.now() - 7;
	public Time currentTime = Datetime.now().addMinutes(5).time();
	public Integer data = 100;
	public Set<String> strSet = new Set<String>{'a','b','c','d','e'};
	public List<String> myList = new List<String>{'a','b','c','d','e'};
	public Map<String,Integer> intMap = new Map<String,Integer>{'a'=>0,'b'=>1,'c'=>2,'d'=>3,'e'=>4};

    public Training(){

    	System.debug(LoggingLevel.INFO, '*** 当前日期: ' + this.currentDate);
    	System.debug(LoggingLevel.INFO, '*** 七天前时间: ' + this.last7date);
    	System.debug(LoggingLevel.INFO, '*** 5分钟后的时间: ' + this.currentTime);
    	// this.strSet.add('f');
    	// this.myList.add('g');
    	// this.intMap.put('f', 5);
		printAllCollection();
   	}

   	//循环遍历输出自身
   	public void loopPrintToSelf(){
   		for (Integer i=0; i<=data; i++ ) {
			System.debug(LoggingLevel.INFO, '*** i: ' + i);
		}
   	}

   	public void printAllCollection(){
   		printSetCollection();
   		printListCollection();
   		printMapConnection();
   	}

   	public void printSetCollection(){
   		Integer i = 0;
   		if (!this.strSet.isEmpty()) {
   		    for (String str:this.strSet ) {
				System.debug(LoggingLevel.INFO, '*** strSet['+i+']: ' + str);
				i++;
			}
   		}
		
   	}

   	public void printListCollection(){
		if (!this.myList.isEmpty()) {
		    for (Integer i = 0; i < this.myList.size(); i++) {
				System.debug(LoggingLevel.INFO, '*** strList['+i+']: ' + myList[i]);
			}
		}
   	}

   	public void printMapConnection(){
   		if (!this.intMap.isEmpty()) {
   			Integer i = 0;
   		    for (String key:this.intMap.keySet() ) {
				System.debug(LoggingLevel.INFO, '*** intMap['+i+']:(' + key + ',' + this.intMap.get(key) + ')');
				i++;
			}
   		}	
   	}
   	 
}