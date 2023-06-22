@isTest
public class ii_UserInfoExTest {
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        
        
    }
    public static testmethod void P_TestGetUserInfo(){
        User newUser1 = new User(FirstName='FName+i4', LastName='LName4', 
                                 UserName='T0014@tmb.com', 
                                 Email='TestTMB24@tmbbank.com', Alias='Tmb24',
                                 LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                 CommunityNickname='Testtmb1',
                                 ProfileId = TestUtils.SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                 Employee_ID__c ='T0014');
        insert newUser1;
        System.RunAs(newUser1){ 
            
            string empid =    ii_UserInfoEx.EmployeeId;
            System.assertNotEquals('', empid);
            Boolean ret =  empid.contains('t0014') ? true : false;
            
            System.debug(':::: empid1 > ' + empid);
            System.assertEquals(true, ret);
        }
    }
    
    
}