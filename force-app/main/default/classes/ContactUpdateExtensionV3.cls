public with sharing  class ContactUpdateExtensionV3 {
    //**********************************************************//
    // Modify log
    //**********************************************************//
    // Change No. : CH01
    // Change By : Uttaporn L.
    // Change Date : 2015.06.22
    // Change Detail : Edit When select Sub-District to --None-- Return Error
    // Case No. : 00002582
    //**********************************************************//
    public Contact contact;
    public Boolean isUpdateSuccess {get; set;}
    public boolean isDisqualified {get; set;}
    public boolean isIDValid {get; set;}
    public boolean isNotCoreBank {get; set;}
    public static final String DML_EXCEPTION_CODE = '1000';
    public static final String CALLOUT_EXCEPTION_CODE = '1002';
    public static final String QUERY_EXCEPTION_CODE = '1001';
    private Contact oldCont;
    public boolean IsCountryAsTH {get; set;}
    public boolean IsOtherCountry {get; set;}
    public String selected {get; set;}
    public Province__C province;
    public District__c district;
    public Sub_District__c subdis;
    public Map<String, String> provinceMap {get; set;}
    public static Map<String, String> districtMap {get; set;}
    public Map<String, String> subdisMap {get; set;}
    public Map<String, String> postcodes {get; set;}
    public String selectedProvince {get; set;}
    public String selectedDistrict {get; set;}
    public String selectedSubDistrict {get; set;}
    public String selectedPostcode {get; set;}
    public List<Province__c> ProvinceList {get; set;}
    public List<District__c> DistrictList {get; set;}
    public List<Sub_District__c> subdisList {get; set;}
    public Set<String> postcodeSet {get; set;}
    public List<SelectOption> ProvinceOptionList {get; set;}
    public List<SelectOption> DistrictOptionList {get; set;}
    public List<SelectOption> SubDistrictOptionList {get; set;}
    public List<SelectOption> PostcodeOptionList {get; set;}
    public Map<String, String> ProvinceNameMap {get; set;}
    public Map<String, String> DistrictNameMap {get; set;}
    public Map<String, String> SubDistrictNameMap {get; set;}
    public string selectedCountry {get; set;}
    public Map<String, String> CountryMap {get; set;}
    public  List<SelectOption> CountriesOptionList {get; set;}
    public  List<Country__c> CountriesList {get; set;}
    private String provinceholder;
    public string photoName {get;set;}
    public Id folderId {get;set;}
    public Blob photoFile {get;set;}

    public String section {get;set;}
    public Boolean isLoading {get;set;}
    public Boolean isVisible {get;set;}
    public Boolean isLoadSuccess {get;set;}

    //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term --
    List<RTL_Contact_Address__c> contactAddr {get;set;}
    
    public String hiddenText {
        get{
            if( hiddenText == null )
            {
                //hiddenText='************';
               hiddenText = system.Label.Data_Condition_Hidden_Text;
            }
            return hiddenText;
        }
        set;
    }

    //Fixed[2018-03]: BAU_6785 (INC0046474) - CRM-Unable to complete survey & Convert leads  
    public static Map<String,App_Config__mdt> mapMetaConf {get{
        Map<String,App_Config__mdt> simList = new Map<String,App_Config__mdt>();        
        for(App_Config__mdt conf : [select id,DeveloperName,Value__c from App_Config__mdt ] ){
            simList.put(conf.DeveloperName,conf);
        }        
        return new Map<String,App_Config__mdt>(simList);
    }set;}

    //constructor
    public ContactUpdateExtensionV3(ApexPages.StandardController controller) {
        
        

        contact = (Contact)controller.getRecord();
        isLoading = true;
        isLoadSuccess = false;
        loadData();
        Contact tmpCont = [SELECT AccountId, C_Province_PE__c, C_Country_PE__c, C_AddressLine5_PE__c, C_AddressLine4_PE__c, C_Zipcode_PE__c, isDisqualified__c FROM Contact WHERE ID = :contact.id LIMIT 1];
        contact.isDisqualified__c = tmpCont.isDisqualified__c;
        isDisqualified = contact.IsDisqualified__c;
        contact.C_Province_PE__c = tmpCont.C_Province_PE__c;
        contact.C_AddressLine5_PE__c = tmpCont.C_AddressLine5_PE__c;
        contact.C_AddressLine4_PE__c = tmpCont.C_AddressLine4_PE__c;
        contact.C_Zipcode_PE__c = tmpCont.C_Zipcode_PE__c;
        contact.AccountID = tmpCont.AccountID;
        System.debug(tmpCont.C_Country_PE__c);
        System.debug(contact.C_Country_PE__c);
        contact.C_Country_PE__c = tmpCont.C_Country_PE__c;
        oldCont = new Contact();
        ProvinceList = new List<Province__c>();
        DistrictList = new List<District__C>();
        subdisList = new List<Sub_District__c>();
        provinceMap = new Map<String, String>();
        districtMap = new Map<String, String>();
        subdisMap = new Map<String, String>();
        postcodes = new Map<String, String>();
        postcodeSet = new Set<String>();
        ProvinceNameMap = new Map<String, String>();
        DistrictNameMap = new Map<String, String>();
        SubDistrictNameMap = new Map<String, String>();
        //selectedProvince = contact.C_Province_PE__c;
        //selectedDistrict = contact.C_AddressLine5_PE__c;
        //selectedSubDistrict = contact.C_AddressLine4_PE__c;
        //selectedPostCode = contact.C_Zipcode_PE__c;
        //selectedCountry = contact.C_Country_PE__c;
        ProvinceOptionList = new List<SelectOption>();
        ProvinceOptionList.add(new SelectOption('', '--None--'));
        //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term --

        // ProvinceList = new List<Province__c>( [SELECT Id, Name, Code__c FROM Province__C  ORDER BY Name]);
        // for (Province__C pro : ProvinceList) {
        //     ProvinceOptionList.add(new SelectOption(pro.id, pro.Name));
        //     provinceMap.put(pro.Name, pro.id);
        //     provinceNameMap.put(pro.id, pro.name);
        // }
        for(AggregateResult ca : [SELECT RTL_Province__c FROM RTL_Contact_Address__c WHERE IsActive__c = true GROUP BY RTL_Province__c])
        {
            String province = (ca.get('RTL_Province__c') == null || ca.get('RTL_Province__c') == '') ? '' : (String) ca.get('RTL_Province__c');
            ProvinceOptionList.add(new SelectOption(province,province));
            provinceMap.put(province, province);
            provinceNameMap.put(province, province);
        }
        ProvinceOptionList.sort();

        DistrictOptionList = new List<SelectOption>();
        SubDistrictOptionList = new List<SelectOption>();
        PostcodeOptionList = new List<SelectOption>();


        // Set Address
        //
        //

        selectedCountry = contact.C_Country_PE__c == null ? '' : contact.C_Country_PE__c;
        if (contact.C_Country_PE__c == 'Thailand') {
            if (contact.C_Province_PE__c != null && contact.C_Province_PE__c != '') {

                selectedProvince = provinceMap.get(contact.C_Province_PE__c);
                Provinceselected();
            }
            if (contact.C_AddressLine5_PE__c != null && contact.C_AddressLine5_PE__c != '') {

                selectedDistrict = districtMap.get(contact.C_AddressLine5_PE__c);

                Districtselected();
            }
            if (contact.C_AddressLine4_PE__c != null && contact.C_AddressLine4_PE__c != '') {
                selectedSubDistrict = subdisMap.get(contact.C_AddressLine4_PE__c);
                SubDistrictSelected();
                selectedPostcode = (contact.C_Zipcode_PE__c == '') ? null : contact.C_Zipcode_PE__c;
            }
            IsCountryAsTH = true;
            IsOtherCountry = false;
        } else {
            IsCountryAsTH = false;
            IsOtherCountry = true;

        }

        //
        //



        CountryMap = new Map<String, String>();
        CountriesOptionList = new List<SelectOption>();
        CountriesOptionList.add(new SelectOption('', '--None--'));
        CountriesList = new List<Country__c>( [SELECT ID, Name, Code__c FROM Country__c WHERE Name != '' AND Code__c != null ORDER BY Name]);
        for (Country__c coun : CountriesList) {
            CountriesOptionList.add(new SelectOption(coun.Name, coun.Name));
            CountryMap.put(coun.Code__c, coun.Name);
        }


        RecordType conRec =  [SELECT Name, id, SobjectType
                              FROM RecordType
                              WHERE id = :contact.RecordTypeId AND SobjectType = 'Contact' LIMIT 1];

        if (conRec.Name == 'Core Bank') {
            isNotCoreBank = false;
        } else {
            isNotCoreBank = true;
        }
    }


    
    public void loadData()
    {
        try{
            section = 'ComCust:Contacts';
        }catch(Exception e){
            this.section = section;
        }
        Contact contDetail = new Contact();
        Profile userProfile = new Profile();
        Account acctDetail = new Account();

        try
        {
            system.debug('contact:::'+contact);
            contDetail = [SELECT id,AccountId  FROM Contact WHERE id = :contact.id ];
            acctDetail = [SELECT id,recordType.name,RTL_RM_Name__c,OwnerId FROM Account WHERE id = :contDetail.AccountId ];
            userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            
        }
        catch (Exception e)
        { 
            //exception here
        }

        isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name,contact.id);
        
        isLoading = false;
        isLoadSuccess = true;
    }

    
    
    public PageReference save() {

        //Fixed[2018-03]: BAU_6785 (INC0046474) - CRM-Unable to complete survey & Convert leads       
        Id profileId = UserInfo.getProfileId();
        system.debug('profileId : ' + profileId );   
        system.debug('contact RecordType Name : ' + contact.RecordTypeId );
        if(profileId != mapMetaConf.get('ProfileId_of_Retail_Integration_API_Only').Value__c
           && profileId != mapMetaConf.get('ProfileId_of_System_Administrator').Value__c 
           && contact.RecordTypeId == mapMetaConf.get('RecordTypeId_of_Retail_Contact').Value__c){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('9001').Status_Message__c));
            return null;
        }    

        contact.C_Country_PE__c = selectedCountry;

        system.debug('selectedCountry in save action : ' + contact.C_Country_PE__c );

        if ( contact.ID_Type_PE__c == '--None--') {
            contact.ID_Type_PE__c = null;
        }
        if ( (contact.FirstName == null || contact.FirstName == '') && isNotCoreBank) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3009').Status_Message__c));
            return null;
        }
        if ( (contact.ID_Type_PE__c != null && contact.ID_Number_PE__c == null) && isNotCoreBank) {
            isUpdateSuccess = false;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3004').Status_Message__c));
            return null;
        }
        /*if (!isIDValid && contact.ID_Type_PE__c == 'Citizen ID') {
            isUpdateSuccess = false;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3001').Status_Message__c));
            return null;
        }*/
        String custAge;
        if (contact.Date_Of_Birth__c != null && isNotCoreBank) {
            custAge = calculateAge(contact.Date_of_Birth__c) + '';
        } else {
            custAge = '0';
        }

        //Date_Of_Birth__c dateOfBirth = Date_Of_Birth__c.getValues('Default');
        //DateTime d = (contact.Date_of_Birth__c==null)?null:contact.Date_Of_Birth__c;
        //contact.Date_of_Birth__c = date.newinstance(d.year(), d.month(), d.day());
        //String myDate =  d.format('yyyy-MM-dd') ;


        if (IsCountryAsTH) {
            if (selectedProvince == null || selectedProvince == '--None--') {
                contact.C_Province_PE__c = '';
            } else {
                contact.C_Province_PE__c = ProvinceNameMap.get(selectedProvince);

            }

            if (selectedDistrict == null || selectedDistrict == '--None--') {
                contact.C_AddressLine5_PE__c = '';
            } else {
                contact.C_AddressLine5_PE__c = DistrictNameMap.get(selectedDistrict);

            }

            if (selectedSubDistrict == null || selectedSubDistrict == '--None--') {
                contact.C_AddressLine4_PE__c = '';
            } else {
                contact.C_AddressLine4_PE__c = SubDistrictNameMap.get(selectedSubDistrict);

            }


            if (selectedPostCode == null || selectedPostCode == '--None--') {
                contact.C_Zipcode_PE__c = '';
            } else {
                contact.C_Zipcode_PE__c = selectedPostCode;
            }
        }

        try {
            contact.LastName = contact.Last_Name__c != null ? contact.Last_Name__c : null;
            contact.AccountId = contact.Account__c != null ? contact.Account__c : null;


            update contact;
            return viewContact();

        } catch (DMLException e) {
            string msg = e.getMessage();
            Integer numErrors = e.getNumDml();
                    String saveErrorMessage = '';
                    for(Integer i=0;i<numErrors;i++) {
                        saveErrorMessage += e.getDmlMessage(i);
                    }
            if (msg.tolowercase().contains('insufficient')) {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3023').Status_Message__c) );
            } else if (contact.Date_of_Birth__c != null) {
                if (contact.Date_of_Birth__c > System.today()) {
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3019').Status_Message__c) );
                } else {
                    
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, saveErrorMessage) );
                }
            } else {
                system.debug('DMLException msg :'+msg);
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, saveErrorMessage) );
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('1000').Status_Message__c));
            }
            return null;
        }
    
    }


    public PageReference saveSF1() {
        contact.C_Country_PE__c = selectedCountry;
        isUpdateSuccess = true;
        system.debug('selectedCountry in save action : ' + contact.C_Country_PE__c );

        if ( contact.ID_Type_PE__c == '--None--') {
            contact.ID_Type_PE__c = null;
        }
        if ( (contact.FirstName == null || contact.FirstName == '' ) && isNotCoreBank ) {
            isUpdateSuccess = false;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3009').Status_Message__c));
            return null;
        }
        if ( (contact.ID_Type_PE__c != null && contact.ID_Number_PE__c == null) && isNotCoreBank ) {
            isUpdateSuccess = false;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3004').Status_Message__c));
            return null;
        }
        /*if (!isIDValid && contact.ID_Type_PE__c == 'Citizen ID') {
            isUpdateSuccess = false;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3001').Status_Message__c));
            return null;
        }*/
        String custAge;
        if (contact.Date_Of_Birth__c != null && isNotCoreBank ) {
            custAge = calculateAge(contact.Date_of_Birth__c) + '';
        } else {
            custAge = '0';
        }

        //Date_Of_Birth__c dateOfBirth = Date_Of_Birth__c.getValues('Default');
        //DateTime d = (contact.Date_of_Birth__c==null)?null:contact.Date_Of_Birth__c;
        //contact.Date_of_Birth__c = date.newinstance(d.year(), d.month(), d.day());
        //String myDate =  d.format('yyyy-MM-dd') ;


        if (IsCountryAsTH) {
            if (selectedProvince == null || selectedProvince == '--None--') {
                contact.C_Province_PE__c = '';
            } else {
                contact.C_Province_PE__c = ProvinceNameMap.get(selectedProvince);

            }

            if (selectedDistrict == null || selectedDistrict == '--None--') {
                contact.C_AddressLine5_PE__c = '';
            } else {
                contact.C_AddressLine5_PE__c = DistrictNameMap.get(selectedDistrict);

            }

            if (selectedSubDistrict == null || selectedSubDistrict == '--None--') {
                contact.C_AddressLine4_PE__c = '';
            } else {
                contact.C_AddressLine4_PE__c = SubDistrictNameMap.get(selectedSubDistrict);

            }


            if (selectedPostCode == null || selectedPostCode == '--None--') {
                contact.C_Zipcode_PE__c = '';
            } else {
                contact.C_Zipcode_PE__c = selectedPostCode;
            }
        }

        try {
            contact.LastName = contact.Last_Name__c != null ? contact.Last_Name__c : null;
            contact.AccountId = contact.Account__c != null ? contact.Account__c : null;


            update contact;

            return null;

        } catch (DMLException e) {
            isUpdateSuccess = false;
            string msg = e.getMessage();
            if (msg.tolowercase().contains('insufficient')) {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3023').Status_Message__c) );
            } else if (contact.Date_of_Birth__c != null) {
                if (contact.Date_of_Birth__c > System.today()) {
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3019').Status_Message__c) );
                } else {
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg) );
                }
            } else {
                system.debug('DMLException msg: '+msg);
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('1000').Status_Message__c));
            }
            return null;
        }
    }


    public PageReference viewContact() {
        PageReference ContactPage;
        ContactPage = new ApexPages.StandardController(contact).view();
        ContactPage.setRedirect(true);
        return ContactPage;
    }





    public void Provinceselected() {
        boolean provincechange = false;
        selectedSubDistrict = null;
        districtMap = New Map<String, String>();
        DistrictNameMap = New Map<String, String>();
        SubDistrictOptionList = new List<SelectOption>();
        SubDistrictOptionList.add(new SelectOption('', '--None--'));
        PostcodeOptionList = new List<SelectOption>();
        PostcodeOptionList.add(new SelectOption('', '--None--'));
        selectedPostcode = null;
        System.debug('selectedDistrict : ' + selectedDistrict + ' : ' + contact.C_AddressLine5_PE__c + ' : ' + contact.C_Province_PE__c + ' : ' + selectedProvince);
        contact.C_Province_PE__c = null;
        PostcodeOptionList =  new List<SelectOption>();
        if (provinceholder == null) {
            provinceholder = selectedProvince;

        } else {
            if (selectedProvince != null && selectedprovince != '' && provinceholder != selectedProvince) {
                provincechange = true;
            }
        }

        if ((selectedProvince != null && selectedProvince != '' && selectedProvince != 'null') || provincechange) {

            DistrictOptionList = new List<SelectOption>();
            contact.C_Province_PE__c = selectedProvince;
            //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term -- 
            // DistrictList = new List<District__c>([SELECT ID, Name, Code__c FROM District__c WHERE Province__c = :selectedProvince ORDER BY Name ]);
            DistrictOptionList.add(new SelectOption('', '--None--'));
            // for (District__C dis : DistrictList) {
            //     DistrictOptionList.add(new SelectOption(dis.id, dis.Name));
            //     districtMap.put(dis.name, dis.id);
            //     DistrictNameMap.put(dis.id, dis.name);
            // }
            for(AggregateResult ca : [SELECT RTL_District__c FROM RTL_Contact_Address__c WHERE RTL_Province__c =: selectedProvince AND IsActive__c = true GROUP BY RTL_District__c])
            {
                String district = (ca.get('RTL_District__c') == null || ca.get('RTL_District__c') == '') ? '' : (String) ca.get('RTL_District__c');
                DistrictOptionList.add(new SelectOption(district,district)); 
                districtMap.put(district,district);
                DistrictNameMap.put(district,district);
            }

            DistrictOptionList.sort();
            provinceholder = selectedprovince;
        } else {

            selectedDistrict = null;
            selectedSubDistrict = null;
            selectedpostcode = null;
            DistrictOptionList = new List<SelectOption>();
            contact.C_AddressLine5_PE__c = null;
            contact.C_AddressLine4_PE__c = null;
            contact.C_Zipcode_PE__c = null;
            postcodeSet = new Set<String>();
            SubDistrictOptionList = new List<SelectOption>();
            PostcodeOptionList = new List<SelectOption>();
        }


    }

    public void DistrictSelected() {
        System.debug('selectedDistrict : ' + selectedDistrict + ' : ' + contact.C_AddressLine5_PE__c);
        if (selectedDistrict != null && selectedDistrict != '' && selectedDistrict != 'null' ) {
            SubDistrictOptionList = new List<SelectOption>();
            PostcodeOptionList = new List<SelectOption>();
            PostcodeOptionList.add(new SelectOption('', '--None--'));
            selectedSubDistrict = null;
            postcodeSet = new Set<String>();
            subdisMap = new Map<String, String>();
            SubDistrictNameMap = new Map<String, String>();
            contact.C_AddressLine5_PE__c = selectedDistrict;
            //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term --
            //subdisList = new List<Sub_District__c>([SELECT ID, Name, Code__c, Zip_code__c, Location_Code__c FROM Sub_District__c WHERE District__c = :selectedDistrict ORDER BY Name]);
            subDistrictOptionList.add(new SelectOption('', '--None--'));
            // for (Sub_District__c subdis : subdisList) {
            //     SubDistrictOptionList.add(new SelectOption(subdis.id, subdis.Name));
            //     subdisMap.put(subdis.name, subdis.id);
            //     SubDistrictNameMap.put(subdis.id, subdis.name);
            //     postcodeSet.add(subdis.Zip_code__c);
            // }
            for(RTL_Contact_Address__c ca : [SELECT Id, Name, RTL_Province__c, RTL_District__c, RTL_Sub_District__c, RTL_Zipcode__c, IsActive__c FROM RTL_Contact_Address__c WHERE RTL_District__c =: selectedDistrict AND IsActive__c = TRUE])
            {
                SubDistrictOptionList.add(new SelectOption(ca.RTL_Sub_District__c,ca.RTL_Sub_District__c)); 
                subdisMap.put(ca.RTL_Sub_District__c,ca.RTL_Sub_District__c);
                SubDistrictNameMap.put(ca.RTL_Sub_District__c,ca.RTL_Sub_District__c);
            }
            SubDistrictOptionList.sort();
        } else {
            selectedSubDistrict = null;
            selectedSubDistrict = null;
            selectedPostcode = null;
            contact.C_AddressLine5_PE__c = null;
            contact.C_AddressLine4_PE__c = null;
            contact.C_Zipcode_PE__c = null;
            SubDistrictOptionList = new List<SelectOption>();
            PostcodeOptionList = new List<SelectOption>();
            postcodeSet = new Set<String>();

        }
    }

    public void SubDistrictSelected() {

        if (selectedSubDistrict != null && selectedSubDistrict != '' && selectedSubDistrict != 'null' ) {
            //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term --
            // Sub_District__c sub = [SELECT ID, Name, Zip_code__c FROM Sub_District__c WHERE ID = : selectedSubDistrict LIMIT 1 ];
            // contact.C_AddressLine4_PE__c = sub.Name;
            // contact.C_Zipcode_PE__c = sub.Zip_code__c;
            contact.C_AddressLine4_PE__c = selectedSubDistrict;
            selectedpostcode = null;
            PostcodeOptionList = new List<SelectOption>();
            PostcodeOptionList.add(new SelectOption('', '--None--'));
            // for (String Postcode : postcodeSet) {

            //     PostcodeOptionList.add(new SelectOption(Postcode, Postcode));
            //     System.debug(Postcode);
            // }
            for(RTL_Contact_Address__c ca : [SELECT Id,Name,RTL_Province__c,RTL_District__c,RTL_Sub_District__c,RTL_Zipcode__c,IsActive__c FROM RTL_Contact_Address__c WHERE RTL_Sub_District__c =: selectedSubDistrict AND IsActive__c = true])
            {
                PostcodeOptionList.add(new SelectOption(ca.RTL_Zipcode__c,ca.RTL_Zipcode__c));
                contact.C_Zipcode_PE__c = ca.RTL_Zipcode__c;
            }
        } else {
            PostcodeOptionList = new List<SelectOption>();
            selectedpostcode = null;
            contact.C_AddressLine4_PE__c = null;
            contact.C_Zipcode_PE__c = null;
        }
    }

    public static Integer calculateAge(Date birthDate) {
        Integer Age;

        Date day = Date.today();

        if (day >= birthDate) {
            Age =   day.year() - birthDate.year();
        } else {
            Age =   day.year() - (birthDate.year() - 1);
        }
        return Age;
    }



    public void CheckCountry() {
        // ========    Fix Contry selected  =======
        // SITDefectLogs20141212_revise with TMB.xlsx
        // No.12
        // Item. Edit Contact
        // Fix by : KTC
        // Email : ktc@ii.co.th
        contact.C_Country_PE__c = selectedCountry;
        System.debug(selectedCountry + ' SELECT : ' + contact.C_Country_PE__c);
        if (contact.C_Country_PE__c == 'Thailand') {
            IsCountryAsTH = true;
            IsOtherCountry = false;



        } else {
            IsCountryAsTH = false;
            IsOtherCountry = true;
            contact.C_Province_PE__c = '';
            contact.C_AddressLine5_PE__c = '';
            contact.C_AddressLine1_PE__c = '';
            contact.C_AddressLine4_PE__c = '';
            Contact.C_Zipcode_PE__c = '';
            contact.C_AddressLine2_PE__c = '';
            contact.C_AddressLine3_PE__c = '';
        }

    }

}