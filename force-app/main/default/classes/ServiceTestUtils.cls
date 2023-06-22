public class ServiceTestUtils {    
    //Profile Type   
    private static Map<String, String> enumToString = new Map<String, String>
    {
        'SystemAdmin' => 'System Administrator',
            'TMBRM' => 'TMB RM Profile',
            'TMBBDM' =>'TMB BDM Profile',
            'TMBSegmentHead' => 'TMB Segment Head Profile'
            };
                private static Map<string, Profile> m_MainProfile {get;set;}        
    private static Map<string , Profile> getProfiles(){
        if(m_MainProfile == null){
            m_MainProfile = new Map<string, Profile>();
            
            //get Profile           
            for(Profile  profile : [SELECT Id, Name FROM Profile WHERE Name IN ('System Administrator' ,'TMB RM Profile','TMB BDM Profile', 'TMB Segment Head Profile')] ){
                m_MainProfile.put(profile.Name, profile);
            }             
        }
        return m_MainProfile;
    }
    public static Profile getProfileByName(EProfile eprofile){ 
        string name =   eprofile.name(); 
        return getProfiles().get(enumToString.get(name));
    }
    public  enum EProfile{
        SystemAdmin,TMBRM,TMBBDM,TMBSegmentHead
   }    
    public static List<User> createUsers(integer startNo, Integer size,String FName,String LName,String Email,ID setProfileID,Boolean isSESegment,Boolean doInsert) {
        List<User> userToCreate = new List<User>();
        for(Integer i = 0;i<size;i++){
            String segment;
            if(isSESegment){
                segment = 'SE';
            }else{
                Segment = 'BB';
            }
            User newUser = new User(FirstName=FName+(startNo + i), LastName=LName, 
                                    UserName=FName+'TestTMB@tmb.com.acctplan'+(startNo + i), 
                                    Email=Email, Alias=Fname,Segment__c =segment,
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname=Fname+LName+(startNo + i)+'Testtmb',
                                    ProfileId = setProfileID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='T001'+(startNo + i));
            userToCreate.add(newUser);
        }
        
        
        if(doInsert){            
            insert userToCreate;          
        }        
        return userToCreate;
    }
    
    
}