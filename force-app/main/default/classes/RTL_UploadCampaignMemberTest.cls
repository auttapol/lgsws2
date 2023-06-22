@isTest
private class RTL_UploadCampaignMemberTest {
	
    @testSetup static void setupData() {

        RTL_Campaign_Running_No__c rn = new RTL_Campaign_Running_No__c( 
                        Name ='Local Exclusive Campaign Running No.' , 
                        DateValue__c='170717',
                        Day__c='17',
                        Month__c='07',
                        Year__c='17',
                        Running_No__c = '01' );
        insert rn;

        //List<AppConfig__c> mc = new List<AppConfig__c> ();
        //mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'true'));
        AppConfig__c mc =new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        insert mc;

        //RecordType rt = [SELECT id FROM recordType WHERE DeveloperName   = 'Master_Campaign' ];

        //List<User> u = TestUtils.createUsers(1, 'UserTest' ,'User1' , 'test@email.com' , false);
        //insert u;

        //Campaign c = TestUtils.createCampaign(1,'CB',false).get(0);
        //c.RecordTypeId = rt.id;
        //c.RTL_Campaign_Type__c  = 'Local Exclusive';
        //insert c;

        RecordType rt = [SELECT id FROM recordType WHERE DeveloperName   = 'Exclusive_Campaign_Active' ];

        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@email.com' , false).get(0);
        u.IsActive = true;
        insert u;

        Campaign masterC = RTL_TestUtility.createMasterCampaign('MasterCam1',
            'D20171001',
            'Exclusive',
            'MB',u
            );
        insert masterC;

        Campaign childC = RTL_TestUtility.createChildCampaign('Campaign_0','1', masterC , rt) ;
        insert childC;

        Group gp = new Group();
        gp.Type = 'Queue';
        gp.Name = 'RTLQ_001';
        insert gp;

        Branch_and_Zone__c branch = new Branch_and_Zone__c();
        branch.RTL_Zone_Code__c = '6711';
        branch.Name = 'Test Branch';

        insert branch;

        //List<Account> ac = TestUtils.createAccounts(1, 'TestAccount','Individual',false);
        //ac[0].TMB_Customer_ID_PE__c = '001100000000000000000011279374';
        //ac[0].recordTypeId = '01290000000iZYGAA2';
        //insert ac;
        Account acct = RTL_TestUtility.createAccounts(1 , false).get(0);
        acct.TMB_Customer_ID_PE__c = '001100000000000000000011279374';
        acct.recordTypeId = '01290000000iZYGAA2';
        insert acct;

        RTL_product_master__c pm1 = new RTL_product_master__c();
        pm1.RTL_Product2_Name__c = 'INVESTMENT';
        insert pm1;

        //List<Contact> ct = TestUtils.createContacts(1,acct.id,false);
        //ct[0].TMB_Customer_ID__c = '001100000000000000000011279374';
        //insert ct;

        Contact ct = RTL_TestUtility.createContacts(acct);
        ct.OwnerId = u.id;
        ct.TMB_Customer_ID__c = '001100000000000000000011279374';
        insert ct;

        RTL_product_master__c p = new RTL_product_master__c(Name='TESTP',
                            Active__c=true);
        insert p;


        //mc.Value__c = 'true';
        //update mc;
    }
	
    @isTest 
    static void testUploadCSVWithCampaign() {
        List<String> listData = new list<String>{};
        listData.add('"TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","MOBILEPHONE","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","PRODUCT_OFFER","PROMOTION","TARGET","PRODUCT_FEATURE","REGISTER_DATE","LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","REMARK1","REMARK2","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","ADDRESS3","PROVINCE","ZIPCODE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","DATA_SOURCE","RATING","Lead Source","Source Reference","Campaign Lead Source","Campaign Lead Reference","Lead Group"');
        listData.add(',"Mr.","Lead 1","Last Name 1","0861839332","001",,"2:COMBO;",,,,,"MM010","Y","Y","Y","Y","Y","Y","Y","Y","หมายเหตุ","หมายเหตุ 2","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","บางเขน","เชียงใหม่","50180","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP",,"50",,,,"Hot ","Lead Source","Source Ref","Camp Lead Source","Camp Lead Ref","Lead Group"');
       

        // listData.add(',,,,,"003",,"2:COMBO;",,,,,"MM013","Y","Y","Y","Y","Y","Y","Y","Y","หมายเหตุ","หมายเหตุ 2","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","เชียงใหม่","50180","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,,"Hot "');
        // listData.add(',"Mr.","Lead 1","Last Name 1",,"002",,"2:COMBO;",,,,,"MM012","Y","Y","Y","Y","Y","Y","Y","Y","หมายเหตุ","หมายเหตุ 2","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","เชียงใหม่","50180","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,,"Hot "');
        //listData.add('"MM013","Y","Y","Y","Y","Y","Y","Y","Y","003",,,"","","","M","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","แม่ริม","เชียงใหม่","50180","","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,"2:COMBO;",,,,,,"หมายเหตุ","หมายเหตุ 2","Hot "');
        // listData.add('"001100000000000000000011279374",,,,,"001",,,,,,,,"Y","Y","Y",,"Y",,,,,,,"Citizen ID",,,,,,,,,,,,,,,,,');
        // listData.add(',"Mr.","Lead 5","Last Name 5","0861839336","001",,,,,,,"RTLQ_001","Y",,,,,,,,,,,"Passport ID ","3560500414041",,,,,"026339014",,,"123@mm.com",,,,,,,,"Low "');
        String csvStringBody = '';
        
        for(integer j=0;j<listData.size();j++){                          
            csvStringBody += listData.get(j)+'\r\n';
        }

        // Prepare CSV data
        //String csvDataUTF8 = EncodingUtil.urlEncode(csvStringBody, 'UTF-8');
        Blob csvFile = Blob.valueof(csvStringBody);

        User u = [SELECT id FROM User WHERE Email= 'test@email.com'];
        Campaign c = [SELECT id FROM Campaign WHERE Name='Campaign_0'];
        Group g = [SELECT id FROM Group WHERE Name='RTLQ_001'];
        Branch_and_Zone__c b = [SELECT id FROM Branch_and_Zone__c WHERE RTL_Zone_Code__c = '6711'];

        Test.startTest();

            System.runAs(u) 
            {
                RTL_UploadCampaignMemberService uc = new RTL_UploadCampaignMemberService();
                uc.csvFileBody = csvFile;
                uc.csvAsString = 'upload.csv';
                uc.selectedCampaignID = c.id;
                uc.importCSVFile();

                Integer maxFileSize  = uc.maxFileSize;
                String fileSizeError  = uc.fileSizeError;

            }
        Test.stopTest();
    }

