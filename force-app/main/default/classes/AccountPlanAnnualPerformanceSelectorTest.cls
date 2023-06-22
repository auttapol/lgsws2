@isTest
private class AccountPlanAnnualPerformanceSelectorTest {    
    @testSetup static void setupTestData(){
        List<AppConfig__c> mc = new List<AppConfig__c>();
        mc.Add(new  AppConfig__c(Name ='CertName' , Value__c= 'TMB_RSA'));
        mc.Add(new  AppConfig__c(Name ='runtrigger' , Value__c= 'false'));
        insert mc;
    }    
    public static Id InsertRecord() {
        Account acc = new Account(Name = 'TestAcct',Phone='050111222',Mobile_Number_PE__c  = '0801112233');  
        insert acc;        
        // Create On Annul Perfomance
        AcctAnnualPerformance__c acctplanAnnual = new AcctAnnualPerformance__c();
        acctplanAnnual.Account__c = acc.Id;
        acctplanAnnual.AS_FEE__c = 10000;
        acctplanAnnual.AVG_CASA__c   = 10000;
        acctplanAnnual.AVG_LOAN_OUT__c  = 10000;
        acctplanAnnual.BA_FEE__c  = 10000;
        acctplanAnnual.CREDIT_FEE__c  = 10000;
        acctplanAnnual.DERIVATIVES_FEE__c  = 10000;
        acctplanAnnual.DIRECT_CM_FEE__c  = 10000;
        acctplanAnnual.EDC_FEE__c  = 10000;
        acctplanAnnual.END_CASA__c  = 10000;
        acctplanAnnual.ENG_LOAN_OUT__c  = 10000;
        acctplanAnnual.Fee__c  = 10000;
        acctplanAnnual.FLEET_FEE__c  = 10000;
        acctplanAnnual.FRONT_END_FEE__c  = 10000;
        acctplanAnnual.FX_FEE__c  = 10000;
        acctplanAnnual.FX_VOLUME__c  = 10000;
        acctplanAnnual.IB_FEE__c  = 10000;
        acctplanAnnual.LG_FEE__c  = 10000;
        acctplanAnnual.NIIc__c  = 10000;
        acctplanAnnual.NIId__c  = 10000;
        acctplanAnnual.OTHER_CM_FEE__c  = 10000;
        acctplanAnnual.OTHER_FEE__c  = 10000;
        acctplanAnnual.TF_FEE__c  = 10000;
        acctplanAnnual.TF_VOLUME__c  = 10000;
        acctplanAnnual.TMB_CUST_ID__c  = 'TMBACCOUNTID';        
        if(Date.today().month()== 1 || Date.today().month()==2){
            Date dt   =   Date.newInstance(Date.today().year(), 1, 1);          
            //  move to last year
            dt =  dt.addDays(-1);
            acctplanAnnual.Transaction_Date__c =  dt;
            
        }
        else{
            acctplanAnnual.Transaction_Date__c=  Date.today();     
        }     
        Insert acctplanAnnual;          
        // AcctAnnualPerformance__c per = [select MonthYear__c From AcctAnnualPerformance__c where  id =: acctplanAnnual.Id];
        // system.debug(':::: MonthYear__c' + per.MonthYear__c);
        
        
        return acc.id;
    }
    // Code  coverate Only     
    @isTest static void TestThaiLocal(){
        boolean  isException = false;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User uThai = new User(Alias = 'standt', Email='standarduser@tmbbank.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='th_TH', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', Username= System.now().millisecond() + 'p***n.tmb**@***.com');
        insert uThai;
        string Year='';
        List<String>  filter;
        System.runAs(uThai) {
            Account acc = new Account(Name = 'TestAcct',Phone='050111222',Mobile_Number_PE__c  = '0801112233');  
            insert acc;             
            //Returns the current Datetime based on a GMT calendar.
            DateTime dt = DateTime.now();
            filter = AccountPlanAnnualPerformanceSelector.calucateMonthInQuery(dt);
            system.debug(':::: Vales Thai >> ' + filter);
        }
        
    }    
    @isTest static void TestEngLocal(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User uEng = new User(Alias = 'standt', Email='standarduser@tmbbank.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles',  Username= System.now().millisecond() + 'p***n.tmb**@***.com');
        insert uEng;
        List<String>  filter;
        System.runAs(uEng) {
            //Returns the current Datetime based on a GMT calendar.
            DateTime dt = DateTime.now();            
            filter = AccountPlanAnnualPerformanceSelector.calucateMonthInQuery(dt);
            system.debug(':::: Vales Eng >> ' + filter);
        }
        
    }        
    @isTest static void queryOneRecordFound() {        
        List<AcctAnnualPerformance__c> lstOfAcctplanAnnuals = null ;
        TestInit.createUser(false);
        User u = TestInit.us;
        System.runAs(u) {            
            // Arrang
            Id  accountId = InsertRecord();    
            // Act
            lstOfAcctplanAnnuals  =  AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDate(new Set<ID> { accountId },Date.today().addMonths(2));
        }
        system.debug('::: ' + lstOfAcctplanAnnuals);        
        // Return list is not null
        System.assertNotEquals(null,lstOfAcctplanAnnuals);        
        System.assertEquals(10000,lstOfAcctplanAnnuals[0].AS_FEE__c );
        
    }    
    @isTest static void queryOneRecordNotCompleteCauseNullParamDate(){
        List<AcctAnnualPerformance__c> lstOfAcctplanAnnuals = null ;
        TestInit.createUser(false);
        User u = TestInit.us;
        boolean isException = false;
        System.runAs(u) {            
            // Arrang
            Id  accountId = InsertRecord();    
            // Act
            try{
                lstOfAcctplanAnnuals  =  AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDate(new Set<ID> { accountId },null);
                
            }
            catch(AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceSelectorException ex){
                isException = true;
            }
            catch(Exception e){
                isException = false;
            }
        }
        system.assert(isException);
    }
    @isTest static void queryOneRecordNotCompleteCauseNullParamIds(){
        List<AcctAnnualPerformance__c> lstOfAcctplanAnnuals = null ;
        TestInit.createUser(false);
        User u = TestInit.us;
        boolean isException = false;
        System.runAs(u) {            
            // Arrang
            Id  accountId = InsertRecord();    
            // Act
            try{
                lstOfAcctplanAnnuals  =  AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDate(null,null);
                
            }
            catch(AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceSelectorException ex){
                isException = true;
            }
            catch(Exception e){
                isException = false;
            }
        }
        system.assert(isException);
    }
    @isTest static void query12LastMonthYear() {
        
        datetime currentDt = Date.today().addMonths(1);
        List<string> monthYearStr  =    AccountPlanAnnualPerformanceSelector.calucateMonthInQuery(currentDt);
        // last 12 month
        system.assertEquals(12 ,monthYearStr.size());
    } 
    @isTest static void query12LastMonthYearFromNow() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User uEng = new User(Alias = 'standt', Email='standarduser@tmbbank.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='th_TH', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles',  Username= System.now().millisecond() + 'p***n.tmb**@***.com');
        insert uEng;
        System.runAs(uEng) {
            datetime currentDt = datetime.now();
            
            system.debug('>>> currentDt '+ currentDt);
            
            List<string> monthYearStr  =    AccountPlanAnnualPerformanceSelector.calucateMonthInQuery(currentDt);
            system.debug('::::: Result >> '+monthYearStr );
            // last 12 month
            system.assertEquals(12 ,monthYearStr.size());
            Map<string, string> myMap = new Map<string, string>();
            for(string a: monthYearStr){
                myMap.put(a,a);
                system.debug('::: > ' + a);        
            }      
            currentDt = currentDt.addMonths(-11);
            integer year   =currentDt.year();
            if(UserInfo.getLocale() =='th_TH'){
                year = year - 543;
                
            }
            
            string verifyDate1 = 'M'+currentDt.month() +'Y'+ year;
            system.debug(':::verifyDate1 ' + verifyDate1);  
            system.assert(myMap.containsKey(verifyDate1));        
            
        }
    }  
    @isTest static void query12LastMonthYearFrom2015Month1() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User uEng = new User(Alias = 'standt', Email='standarduser@tmbbank.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='th_TH', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles',  Username= System.now().millisecond() + 'p***n.tmb**@***.com');
        insert uEng;
        System.runAs(uEng) {
            datetime currentDt =datetime.newInstance(2015, 1, 1);
            
            
            system.debug('>>> currentDt '+ currentDt);
            
            List<string> monthYearStr  =    AccountPlanAnnualPerformanceSelector.calucateMonthInQuery(currentDt);
            system.debug('::::: Result >> '+monthYearStr );
            // last 12 month
            system.assertEquals(12 ,monthYearStr.size());
            Map<string, string> myMap = new Map<string, string>();
            for(string a: monthYearStr){
                myMap.put(a,a);
                system.debug('::: > ' + a);        
            }      
            currentDt = currentDt.addMonths(-11);
            integer year   =currentDt.year();
            if(UserInfo.getLocale() =='th_TH'){
                year = year - 543;
                
            }
            
            string verifyDate1 = 'M'+currentDt.month() +'Y'+ year;
            system.debug(':::verifyDate1 ' + verifyDate1);  
            system.assert(myMap.containsKey(verifyDate1));        
            
        }
    }      
    @isTest static void verifyTimeOnTimeZone(){        
        string case1 ='';
        string case2 ='';       
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User uEng = new User(Alias = 'standt', Email='standarduser@tmbbank.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles', Username= System.now().millisecond() + 'p***n.tmb**@***.com');
        insert uEng;
        System.runAs(uEng) {
            Date currentDt = Date.today();
            system.debug('::: Date Time Case1    '   + currentDt);
            Account acc = new Account(Name = 'TestAcct',Phone='050111222',Mobile_Number_PE__c  = '0801112233');  
            insert acc;
            
            // Create On Annul Perfomance
            AcctAnnualPerformance__c acctplanAnnual = new AcctAnnualPerformance__c();
            acctplanAnnual.Account__c = acc.Id;
            acctplanAnnual.AS_FEE__c = 10000;
            acctplanAnnual.AVG_CASA__c   = 10000;
            acctplanAnnual.AVG_LOAN_OUT__c  = 10000;
            acctplanAnnual.BA_FEE__c  = 10000;
            acctplanAnnual.CREDIT_FEE__c  = 10000;
            acctplanAnnual.DERIVATIVES_FEE__c  = 10000;
            acctplanAnnual.DIRECT_CM_FEE__c  = 10000;
            acctplanAnnual.EDC_FEE__c  = 10000;
            acctplanAnnual.END_CASA__c  = 10000;
            acctplanAnnual.ENG_LOAN_OUT__c  = 10000;
            acctplanAnnual.Fee__c  = 10000;
            acctplanAnnual.FLEET_FEE__c  = 10000;
            acctplanAnnual.FRONT_END_FEE__c  = 10000;
            acctplanAnnual.FX_FEE__c  = 10000;
            acctplanAnnual.FX_VOLUME__c  = 10000;
            acctplanAnnual.IB_FEE__c  = 10000;
            acctplanAnnual.LG_FEE__c  = 10000;
            acctplanAnnual.NIIc__c  = 10000;
            acctplanAnnual.NIId__c  = 10000;
            acctplanAnnual.OTHER_CM_FEE__c  = 10000;
            acctplanAnnual.OTHER_FEE__c  = 10000;
            acctplanAnnual.TF_FEE__c  = 10000;
            acctplanAnnual.TF_VOLUME__c  = 10000;
            acctplanAnnual.TMB_CUST_ID__c  = 'TMBACCOUNTID';        
            acctplanAnnual.Transaction_Date__c=  currentDt;      
            Insert acctplanAnnual; 
            
            AcctAnnualPerformance__c per = [select Id, MonthYear__c From AcctAnnualPerformance__c where  id =: acctplanAnnual.Id];
            system.debug(':::: Case 1 : MonthYear__c + ' + per.MonthYear__c);
            case1 = per.MonthYear__c;
            string verifyDate1 = 'M'+currentDt.month() +'Y'+ currentDt.year();
            system.assertEquals(verifyDate1, case1);
        }        
        
        User uthai = new User(Alias = 'standt', Email='standarduser@tmbbank.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='th_TH', ProfileId = p.Id, 
                              TimeZoneSidKey='Asia/Bangkok',  Username= System.now().millisecond() + 'p***n.tmb**@***.com');
        insert uthai;
        System.runAs(uthai) {
            Date currentDt = Date.today();
            
            system.debug('::: Date Time Case2   ' + currentDt);
            
            Account acc = new Account(Name = 'TestAcct',Phone='050111222',Mobile_Number_PE__c  = '0801112233');  
            insert acc;        
            // Create On Annul Perfomance
            AcctAnnualPerformance__c acctplanAnnual = new AcctAnnualPerformance__c();
            acctplanAnnual.Account__c = acc.Id;
            acctplanAnnual.AS_FEE__c = 10000;
            acctplanAnnual.AVG_CASA__c   = 10000;
            acctplanAnnual.AVG_LOAN_OUT__c  = 10000;
            acctplanAnnual.BA_FEE__c  = 10000;
            acctplanAnnual.CREDIT_FEE__c  = 10000;
            acctplanAnnual.DERIVATIVES_FEE__c  = 10000;
            acctplanAnnual.DIRECT_CM_FEE__c  = 10000;
            acctplanAnnual.EDC_FEE__c  = 10000;
            acctplanAnnual.END_CASA__c  = 10000;
            acctplanAnnual.ENG_LOAN_OUT__c  = 10000;
            acctplanAnnual.Fee__c  = 10000;
            acctplanAnnual.FLEET_FEE__c  = 10000;
            acctplanAnnual.FRONT_END_FEE__c  = 10000;
            acctplanAnnual.FX_FEE__c  = 10000;
            acctplanAnnual.FX_VOLUME__c  = 10000;
            acctplanAnnual.IB_FEE__c  = 10000;
            acctplanAnnual.LG_FEE__c  = 10000;
            acctplanAnnual.NIIc__c  = 10000;
            acctplanAnnual.NIId__c  = 10000;
            acctplanAnnual.OTHER_CM_FEE__c  = 10000;
            acctplanAnnual.OTHER_FEE__c  = 10000;
            acctplanAnnual.TF_FEE__c  = 10000;
            acctplanAnnual.TF_VOLUME__c  = 10000;
            acctplanAnnual.TMB_CUST_ID__c  = 'TMBACCOUNTID';        
            acctplanAnnual.Transaction_Date__c=  currentDt;      
            Insert acctplanAnnual; 
            AcctAnnualPerformance__c per = [select Id, MonthYear__c From AcctAnnualPerformance__c where  id =: acctplanAnnual.Id ];                    
            system.debug(':::: Case 2 : MonthYear__c + ' + per.MonthYear__c);
            case2 = per.MonthYear__c;            
            string verifyDate2 = 'M'+currentDt.month() +'Y'+ (currentDt.year()-543);        
            system.assertEquals(verifyDate2, case2);   
        }
    }    
    @isTest static void checkLocalForDate(){
        Account acc = new Account(Name = 'TestAcct',Phone='050111222',Mobile_Number_PE__c  = '0801112233');  
        insert acc;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User uEng = new User(Alias = 'standt', Email='standarduser@tmbbank.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles',  Username= System.now().millisecond() + 'p***n.tmb**@***.com');
        insert uEng;
        System.runAs(uEng) {
            
            DateTime dt = Date.today();
            integer currentDt = dt.year();
            system.debug('DATE 1 : ' +currentDt );
            List<AcctAnnualPerformance__c> lstOfAcctplanAnnuals  =  AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDate(new Set<ID> { acc.Id },dt);
            
            
        }
        
        
        User uthai = new User(Alias = 'standt', Email='standarduser@tmbbank.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='th_TH', ProfileId = p.Id, 
                              TimeZoneSidKey='Asia/Bangkok', UserName='tmbstandarduser@testorg2.com');
        insert uthai;
        System.runAs(uthai) {
            DateTime dt = Date.today();
            integer currentDt = dt.year();
            system.debug('DATE 2 : ' +currentDt );
            List<AcctAnnualPerformance__c> lstOfAcctplanAnnuals  =  AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDate(new Set<ID> { acc.Id },dt);
        }
        
    }  
    @isTest static void selectGroupPerformance(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User uThai = new User(Alias = 'standt', Email='standarduser@tmbbank.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='th_TH', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', Username= System.now().millisecond() + 'p***n.tmb**@***.com');
        insert uThai;
        System.runAs(uThai) {
            Account acc = new Account(Name = 'TestAcct',Phone='050111222',Mobile_Number_PE__c  = '0801112233');  
            insert acc; 
            // Create On Annul Perfomance
            List<AcctAnnualPerformance__c> annuals = new List<AcctAnnualPerformance__c>();
            for(integer i =1 ; i<= 10 ; i++){
                AcctAnnualPerformance__c acctplanAnnual = new AcctAnnualPerformance__c();
                acctplanAnnual.Account__c = acc.Id;
                acctplanAnnual.AS_FEE__c = 10000;
                acctplanAnnual.AVG_CASA__c   = 10000;
                //acctplanAnnual.AVG_LOAN_OUT__c  = 10000;
                acctplanAnnual.BA_FEE__c  = 10000;
                acctplanAnnual.CREDIT_FEE__c  = 10000;
                acctplanAnnual.DERIVATIVES_FEE__c  = 10000;
                acctplanAnnual.DIRECT_CM_FEE__c  = 10000;
                acctplanAnnual.EDC_FEE__c  = 10000;
                acctplanAnnual.END_CASA__c  = 10000;
                acctplanAnnual.ENG_LOAN_OUT__c  = 10000;
                acctplanAnnual.Fee__c  = 10000;
                acctplanAnnual.FLEET_FEE__c  = 10000;
                acctplanAnnual.FRONT_END_FEE__c  = 10000;
                acctplanAnnual.FX_FEE__c  = 10000;
                acctplanAnnual.FX_VOLUME__c  = 10000;
                acctplanAnnual.IB_FEE__c  = 10000;
                acctplanAnnual.LG_FEE__c  = 10000;
                acctplanAnnual.NIIc__c  = 10000;
                acctplanAnnual.NIId__c  = 10000;
                acctplanAnnual.OTHER_CM_FEE__c  = 10000;
                acctplanAnnual.OTHER_FEE__c  = 10000;
                acctplanAnnual.TF_FEE__c  = 10000;
                acctplanAnnual.TF_VOLUME__c  = 10000;
                acctplanAnnual.TMB_CUST_ID__c  = 'TMBACCOUNTID';        
                  if(Date.today().month()== 1 || Date.today().month()==2){
            Date dt   =   Date.newInstance(Date.today().year(), 1, 1);          
            //  move to last year
            dt =  dt.addDays(-1);
            acctplanAnnual.Transaction_Date__c =  dt;
            
        }
        else{
            acctplanAnnual.Transaction_Date__c=  Date.today();     
        }     
                annuals.add(acctplanAnnual);
            }            
            Insert annuals;  
            
            List<AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> lstOfAcctplanAnnuals  
                =  AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroup(
                    new Set<ID> { acc.Id },Date.today().addMonths(2));
            
            system.assert(lstOfAcctplanAnnuals.size() > 0);
            system.assert(lstOfAcctplanAnnuals[0].AS_FEE == 100000);
            system.assert(lstOfAcctplanAnnuals[0].AVG_LOAN_OUT == 0);
        }
        
    }   
    @isTest static void selectGroupPerformanceNullParam(){
        
        boolean  isException = false;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User uThai = new User(Alias = 'standt', Email='standarduser@tmbbank.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='th_TH', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles',  Username= System.now().millisecond() + 'p***n.tmb**@***.com');
        insert uThai;
        
        
        System.runAs(uThai) {
            Account acc = new Account(Name = 'TestAcct',Phone='050111222',Mobile_Number_PE__c  = '0801112233');  
            insert acc; 
            
            try{
                List<AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> lstOfAcctplanAnnuals   =  AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroup(null,null);
                
            }
            catch(AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceSelectorException ex){
                isException = true;
            }
            catch(Exception e){
                isException = false;
            }
            
            system.assert(isException);
            isException = false;
            try{
                List<AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> lstOfAcctplanAnnuals   =  AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroup( new Set<ID> { acc.Id },null);
                
            }
            catch(AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceSelectorException ex){
                isException = true;
            }
            catch(Exception e){
                isException = false;
            }
            system.assert(isException);
            
            isException = false;
            
            try{
                List<String> lst   =  AccountPlanAnnualPerformanceSelector.calucateMonthInQuery(null);
                
            }
            catch(AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceSelectorException ex){
                isException = true;
            }
            catch(Exception e){
                isException = false;
            }
            system.assert(isException);
        }
        
    }
}