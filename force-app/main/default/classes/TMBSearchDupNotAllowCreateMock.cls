@isTest
global class TMBSearchDupNotAllowCreateMock implements WebServiceMock {
    public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
       
        System.debug(LoggingLevel.INFO, 'TMBServiceProxyMockImpl.doInvoke() - ' +
            '\n request: ' + request +
            '\n response: ' + response +
            '\n endpoint: ' + endpoint +
            '\n soapAction: ' + soapAction +
            '\n requestName: ' + requestName +
            '\n responseNS: ' + responseNS +
            '\n responseName: ' + responseName +
            '\n responseType: ' + responseType);
       
        TMBServiceProxy.SearchResultDTO SearchResult1 = new TMBServiceProxy.SearchResultDTO(); 
            SearchResult1.status ='0000';
            SearchResult1.totalrecord = '1';
            SearchResult1.massage = '';
           
                
         TMBServiceProxy.ArrayOfSearchDataDTO ArrayOfSearch = new TMBServiceProxy.ArrayOfSearchDataDTO();
         TMBServiceProxy.SearchDataDTO[] searchArr = New List<TMBServiceProxy.SearchDataDTO>();   
         TMBServiceProxy.SearchDataDTO searchdata = new TMBServiceProxy.SearchDataDTO();
                 Account Acct = new Account(); 
            Acct.Name = 'Test Account';
            //Acct.Company_Name_Temp__c  =  'TestCompany';
            Acct.ID_Type_PE__c  = 'Citizen ID';
            Acct.ID_Number_PE__c  = '15101';
            //Acct.Fax_No_Temp__c = '1001';
            Acct.Phone = '053535';
            //Acct.Address_Line_1_Temp__c = 'Address1';
            //Acct.Address_Line_2_Temp__c = 'Address2';
            //Acct.Address_Line_3_Temp__c = 'Address3';
            //Acct.Primary_Address_Line_1_Temp__c = 'Primary Address1';
            //Acct.Primary_Address_Line_2_Temp__c = 'Primary Address2';
            //Acct.Primary_Address_Line_3_Temp__c = 'Primary Address3';
            //Acct.Province_Primary_Temp__c = 'Chiang Mai';
            //Acct.Zip_Code_Primary_Temp__c = '50000';
            //Acct.Zip_Code_Temp__c = '1001';
            Acct.Customer_Type__c = 'Individual';
            Acct.First_name_PE__c = 'TestNotSame';
            Acct.First_Name_ENG_PE__c = 'TestNotSame';
            Acct.Last_name_PE__c = 'TestMock';
        	Acct.Last_Name_PE_Eng__c  = 'TestMock';
            //Acct.Office_Number_Temp__c = '0876213284';
            //Acct.Mobile_Number_Temp__c = '05689145';
            Acct.Rating = 'Hot';
            Acct.IsDisqualified__c = false;
             //  User AdminUser = TestUtils.createUsers(1,'AccountOwner', 'Ownertest','OwnerIDtest@email.com', true).get(0);
                Acct.OwnerId = TestUtils.userList.get(0).id;
                insert acct;
            
                
                searchdata.ID_TYPE = 'CI';
                searchdata.ID_NUMBER = acct.ID_Number_PE__c;
                searchdata.SF_ID = acct.id;
                searchdata.FNAME = acct.First_name_PE__c;
                searchdata.LNAME = acct.Last_name_PE__c;
                searchdata.CUST_PROS_TYPE = acct.Account_Type__c;
                //searchdata.PRI_ADDR1 = acct.Address_Line_1_Temp__c;
                //searchdata.PRI_ADDR2 = acct.Address_Line_2_Temp__c; 
                //searchdata.PRI_ADDR3 = acct.Address_Line_3_Temp__c;
                //searchdata.PRI_POSTAL_CD = acct.Zip_Code_Temp__c;
                //searchdata.PRI_PH_NBR = acct.Mobile_Number_Temp__c;
                
        searchArr.add(searchdata);
        ArrayOfSearch.SearchDataDTO = searchArr;
        SearchResult1.Datas = ArrayOfSearch;
        TMBServiceProxy.SearchResponse_element searchResponse = new TMBServiceProxy.SearchResponse_element();
        searchResponse.SearchResult = SearchResult1;
       response.put('response_x', searchResponse); 
   } 
}