	@isTest 
	static void testUploadCSVWithoutCampaign() {

		
		List<String> listData = new list<String>{};

        listData.add('"TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","MOBILEPHONE","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","PRODUCT_OFFER","PROMOTION","TARGET","PRODUCT_FEATURE","REGISTER_DATE","LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","REMARK1","REMARK2","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","PROVINCE","ZIPCODE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","FB_EMAIL","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","DATA_SOURCE","RATING","Lead Source","Source Reference","Campaign Lead Source","Campaign Lead Reference","Lead Group"');
        listData.add(',"Mr.","Lead 1","Last Name 1",,"002",,"2:COMBO;",,,,,"MM012","Y","Y","Y","Y","Y","Y","Y","Y","หมายเหตุ","หมายเหตุ 2","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","เชียงใหม่","50180","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,,"Hot ","Lead Source","Source Ref","Camp Lead Source","Camp Lead Ref","Lead Group"');


        //listData.add('"LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","GENDER","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","ADDRESS3","PROVINCE","ZIPCODE","MOBILEPHONE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","FB_EMAIL","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","PRODUCT_OFFER","REGISTER_DATE","DATA_SOURCE","PROMOTION","TARGET","PRODUCT_FEATURE","REMARK1","REMARK2","RATING"');
        //listData.add('"MM010","Y","Y","Y","Y","Y","Y","Y","Y","001",,,"Mr.","Lead 1","Last Name 1","M","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","แม่ริม","เชียงใหม่","50180","0861839332","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,"2:COMBO;",,,,,,"หมายเหตุ","หมายเหตุ 2","Hot "');
        String csvStringBody = '';
        
        for(integer j=0;j<listData.size();j++){             	         
            csvStringBody += listData.get(j)+'\r\n';
        }

        // Prepare CSV data
 		//String csvDataUTF8 = EncodingUtil.urlEncode(csvStringBody, 'UTF-8');
        Blob csvFile = Blob.valueof(csvStringBody);

        User u = [SELECT id FROM User WHERE Email= 'test@email.com'];
        Campaign c = [SELECT id FROM Campaign WHERE Name='Campaign_0'];
        Group g = [SELECT id FROM Group WHERE Name='RTLQ_001'];
        Branch_and_Zone__c b = [SELECT id FROM Branch_and_Zone__c WHERE RTL_Zone_Code__c = '6711'];

 		Test.startTest();

            System.runAs(u) 
            {
                RTL_UploadCampaignMemberService uc = new RTL_UploadCampaignMemberService();
                uc.csvFileBody = csvFile;
                uc.csvAsString = 'upload.csv';
                uc.importCSVFile();
                uc.getUploadLogs();
                uc.getIsAllowedUpload();

                
                uc.getPageMessage();

                List<SelectOption> CampaignSelectOptionList = uc.CampaignSelectOptionList;
                RecordType retailRCT = RTL_UploadCampaignMemberService.retailRCT;
                

                RTL_UploadCampaignMemberService.guid();
                RTL_UploadCampaignMemberService.processCSVdata( listData.get(1) );


            }

        Test.stopTest();
	}
	


