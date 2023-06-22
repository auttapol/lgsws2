@isTest
global class ContactExtensionV3Test {

	static testmethod void CreateContact(){
        TestUtils.createIdType();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        TestUtils.createDateOfBirth();
         Map<String,ID> addressmap = TestUtils.CreateAddress();
        
    	Account acct = TestUtils.createAccounts(1,'CreateContact','Individual', true).get(0);
        Contact cont = TestUtils.createContacts(1, acct.id, false).get(0);
  Country__C Thailand = new Country__c ();
        
        thailand.Name = 'Thailand';
        thailand.Code__c ='66';
        insert thailand;
        ApexPages.StandardController sc = new ApexPages.StandardController(cont);
        ContactExtensionV3 ConEX = new ContactExtensionV3(sc);
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
        System.debug('selectedSubDistrict : '+ConEx.selectedSubDistrict);
        ConEx.SubDistrictSelected();
        ConEx.selectedCountry='Thailand';
        ConEx.CheckCountry();
        ConEx.selectedCountry='EN';
        ConEx.CheckCountry();
        ContactExtensionV3.calculateAge(Date.newInstance(1980, 2, 17));
        ConEX.save(); 
        
        cont.ID_Type_PE__c = 'Alien ID';
      	 ConEX.save(); 
        cont.FirstName ='Tinnakrit';
       	ConEX.save(); 
        cont.ID_Type_PE__c = 'Citizen ID';
        cont.ID_Number_PE__c = '15101';
       	ConEX.save(); 
        cont.Date_of_Birth__c = System.today();
        cont.LastName = 'Kidmai';
        cont.Last_Name__c = 'Kidmai';
		ConEX.save();        
        ConEx.viewContact();
    }
    
    
}