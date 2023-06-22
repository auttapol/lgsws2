public class CAID {
    /*
    Change No. : CH01
    Change By : Uttaporn
    Change Date : 2015-04-02
    Change Detail: Segment Over flow when send 4 Digit on Obj Running__c
    */
    
    static Boolean detectError = false;
    static String errorException = '';
    static String STR_INSERT = 'insert';
    static String STR_UPDATE = 'update';
    static String STR_DELETE = 'delete';
    
    static Integer digitSegment = 2;
    static Integer digitHub = 4;
    static Integer digitUserId = 5;
	static Integer digitDay = 2;
    static Integer digitMonth = 2;
    static Integer digitYear = 2;
    static Integer digitNo = 3;
    
    public static void checkGenerateCAID(List<Opportunity> listOppsNew,List<Opportunity> listOppsOld,String eventMode){
        System.debug(':::: Trigger_CAID Start ::::');
        Date currentDate = Date.today();
        Integer currentYear = (UserInfo.getLocale() == 'th_TH' ) ? currentDate.year()-543 : currentDate.year();
        Integer currentMonth = currentDate.month();
        Integer currentDay = currentDate.day();
        List<Id> listUserId = new List<Id>();
        for( Opportunity opp : listOppsNew){
            listUserId.add(opp.OwnerId);
        }
        //System.debug( listUserId.size() );
        List<String> listSegment = new List<String>();
        List<String> listHub = new List<String>();
        List<String> listEmpId = new List<String>();
        List<User> listUser = [ select Id,Segment__c,Zone_Code__c,Employee_ID__c from User where Id IN :listUserId ];
        Map<String,User> mapUser = new Map<String,User>();
        String strSegment_Sub;
        for( User u : listUser ){
            
            mapUser.put(u.Id,u);
            
             if( u.Segment__c == null || u.Segment__c == '' ){
                u.Segment__c = 'NA';
            }
            if(u.Zone_Code__c ==null || u.Zone_Code__c ==''){
                u.Zone_Code__c = '0000';
            }
            
            strSegment_Sub = genNumber(u.Segment__c,digitSegment); // <<  CH01
            listSegment.add(strSegment_Sub);
            listHub.add(u.Zone_Code__c);
            listEmpId.add(u.Employee_ID__c);
        }
        
       /* System.debug('userId : '+listEmpId );
        System.debug('segment : '+listSegment );
        System.debug('listHub : '+listHub );
       */
        
        Map<Id,AggregateResult> listRunning = new Map<Id,AggregateResult>();
        
        try{
            listRunning = new Map<Id,AggregateResult>([select MAX(No__c) lastNo,UserId__c Id
                                                       from Running__c
                                                       where Year__c = :currentYear
                                                       and Month__c = :currentMonth
                                                       and Day__c = :currentDay
                                                       and UserId__c IN :listEmpId
                                                       and Segment__c IN :listSegment
                                                       and Hub__c IN :listHub
                                                       group by UserId__c]);
        }catch (ListException e){
            System.debug(e.getMessage());
        }
        
        Map<String,Running__c> mapSaveValue = new Map<String,Running__c>();
        for(AggregateResult agg : listRunning.values()){
            Running__c r = new Running__c();
            r.No__c = ( agg.get('lastNo') == null ) ? 1 : (Decimal)agg.get('lastNo');
            mapSaveValue.put( String.valueOf(agg.get('Id')) , r);
        }
        //System.debug( '>> ' + mapSaveValue);
        
        List<Running__c> listRowInsert = new List<Running__c>(); 
        for( Opportunity u : listOppsNew ){
            Running__c rowRunning;
            Decimal nextNo = 1;
            Boolean detectRow = false;
            
            String strUserId =  mapUser.get( u.OwnerId ).Employee_ID__c;
            
            if( mapSaveValue.size() > 0 ){
                if( mapSaveValue.containsKey( strUserId ) ){
                    detectRow = true;
                    mapSaveValue.get( strUserId ).No__c+=1;
                    nextNo = (Decimal)mapSaveValue.get( strUserId ).No__c;
                }else{
                    System.debug('::::: error containsKey empId : '+ strUserId +' in mapSaveValue ');  
                }
            }
           // System.debug('>>'+nextNo +'  >> '+detectRow);
            
            if(!detectRow){
                if( mapSaveValue.containsKey( strUserId ) ){
                    mapSaveValue.get( strUserId ).No__c+=1;
                    nextNo=(Decimal)mapSaveValue.get( strUserId ).No__c;
                }else{
                    Running__c r = new Running__c();
                    r.No__c = nextNo;
                    mapSaveValue.put( strUserId , r);
                }

            }
            
            
            
            String strSegment = stringToNull( mapUser.get( u.OwnerId ).Segment__c ) ;
            /*if( strSegment == null || strSegment == '' ){
               strSegment = 'NA';
            }*/
            strSegment_Sub = genNumber(strSegment ,digitSegment); // <<  CH01
            String strHub = stringToNull( mapUser.get( u.OwnerId ).Zone_Code__c );
            strUserId = stringToNull( mapUser.get( u.OwnerId ).Employee_ID__c );
            /*
            
            if( strHub == null || strHub == '' ){
                strHub = '0000';
            }*/
            
            rowRunning = new Running__c(
                No__c =  nextNo,
                Year__c = currentYear,
                Month__c = currentMonth,
                Day__C = currentDay,
                UserId__c = strUserId,
                Segment__c = strSegment_Sub,
                Hub__c = strHub
            ); // <<  CH01
            
            String jsonInput = '{\n' +
                ' "Segment" : "'+ strSegment +'" ,\n' +
                ' "Hub" : "'+ strHub +'" ,\n' +
                ' "Day" : '+currentDay+',\n' +
                ' "Month" : '+currentMonth+',\n' +
                ' "Year" : '+currentYear+',\n' +
                ' "UserId" : "'+ strUserId +'",\n' +
                ' "No" : '+nextNo+' \n' +
                '}';
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
            
            /*System.debug('::::: Segment : '+m.get('Segment'));
            System.debug('::::: Hub : '+m.get('Hub'));
            System.debug('::::: Month : '+m.get('Month'));
            System.debug('::::: Year : '+m.get('Year'));
            System.debug('::::: UserId : '+m.get('UserId'));
            System.debug('::::: No : '+m.get('No'));
            */
            /*
            if( strSegment == null || strSegment == '' ){
               // u.addError( Trigger_Msg__c.getValues('Not_Found_Segment').Description__c ,false);  
               //  
               strSegment = 'NA';
               //     
            }
            
            if( strHub == null || strHub == '' ){
                //u.addError( Trigger_Msg__c.getValues('Not_Found_Zone_Code').Description__c ,false);  
                //
                strHub = '0000';
                //
            }*/
            
            if( strUserId == null || strUserId == '' ){
                u.addError( Trigger_Msg__c.getValues('Not_Found_Employee_ID').Description__c ,false);    
            }
            
            String caid = generateCAID(m);
            System.debug('CAID : '+ caid +' Owner ID : '+u.OwnerId +' oppId : '+u.Id);
            u.CAID__c = caid;
            listRowInsert.add(rowRunning);
        }
        
        insert listRowInsert;
        
        System.debug(':::: Trigger_CAID End ::::');
        //System.debug('::::: size rowInsert : '+listRowInsert.size());
       
    }
    
    public static String generateCAID(Map<String,Object> objRunning){
        Integer currentYear = (Integer)objRunning.get('Year');
        Integer currentMonth = (Integer)objRunning.get('Month');
        Integer currentday = (Integer)objRunning.get('Day');
        /* SSHHHHUUUUUMMYYYYXXX */
        
        String segment = stringToNull( string.valueOf( objRunning.get('Segment') ) );
        String hub = stringToNull( string.valueOf( objRunning.get('Hub') ) );
        String userId = stringToNull( string.valueOf( objRunning.get('UserId') ) );
        String running = stringToNull( string.valueOf( objRunning.get('No') ) );
        
        String strSegment = '';
        String strHub = '';
        String strUserId = '';
        String strDay = '';
        String strMonth = '';
        String strYear = '';
        String strRunning = '';
        Integer i = 0;
        String caid = '';
        
        strSegment = genNumber(segment,digitSegment);
        strHub = genNumber(hub,digitHub);
        strUserId = genNumber(userId,digitUserId);
        strDay = genNumber(String.valueOf(currentDay) ,digitday);
        strMonth = genNumber( String.valueOf(currentMonth) ,digitMonth);
        String strYY = String.valueOf(currentYear).substring(2,4);
        strYear = genNumber(strYY,digitYear);
        strRunning = genNumber(running,digitNo);
        
        return strSegment+strHub+strUserId+strDay+strMonth+strYear+strRunning;        
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