    @isTest 
    static void testUploadCSVwrongFile() {
        List<String> listData = new list<String>{};
        listData.add('"LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","GENDER","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","ADDRESS3","PROVINCE","ZIPCODE","MOBILEPHONE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","FB_EMAIL","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","PRODUCT_OFFER","REGISTER_DATE","DATA_SOURCE","PROMOTION","TARGET","PRODUCT_FEATURE","REMARK1","REMARK2","RATING","MoreFiled"');
        listData.add('"MM010","Y","Y","Y","Y","Y","Y","Y","Y","001",,,"Mr.","Lead 1","Last Name 1","M","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","แม่ริม","เชียงใหม่","50180","0861839332","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,"2:COMBO;",,,,,,"หมายเหตุ","หมายเหตุ 2","Hot "');

        String csvStringBody = '';
        
        for(integer j=0;j<listData.size();j++){                          
            csvStringBody += listData.get(j)+'\r\n';
        }

        // Prepare CSV data
        //String csvDataUTF8 = EncodingUtil.urlEncode(csvStringBody, 'UTF-8');
        Blob csvFile = Blob.valueof(csvStringBody);

        User u = [SELECT id FROM User WHERE Email= 'test@email.com'];
        Campaign c = [SELECT id FROM Campaign WHERE Name='Campaign_0'];
        Group g = [SELECT id FROM Group WHERE Name='RTLQ_001'];
        Branch_and_Zone__c b = [SELECT id FROM Branch_and_Zone__c WHERE RTL_Zone_Code__c = '6711'];

        Test.startTest();

            System.runAs(u) 
            {
                RTL_UploadCampaignMemberService uc = new RTL_UploadCampaignMemberService();
                uc.csvFileBody = csvFile;
                uc.csvAsString = 'upload.csv';
                uc.importCSVFile();

            }
        Test.stopTest();
    }

    // @isTest 
    //static void testUploadCSVRowLimitFile() {
    //    List<String> listData = new list<String>{};
    //    listData.add('"LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","GENDER","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","ADDRESS3","PROVINCE","ZIPCODE","MOBILEPHONE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","FB_EMAIL","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","PRODUCT_OFFER","REGISTER_DATE","DATA_SOURCE","PROMOTION","TARGET","PRODUCT_FEATURE","REMARK1","REMARK2","RATING"');
        
    //    for(Integer x = 0;x<20002;x++)
    //    {
    //        listData.add('"MM010","Y","Y","Y","Y","Y","Y","Y","Y","00'+x+'",,,"Mr.","Lead 1","Last Name 1","M","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","แม่ริม","เชียงใหม่","50180","0861839332","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,"2:COMBO;",,,,,,"หมายเหตุ","หมายเหตุ 2","Hot "');
    //    }
    //    String csvStringBody = '';
        
    //    for(integer j=0;j<listData.size();j++){                          
    //        csvStringBody += listData.get(j)+'\r\n';
    //    }

    //    // Prepare CSV data
    //    //String csvDataUTF8 = EncodingUtil.urlEncode(csvStringBody, 'UTF-8');
    //    Blob csvFile = Blob.valueof(csvStringBody);

    //    User u = [SELECT id FROM User WHERE Email= 'test@email.com'];
    //    Campaign c = [SELECT id FROM Campaign WHERE Name='Campaign_0'];
    //    Group g = [SELECT id FROM Group WHERE Name='RTLQ_001'];
    //    Branch_and_Zone__c b = [SELECT id FROM Branch_and_Zone__c WHERE RTL_Zone_Code__c = '6711'];

    //    Test.startTest();

    //        System.runAs(u) 
    //        {
    //            RTL_UploadCampaignMemberService uc = new RTL_UploadCampaignMemberService();
    //            uc.csvFileBody = csvFile;
    //            uc.csvAsString = 'upload.csv';
    //            uc.importCSVFile();

    //        }
    //    Test.stopTest();
    //}


