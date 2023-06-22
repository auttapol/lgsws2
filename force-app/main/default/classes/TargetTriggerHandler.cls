public class TargetTriggerHandler {
    static Boolean detectError = false;
    static String errorException = '';
    static String STR_INSERT = 'insert';
    static String STR_UPDATE = 'update';
    static String STR_DELETE = 'delete';
    
    Static String lbActivitiesTarget = 'A';
    Static String lbSalesTarget = 'S';
    Static String lbPipelinesTarget = 'P';
    //Piyawat NI Target
    Static String lbNITarget = 'N';
    
    public static void handlerBeforeInsert(List<Target__c> targetsNew){
        List<Target__c> listNew = checkConditionT12(targetsNew,null);
        if( listNew.size() > 0 ){
            Trigger_T12( listNew ,null,STR_INSERT); 
        }
    }
    
    public static void handlerBeforeUpdate(List<Target__c> targetsNew,List<Target__c> targetsOld){
        List<Target__c> listNew = checkConditionT12_Update(targetsNew,targetsOld);
        if( listNew.size() > 0 ){
            Trigger_T12( listNew ,targetsOld,STR_UPDATE); 
        }
    }
    
    public static List<Target__c> checkConditionT12(List<Target__c> targetsNew,List<Target__c> targetsOld){
        List<Target__c> listReturn = new List<Target__c>();
        Map<Id,Target__c> mapTargetsOld = new Map<Id,Target__c>();
        if( targetsOld != null && targetsOld.size() > 0 ){
            mapTargetsOld.putAll(targetsOld);
        }
        
        for( Target__c t : targetsNew ){
            if( t.RecordTypeId != null && t.Monthly_Target_Date__c != null ){ 
                listReturn.add(t);
            }else{
                t.RecordTypeId.addError('Please choose Record Type and Monthly Target Date');
            }
        }
        
        return listReturn;
    }
    
    public static List<Target__c> checkConditionT12_Update(List<Target__c> targetsNew,List<Target__c> targetsOld){
        List<Target__c> listReturn = new List<Target__c>();
        Map<Id,Target__c> mapTargetsOld = new Map<Id,Target__c>();
        if( targetsOld != null && targetsOld.size() > 0 ){
            mapTargetsOld.putAll(targetsOld);
        }
        
        for( Target__c t : targetsNew ){
            if( t.RecordTypeId != null && t.Monthly_Target_Date__c != null ){ 
                if( t.Monthly_Target_Date__c.month() != mapTargetsOld.get(t.Id).Monthly_Target_Date__c.month() 
                   || t.Monthly_Target_Date__c.year() != mapTargetsOld.get(t.Id).Monthly_Target_Date__c.year() 
                   || t.Product__c != mapTargetsOld.get(t.Id).Product__c 
                   || t.Opportunity_stage__c != mapTargetsOld.get(t.Id).Opportunity_stage__c){
                       listReturn.add(t);                           
                   }else{
                       System.debug(':::: '+t.Id +' not change');
                   }                
            }else{
                t.RecordTypeId.addError('Please choose Record Type and Monthly Target Date');
            }
        }
        
        return listReturn;
    }
    
    public static void Trigger_T12(List<Target__c> targetsNew,List<Target__c> targetsOld,String eventMode){
        
        List<Integer> listMonth = new List<Integer>();
        List<Integer> listYear = new List<Integer>();
        List<Id> listOwnerId = new List<Id>();
        Map<String,Target__c> mapSaveValue = new Map<String,Target__c>();
        Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>([select Id,Name from RecordType]);
        List<Id> listUserId = new List<Id>();
        for( Target__c t : targetsNew){
            listUserId.add(t.OwnerId);
        }
        List<User> listUser = [ select Id,Segment__c,Zone_Code__c,Employee_ID__c from User where Id IN :listUserId ];
        Map<String,User> mapUser = new Map<String,User>();
        for( User u : listUser ){
            mapUser.put(u.Id,u);
        }
        
        for( Target__c t : targetsNew ){
            
            if(t.OwnerId != null){
                listOwnerId.add(t.OwnerId);
            }
            
            if( t.Monthly_Target_Date__c != null ){
                listMonth.add( Integer.valueOf(String.valueOf(t.Monthly_Target_Date__c).substring(5,7)) );
                listYear.add( Integer.valueOf(String.valueOf(t.Monthly_Target_Date__c).substring(0,4)) );
            }
        }
        
        List<Target__c> listTarget = [ 
            select OwnerId,Monthly_Target_Date__c,Reference_ID__c,Product__c,Opportunity_stage__c,RecordTypeId
            from Target__c 
            where CALENDAR_MONTH(Monthly_Target_Date__c) IN :listMonth
            and CALENDAR_YEAR(Monthly_Target_Date__c) IN :listYear
            and OwnerId IN :listOwnerId
        ];
        
        for( Target__c target : targetsNew ){
            
            //System.debug(' m : '+ target.Monthly_Target_Date__c.month());
            //System.debug(' y : '+ target.Monthly_Target_Date__c.year());
            Boolean checkDup = false;
            for( Target__c t : listTarget ){
                if( target.OwnerId == t.OwnerId 
                   && target.Monthly_Target_Date__c.month() == t.Monthly_Target_Date__c.month()
                   && target.Monthly_Target_Date__c.year() == t.Monthly_Target_Date__c.year()
                   && target.Product__c == t.Product__c
                   && target.Opportunity_stage__c == t.Opportunity_stage__c
                   && target.RecordTypeId == t.RecordTypeId
                  ){                      
                      checkDup = true;
                      if( t.Reference_ID__c != null && t.Reference_ID__c != '' ){
                          mapSaveValue.put( t.Reference_ID__c , t );
                          target.Reference_ID__c.addError( Trigger_Msg__c.getValues('Duplicate_Reference_ID').Description__c );
                      }
                      System.debug('::::: detect record dup ownerId : '+target.OwnerId+' MM/YYYY : '+target.Monthly_Target_Date__c.month()+'/'+
                                   target.Monthly_Target_Date__c.year() +' | '+t.Reference_ID__c );
                  }
                
            }
            if(!checkDup){
                String strRecordType = ( mapRecordType.containsKey(target.RecordTypeId) ) ? mapRecordType.get(target.RecordTypeId).name : '' ;
                Integer currentMonth =  target.Monthly_Target_Date__c.month() ;
                Integer currentYear = (UserInfo.getLocale() == 'th_TH' ) ? target.Monthly_Target_Date__c.year()-543 : target.Monthly_Target_Date__c.year();
                String strTmbId = stringToNull( mapUser.get( target.OwnerId ).Employee_ID__c );
                String strZoneCode = stringToNull( mapUser.get( target.OwnerId ).Zone_Code__c );
                String strProduct = stringToNull( target.Product__c );
                String strOppStage = stringToNull( target.Opportunity_stage__c );
                strRecordType = strRecordType.substring(0, 1);// label recordType first position
                
                String jsonInput = '{\n' +
                    ' "RecordType" : "'+ strRecordType +'" ,\n' +
                    ' "Month" : '+ currentMonth +' ,\n' +
                    ' "Year" : '+currentYear+',\n' +
                    ' "TmbId" : "'+strTmbId+'" ,\n' +
                    ' "ZoneCode" : "'+ strZoneCode +'",\n' +
                    ' "Product" : "'+ strProduct +'",\n' +
                    ' "OppStage" : "'+strOppStage+'" \n' +
                    '}';
                System.debug(':: '+jsonInput);
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                
                if( strRecordType == null || strRecordType == '' ){
                    target.addError( Trigger_Msg__c.getValues('Not_Found_RecordType').Description__c ,false);    
                }
                
                if( strTmbId == null || strTmbId == '' ){
                    target.addError( Trigger_Msg__c.getValues('Not_Found_Employee_ID').Description__c ,false);    
                }
                
                if( strZoneCode == null || strZoneCode == '' ){
                    target.addError( Trigger_Msg__c.getValues('Not_Found_Zone_Code').Description__c ,false);    
                }
                
                String refId = generateRefId(m);
                if( mapSaveValue.containsKey(refId)  ){
                    target.Reference_ID__c.addError( Trigger_Msg__c.getValues('Duplicate_Reference_ID').Description__c );
                    System.debug('::::: error duplicate refId : '+refId+' :::::');
                }else{
                    target.Reference_ID__c = refId;
                    mapSaveValue.put( refId , target );    
                }
                
                System.debug('REF ID : '+ refId +' Owner ID : '+target.OwnerId);
                
            }            
        }        
    }
    
    public static String generateRefId(Map<String,Object> obj){
        Integer currentYear = Integer.valueOf( obj.get('Year') );
        Integer currentMonth = Integer.valueOf( obj.get('Month') );
        /* SMMYYYYUUUUUHHHH[PRODUCT] */
        /* AMMYYYYUUUUUHHHH */
        /* PMMYYYYUUUUUHHHH[OPPSTAGE] */
        
        String recordType = stringToNull( string.valueOf( obj.get('RecordType') ) );
        String tmbId = stringToNull( string.valueOf( obj.get('TmbId') ) );
        String zoneCode = stringToNull( string.valueOf( obj.get('ZoneCode') ) );
        String product = stringToNull( string.valueOf( obj.get('Product') ) );
        String oppStage = stringToNull( string.valueOf( obj.get('OppStage') ) );
        
        String strRecordType = '';
        String strTmbId = '';
        String strZoneCode = '';
        String strProduct = '';
        String strOppStage = '';
        String strMonth = '';
        String strYear = '';
        
        Integer i = 0;
        String refId = '';
        
        strRecordType = genNumber(recordType,recordType.length());
        strTmbId = genNumber(tmbId,tmbId.length());
        strZoneCode = genNumber(zoneCode,zoneCode.length());
        strMonth = genNumber( String.valueOf(currentMonth) ,String.valueOf(currentMonth).length());
        strYear = genNumber(  String.valueOf(currentYear) ,String.valueOf(currentYear).length());
        strProduct = genNumber(product,product.length());
        strOppStage = genNumber(oppStage,oppStage.length());
        String lastType = '';
        if( strRecordType == lbSalesTarget ){
            lastType = strProduct;
        }else if( strRecordType == lbActivitiesTarget ){
            
        }else if( strRecordType == lbPipelinesTarget ){
            lastType = strOppStage;
        }
        else if( strRecordType == lbNITarget ){
           
        }
        
        return strRecordType+strMonth+strYear+strTmbId+strZoneCode+lastType;        
    } 
    
    public static String genNumber(String str,Integer len){
        String strReturn = '';
        Integer lenStr = 0;
        
        lenStr = (str == null || str == '') ? 0 : str.length();
        
        if( lenStr == len ){
            strReturn = str;
        }else if(lenStr > len){
            strReturn = str.substring(0, len);
            System.debug('::::: Error Digit '+lenStr+' of '+len);
            System.debug('::::: '+strReturn);
            
        }else{
            for(Integer i = lenStr ; i < len ; i++ ){
                strReturn += '0';
            } 
            strReturn += str;
        }
        return strReturn;
        
    } 
    
    public static String stringToNull(String strInput){
        return ( strInput == null ) ? '' : strInput;
    }
}