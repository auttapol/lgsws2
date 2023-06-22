global class RTL_UploadCampaignMemberImportBatch implements Queueable
{
	String ucmbId;
	RTL_Upload_Campaign_Member_Batch__c ucmb;
	RTL_Upload_Campaign_Member_Logs__c ucml;

	public RTL_UploadCampaignMemberImportBatch(RTL_Upload_Campaign_Member_Logs__c uploadCampaignMemberLog)
	{
		ucml = uploadCampaignMemberLog;

		String ucmlId = uploadCampaignMemberLog.id;

		// Get lowest sequnce of batch that status is inqueue to process
		RTL_Upload_Campaign_Member_Batch__c[] ucmbArray = [SELECT  ID,RTL_Status__c,RTL_Upload_Campaign_Member_Logs__c,
		 	RTL_Upload_Campaign_Member_Logs__r.RTL_CampaignID__c, RTL_Upload_Campaign_Member_Logs__r.RTL_Campaign__r.RecordType.DeveloperName,
		 	RTL_Batch_No__c,RTL_Start_at_Row_No__c,RTL_End_at_Row_No__c
				FROM RTL_Upload_Campaign_Member_Batch__c 
				WHERE RTL_Status__c = 'In Queue'
				AND RTL_Upload_Campaign_Member_Logs__c = :ucmlId
				ORDER BY RTL_Batch_No__c
				LIMIT 1
				];

		if( ucmbArray.size() > 0 )
		{
			ucmbId = ucmbArray[0].id;
			ucmb = ucmbArray[0];
		}
		else 
		{
			ucmbId = null;
		}
		
	}

	private void sendNotificationEmail()
    {
        Attachment bodyfile =[SELECT ID,Name,ParentID from Attachment WHERE ParentID =:ucml.id LIMIT 1];
        String originalFileName = bodyfile.Name;
        String rawFileName = '';
        if (originalFileName.indexOf('.') > 0)
        {
            rawFileName = originalFileName.substring(0, originalFileName.lastIndexOf('.'));
        }
        else
        {
            rawFileName = originalFileName;
        }
        
        //String logFileName = rawFileName + '[x-result log].csv';

        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        
        //PageReference pageRef = new PageReference('/apex/UploadCampaignMember');
        // String tagerUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/ui/support/servicedesk/ServiceDeskPage#/apex/RTL_UploadCampaignMember' + '#logview';
        String tagerUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/one/one.app#' + 
            EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'componentDef' => 'one:alohaPage',
                'attributes' => new Map<String, Object>{
                    'address' => URL.getSalesforceBaseUrl().toExternalForm() + '/apex/RTL_UploadCampaignMember#logview'
                }
            })));
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { userEmail };
        //message.optOutPolicy = 'FILTER';

        message.subject = String.format(  Label.RTL_UploadCampaignMember_Email_Header , new String[]{ originalFileName }  ) ;

        String resultTable = '<table style="border: 1px solid black;border-collapse: collapse;">'+
                                '<tr style="text-align:  center;">'+
                                '<td style="border: 1px solid black;">No.</td>'+
                                '<td style="border: 1px solid black;">File Name</td>'+
                                '<td style="border: 1px solid black;">Campaign Code</td>'+
                                '<td style="border: 1px solid black;">Campaign Name</td>'+
                                '<td style="border: 1px solid black;">Total Process Records</td>'+
                                '<td style="border: 1px solid black;">Success Records</td>'+
                                '<td style="border: 1px solid black;">Fail Records</td>'+
                            '</tr>';

        Integer count = 0;
        for( RTL_Upload_Campaign_Member_Import_Log__c ucmil : [SELECT ID , CreatedDate , Name,
                        RTL_Total_Record__c,RTL_Total_Success__c,RTL_Total_Fail__c,RTL_Total_Ignore__c, 
                        RTL_Batch_No__c , 
                        RTL_Upload_Campaign_Member_Logs__r.RTL_Campaign__r.name,
                        RTL_Upload_Campaign_Member_Logs__r.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c,
                        (SELECT Id, Name FROM Attachments LIMIT 1) 
                    FROM RTL_Upload_Campaign_Member_Import_Log__c 
                    WHERE RTL_Upload_Campaign_Member_Logs__c = :ucml.id
                    ORDER BY RTL_Upload_Campaign_Member_Logs__r.Name DESC,RTL_Batch_No__c 
                    ])
        {
            count++;
                    resultTable += '<tr>'+
                '<td style="border: 1px solid black;text-align:  right;">'+count+'</td>'+
                '<td style="border: 1px solid black;">'+ucmil.Attachments[0].Name+'</td>'+
                '<td style="border: 1px solid black;">'+ ( ucmil.RTL_Upload_Campaign_Member_Logs__r.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c != null ? ucmil.RTL_Upload_Campaign_Member_Logs__r.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c : '' ) +'</td>'+
                '<td style="border: 1px solid black;">'+ ( ucmil.RTL_Upload_Campaign_Member_Logs__r.RTL_Campaign__r.name != null ? ucmil.RTL_Upload_Campaign_Member_Logs__r.RTL_Campaign__r.name : ''  ) + '</td>'+
                '<td style="border: 1px solid black;text-align:  right;">'+ucmil.RTL_Total_Record__c+'</td>'+
                '<td style="border: 1px solid black;text-align:  right;">'+ucmil.RTL_Total_Success__c+'</td>'+
                '<td style="border: 1px solid black;text-align:  right;">'+ucmil.RTL_Total_Fail__c+'</td>'+
            '</tr>';

        }

        resultTable += '</table>';

        List<String> fillers = new String[]{ originalFileName, tagerUrl , resultTable };
        String content = String.format( Label.RTL_UploadCampaignMember_Email_Content , fillers );
        message.setHtmlBody(content);

        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
    }

	//public void process()
	public void execute(QueueableContext context) {	
        System.debug('Start UploadCampaignMemberImportBatch ' + system.now());
		if( ucmbId == null )
		{
			// This mean no In Queue Campaing Batch for processing , send email here

			ucmL.RTL_IsInProgress__c = false; 
			ucmL.RTL_UploadStatus__c = 'Complete';
	    	update ucmL;

	    	sendNotificationEmail();

		}
		else 
		{
			Attachment bodyfile = [SELECT ID, Body, ParentID FROM Attachment WHERE ParentID =: ucmbId LIMIT 1];	

			String csvdetail = bodyfile.body.tostring();
                  	
          	// Prepare data from split CSV
            List<String> csvdetail2 = new list<String>();

            String csvEOL = RTL_UploadCampaignMemberService.getEOL(csvdetail);

            // csvdetail2 = RTL_UploadCampaignMemberService.safeSplit(csvdetail, csvEOL);
            csvdetail2.addAll( RTL_UploadCampaignMemberService.safeSplit(csvdetail, csvEOL) ); 

            List<RTL_Upload_Campaign_Members__c> UploadCampMemList = new List<RTL_Upload_Campaign_Members__c>();

            // First loop to get all Product Name , Assigned Anget and Assigned Branch

            Set<String> productNameSet = new Set<String>();
            Set<String> assignedBranchSet = new Set<String>();
            Set<String> assignedAgentSet = new Set<String>();

            for(Integer i = 1 ; i < csvdetail2.size() ; i++){
                
                List<String> csvRecordDataTemp = csvdetail2[i].trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);
                List<String> csvRecordData = new List<String>();
                // Remove quote from column CSV string
                for( Integer j = 0 ; j < csvRecordDataTemp.size() ; j++){
                    csvRecordData.add(RTL_UploadCampaignMemberService.processCSVdata(csvRecordDataTemp[j]));
                }

                if(csvRecordData.size() == RTL_UploadCampaignMemberService.csvColumnNo) 
                {
                    String offerProduct = csvRecordData[7];
                    List<List<String>> productsOffer = RTL_UploadCampaignMemberCreateLead.processProductOfferString(offerProduct);

                    for( List<String> productItem : productsOffer  )
                    {
                        if(productItem.size() == 2 && productItem.get(0) == '3' )
                        {
                            productNameSet.add(productItem.get(1));
                        }
                        
                    }
                    
                    String branchCode =  csvRecordData[5];
                    if( branchCode != '' )
                    {
                        assignedBranchSet.add(branchCode);
                    }

                    String agentCode =  csvRecordData[6];
                    if( agentCode != '' )
                    {
                        assignedAgentSet.add(agentCode);
                    }
                    
                }

            }
            
            List<RTL_product_master__c> productList = [SELECT ID, Name FROM RTL_product_master__c WHERE name in :productNameSet];

            Set<String> existingProductName = new Set<String>();

            for( RTL_product_master__c productObj : productList )
            {
                existingProductName.add(productObj.name);
            }

            Set<String> existingSubGroupName = new Set<String>();
            Schema.DescribeFieldResult fieldResult = CampaignMember.RTL_Sub_Group_1__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            for( Schema.PicklistEntry pickListVal : ple){
                existingSubGroupName.add(pickListVal.getLabel().tolowercase() );
            }

            Set<String> existingGroupName = new Set<String>();
            Schema.DescribeFieldResult fieldResult2 = CampaignMember.RTL_Product_Group_1__c.getDescribe();
            List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();

            for( Schema.PicklistEntry pickListVal : ple2){
                existingGroupName.add(pickListVal.getLabel().tolowercase() );
            }     

            Set<String> existingBranchCode = new Set<String>();

            for( Branch_and_Zone__c bc : [SELECT id,Branch_Code__c 
                    FROM Branch_and_Zone__c 
                    WHERE Branch_Code__c IN :assignedBranchSet
                    AND IsActive__c = true
                    ])
            {
                existingBranchCode.add(bc.Branch_Code__c);
            }

            Set<String> existingAgentCode = new Set<String>();
            for(User us : [SELECT ID,Employee_ID__c
                        FROM User 
                        WHERE Employee_ID__c IN:assignedAgentSet
                        AND IsActive = true
                        ])
            {
                existingAgentCode.add(us.Employee_ID__c);
            }

			// Loop to each CSV line and set up upload member
            //strart from row 2
            for(Integer i = 1 ; i < csvdetail2.size() ; i++){

                List<String> csvRecordDataTemp = csvdetail2[i].trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);

                List<String> csvRecordData = new List<String>();

                    // Remove quote from column CSV string
                for( Integer j = 0 ; j < csvRecordDataTemp.size() ; j++){
                    csvRecordData.add(RTL_UploadCampaignMemberService.processCSVdata(csvRecordDataTemp[j]));
                }

                //System.debug('CSVDATA : ' + csvRecordData + csvRecordData.size() + RTL_UploadCampaignMemberService.csvColumnNo);
					// If CSV column equal to 48 , process
                if(csvRecordData.size() == RTL_UploadCampaignMemberService.csvColumnNo) {	

                    boolean isAllBlank = true;
                    for(String recorddate : csvRecordData){
                        if(recorddate !=null && recorddate !=''){
                            isAllBlank = false;
                        }
                    }

						// prepare data for Upload_Campaign_Members__c
                    RTL_Upload_Campaign_Members__c ucm = new RTL_Upload_Campaign_Members__c();                               
                        
                        // check if record not blank in CSV
                    if(!isAllBlank){
                        	
                        // Assign data to object
                        ucm.RTL_Row_No__c = i + ( ucmb.RTL_Start_at_Row_No__c - 1 );
                        ucm.RTL_CampaignID__c = ucmb.RTL_Upload_Campaign_Member_Logs__r.RTL_CampaignID__c;
                        ucm.RTL_Upload_Campaign_Member_Batch__c = ucmb.ID;
                        ucm.RTL_Upload_Campaign_Member_Logs__c = ucmb.RTL_Upload_Campaign_Member_Logs__c;


                        //=================== New arrange column (// {excel column}) ===============================
                        ucm.RTL_TMBCustID__c = csvRecordData[0]; //A

                        ucm.RTL_Title__c = csvRecordData[1]; //B
                        ucm.RTL_FirstName__c = csvRecordData[2]; //C
                        ucm.RTL_LastName__c = csvRecordData[3]; //D

                        ucm.RTL_MOBILEPHONE__c = csvRecordData[4]; //E
                        ucm.RTL_AssignedBranch__c  = csvRecordData[5]; //F
                        ucm.RTL_AssignedRM__c = csvRecordData[6]; //G

                        ucm.RTL_PRODUCT_OFFER__c = csvRecordData[7]; // H
                        ucm.RTL_PROMOTION__c = csvRecordData[8]; // I
                        ucm.RTL_TARGET__c = csvRecordData[9]; // J
                        ucm.RTL_PRODUCT_FEATURE__c = csvRecordData[10]; // K
                        ucm.RTL_REGISTER_DATE__c = csvRecordData[11]; //L

                        ucm.RTL_leadOwner__c = csvRecordData[12]; //M

                        ucm.RTL_CHANNEL_DM__c = csvRecordData[13]; //N
                        ucm.RTL_CHANNEL_OB__c = csvRecordData[14]; //O
                        ucm.RTL_CHANNEL_SMS__c = csvRecordData[15]; //P
                        ucm.RTL_CHANNEL_EDM__c = csvRecordData[16]; //Q
                        ucm.RTL_CHANNEL_BRANCH__c = csvRecordData[17]; //R
                        ucm.RTL_CHANNEL_MIB__c = csvRecordData[18]; //S
                        ucm.RTL_CHANNEL_OBD__c = csvRecordData[19]; //T
                        ucm.RTL_CHANNEL_OTHER__c  = csvRecordData[20]; //U
                        ucm.RTL_REMARK1__c = csvRecordData[21]; //V
                        ucm.RTL_REMARK2__c = csvRecordData[22]; //W

                        ucm.RTL_AGE__c = csvRecordData[23]; //X
                        ucm.RTL_ID_Type__c = csvRecordData[24]; //Y
                        ucm.RTL_Citizen_ID__c = csvRecordData[25]; //Z

                        ucm.RTL_ADDRESS1__c = csvRecordData[26]; //AA
                        ucm.RTL_ADDRESS2__c = csvRecordData[27]; //AB ***************** City -> address 2
                        ucm.RTL_ADDRESS3__c = csvRecordData[28]; //AC District

                        ucm.RTL_PROVINCE__c = csvRecordData[29]; //AD
                        ucm.RTL_ZIPCODE__c = csvRecordData[30]; //AE
                        ucm.RTL_HOMEPHONE__c = csvRecordData[31]; //AF ****************  phone no (AE) -> lead  rtl_phone_no

                        ucm.RTL_INCOME__c = csvRecordData[32]; //AG
                        ucm.RTL_OCCUPATION__c = csvRecordData[33]; //AH
                        ucm.RTL_Email_Address__c = csvRecordData[34]; //AI
                        ucm.RTL_FB_ID__c = csvRecordData[35]; //AJ
                        // ucm.RTL_FB_EMAIL__c = csvRecordData[36]; //AK remove this field

                        ucm.RTL_Segment__c = csvRecordData[36]; //AL

                        ucm.RTL_COST_PER_LEAD__c = csvRecordData[37]; //AM
                        ucm.RTL_SOURCE__c = csvRecordData[38]; // AN
                        ucm.RTL_UPDATE_DATE__c = csvRecordData[39]; //AO

                        ucm.RTL_DATA_SOURCE__c = csvRecordData[40]; //AP
                        ucm.RTL_Rating__c = csvRecordData[41]; //AQ

                        ucm.LeadSource__c = csvRecordData[42];//AR
                        ucm.RTL_Source_Reference__c = csvRecordData[43]; //AS
                        ucm.RTL_TMB_Campaign_Source__c = csvRecordData[44]; //AT
                        ucm.RTL_TMB_Campaign_Reference__c = csvRecordData[45]; //AU
                        ucm.RTL_Customer_Segment__c = csvRecordData[46]; //AV
                        ucm.RTL_Web_Unique_ID__c = csvRecordData[47]; //AW


                        //=================== New arrange column ===============================

                        // ucm.RTL_leadOwner__c = csvRecordData[0];

                        // ucm.RTL_CHANNEL_DM__c = csvRecordData[1];
                        // ucm.RTL_CHANNEL_OB__c = csvRecordData[2];
                        // ucm.RTL_CHANNEL_SMS__c = csvRecordData[3];
                        // ucm.RTL_CHANNEL_EDM__c = csvRecordData[4];
                        // ucm.RTL_CHANNEL_BRANCH__c = csvRecordData[5];
                        // ucm.RTL_CHANNEL_MIB__c = csvRecordData[6];
                        // ucm.RTL_CHANNEL_OBD__c = csvRecordData[7];
                        // ucm.RTL_CHANNEL_OTHER__c  = csvRecordData[8];
                        // ucm.RTL_AssignedBranch__c  = csvRecordData[9];
                        // ucm.RTL_AssignedRM__c = csvRecordData[10];

                        // ucm.RTL_TMBCustID__c = csvRecordData[11];
                        // ucm.RTL_Title__c = csvRecordData[12];
                        // ucm.RTL_FirstName__c = csvRecordData[13];
                        // ucm.RTL_LastName__c = csvRecordData[14];
                        // ***** // ucm.RTL_GENDER__c = csvRecordData[15];
                        // ucm.RTL_AGE__c = csvRecordData[16];
                        // ucm.RTL_ID_Type__c = csvRecordData[17];
                        // ucm.RTL_Citizen_ID__c = csvRecordData[18];
                        // ucm.RTL_ADDRESS1__c = csvRecordData[19];
                        // ucm.RTL_ADDRESS2__c = csvRecordData[20];

                        // *****// ucm.RTL_ADDRESS3__c = csvRecordData[21];
                        // ucm.RTL_PROVINCE__c = csvRecordData[22];
                        // ucm.RTL_ZIPCODE__c = csvRecordData[23];
                        // ucm.RTL_MOBILEPHONE__c = csvRecordData[24];
                        // ucm.RTL_HOMEPHONE__c = csvRecordData[25];
                        // ucm.RTL_INCOME__c = csvRecordData[26];
                        // ucm.RTL_OCCUPATION__c = csvRecordData[27];
                        // ucm.RTL_Email_Address__c = csvRecordData[28];
                        // ucm.RTL_FB_ID__c = csvRecordData[29];
                        // ucm.RTL_FB_EMAIL__c = csvRecordData[30];

                        // ucm.RTL_Customer_Segment__c = csvRecordData[31];
                        // ucm.RTL_COST_PER_LEAD__c = csvRecordData[32];
                        // ucm.RTL_SOURCE__c = csvRecordData[33];
                        // ucm.RTL_UPDATE_DATE__c = csvRecordData[34];
                        // ucm.RTL_PRODUCT_OFFER__c = csvRecordData[35];
                        // ucm.RTL_REGISTER_DATE__c = csvRecordData[36];
                        // ucm.RTL_DATA_SOURCE__c = csvRecordData[37];
                        // ucm.RTL_PROMOTION__c = csvRecordData[38];
                        // ucm.RTL_TARGET__c = csvRecordData[39];
                        // ucm.RTL_PRODUCT_FEATURE__c = csvRecordData[40]; 

                        // ucm.RTL_REMARK1__c = csvRecordData[41];
                        // ucm.RTL_REMARK2__c = csvRecordData[42];
                        // ucm.RTL_Rating__c = csvRecordData[43];

                        // if tmb cust id not defined  . name + surname and mobile phone within current job must unique
                        if(  ucm.RTL_TMBCustID__c == '' ||  ucm.RTL_TMBCustID__c == null ){
                            //Verify data
                            if( ucm.RTL_MOBILEPHONE__c == '' ){
                                ucm.RTL_ImportStatus__c = 'Failed';
                                ucm.RTL_ImportStatusDescription__c = 'Mobile Phone Cannot empty.';
                                ucm.RTL_Batch_Name__c = RTL_UploadCampaignMemberService.guid();
                                ucm.RTL_Batch_Telephone__c = RTL_UploadCampaignMemberService.guid();
                            }
                            else if( ucm.RTL_FirstName__c == '' ){
                                ucm.RTL_ImportStatus__c = 'Failed';
                                ucm.RTL_ImportStatusDescription__c = 'Firstname cannot empty.';
                                ucm.RTL_Batch_Name__c = RTL_UploadCampaignMemberService.guid();
                                ucm.RTL_Batch_Telephone__c = RTL_UploadCampaignMemberService.guid();
                            }
                            else if( ucm.RTL_LastName__c == ''){
                                ucm.RTL_ImportStatus__c = 'Failed';
                                ucm.RTL_ImportStatusDescription__c = 'Lastname cannot empty.';
                                ucm.RTL_Batch_Name__c = RTL_UploadCampaignMemberService.guid();
                                ucm.RTL_Batch_Telephone__c = RTL_UploadCampaignMemberService.guid();
                            }
                            // If name and phone pass verify , create unique string for futher check duplicate
                            else {
                                ucm.RTL_Batch_Name__c = ucm.RTL_FirstName__c +ucm.RTL_LastName__c  + ucmb.RTL_Upload_Campaign_Member_Logs__c;
                                ucm.RTL_Batch_Telephone__c =  ucm.RTL_MOBILEPHONE__c + ucmb.RTL_Upload_Campaign_Member_Logs__c;
                            }
                            
                        }
                            // Else , this field will empty , so set uuid to make it unique
                        else{
                            // ucm.RTL_Batch_Name__c = RTL_UploadCampaignMemberService.guid();
                            // ucm.RTL_Batch_Telephone__c = RTL_UploadCampaignMemberService.guid();
                            ucm.RTL_Batch_Telephone__c =  ucm.RTL_MOBILEPHONE__c + ucmb.RTL_Upload_Campaign_Member_Logs__c;
                        }

                            //======================= Verify Product ===================   
                        if(  ucm.RTL_PRODUCT_OFFER__c != '' ){
                            List<List<String>> productsOffer = RTL_UploadCampaignMemberCreateLead.processProductOfferString( ucm.RTL_PRODUCT_OFFER__c );

                            List<String> missingPorduct = new List<String>();
                            List<String> missingSubGroup = new List<String>();
                            List<String> missingGroup = new List<String>();
                            Boolean wrongFormat = false;

                            for( List<String> productItem : productsOffer  ){
                                if(productItem == null || productItem.size() != 2) {
                                    wrongFormat = true;
                                    break;
                                } else
                                if( productItem.get(0) == '3' ){
                                    String productName = productItem.get(1);
                                    if( !existingProductName.contains( productName ) )
                                    {
                                        missingPorduct.add(productName);
                                    }
                                }
                                else if( productItem.get(0) == '2' ){
                                    String subGroupName = productItem.get(1);
                                    if( !existingSubGroupName.contains( subGroupName.tolowercase() ) )
                                    {
                                        missingSubGroup.add(subGroupName);
                                    }
                                    
                                }
                                else if( productItem.get(0) == '1' ){
                                    String groupName = productItem.get(1);
                                    if( !existingGroupName.contains( groupName.tolowercase() ) )
                                    {
                                        missingGroup.add(groupName);
                                    }
                                }
                                else{
                                    wrongFormat = true;
                                    break;
                                }
                            }

                            if( wrongFormat )
                            {
                                ucm.RTL_ImportStatus__c = 'Failed';
                                String errorMsg = 'Product Offer Format incorrect';
                                ucm.RTL_ImportStatusDescription__c = errorMsg;
                            }
                            else if( missingPorduct.size() > 0 || missingSubGroup.size() > 0 || missingGroup.size() > 0 )
                            {
                                ucm.RTL_ImportStatus__c = 'Failed';

                                String errorMsg = '';

                                if(  missingPorduct.size() > 0 )
                                {
                                    errorMsg += 'Product not found: {' + String.join(missingPorduct, ',')+'},';
                                }

                                if(  missingSubGroup.size() > 0 )
                                {
                                    errorMsg += 'SubGroup not found: {' + String.join(missingSubGroup, ',')+'},';
                                }

                                if(  missingGroup.size() > 0 )
                                {
                                    errorMsg += 'Group not found: {' + String.join(missingGroup, ',')+'},';
                                }

                                ucm.RTL_ImportStatusDescription__c = errorMsg;
                            }
                        }

                            //If import as lead , remove validation
                        if( ucmb.RTL_Upload_Campaign_Member_Logs__r.RTL_CampaignID__c != null )
                        {

                            //Check if branch and Agent stamp but not valid

                            if(  ucm.RTL_AssignedBranch__c != '' && !existingBranchCode.contains( ucm.RTL_AssignedBranch__c )  )
                            {
                                ucm.RTL_ImportStatus__c = 'Failed';
                                ucm.RTL_ImportStatusDescription__c = 'Invalid Branch Code: ' + ucm.RTL_AssignedBranch__c;
                                
                            }

                            if(  ucm.RTL_AssignedRM__c != '' && !existingAgentCode.contains( ucm.RTL_AssignedRM__c )  )
                            {
                                ucm.RTL_ImportStatus__c = 'Failed';
                                ucm.RTL_ImportStatusDescription__c = 'Invalid Agent Code: ' + ucm.RTL_AssignedRM__c;
                            }

                                // If both Agent and Branch not found
                                //System.debug(existingBranchCode + ' : ' + ucm.RTL_AssignedBranch__c);
                                //System.debug(existingAgentCode + ' : ' + ucm.RTL_AssignedRM__c);
                            if( !existingBranchCode.contains( ucm.RTL_AssignedBranch__c ) &&  !existingAgentCode.contains( ucm.RTL_AssignedRM__c ) )
                            {
                                ucm.RTL_ImportStatus__c = 'Failed';
                                ucm.RTL_ImportStatusDescription__c = 'Invalid both Agent Code and Branch Code';
                            }

                        }

                        
                        if(
                            new List<String>{ 'Exclusive_Campaign', 'Exclusive_Campaign_Active' }
                                .contains(ucmb.RTL_Upload_Campaign_Member_Logs__r.RTL_Campaign__r.RecordType.DeveloperName) &&
                            (ucm.RTL_Web_Unique_ID__c == '' || ucm.RTL_Web_Unique_ID__c == null)
                        ) {
                            ucm.RTL_ImportStatus__c = 'Failed';
                            ucm.RTL_ImportStatusDescription__c = 'Invalid Web Unique ID is required';
                        }
                                //**** This List can cause max heap size ******
                        UploadCampMemList.add(ucm);
                    }   
                }  
            }

		        //Attemp to insert campaign member to temp table
            Database.SaveResult[] ucmResultList = Database.insert(UploadCampMemList, false);

            //================ do not check here for error ===========================================
		    List<RTL_Upload_Campaign_Members__c> errorList = new List<RTL_Upload_Campaign_Members__c>();
            integer fieldFirstNameLength = 0;
            integer fieldLastNameLength = 0;
            integer fieldMobilePhoneLength = 0;

            if(ucmResultList.size() > 0){
                 fieldFirstNameLength = Schema.SObjectType.RTL_Upload_Campaign_Members__c.fields.RTL_FirstName__c.getLength();
                 fieldLastNameLength = Schema.SObjectType.RTL_Upload_Campaign_Members__c.fields.RTL_LastName__c.getLength();
                 fieldMobilePhoneLength = Schema.SObjectType.RTL_Upload_Campaign_Members__c.fields.RTL_MOBILEPHONE__c.getLength();
            }
            for (Integer i = 0; i < ucmResultList.size(); i++) {

                if( !ucmResultList.get(i).isSuccess() )
                {
                    // for (Integer k = 0; k < ucmResultList.get(i).getErrors().size(); k++) {
                    //     System.debug(System.LoggingLevel.ERROR, ucmResultList.get(i).getErrors().get(k)?.getMessage());
                    // }
                    //RTL_Upload_Campaign_Members__c ucmEror = new RTL_Upload_Campaign_Members__c();
                    RTL_Upload_Campaign_Members__c ucmEror = UploadCampMemList.get(i);                    
                    //Database.Error error = ucmResultList.get(i).getErrors().get(0);
                    //String errorMessage = 'Campaign Member Error: ' + error.getMessage();

                    String errorMessage = '';
                    ucmEror.RTL_ImportStatus__c = 'Failed';
                    if(ucmResultList.get(i).getErrors().tostring().contains(Label.UploadCampaignMemberErrorMsgMaxLength)){
                        errorMessage = 'Some fields data value too large : '+ (ucmResultList.get(i).getErrors().tostring().split(';')[0]);
                        errorMessage = errorMessage.replace('Database.Error[getFields=(','');
                       
                        ucmEror.RTL_TMBCustID__c = null;
                        ucmEror.RTL_Title__c = null;

                        ucmEror.RTL_FirstName__c = (ucmEror.RTL_FirstName__c.length() > fieldFirstNameLength ? ucmEror.RTL_FirstName__c.substring(0,fieldFirstNameLength) : ucmEror.RTL_FirstName__c);
                        ucmEror.RTL_LastName__c = (ucmEror.RTL_LastName__c.length() > fieldLastNameLength ? ucmEror.RTL_LastName__c.substring(0,fieldLastNameLength) : ucmEror.RTL_LastName__c); 
                        ucmEror.RTL_MOBILEPHONE__c = (ucmEror.RTL_MOBILEPHONE__c.length() > fieldMobilePhoneLength ?  ucmEror.RTL_MOBILEPHONE__c.substring(0,fieldMobilePhoneLength) : ucmEror.RTL_MOBILEPHONE__c);

                        ucmEror.RTL_AssignedBranch__c  = null;
                        ucmEror.RTL_AssignedRM__c = null;

                        ucmEror.RTL_PRODUCT_OFFER__c = null;
                        ucmEror.RTL_PROMOTION__c = null;
                        ucmEror.RTL_TARGET__c = null;
                        ucmEror.RTL_PRODUCT_FEATURE__c = null;
                        ucmEror.RTL_REGISTER_DATE__c = null;

                        ucmEror.RTL_leadOwner__c = null;

                        ucmEror.RTL_CHANNEL_DM__c = null;
                        ucmEror.RTL_CHANNEL_OB__c = null;
                        ucmEror.RTL_CHANNEL_SMS__c = null;
                        ucmEror.RTL_CHANNEL_EDM__c = null;
                        ucmEror.RTL_CHANNEL_BRANCH__c = null;
                        ucmEror.RTL_CHANNEL_MIB__c =  null;
                        ucmEror.RTL_CHANNEL_OBD__c =  null;
                        ucmEror.RTL_CHANNEL_OTHER__c  = null;
                        ucmEror.RTL_REMARK1__c = null;
                        ucmEror.RTL_REMARK2__c = null;

                        ucmEror.RTL_AGE__c = null;
                        ucmEror.RTL_ID_Type__c =  null;
                        ucmEror.RTL_Citizen_ID__c =  null;

                        ucmEror.RTL_ADDRESS1__c = null;
                        ucmEror.RTL_ADDRESS2__c = null;
                        ucmEror.RTL_ADDRESS3__c = null;

                        ucmEror.RTL_PROVINCE__c =  null;
                        ucmEror.RTL_ZIPCODE__c =  null;
                        ucmEror.RTL_HOMEPHONE__c =  null;

                        ucmEror.RTL_INCOME__c =null;
                        ucmEror.RTL_OCCUPATION__c =null;
                        ucmEror.RTL_Email_Address__c = null;
                        ucmEror.RTL_FB_ID__c = null;
                       // ucm.RTL_FB_EMAIL__c = csvRecordData[36]; //AK remove this field

                       ucmEror.RTL_Segment__c = null;

                       ucmEror.RTL_COST_PER_LEAD__c = null;
                       ucmEror.RTL_SOURCE__c = null;
                       ucmEror.RTL_UPDATE_DATE__c = null;

                       ucmEror.RTL_DATA_SOURCE__c = null;
                       ucmEror.RTL_Rating__c = null;

                       ucmEror.LeadSource__c = null;
                       ucmEror.RTL_Source_Reference__c = null;
                       ucmEror.RTL_TMB_Campaign_Source__c =null;
                       ucmEror.RTL_TMB_Campaign_Reference__c = null;
                       ucmEror.RTL_Customer_Segment__c = null;
                       ucmEror.RTL_Web_Unique_ID__c = null;
                    }else{
                        errorMessage = 'Duplicate Firstname/Lastname or Mobile Phone with previous record.';    
                    }    
                    
                    ucmEror.RTL_ImportStatusDescription__c = errorMessage;

                    ucmEror.RTL_Batch_Name__c = RTL_UploadCampaignMemberService.guid();
                    ucmEror.RTL_Batch_Telephone__c = RTL_UploadCampaignMemberService.guid();

                    // Add to error
                    errorList.add(ucmEror);
                }

            }

        System.debug('End UploadCampaignMemberImportBatch ' + system.now());
		// Chain to other job to process error records (Avoid limitation exceed)
		RTL_UploadCampaignMemberImportError importErrorQueue = new RTL_UploadCampaignMemberImportError(ucml,ucmb,errorList);
        if(!Test.isRunningTest()) System.enqueueJob(importErrorQueue);
		}
	}
}