    @isTest
    static void testQueueWithCampaing()
    {

        List<String> listData = new list<String>{};
        listData.add('"TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","MOBILEPHONE","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","PRODUCT_OFFER","PROMOTION","TARGET","PRODUCT_FEATURE","REGISTER_DATE","LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","REMARK1","REMARK2","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","PROVINCE","ZIPCODE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","FB_EMAIL","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","DATA_SOURCE","RATING","Lead Source","Source Reference","Campaign Lead Source","Campaign Lead Reference","Lead Group"');
        listData.add(',"Mr.","Lead 1","Last Name 1","0861839332","001",,"2:COMBO;",,,,,"MM010","Y","Y","Y","Y","Y","Y","Y","Y","หมายเหตุ","หมายเหตุ 2","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","เชียงใหม่","50180","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,,"Hot ","Lead Source","Source Ref","Camp Lead Source","Camp Lead Ref","Lead Group"');
        listData.add(',,,,,"003",,"2:COMBO;",,,,,"MM013","Y","Y","Y","Y","Y","Y","Y","Y","หมายเหตุ","หมายเหตุ 2","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","เชียงใหม่","50180","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,,"Hot ","Lead Source","Source Ref","Camp Lead Source","Camp Lead Ref","Lead Group"');
        listData.add(',"Mr.","Lead 1","Last Name 1",,"002",,"2:COMBO;",,,,,"MM012","Y","Y","Y","Y","Y","Y","Y","Y","หมายเหตุ","หมายเหตุ 2","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","เชียงใหม่","50180","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,,"Hot ","Lead Source","Source Ref","Camp Lead Source","Camp Lead Ref","Lead Group"');
        //listData.add('"MM013","Y","Y","Y","Y","Y","Y","Y","Y","003",,,"","","","M","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","แม่ริม","เชียงใหม่","50180","","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,"2:COMBO;",,,,,,"หมายเหตุ","หมายเหตุ 2","Hot "');
        listData.add('"001100000000000000000011279374",,,,,"001",,,,,,,,"Y","Y","Y",,"Y",,,,,,,"Citizen ID",,,,,,,,,,,,,,,,,');
        listData.add(',"Mr.","Lead 5","Last Name 5","0861839336","001",,,,,,,"RTLQ_001","Y",,,,,,,,,,,"Passport ID ","3560500414041",,,,,"026339014",,,"123@mm.com",,,,,,,,"Low ","Lead Source","Source Ref","Camp Lead Source","Camp Lead Ref","Lead Group"');
        String csvStringBody = '';
        
        for(integer j=0;j<listData.size();j++){                          
            csvStringBody += listData.get(j)+'\r\n';
        }

        // Prepare CSV data
        //String csvDataUTF8 = EncodingUtil.urlEncode(csvStringBody, 'UTF-8');
        Blob csvFileBody = Blob.valueof(csvStringBody);

        User u = [SELECT id FROM User WHERE Email= 'test@email.com'];
        Campaign c = [SELECT id,Name FROM Campaign WHERE Name='Campaign_0'];
        Group g = [SELECT id FROM Group WHERE Name='RTLQ_001'];
        Branch_and_Zone__c b = [SELECT id FROM Branch_and_Zone__c WHERE RTL_Zone_Code__c = '6711'];

        Test.startTest(); 
            System.runAs(u) 
            {
                // new Upload_Campaign_Member_Logs__c
                RTL_Upload_Campaign_Member_Logs__c ucmL = new RTL_Upload_Campaign_Member_Logs__c();
                String batchName = '';
            
                ucmL.RTL_CampaignID__c = c.id;
                ucmL.RTL_Campaign__c = c.id;
                batchName = c.Name;
                
                ucmL.RTL_IsInProgress__c = true;
                ucmL.RTL_UploadStatus__c = 'Starting';
                // Insert new Upload_Campaign_Member_Logs__c
                insert ucmL;
                
                // Create new attachement from uploaded CSV 
                
                Attachment importattachmentfile = new Attachment();
                importattachmentfile.parentId = ucml.id;
                //importattachmentfile.name = 'Import Csv file : '+batchName+'.csv';
                importattachmentfile.name = 'Test';
                
                
                importattachmentfile.IsPrivate = true;
                importattachmentfile.body = csvFileBody;
                insert importattachmentfile;

                // Assign attacthment (CSV) to Upload_Campaign_Member_Logs__c
                ucml.RTL_Import_CSV_file_ID__c = importattachmentfile.id;
                
                // Update Upload_Campaign_Member_Logs__c (Add attachment)
                update ucml;

                RTL_UploadCampaignMemberSplitQueueable splitFileQueue = new RTL_UploadCampaignMemberSplitQueueable( ucml.id );
                splitFileQueue.execute(null);

                RTL_UploadCampaignMemberImportBatch importQueue = new RTL_UploadCampaignMemberImportBatch(ucml);
                importQueue.execute(null);

                //========== Make Recursive Queue end ===============
                RTL_Upload_Campaign_Member_Batch__c[] ucmbArray = [SELECT  ID,RTL_Status__c,RTL_Upload_Campaign_Member_Logs__c,
                    RTL_Upload_Campaign_Member_Logs__r.RTL_CampaignID__c,
                    RTL_Batch_No__c,RTL_Start_at_Row_No__c,RTL_End_at_Row_No__c
                        FROM RTL_Upload_Campaign_Member_Batch__c 
                        WHERE RTL_Status__c = 'In Queue'
                        AND RTL_Upload_Campaign_Member_Logs__c = :ucml.id
                        ORDER BY RTL_Batch_No__c
                        ];

                for(RTL_Upload_Campaign_Member_Batch__c ucmb : ucmbArray )
                {
                    ucmb.RTL_Status__c = 'Completed';
                }
                update ucmbArray;

                RTL_UploadCampaignMemberImportBatch importQueue2 = new RTL_UploadCampaignMemberImportBatch(ucml);
                importQueue2.execute(null);

            }
        Test.stopTest();

    }

