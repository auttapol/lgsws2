public with sharing class RTL_CampaignmemberHistoryExtension {

    class HistoryWrapper
    {
        public RTL_Campaign_Member_History_detail__c cmhd {get;set;}
        public String oldValue{get;set;}
        public String newValue{get;set;}
        public String filedLabel{get;set;}
        private String error = '{N/A}';

        private Set<String> pickListField {
            get{
                if (pickListField == null) 
                {
                    pickListField = new Set<String>();
                    pickListField.add('RTL_Contact_Status__c');
                    pickListField.add('RTL_Reason__c');
                    pickListField.add('Status');
                    pickListField.add('RTL_Invitation_Status__c');
                    pickListField.add('RTL_Attendant_Status__c');
                }
              return pickListField;

            } set;
        }

        private Set<String> customMapField {
            get{
                if (customMapField == null) 
                {
                    customMapField = new Set<String>();
                    customMapField.add('RTL_Offer_Result_Eng__c');
                }
              return customMapField;

            } set;
          }

        public HistoryWrapper(RTL_Campaign_Member_History_detail__c cmhdData)
        {
            cmhd = cmhdData;
            oldValue = getTranslatedValue( cmhd.RTL_Field_Old_Value__c );
            newValue = getTranslatedValue( cmhd.RTL_Field_New_Value__c );
            filedLabel = getLabel();
            


        }

        private String getLabel()
        {
            String label = '';
            try{
                DescribeSObjectResult objResult = Schema.getGlobalDescribe().get('CampaignMember').getDescribe();
                DescribeFieldResult fieldResult = objResult.fields.getMap().get(cmhd.RTL_Field_Name__c).getDescribe();
                label =  fieldResult.getLabel();
            }
            catch (Exception e)
            {
                label = error;
            }
            return label;
        }

        private String getTranslatedValue(String apiName)
        {
            String translatedValue = '';
            String filedName = cmhd.RTL_Field_Name__c;

            try
            {
                if(  pickListField.contains(filedName) )
                {
                    translatedValue = RTL_Utility.getLabelPicklist( apiName,filedName,'CampaignMember' );
                }
                else if(  customMapField.contains(filedName) )
                {
                    if( apiName == 'Pending' )
                    {
                        translatedValue = Label.RTL_Campaign_Member_Filter_Offer_Pending;
                    }
                    else if ( apiName == 'Interested' )
                    {
                        translatedValue = Label.RTL_Campaign_Member_Filter_Offer_Interest;
                    }
                    else if ( apiName == 'Not Interested' )
                    {
                        translatedValue = Label.RTL_Campaign_Member_Filter_Offer_NotInterest;
                    }
                    else if ( apiName == 'N/A' )
                    {
                        translatedValue = 'N/A';
                    }   
                    else 
                    {
                        translatedValue = error;
                    }
                    
                }
                else 
                {
                    translatedValue = apiName;
                }
            }
            catch (Exception e)
            {
                translatedValue = error;
            }
            
            return translatedValue;
        }
    }

    private final CampaignMember campaignMemberObj;
    public List <RTL_Campaign_Member_History__c> cmhList {get;set;}
    private List <RTL_Campaign_Member_History_detail__c> cmhdList;
    public Map<Id,List<RTL_Campaign_Member_History_detail__c>> cmhdMap {get;set;}

    public Map<Id,List<HistoryWrapper>> cmhdWrapperMap {get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public RTL_CampaignmemberHistoryExtension(ApexPages.StandardController stdController) {
        campaignMemberObj = (CampaignMember)stdController.getRecord();

        cmhList = [SELECT ID,RTL_Campaign_Member_ID__c,RTL_Campaign__c,
                            RTL_Contact__c,RTL_Date__c,RTL_Lead__c,RTL_Modified_By__c
                                                                     FROM RTL_Campaign_Member_History__c 
                                                                     WHERE RTL_Campaign_Member_ID__c =:campaignMemberObj.id
                                                                     ORDER BY RTL_Date__c DESC ];

        cmhdList = [SELECT ID,RTL_Field_Name__c,RTL_Field_New_Value__c,RTL_Field_Old_Value__c,RTL_Campaign_Member_History__c
                                                                    FROM  RTL_Campaign_Member_History_detail__c 
                                                                    WHERE RTL_Campaign_Member_History__c IN:cmhList
                                                                    ORDER BY CreatedDate DESC ];    
        cmhdMap = new Map<Id,List<RTL_Campaign_Member_History_detail__c>> ();
        cmhdWrapperMap = new Map<Id,List<HistoryWrapper>>();
        

        for(RTL_Campaign_Member_History_detail__c cmhd : cmhdList){

            HistoryWrapper cmhdWrapper = new HistoryWrapper(cmhd);

            if(cmhdMap.containsKey(cmhd.RTL_Campaign_Member_History__c)){
                cmhdMap.get(cmhd.RTL_Campaign_Member_History__c).add(cmhd);

                cmhdWrapperMap.get(cmhd.RTL_Campaign_Member_History__c).add(cmhdWrapper);

            }else{
                List<RTL_Campaign_Member_History_detail__c> cmhdChild = new List<RTL_Campaign_Member_History_detail__c>();
                cmhdChild.add(cmhd);
                cmhdMap.put(cmhd.RTL_Campaign_Member_History__c,cmhdChild);

                List<HistoryWrapper> cmhdWrapperChild = new List<HistoryWrapper>();
                cmhdWrapperChild.add(cmhdWrapper);
                cmhdWrapperMap.put(cmhd.RTL_Campaign_Member_History__c,cmhdWrapperChild);
            }
        }

        //Verify if cmhList existing in cmhdMap
        for( Integer i=0;i<cmhList.size();i++ )
        {
            if( cmhdMap.containsKey( cmhList.get(i).id ) == false )
            {
                cmhList.remove(i);
            }
        }

    }    

    public PageReference cancel(){
        PageReference returnPage;
        try{
            returnPage = UserInfo.getUiThemeDisplayed() == 'Theme3' ? new PageReference('/'+campaignMemberObj.id) : null;
        }catch(Exception e){
            //returnPage = new PageReference('/'+currentObject.Id);  
        }
        
        return returnPage;
    }

    public RTL_CampaignmemberHistoryExtension()
    {

    }
    public String getTranslatedValue()
    {
        return 'xxx';
    }                                                  
  
}