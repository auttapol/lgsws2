@RestResource(urlMapping='/Referral/*')
global class RESTReferralWebservice {
    private static Integer SUCCESS = 200;
    private static Integer INTERNAL_ERR = 500;

    global class Response {
        public String Id;
        public String Name;
        public Integer Code;
    }

    @HttpPost
    global static Response createReferral(Map<String,String> jsonInput,Map<String,String> recordType){
        Response resp = new Response();
        String serviceName = 'Create_Referral_Advisory';
        Datetime startTime = datetime.now();
        String objectName = 'RTL_Referral__c';
        Sobject refObj = Schema.getGlobalDescribe().get(objectName).newSObject();
        
        try {
            Id recordTypeId = Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName()
                      .get(recordType.get('Name')).getRecordTypeId();

            refObj.put('RecordTypeId',recordTypeId);

            Map<String, Schema.SObjectField> fieldst = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

            for (String field : jsonInput.keySet()) {
                RTL_Utility.setRelationData(refObj,fieldst,field, jsonInput);
            } 


            String empNo = jsonInput.get('RTL_Referred_By_Id__c');

            List<User> userLst = [SELECT Id,Name
                                    ,Employee_ID__c
                                    ,MobilePhone
                                    ,RTL_Branch__c
                                    ,Zone_Code__c
                                    ,Region_Code__c 
                                    ,Zone__c
                                    ,Region__c
                                  From User Where Employee_ID__c =: empNo ];

            if (userLst != null && userLst.size() > 0) {
                User usr = userLst.get(0);
                refObj.put('RTL_EmployeeID__c',empNo);
                refObj.put('RTL_Employee_Name__c',usr.Name);
                refObj.put('RTL_Office_Number__c',usr.MobilePhone);
                refObj.put('RTL_Refer_Branch_Name__c',usr.RTL_Branch__c);
                //refObj.put('RTL_Zone_Team__c',usr.Zone_Code__c);
                //refObj.put('RTL_Region_Group__c',usr.Region_Code__c);

                refObj.put('RTL_Zone_Team__c',usr.Zone__c);
                refObj.put('RTL_Region_Group__c',usr.Region__c);
            }

            insert refObj;

            RTL_Referral__c ref = [SELECT Id,Name From RTL_Referral__c Where Id=:refObj.Id];

            resp.Code = SUCCESS;
            resp.Id   = ref.Id;
            resp.Name = ref.Name;

            RTL_CampaignUtil.saveToOnlineLog(true
                                , ''
                                , serviceName+'_Successfully'
                                , ''
                                , UserInfo.getName()
                                , ''
                                , serviceName
                                , String.valueOf(refObj)
                                , String.valueOf(resp)
                                , null
                                , startTime
                                ,datetime.now()
                                );

        }catch(Exception e) {
            resp.Code = INTERNAL_ERR;
            resp.Name = e.getMessage();
            

            RTL_CampaignUtil.saveToOnlineLog(false
                                , ''
                                , e.getMessage()
                                , ''
                                , UserInfo.getName()
                                , ''
                                , serviceName
                                , String.valueOf(refObj)
                                , String.valueOf(resp)
                                , null
                                , startTime
                                ,datetime.now()
                                );
        }
    	return resp;
    }

}