    @isTest
    static void RTL_UploadCampaignMemberBatchTest()
    {

        List<String> listData = new list<String>{};

        listData.add('"TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","MOBILEPHONE","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","PRODUCT_OFFER","PROMOTION","TARGET","PRODUCT_FEATURE","REGISTER_DATE","LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","REMARK1","REMARK2","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","ADDRESS3","PROVINCE","ZIPCODE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","DATA_SOURCE","RATING","Lead Source","Source Reference","Campaign Lead Source","Campaign Lead Reference","Lead Group"');
        listData.add(',"Mr.","Lead 5","Last Name 5","0861839336","001",,,,,,,"RTLQ_001","Y",,,,,,,,,,,"Passport ID ","3560500414041",,,,,"026339014",,,"123@mm.com",,,,,,,,"Low ","Lead Source","Source Reference","Campaign Lead Source","Campaign Lead Reference","Lead Group"');
		listData.add(',,"สมคXXXXXXXXXX","แจ้YYYYYYYYYY","123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",,"20840","3:CYC",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,');
        
        //listData.add('"LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","GENDER","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","ADDRESS3","PROVINCE","ZIPCODE","MOBILEPHONE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","FB_EMAIL","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","PRODUCT_OFFER","REGISTER_DATE","DATA_SOURCE","PROMOTION","TARGET","PRODUCT_FEATURE","REMARK1","REMARK2","RATING"');
        //listData.add('"RTLQ_001","Y",,,,,,,,"001",,,"Mr.","Lead 5","Last Name 5","M",,"Passport ID ","3560500414041",,,,,,"0861839336","026339014",,,"123@mm.com",,,,,,,,,,,,,,,"Low "');
        String csvStringBody = '';
        
        for(integer j=0;j<listData.size();j++){                          
            csvStringBody += listData.get(j)+'\r\n';
        }

        // Prepare CSV data
        //String csvDataUTF8 = EncodingUtil.urlEncode(csvStringBody, 'UTF-8');
        Blob csvFileBody = Blob.valueof(csvStringBody);

        User u = [SELECT id FROM User WHERE Email= 'test@email.com'];
        Campaign c = [SELECT id,Name FROM Campaign WHERE Name='Campaign_0'];
        Group g = [SELECT id FROM Group WHERE Name='RTLQ_001'];
        Branch_and_Zone__c b = [SELECT id FROM Branch_and_Zone__c WHERE RTL_Zone_Code__c = '6711'];

        Test.startTest(); 
            System.runAs(u) 
            {
                // new Upload_Campaign_Member_Logs__c
                RTL_Upload_Campaign_Member_Logs__c ucmL = new RTL_Upload_Campaign_Member_Logs__c();
                String batchName = '';
            
                ucmL.RTL_CampaignID__c = c.id;

                
                ucmL.RTL_Campaign__c = c.id;
                batchName = c.Name;
                
                ucmL.RTL_IsInProgress__c = true;
                ucmL.RTL_UploadStatus__c = 'Starting';
                // Insert new Upload_Campaign_Member_Logs__c
                insert ucmL;
                
                // Create new attachement from uploaded CSV 
                
                Attachment importattachmentfile = new Attachment();
                importattachmentfile.parentId = ucml.id;
                //importattachmentfile.name = 'Import Csv file : '+batchName+'.csv';
                importattachmentfile.name = 'Test';
                
                
                importattachmentfile.IsPrivate = true;
                importattachmentfile.body = csvFileBody;
                insert importattachmentfile;

                // Assign attacthment (CSV) to Upload_Campaign_Member_Logs__c
                ucml.RTL_Import_CSV_file_ID__c = importattachmentfile.id;
                
                // Update Upload_Campaign_Member_Logs__c (Add attachment)
                update ucml;

                RTL_UploadCampaignMemberSplitQueueable splitFileQueue = new RTL_UploadCampaignMemberSplitQueueable( ucml.id );
                splitFileQueue.execute(null);

                RTL_UploadCampaignMemberImportBatch importQueue = new RTL_UploadCampaignMemberImportBatch(ucml);
                importQueue.execute(null);

                //========== Make Recursive Queue end ===============
                RTL_Upload_Campaign_Member_Batch__c[] ucmbArray = [SELECT  ID,RTL_Status__c,RTL_Upload_Campaign_Member_Logs__c,
                    RTL_Upload_Campaign_Member_Logs__r.RTL_CampaignID__c,
                    RTL_Batch_No__c,RTL_Start_at_Row_No__c,RTL_End_at_Row_No__c
                        FROM RTL_Upload_Campaign_Member_Batch__c 
                        WHERE RTL_Status__c = 'In Queue'
                        AND RTL_Upload_Campaign_Member_Logs__c = :ucml.id
                        ORDER BY RTL_Batch_No__c
                        ];

                for(RTL_Upload_Campaign_Member_Batch__c ucmb : ucmbArray )
                {
                    ucmb.RTL_Status__c = 'Completed';
                }
                update ucmbArray;

                RTL_UploadCampaignMemberImportBatch importQueue2 = new RTL_UploadCampaignMemberImportBatch(ucml);
                importQueue2.execute(null);

                List<RTL_Upload_Campaign_Members__c> ucmList = [SELECT id,RTL_ImportStatus__c 
                    FROM RTL_Upload_Campaign_Members__c 
                    WHERE RTL_Upload_Campaign_Member_Batch__c = : ucmbArray.get(0).id
                    ORDER BY RTL_Row_No__c ASC];

                for ( RTL_Upload_Campaign_Members__c ucm : ucmList )
                {
                    ucm.RTL_ImportStatus__c = null;
                }
                update ucmList;

                for(RTL_Upload_Campaign_Member_Batch__c ucmb : ucmbArray )
                {
                    RTL_UploadCampaignMemberBatch ucmBatch = new RTL_UploadCampaignMemberBatch(ucmL,ucmb);
                    Database.executeBatch(ucmBatch ,10);
                }

            }
        Test.stopTest();

    }

