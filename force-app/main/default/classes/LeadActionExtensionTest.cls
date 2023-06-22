@isTest
public class LeadActionExtensionTest {
    static User ComUser1 = [select ID from user where isactive = true and ProfileId in (SELECT Id FROM Profile WHERE Name like '%BDM%' ) LIMIT 1];
    static {
        TestUtils.createAppConfig();
        TestUtils.createDisqualifiedReason(); 
        try {
            TestUtils.createObjUserPermission();
        } catch (Exception e){
            System.debug(e.getMessage());
        }
        TestInit.createCustomSettingTriggerMsg();    
    }    
    
    @testSetup static void setup() {
        RecordType rt = [select id,Name from RecordType where SobjectType='Lead' and Name='Commercial Account' Limit 1];
        RecordType visitrt = [select id,Name from RecordType where SobjectType='Call_Report__c' and Name='Visit Plan for Lead' Limit 1];

        Id pb1 = Test.getStandardPricebookId();
        pricebook2 pb2 = new pricebook2(name='test',isActive=true,TMB_Pricebook__c='test');insert pb2;
        product2 prod = new product2(name='test',isactive=true,Product_Domain__c='Risk');insert prod;
        pricebookentry pbe = new pricebookentry(isactive=true,unitprice=1.00,product2id=prod.id,pricebook2id=pb1,usestandardprice=false);insert pbe;
        pricebookentry pbe2 = new pricebookentry(isactive=true,unitprice=1.00,product2id=prod.id,pricebook2id=pb2.id);insert pbe2;
        user u = [select segment__c from user where id =: userinfo.getUserId()];
        u.segment__c = 'MB';
        update u;
        if (u.segment__c != null) insert new Price_book_access__c(name=u.segment__c,PricebookItem__c='test');
        else insert new Price_book_access__c(name='MB',PricebookItem__c='test');
        
        User us = TestUtils.createUsers(1,'Test','Leadactionextension','action@tmbbank.com',true).get(0);
        
        
        TestUtils.createStatusCode();
        
        Account acc1 = new Account ();
        //acc1.Office_Number_Temp__c = '0876213284';
        //acc1.Mobile_Number_Temp__c = '05689145';
        acc1.Rating = 'Hot';
        acc1.IsDisqualified__c = false;
        acc1.Customer_Type__c = 'Individual';
        acc1.First_name_PE__c = 'Visit';
        acc1.First_Name_ENG_PE__c = 'Visit';
        acc1.Last_name_PE__c = 'TestMock';
        acc1.Last_Name_PE_Eng__c  = 'TestMock';
        acc1.ID_Type_PE__c = 'Citizen ID';
        acc1.ID_Number_PE__c = '5100600076849';
        acc1.Name = 'Test Account';
        acc1.Segment_crm__c = '3';
        acc1.Phone ='345345';
        acc1.Phone ='050111222';
        acc1.OwnerId = us.id;
        acc1.Mobile_Number_PE__c  = '0801112233';
        acc1.TMB_Customer_ID_PE__c = '001100000000000000000000001235';
        
        insert acc1;
        
        List<Lead> leadinsert = new List<Lead>();
        Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.Status = 'Open';
        leadRec.ownerID = ComUser1.id;
        
        Lead leadRec2 = new Lead();
        leadRec2.Phone = '0877874871';
        leadRec2.Company = 'LeadExtension';
        leadRec2.ID_Type__c = 'Passport ID';
        leadRec2.ID_Number__c = '13255555';
        leadRec2.Mobile_No__c = '053532198';
        leadRec2.Customer_Type__c = 'Individual';
        leadRec2.FirstName =  'LeadExFirst';
        leadRec2.LastName = 'LeadExLast';
        leadRec2.account__c = acc1.id;
        leadRec2.Status = 'Failed Prescreening';
        leadRec2.ownerID = ComUser1.id;
        
        Lead leadRec3 = new Lead();
        leadRec3.Phone = '0877874871';
        leadRec3.Company = 'LeadExtension';
        leadRec3.ID_Type__c = 'Passport ID';
        leadRec3.ID_Number__c = '13255555';
        leadRec3.Mobile_No__c = '053532198';
        leadRec3.Customer_Type__c = 'Individual';
        leadRec3.FirstName =  'LeadExFirst';
        leadRec3.LastName = 'LeadExLast';
        leadRec3.Status = 'Contacted';
        leadRec3.recordtypeId = rt.Id;
        leadRec3.ownerID = ComUser1.id;
        
        
        Lead leadRec4 = new Lead();
        leadRec4.Phone = '0877874871';
        leadRec4.Company = 'LeadExtension';
        leadRec4.ID_Type__c = 'Passport ID';
        leadRec4.ID_Number__c = '13255555';
        leadRec4.FirstName =  'LeadExFirst';
        leadRec4.LastName = 'LeadExLast';
        leadRec4.Status = 'Contacted';
        leadRec4.Suggested_Team__c = 'BB';
        leadRec4.ownerID = ComUser1.id;
        
        Lead leadRec5 = new Lead();
        leadRec5.Phone = '0877874871';
        leadRec5.Company = 'LeadExtension';
        leadRec5.ID_Type__c = 'Passport ID';
        leadRec5.ID_Number__c = '13255555';
        leadRec5.FirstName =  'LeadExFirst';
        leadRec5.LastName = 'LeadExLast';
        leadRec5.Status = 'Contacted';
        leadRec5.Suggested_Team__c = 'BB';
        leadRec5.ownerID = ComUser1.id;
        //leadRec5.recordtypeId = rt.Id;
        
        
        Lead leadRec6 = new Lead();
        leadRec6.Phone = '0877874871';
        leadRec6.Company = 'LeadExtension';
        leadRec6.ID_Type__c = 'Passport ID';
        leadRec6.ID_Number__c = '13255555';
        leadRec6.FirstName =  'LeadExFirst';
        leadRec6.LastName = 'LeadExLast';
        leadRec6.Status = 'Contacted';
        leadRec6.account__c = acc1.id;
        leadRec6.recordtypeId = rt.Id;
        leadRec6.ownerID = ComUser1.id;
        
        
        
        Lead leadRec7 = new Lead();
        leadRec7.Phone = '0877874871';
        leadRec7.Company = 'LeadExtension';
        leadRec7.ID_Type__c = 'Passport ID';
        leadRec7.ID_Number__c = '13255555';
        leadRec7.FirstName =  'LeadExFirst';
        leadRec7.LastName = 'LeadExLast';
        leadRec7.Status = 'Contacted';
        leadRec7.Suggested_Team__c = 'BB';
        leadRec7.Mobile_No__c = '0911112345';
        leadRec7.Office_No__c = '0922518500';
        leadRec7.ownerID = ComUser1.id;
        
        leadinsert.add(leadRec);
        leadinsert.add(leadRec2);
        leadinsert.add(leadRec3);
        leadinsert.add(leadRec4);
        leadinsert.add(leadRec5);
        leadinsert.add(leadRec6);
        leadinsert.add(leadRec7);
        insert leadinsert;
        
        
        Call_Report__c cr = new Call_Report__c();
        cr.recordtypeId = visitrt.Id;
        cr.Lead__c = leadinsert[0].id;
        cr.Date_of_Visit__c = system.today();
        cr.Categories__c = 'Initiatives';
        cr.Main_purpose__c = 'CB';
        cr.Sub_Purpose__c = 'Cash_Fleet Card';
        cr.ownerid = ComUser1.id;
        insert cr;
        
        
        List<product_interest__c> inproduct = new List<product_interest__c>();
        product_interest__c pi = new product_interest__c();
        pi.Lead__c = leadinsert[3].id;
        pi.Product__c = prod.id;
        pi.Opportunity_Type__c = 'Credit';
        
        product_interest__c pi2 = new product_interest__c();
        pi2.Lead__c = leadinsert[5].id;
        pi2.Product__c = prod.id;
        pi2.Opportunity_Type__c = 'Credit';
        
        product_interest__c pi3 = new product_interest__c();
        pi3.Lead__c = leadinsert[6].id;
        pi3.Product__c = prod.id;
        pi3.Opportunity_Type__c = 'Credit';
        
        inproduct.add(pi);
        inproduct.add(pi2);
        inproduct.add(pi3);
        insert inproduct;
    }
    Public static testmethod void Prescreen() {
        List<Lead> leadinsert = [SELECT Id,Phone,Company,ID_Type__c,ID_Number__c,FirstName,LastName,Status,Suggested_Team__c,Mobile_No__c,Office_No__c,ownerID FROM Lead ORDER BY CreatedDate DESC];
        test.startTest();
        
        PageReference prescreen1 = Page.LeadAction;
        Test.setCurrentPage(prescreen1);
        ApexPages.currentPage().getParameters().put('id', leadinsert[0].id);
        ApexPages.currentPage().getParameters().put('action', 'prescreen');
         ApexPages.currentPage().getParameters().put('mode', '1');
        ApexPages.StandardController controllerpre1 = new ApexPages.StandardController(leadinsert[0]);
        LeadActionExtension leadact = new LeadActionExtension(controllerpre1);
        leadact.displayAction();
        leadact.backtoListview();
        leadact.selectAction();
        leadact.tempLead = leadinsert[0];
        leadact.tempLead.Pre_screening_Result__c = 'Failed';
        leadact.actSave();
        leadact.checkDupAction();
        
        ApexPages.StandardController controllerpre2 = new ApexPages.StandardController(leadinsert[0]);
        LeadActionExtension leadact2 = new LeadActionExtension(controllerpre2);
        leadact2.displayAction();
        leadact2.selectAction();
        leadact2.saveDesktop();
        leadact2.saveMobile();  
        leadact2.tempLead = leadinsert[0];
        leadact2.tempLead.Pre_screening_Result__c = 'Failed';
        leadact2.tempLead.Unqualified_Action__c = 'For Failed Prescreening';
        leadact2.actSave();
        
        ApexPages.StandardController controllerpre3 = new ApexPages.StandardController(leadinsert[0]);
        LeadActionExtension leadact3 = new LeadActionExtension(controllerpre3);
        leadact3.displayAction();
        leadact3.selectAction();
        leadact3.tempLead = leadinsert[0];
        leadact3.tempLead.Pre_screening_Result__c = 'Failed';
        leadact3.tempLead.Unqualified_Reasons__c = 'Credit issue';
        leadact3.actSave();
        
        ApexPages.StandardController controllerpre4 = new ApexPages.StandardController(leadinsert[0]);
        LeadActionExtension leadact4 = new LeadActionExtension(controllerpre4);
        leadact4.displayAction();
        leadact4.tempLead = leadinsert[0];
        leadact4.tempLead.Pre_screening_Result__c = 'Passed';
        leadact4.tempLead.Unqualified_Reasons__c = 'Credit issue';
        leadact4.actSave();
        
        
        ApexPages.StandardController controllerpre5 = new ApexPages.StandardController(leadinsert[0]);
        LeadActionExtension leadact5 = new LeadActionExtension(controllerpre5);
        leadact5.displayAction();
        leadact5.tempLead = leadinsert[0];
        leadact5.tempLead.Pre_screening_Result__c = 'Passed';
        leadact5.actSave();
        leadact5.checkDupAction();
        
        
        
        ApexPages.StandardController controllerpre15 = new ApexPages.StandardController(leadinsert[0]);
        LeadActionExtension leadact15 = new LeadActionExtension(controllerpre15);
        leadact15.displayAction();
        leadact15.tempLead = leadinsert[0];
        leadact15.tempLead.Pre_screening_Result__c = 'Failed';
        leadact15.tempLead.Unqualified_Reasons__c = 'test issue';
        leadact15.actSave();
        leadact15.saveMobile();
        leadact15.saveDesktop();

        
        PageReference reassign = Page.LeadAction;
        Test.setCurrentPage(reassign);
        ApexPages.currentPage().getParameters().put('id', leadinsert[0].id);
        ApexPages.currentPage().getParameters().put('action', 'reassign');
        
        ApexPages.StandardController controllerReassign = new ApexPages.StandardController(leadinsert[0]);
        LeadActionExtension leadRe = new LeadActionExtension(controllerReassign);
        leadRe.displayAction();
        leadRe.actSave();
        leadre.saveDesktop();

        
        
        PageReference reject = Page.LeadAction;
        Test.setCurrentPage(reject);
        ApexPages.currentPage().getParameters().put('id', leadinsert[0].id);
        ApexPages.currentPage().getParameters().put('action', 'reject');
        
        ApexPages.StandardController controllerReject = new ApexPages.StandardController(leadinsert[0]);
        LeadActionExtension leadReject = new LeadActionExtension(controllerReject);
        leadReject.displayAction();
        leadReject.actSave();
        
        
        
        PageReference Notinterest = Page.LeadAction;
        Test.setCurrentPage(Notinterest);
        ApexPages.currentPage().getParameters().put('id', leadinsert[0].id);
        ApexPages.currentPage().getParameters().put('action', 'notinterest');
        
        ApexPages.StandardController controllerNotIn = new ApexPages.StandardController(leadinsert[0]);
        LeadActionExtension leadNot = new LeadActionExtension(controllerNotIn);
        leadNot.displayAction();
        leadNot.actSave();
            
        
        
        PageReference prescreen2 = Page.LeadAction;
        Test.setCurrentPage(prescreen2);
        ApexPages.currentPage().getParameters().put('id', leadinsert[1].id);
        ApexPages.currentPage().getParameters().put('action', 'prescreen');
        
        ApexPages.StandardController controllerpre6 = new ApexPages.StandardController(leadinsert[1]);
        LeadActionExtension leadac6 = new LeadActionExtension(controllerpre6);
        leadac6.displayAction();
        leadac6.backtoListview();
        leadac6.selectAction();
        leadac6.tempLead = leadinsert[1];
        leadac6.tempLead.Pre_screening_Result__c = 'Failed';
        leadac6.tempLead.Unqualified_Reasons__c = 'Product not matched';
        leadac6.actSave(); 
        
        
        ApexPages.StandardController controllerpre11 = new ApexPages.StandardController(leadinsert[1]);
        LeadActionExtension leadac11 = new LeadActionExtension(controllerpre11);
        leadac11.displayAction();
        leadac11.backtoListview();
        leadac11.selectAction();
        leadac11.tempLead = leadinsert[1];
        leadac11.tempLead.Pre_screening_Result__c = 'Passed';
        leadac11.saveDesktop();
        leadac11.saveMobile();
        leadac11.actSave(); 
        
        
        PageReference prescreen3 = Page.LeadAction;
        Test.setCurrentPage(prescreen3);
        ApexPages.currentPage().getParameters().put('id', leadinsert[2].id);
        ApexPages.currentPage().getParameters().put('action', 'prescreen');
        
        ApexPages.StandardController controllerpre7 = new ApexPages.StandardController(leadinsert[2]);
        LeadActionExtension leadac7 = new LeadActionExtension(controllerpre7);
        leadac7.displayAction();
        leadac7.backtoListview();
        leadac7.selectAction();
        leadac7.tempLead = leadinsert[2];
        leadac7.tempLead.Pre_screening_Result__c = 'Passed';
        leadac7.actSave();
        
        
        
        PageReference reassign2= Page.LeadAction;
        Test.setCurrentPage(reassign2);
        ApexPages.currentPage().getParameters().put('id', leadinsert[2].id);
        ApexPages.currentPage().getParameters().put('action', 'reassign');
        
        ApexPages.StandardController controllerpre8 = new ApexPages.StandardController(leadinsert[2]);
        LeadActionExtension leadac8 = new LeadActionExtension(controllerpre8);
        leadac8.displayAction();
        leadac8.backtoListview();
        leadac8.selectAction();
        leadac8.actSave();
        leadac8.saveDesktop();
        leadac8.saveMobile();
        
        PageReference reassign3= Page.LeadAction;
        Test.setCurrentPage(reassign3);
        ApexPages.currentPage().getParameters().put('id', leadinsert[3].id);
        ApexPages.currentPage().getParameters().put('action', 'reassign');
        
        ApexPages.StandardController controllerpre9 = new ApexPages.StandardController(leadinsert[3]);
        LeadActionExtension leadac9 = new LeadActionExtension(controllerpre9);
        leadac9.displayAction();
        leadac9.backtoListview();
        leadac9.selectAction();
        leadac9.actSave();
        
        Test.StopTest();
         
    }
    
