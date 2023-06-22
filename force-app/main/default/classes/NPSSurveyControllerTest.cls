@istest
public class NPSSurveyControllerTest {
    
    static {
         TestUtils.createIdType();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        TestUtils.createDateOfBirth();
        TestUtils.CreateProceBookAccess();
        List<Status_Code__c> statuslist = new List<Status_Code__c>();
        Status_Code__c error621 = new Status_Code__c();
        error621.isError__c = false;
        error621.Name = '6201';
        error621.Status_Message__c = 'Test1';
        statuslist.add(error621);
        Status_Code__c error622 = new Status_Code__c();
        error622.isError__c = false;
        error622.Name = '6202';
        error622.Status_Message__c = 'Test2';
        statuslist.add(error622);
        Status_Code__c error623 = new Status_Code__c();
        error623.isError__c = false;
        error623.Name = '6203';
        error623.Status_Message__c = 'Test3';
        statuslist.add(error623);
        insert statuslist;

          RTL_CampaignMember_Running_No__c cmrn = new RTL_CampaignMember_Running_No__c(
            Name = 'Campaign Member Running No',
            Running_No__c = '000000'
            );

        insert cmrn;

        
    }
    
    public static RecordType CommercialLeadRecordType {get{
        if(CommercialLeadRecordType ==null){
           CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CommercialLeadRecordType;
    }set;}
    
    
    
    public static testmethod void NPSSurveyControllerTest(){
        Lead leadRec = CreateCommercialleadforSurvey();
        SurveyMaster__c svmt = CreateSurveyMaster();
        Campaign camp = createCampaign();
        addLeadToCampaign(camp,leadrec);
        Campaign_Survey_Master__c cpsmt = new Campaign_Survey_Master__c ();
        cpsmt.Survey_Master__c = svmt.id;
        cpsmt.Campaign__c = camp.id;
        insert cpsmt;
        
         PageReference npssurveyPage = Page.NPS_Survey;
        Test.setCurrentPage(npssurveyPage);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', leadRec.id);
        NPSSurveyController npscon = new NPSSurveyController();
       
        npscon.SurveyID = svmt.id;
        npscon.SelectedSurveyMaster();
        npscon.dosave();
        npscon.completesurveyFromCSV();
        
        Survey__c existingsurvey = npscon.tempSurveyDetail;
        existingsurvey.Answer2__c = '2;3;4';
        update existingsurvey;
        ApexPages.StandardController controller = new ApexPages.StandardController (existingsurvey);
        NPSSurveyController npsstdcontroller = new NPSSurveyController(controller);
        npsstdcontroller.redirectProxy();
        ApexPages.currentPage().getParameters().put('id', existingsurvey.id);
        NPSSurveyController npsexisting = new NPSSurveyController();
        
        npsexisting.completesurvey();
        existingsurvey.Result__c = 'Completed';
        update existingsurvey;
        try{
          delete existingsurvey;  
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        
        
        
        
        Test.stopTest();
        
        
       
        
    }
    
    
    
    public static SurveyMaster__c CreateSurveyMaster(){
        
        List<SurveyMaster__c> svmtList = new List<SurveyMaster__c>();
        SurveyMaster__c svmt1 = new SurveyMaster__c ();
        svmt1.Active__c = true;
        svmt1.Additional_Feedback_Required_1__c  = true;
        svmt1.Answer1_1__c = '1';
        svmt1.Answer1_2__c = '2';
        svmt1.Answer1_3__c = '3';
        svmt1.Answer1_4__c = '4';
        svmt1.Question_Type_1__c = 'Free Text';
        svmt1.Question1__c = 'Question No. 1';
        svmt1.Topic__c = 'Topic Test';
        
        

        svmt1.Additional_Feedback_Required_2__c  = true;
        svmt1.Answer2_1__c = '1';
        svmt1.Answer2_2__c = '2';
        svmt1.Answer2_3__c = '3';
        svmt1.Answer2_4__c = '4';
        svmt1.Question_Type_2__c = 'Multi picklist';
        svmt1.Question2__c = 'Question No. 2';
        
        svmt1.Additional_Feedback_Required_3__c  = true;
        svmt1.Answer3_1__c = '1';
        svmt1.Answer3_2__c = '2';
        svmt1.Answer3_3__c = '3';
        svmt1.Answer3_4__c = '4';
        svmt1.Question_Type_3__c = 'Picklist';
        svmt1.Question3__c = 'Question No. 3';
        
        svmt1.Additional_Feedback_Required_4__c  = true;
        svmt1.Answer4_1__c = '1';
        svmt1.Answer4_2__c = '2';
        svmt1.Answer4_3__c = '3';
        svmt1.Answer4_4__c = '4';
        svmt1.Question_Type_4__c = 'Rating (0-10)';
        svmt1.Question4__c = 'Question No. 4';
        
        svmt1.Additional_Feedback_Required_5__c  = true;
        svmt1.Answer5_1__c = '1';
        svmt1.Answer5_2__c = '2';
        svmt1.Answer5_3__c = '3';
        svmt1.Answer5_4__c = '4';
        svmt1.Question_Type_5__c = '    Check box';
        svmt1.Question5__c = 'Question No. 5';
        
        
        
        svmtList.add(svmt1);
        
        
       
        
        
        insert svmt1;
        return svmt1;
        
            
    }
    
    public static void addLeadToCampaign(Campaign campRec,Lead leadrec){
        CampaignMember campMem = new CampaignMember();
        campMem.CampaignID = campRec.id;
        campMem.LeadID = leadrec.id;
        
        insert campMem;
        
    }
    
    public static Campaign createCampaign(){
            Campaign camp = new Campaign();
            camp.Name = 'Lead NPS Campaign';
            camp.Segment__c = 'SE';
            camp.OwnerId  = userinfo.getUserId();
        
        insert camp;
        
        return camp;
    }
    
    public static Lead CreateCommercialleadforSurvey(){
        
        Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
         insert leadRec;
        
        return leadRec;
    }

}