    @isTest 
    static void TestUploadCampaignMemberCreateLeadOhterFunct() {
        User u = [SELECT id FROM User WHERE Email= 'test@email.com'];
        RTL_product_master__c prd = new RTL_product_master__c(Product_Sub_group__c = 'abc' , Product_Group__c = 'ccc');
        insert prd;
        
        system.debug(prd);
        
        String productOfferString = '3:zas;1:asa;2:23f;1:22;2:22';
        
        Map<String,RTL_product_master__c > rpMap = new Map<String, RTL_product_master__c>();
        rpMap.put('zas', prd);
        system.debug(rpMap);
        
        
        Map<String,String> rpsgMap = new Map<String,String>();
        
        
        Test.startTest();

            System.runAs(u) 
            {
                           
                List<List<String>> res = RTL_UploadCampaignMemberCreateLead.generateProductOfferList(productOfferString, rpMap, rpsgMap);
				List<RTL_Interested_products_c__c> abc = RTL_UploadCampaignMemberCreateLead.generateProductInterestedList(productOfferString, rpMap);

            }
        Test.stopTest();
    }

    @isTest
    static void RTL_UploadCampaignMemberBatchTestbb()
    {

        List<String> listData = new list<String>{};

        listData.add('"TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","MOBILEPHONE","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","PRODUCT_OFFER","PROMOTION","TARGET","PRODUCT_FEATURE","REGISTER_DATE","LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","REMARK1","REMARK2","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","ADDRESS3","PROVINCE","ZIPCODE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","DATA_SOURCE","RATING","Lead Source","Source Reference","Campaign Lead Source","Campaign Lead Reference","Lead Group"');
        listData.add(',"Mr.","Lead 5","Last Name 5","0861839336","001",,,,,,,"RTLQ_001","Y","Y","Y","Y","Y","Y","Y","Y",,,,"Passport ID ","3560500414041",,,,,"026339014",,,"123@mm.com",,,,,,,,"Low ","Lead Source","Source Reference","Campaign Lead Source","Campaign Lead Reference","Lead Group"');

        listData.add('"001100000000000000000011279374",,,,,"001",,,,,,,,"Y","Y","Y",,"Y",,,,,,,"Citizen ID",,,,,,,,,,,,,,,,,');

        //listData.add('"LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","GENDER","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","ADDRESS3","PROVINCE","ZIPCODE","MOBILEPHONE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","FB_EMAIL","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","PRODUCT_OFFER","REGISTER_DATE","DATA_SOURCE","PROMOTION","TARGET","PRODUCT_FEATURE","REMARK1","REMARK2","RATING"');
        //listData.add('"RTLQ_001","Y",,,,,,,,"001",,,"Mr.","Lead 5","Last Name 5","M",,"Passport ID ","3560500414041",,,,,,"0861839336","026339014",,,"123@mm.com",,,,,,,,,,,,,,,"Low "');
        String csvStringBody = '';
        
        for(integer j=0;j<listData.size();j++){                          
            csvStringBody += listData.get(j)+'\r\n';
        }

        // Prepare CSV data
        //String csvDataUTF8 = EncodingUtil.urlEncode(csvStringBody, 'UTF-8');
        Blob csvFileBody = Blob.valueof(csvStringBody);

        User u = [SELECT id FROM User WHERE Email= 'test@email.com'];
        Campaign c = [SELECT id,Name FROM Campaign WHERE Name='Campaign_0'];
        Group g = [SELECT id FROM Group WHERE Name='RTLQ_001'];
        Branch_and_Zone__c b = [SELECT id FROM Branch_and_Zone__c WHERE RTL_Zone_Code__c = '6711'];

        Test.startTest(); 
            System.runAs(u) 
            {
                // new Upload_Campaign_Member_Logs__c
                RTL_Upload_Campaign_Member_Logs__c ucmL = new RTL_Upload_Campaign_Member_Logs__c();
                String batchName = '';
            
                ucmL.RTL_CampaignID__c = c.id;
                batchName = c.Name;
                
                ucmL.RTL_IsInProgress__c = true;
                ucmL.RTL_UploadStatus__c = 'Starting';
                // Insert new Upload_Campaign_Member_Logs__c
                insert ucmL;
                
                // Create new attachement from uploaded CSV 
                
                Attachment importattachmentfile = new Attachment();
                importattachmentfile.parentId = ucml.id;
                //importattachmentfile.name = 'Import Csv file : '+batchName+'.csv';
                importattachmentfile.name = 'Test';
                
                
                importattachmentfile.IsPrivate = true;
                importattachmentfile.body = csvFileBody;
                insert importattachmentfile;

                // Assign attacthment (CSV) to Upload_Campaign_Member_Logs__c
                ucml.RTL_Import_CSV_file_ID__c = importattachmentfile.id;
                
                // Update Upload_Campaign_Member_Logs__c (Add attachment)
                update ucml;

                RTL_UploadCampaignMemberSplitQueueable splitFileQueue = new RTL_UploadCampaignMemberSplitQueueable( ucml.id );
                splitFileQueue.execute(null);

                RTL_UploadCampaignMemberImportBatch importQueue = new RTL_UploadCampaignMemberImportBatch(ucml);
                importQueue.execute(null);

                //========== Make Recursive Queue end ===============
                RTL_Upload_Campaign_Member_Batch__c[] ucmbArray = [SELECT  ID,RTL_Status__c,RTL_Upload_Campaign_Member_Logs__c,
                    RTL_Upload_Campaign_Member_Logs__r.RTL_CampaignID__c,
                    RTL_Batch_No__c,RTL_Start_at_Row_No__c,RTL_End_at_Row_No__c
                        FROM RTL_Upload_Campaign_Member_Batch__c 
                        WHERE RTL_Status__c = 'In Queue'
                        AND RTL_Upload_Campaign_Member_Logs__c = :ucml.id
                        ORDER BY RTL_Batch_No__c
                        ];

                for(RTL_Upload_Campaign_Member_Batch__c ucmb : ucmbArray )
                {
                    ucmb.RTL_Status__c = 'Completed';
                }
                update ucmbArray;

                RTL_UploadCampaignMemberImportBatch importQueue2 = new RTL_UploadCampaignMemberImportBatch(ucml);
                importQueue2.execute(null);

                List<RTL_Upload_Campaign_Members__c> ucmList = [SELECT id,RTL_ImportStatus__c 
                    FROM RTL_Upload_Campaign_Members__c 
                    WHERE RTL_Upload_Campaign_Member_Batch__c = : ucmbArray.get(0).id
                    ORDER BY RTL_Row_No__c ASC];

                for ( RTL_Upload_Campaign_Members__c ucm : ucmList )
                {
                    ucm.RTL_ImportStatus__c = null;
                }
                update ucmList;

                for(RTL_Upload_Campaign_Member_Batch__c ucmb : ucmbArray )
                {
                    RTL_UploadCampaignMemberBatch ucmBatch = new RTL_UploadCampaignMemberBatch(ucmL,ucmb);
                    Database.executeBatch(ucmBatch ,10);
                }

            }
        Test.stopTest();

    }