    Public static testmethod void Prescreen2() {
        test.startTest();
        List<Lead> leadinsert = [SELECT Id,Phone,Company,ID_Type__c,ID_Number__c,FirstName,LastName,Status,Suggested_Team__c,Mobile_No__c,Office_No__c,ownerID FROM Lead ORDER BY CreatedDate DESC];
        RecordType rt = [select id,Name from RecordType where SobjectType='Lead' and Name='Commercial Account' Limit 1];
        RecordType visitrt = [select id,Name from RecordType where SobjectType='Call_Report__c' and Name='Visit Plan for Lead' Limit 1];        
        
        PageReference reassign4= Page.LeadAction;
        Test.setCurrentPage(reassign4);
        ApexPages.currentPage().getParameters().put('id', leadinsert[4].id);
        ApexPages.currentPage().getParameters().put('action', 'reassign');
        
        ApexPages.StandardController controllerpre10 = new ApexPages.StandardController(leadinsert[4]);
        LeadActionExtension leadac10 = new LeadActionExtension(controllerpre10);
        leadac10.displayAction();
        leadac10.backtoListview();
        leadac10.selectAction();
        leadac10.actSave();
        
        
        
        PageReference Displayaction= Page.LeadAction;
        Test.setCurrentPage(Displayaction);
        ApexPages.currentPage().getParameters().put('id', leadinsert[4].id);
        
        ApexPages.StandardController controllerpre12 = new ApexPages.StandardController(leadinsert[4]);
        LeadActionExtension leadac12 = new LeadActionExtension(controllerpre12);
        leadac12.displayAction();
        
        
        
        PageReference reassign5= Page.LeadAction;
        Test.setCurrentPage(reassign5);
        ApexPages.currentPage().getParameters().put('id', leadinsert[5].id);
        ApexPages.currentPage().getParameters().put('action', 'reassign');
        
        ApexPages.StandardController controllerpre13 = new ApexPages.StandardController(leadinsert[5]);
        LeadActionExtension leadac13 = new LeadActionExtension(controllerpre13);
        leadac13.displayAction();
        leadac13.backtoListview();
        leadac13.selectAction();
        leadac13.actSave();
        leadac13.PreScreenResultChange();
        
        
        
        PageReference reassign6= Page.LeadAction;
        Test.setCurrentPage(reassign6);
        ApexPages.currentPage().getParameters().put('id', leadinsert[6].id);
        ApexPages.currentPage().getParameters().put('action', 'reassign');
        
        ApexPages.StandardController controllerpre14 = new ApexPages.StandardController(leadinsert[6]);
        LeadActionExtension leadac14 = new LeadActionExtension(controllerpre14);
        leadac14.displayAction();
        leadac14.backtoListview();
        leadac14.selectAction();
        leadac14.actSave();
        
        test.stoptest(); 
    }
}