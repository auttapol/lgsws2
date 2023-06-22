@isTest
global class ContactUpdateExtensionV3Test {
	static testmethod void UpdateContact(){
        TestUtils.createIdType();
        TestUtils.createAppConfig();        
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        TestUtils.createDateOfBirth();
         Map<String,ID> addressmap = TestUtils.CreateAddress();
        
    	Account acct = TestUtils.createAccounts(1,'CreateContact','Individual', true).get(0);
        Contact cont = TestUtils.createContacts(1, acct.id, true).get(0);
        cont.RecordTypeId = [SELECT Name,id,SobjectType 
                             FROM RecordType 
                             WHERE Name=:'Salesforce' AND SobjectType='Contact' LIMIT 1].get(0).id;
        cont.C_Country_PE__c = 'Thailand';
        cont.C_Province_PE__c = addressmap.get('Province');
        cont.C_AddressLine5_PE__c = addressmap.get('District');
        cont.C_AddressLine4_PE__c =  addressmap.get('Sub District');
        update cont;
  Country__C Thailand = new Country__c ();
        
        thailand.Name = 'Thailand';
        thailand.Code__c ='66';
        insert thailand;
        ApexPages.StandardController sc = new ApexPages.StandardController(cont);
        ContactUpdateExtensionV3 ConEX = new ContactUpdateExtensionV3(sc);
         conEx.Provinceselected();
        conEx.DistrictSelected();
        ConEx.SubDistrictSelected();
                ConEx.selectedProvince = addressmap.get('Province');
        
        ConEx.selectedDistrict = addressmap.get('District');
        
        ConEx.selectedSubDistrict =  addressmap.get('Sub District');
      	
       
       	conEx.isIDValid = true;
        conEx.Provinceselected();
        conEx.DistrictSelected();
        Sub_District__c subdistrict = new Sub_District__c();
        subdistrict.Name = 'ห้วยขวาง';
        subdistrict.Zip_code__c ='10230';
        
        insert subdistrict;
         ConEx.selectedSubDistrict = subdistrict.id;
        ConEx.SubDistrictSelected();
        ConEx.CheckCountry();
        ConEx.contact.C_Country_PE__c='EN';
        conEx.CheckCountry();
        conEx.contact.C_Country_PE__c='Thailand';
        ContactUpdateExtensionV3.calculateAge(Date.newInstance(1980, 2, 17));
        conEx.IsCountryAsTH = true;
        ConEX.save(); 
        ConEx.saveSF1();
        
        cont.ID_Type_PE__c = 'Alien ID';
      	 ConEX.save(); 
        ConEx.saveSF1();
        cont.FirstName ='Tinnakrit';
       	ConEX.save(); 
        ConEx.saveSF1();
        cont.ID_Type_PE__c = 'Citizen ID';
        cont.ID_Number_PE__c = '15101';
       	ConEX.save(); 
        ConEx.saveSF1();
        cont.Date_of_Birth__c = System.today();
        cont.LastName = 'Kidmai';
        cont.Last_Name__c = 'Kidmai';
		ConEX.save();  
        ConEx.saveSF1();      
        ConEx.viewContact();
    }
    
    //Fixed[2018-03]: BAU_6785 (INC0046474) - CRM-Unable to complete survey & Convert leads        
    static testmethod void UpdateContactByNotAdmin(){
    
        User newUser = new User(FirstName='ctFirst', LastName='ctLast', 
                                    UserName='ctname@tmb.com', 
                                    Email='ctname@tmbbank.com', Alias='ct',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='cttmb',
                                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id
                                    ,TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='C0001',Zone__c=
                                    '1001',Segment__c ='AA',Zone_Code__c ='1001');           
        insert newUser;
        System.runAs(newUser) {
        	insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=newUser.Id);
        }
        System.runAs(newUser) {
            TestUtils.createIdType();
            TestUtils.createAppConfig();
                
            //Status_Code__c error9001 = new Status_Code__c();
            //error9001.isError__c = true;
            //error9001.Name = '9001';
            //error9001.Status_Message__c = 'Retail contact can’t be edited.';
            //insert error9001;
                
            TestUtils.createStatusCode();
            TestUtils.createDisqualifiedReason();
            TestUtils.createDateOfBirth();
            Map<String,ID> addressmap = TestUtils.CreateAddress();
            
            Account acct = TestUtils.createAccounts(1,'CreateContact_Aa','Individual', true).get(0);
                
            Contact newContact = new Contact(
                AccountId = acct.Id,
                Salutation = 'Mr.',
                LastName = 'contact_Aa',
                Date_of_Birth__c = Date.today(),
                Position__c = 'position1',
                Value_Style__c = 'Risk Awareness',
                Decision_Map__c = 'User',
                Product_Decision__c = '',
                Description__c = 'contact description',
                OwnerId  = newUser.Id);     
            insert newContact;
            
            Contact cont = newContact; //TestUtils.createContacts(1, acct.id, true).get(0);
            cont.RecordTypeId = [SELECT Name,id,SobjectType 
                                 FROM RecordType 
                                 WHERE Name=:'Retail Contact' AND SobjectType='Contact' LIMIT 1].get(0).id;
            cont.C_Country_PE__c = 'Thailand';
            cont.C_Province_PE__c = addressmap.get('Province');
            cont.C_AddressLine5_PE__c = addressmap.get('District');
            cont.C_AddressLine4_PE__c =  addressmap.get('Sub District');
            update cont;
            Country__C Thailand = new Country__c ();        
            thailand.Name = 'Thailand';
            thailand.Code__c ='66';
            insert thailand;
            ApexPages.StandardController sc = new ApexPages.StandardController(cont);
            ContactUpdateExtensionV3 ConEX = new ContactUpdateExtensionV3(sc);
             conEx.Provinceselected();
            conEx.DistrictSelected();
            ConEx.SubDistrictSelected();
            ConEx.selectedProvince = addressmap.get('Province');
            ConEx.selectedDistrict = addressmap.get('District');        
            ConEx.selectedSubDistrict =  addressmap.get('Sub District');
            conEx.isIDValid = true;
            conEx.Provinceselected();
            conEx.DistrictSelected();
                
            Sub_District__c subdistrict = new Sub_District__c();
            subdistrict.Name = 'ห้วยขวาง';
            subdistrict.Zip_code__c ='10230';        
            insert subdistrict;
                
            ConEx.selectedSubDistrict = subdistrict.id;
            ConEx.SubDistrictSelected();
            ConEx.CheckCountry();
            ConEx.contact.C_Country_PE__c='EN';
            conEx.CheckCountry();
            conEx.contact.C_Country_PE__c='Thailand';
            ContactUpdateExtensionV3.calculateAge(Date.newInstance(1980, 2, 17));
            conEx.IsCountryAsTH = true;
            ConEX.save();                           
        }    
    }

}