    // @isTest
    // static void testQueueWithoutCampaing()
    // {

    //     List<String> listData = new list<String>{};
    //     listData.add('"TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","MOBILEPHONE","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","PRODUCT_OFFER","PROMOTION","TARGET","PRODUCT_FEATURE","REGISTER_DATE","LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","REMARK1","REMARK2","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","PROVINCE","ZIPCODE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","FB_EMAIL","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","DATA_SOURCE","RATING"');
    //     listData.add(',"Mr.","Lead 1","Last Name 1","0861839332","001",,"2:COMBO;",,,,,"MM010","Y","Y","Y","Y","Y","Y","Y","Y","หมายเหตุ","หมายเหตุ 2","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","เชียงใหม่","50180","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,,"Hot "');
    //     listData.add(',,,,,"003",,"2:COMBO;",,,,,"MM013","Y","Y","Y","Y","Y","Y","Y","Y","หมายเหตุ","หมายเหตุ 2","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","เชียงใหม่","50180","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,,"Hot "');
    //     listData.add(',"Mr.","Lead 1","Last Name 1",,"002",,"2:COMBO;",,,,,"MM012","Y","Y","Y","Y","Y","Y","Y","Y","หมายเหตุ","หมายเหตุ 2","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","เชียงใหม่","50180","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,,"Hot "');
    //     //listData.add('"MM013","Y","Y","Y","Y","Y","Y","Y","Y","003",,,"","","","M","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","แม่ริม","เชียงใหม่","50180","","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,"2:COMBO;",,,,,,"หมายเหตุ","หมายเหตุ 2","Hot "');
    //     listData.add('"001100000000000000000011279374",,,,,,"MM010",,,,,,,"Y","Y","Y",,"Y",,,,,,,"Citizen ID",,,,,,,,,,,,,,,,,');
    //     listData.add(',"Mr.","Lead 5","Last Name 5","0861839336","001",,,,,,,"RTLQ_001","Y",,,,,,,,,,,"Passport ID ","3560500414041",,,,,"026339014",,,"123@mm.com",,,,,,,,"Low "');
    //     String csvStringBody = '';

    //     //List<String> listData = new list<String>{};
    //     //listData.add('"LEAD_OWNER_QUEUE","CHANNEL_DM","CHANNEL_OB","CHANNEL_SMS","CHANNEL_EDM","CHANNEL_BRANCH","CHANNEL_MIB","CHANNEL_OBD","CHANNEL_OTHER","ASSIGN_BRANCH_CD","ASSIGN_EMP_ID","TMB_CUST_ID","TITLE","FIRSTNAME_TH","LASTNAME_TH","GENDER","AGE","ID TYPE","ID NUMBER","ADDRESS1","ADDRESS2","ADDRESS3","PROVINCE","ZIPCODE","MOBILEPHONE","HOMEPHONE","INCOME","OCCUPATION","EMAIL","FB_ID","FB_EMAIL","SEGMENT","COST_PER_LEAD","SOURCE","UPDATE_DATE","PRODUCT_OFFER","REGISTER_DATE","DATA_SOURCE","PROMOTION","TARGET","PRODUCT_FEATURE","REMARK1","REMARK2","RATING"');
    //     //listData.add('"MM010","Y","Y","Y","Y","Y","Y","Y","Y",,"12345",,"Mr.","Lead 1","Last Name 1","M","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","แม่ริม","เชียงใหม่","50180","0861839332","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,"2:COMBO;3:TESTP;1:INVESTMENT;3:TESTP;3:TESTP;3:TESTP;",,,,,,"หมายเหตุ","หมายเหตุ 2","Hot "');
    //     //listData.add('"MM010","Y","Y","Y","Y","Y","Y","Y","Y","001",,,"Mr.","Lead 1","Last Name 1","M","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","แม่ริม","เชียงใหม่","50180","0861839332","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,"2:COMBO;",,,,,,"หมายเหตุ","หมายเหตุ 2","Hot "');
    //     //listData.add('"MM010","Y","Y","Y","Y","Y","Y","Y","Y","002",,,"Mr.","Lead 1","Last Name 1","M","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","แม่ริม","เชียงใหม่","50180","","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,"2:COMBO;",,,,,,"หมายเหตุ","หมายเหตุ 2","Hot "');
    //     //listData.add('"MM010","Y","Y","Y","Y","Y","Y","Y","Y","003",,,"","","","M","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","แม่ริม","เชียงใหม่","50180","","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,"50",,,"2:COMBO;",,,,,,"หมายเหตุ","หมายเหตุ 2","Hot "');
    //     //listData.add(',"Y","Y","Y",,"Y",,,,"001",,"001100000000000000000011279374",,,,,,"Citizen ID",,,,,,,,,,,,,,,,,,,,,,,,,,');
    //     //listData.add(',"Y",,,"Y",,,,,"6711","12345","001100000000000000000011279384",,,,,,"Alien ID ",,,,,,,,,,,,,,,,,,,,,,,,,,');
    //     //listData.add(',"Y",,,"Y",,,,,"6711","12345","001100000000000000000011279381",,,,,,"Work permit ID ",,,,,,,,,,,,,,,,,,,,,,,,,,');
    //     //listData.add('"41735","Y","Y","Y","Y","Y","Y","Y","Y","001",,,"Mr.","Lead 1","Last Name 1","M","27 – 40 years","Citizen ID","3560500414041","78 ม5 ","ดอนแก้ว","แม่ริม","เชียงใหม่",50180,"0861839332","026339010","500","โปรแกรมเมอร์","123@mm.com","TeerasarnP","321@fb.com",,50,,,"1:INVESTMENT;2:MM;3:TESTP;3:TESTP;3:TESTP;3:TESTP;",,,,,,"หมายเหตุ","หมายเหตุ 2","Hot "');
    //     //String csvStringBody = '';
        
    //     for(integer j=0;j<listData.size();j++){                          
    //         csvStringBody += listData.get(j)+'\r\n';
    //     }

    //     // Prepare CSV data
    //     //String csvDataUTF8 = EncodingUtil.urlEncode(csvStringBody, 'UTF-8');
    //     Blob csvFileBody = Blob.valueof(csvStringBody);

    //     User u = [SELECT id FROM User WHERE Email= 'test@email.com'];
    //     Campaign c = [SELECT id,Name FROM Campaign WHERE Name='Campaign_0'];
    //     Group g = [SELECT id FROM Group WHERE Name='RTLQ_001'];
    //     Branch_and_Zone__c b = [SELECT id FROM Branch_and_Zone__c WHERE RTL_Zone_Code__c = '6711'];

    //     Test.startTest(); 
    //         System.runAs(u) 
    //         {
    //             // new Upload_Campaign_Member_Logs__c
    //             RTL_Upload_Campaign_Member_Logs__c ucmL = new RTL_Upload_Campaign_Member_Logs__c();
    //             //String batchName = '';
            
    //             ucmL.RTL_CampaignID__c = null;
    //             ucmL.RTL_Campaign__c = null;
    //             //batchName = c.Name;
                
    //             ucmL.RTL_IsInProgress__c = true;
    //             ucmL.RTL_UploadStatus__c = 'Starting';
    //             // Insert new Upload_Campaign_Member_Logs__c
    //             insert ucmL;
                
    //             // Create new attachement from uploaded CSV 
                
    //             Attachment importattachmentfile = new Attachment();
    //             importattachmentfile.parentId = ucml.id;
    //             importattachmentfile.name = 'Test';
                
                
    //             importattachmentfile.IsPrivate = true;
    //             importattachmentfile.body = csvFileBody;
    //             insert importattachmentfile;

    //             // Assign attacthment (CSV) to Upload_Campaign_Member_Logs__c
    //             ucml.RTL_Import_CSV_file_ID__c = importattachmentfile.id;
                
    //             // Update Upload_Campaign_Member_Logs__c (Add attachment)
    //             update ucml;

    //             RTL_UploadCampaignMemberSplitQueueable splitFileQueue = new RTL_UploadCampaignMemberSplitQueueable( ucml.id );
    //             splitFileQueue.execute(null);

    //             RTL_UploadCampaignMemberImportBatch importQueue = new RTL_UploadCampaignMemberImportBatch(ucml);
    //             importQueue.execute(null);

                
    //         }
    //     Test.stopTest();

    // }


    //@isTest
    //static void RTL_UploadCampaignMemberBatchTest()
    //{


    //    RTL_UploadCampaignMemberBatch ucmBatch = new RTL_UploadCampaignMemberBatch(ucmL,ucmb);
    //    Database.executeBatch(ucmBatch ,itemPerSaveMember);
    //}
	
}