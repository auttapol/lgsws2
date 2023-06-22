public with sharing class ContactExtensionV3 implements Database.AllowsCallouts{
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
    
    public string accid {get;set;}
    public static final String DML_EXCEPTION_CODE = '1000';
    public static final String CALLOUT_EXCEPTION_CODE = '1002';
    public static final String QUERY_EXCEPTION_CODE = '1001'; 
    public boolean isCalloutAllow {get;set;}
    public boolean isCreateSuccess {get;set;}
    public boolean isIDValid {get;set;}
    public boolean IsCountryAsTH {get;set;}
    public boolean IsOtherCountry {get;set;}
    public String selected {get;set;}
    public Integer ContactMobileNoTemp {get;set;}
    public Province__C province;
    public District__c district;
    public Sub_District__c subdis;
    public Map<id, List<SelectOption>> provinceMap {get;set;}
    public static Map<String,id> districtMap {get;set;}
    public Map<String,id> subdisMap {get;set;}
    public Map<id,string> postcodes {get;set;}
    public String selectedProvince {get;set;}
    public String selectedDistrict {get;set;}
    public String selectedSubDistrict {get;set;}
    public String selectedPostcode {get;set;}
    public List<Province__c> ProvinceList{get;set;}
    public List<District__c> DistrictList{get;set;}
    public List<Sub_District__c> subdisList {get;set;}
    public Set<String> postcodeSet {get;set;}
    public List<SelectOption> ProvinceOptionList {get;set;}
    public List<SelectOption> DistrictOptionList {get;set;}
    public List<SelectOption> SubDistrictOptionList {get;set;}
    public List<SelectOption> PostcodeOptionList {get;set;}
    public string selectedCountry {get;set;}
    public Map<String,String> CountryMap {get;set;}
    public  List<SelectOption> CountriesOptionList {get;set;}
    public  List<Country__c> CountriesList {get;set;}
    //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term --
    Map<String, Map<String, Map<String, String>>> mapAddress = new Map<String, Map<String, Map<String, String>>>();
  
    //constructor
    public ContactExtensionV3(ApexPages.StandardController controller) {
        ProvinceList = new List<Province__c>();
        DistrictList = new List<District__C>();
        subdisList = new List<Sub_District__c>();
        provinceMap = new Map<id, List<SelectOption>>();
        districtMap = new Map<String,id>();
        subdisMap = new Map<String,id>();
        postcodes = new Map<id,string>();
        postcodeSet = new Set<String>();            
        ProvinceOptionList = new List<SelectOption>();
        ProvinceOptionList.add(new SelectOption('','--None--'));
        //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term --
        //ProvinceList = new List<Province__c>( [SELECT Id,Name,Code__c FROM Province__C WHERE id != null ORDER BY Name]);
        
        for(AggregateResult ca : [SELECT RTL_Province__c FROM RTL_Contact_Address__c WHERE IsActive__c = true GROUP BY RTL_Province__c])
        {
            String province = (ca.get('RTL_Province__c') == null || ca.get('RTL_Province__c') == '') ? '' : (String) ca.get('RTL_Province__c');
            ProvinceOptionList.add(new SelectOption(province,province));
        }
        System.debug('ProvinceOptionList:'+ProvinceOptionList.size());
        
        ProvinceOptionList.sort();

        //ProvinceOptionList.sort();
        // for(Province__C pro : ProvinceList){
        //     ProvinceOptionList.add(new SelectOption(pro.id,pro.Name));
        // }

        DistrictOptionList = new List<SelectOption>();
        SubDistrictOptionList = new List<SelectOption>();
        PostcodeOptionList = new List<SelectOption>();
        contact = (Contact)controller.getRecord();      
        
         if(ApexPages.currentPage().getParameters().containsKey('accid'))
        {
            contact.Account__c = ApexPages.currentPage().getParameters().get('accid');
        }
        
        CountryMap = new Map<String,String>();
        CountriesOptionList = new List<SelectOption>();
        DistrictOptionList.add(new SelectOption('','--None--'));
        SubDistrictOptionList.add(new SelectOption('','--None--'));
        PostcodeOptionList.add(new SelectOption('','--None--'));            
        CountriesList = new List<Country__c>( [SELECT ID,Name,Code__c FROM Country__c WHERE Name != '' AND Code__c != null ORDER BY Name]);
        for(Country__c coun : CountriesList){
            CountriesOptionList.add(new SelectOption(coun.Name,coun.Name));
            CountryMap.put(coun.Code__c, coun.Name);
        }
        contact.C_Country_PE__c = 'Thailand';
        selectedCountry = 'Thailand';
        IsCountryAsTH =true;
    }
    
    public PageReference save(){ 
        if(contact.ID_Type_PE__c!=null&&contact.ID_Number_PE__c==null){         
           ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3004').Status_Message__c));
           return null;
        }
        if(contact.FirstName==null||contact.FirstName==''){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3009').Status_Message__c));
            return null;
        }
        
       /* if(!isIDValid&&contact.ID_Type_PE__c=='Citizen ID'){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3001').Status_Message__c));
            return null;
        }*/
        
        contact.LastName = contact.Last_Name__c!=null?contact.Last_Name__c:null;
        contact.AccountId = contact.Account__c!=null?contact.Account__c:null;

        try{
            
            insert contact;
            
            PageReference ContactPage;
            ContactPage = new ApexPages.StandardController(contact).view();
            ContactPage.setRedirect(true);          
            return ContactPage; 
            
        }catch(DMLException e){
            if(contact.Date_of_Birth__c !=null){
                if(contact.Date_of_Birth__c > System.today()){
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('3019').Status_Message__c) );
            }
            }else{
                System.debug('DMLException msg : '+e.getMessage());
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('1000').Status_Message__c));
            }
            return null;
        }

        return null;
    }
    
        public PageReference saveSF1(){ 
            isCreateSuccess=true;
        if(contact.ID_Type_PE__c!=null&&contact.ID_Number_PE__c==null){         
            isCreateSuccess=false;
           ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3004').Status_Message__c));
           return null;
        }
        if(contact.FirstName==null||contact.FirstName==''){
            isCreateSuccess=false;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3009').Status_Message__c));
            return null;
        }
        
       /* if(!isIDValid&&contact.ID_Type_PE__c=='Citizen ID'){
            isCreateSuccess=false;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3001').Status_Message__c));
            return null;
        }*/
        
        contact.LastName = contact.Last_Name__c!=null?contact.Last_Name__c:null;
        contact.AccountId = contact.Account__c!=null?contact.Account__c:null;

        try{
            
            insert contact;
            
        }catch(DMLException e){
            if(contact.Date_of_Birth__c !=null){
                if(contact.Date_of_Birth__c > System.today()){
                 isCreateSuccess=false;   
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('3019').Status_Message__c) );
            }
            }else{
                isCreateSuccess=false;
                System.debug('DMLException msg : '+e.getMessage());
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('1000').Status_Message__c));
            }
            return null;
        }

        return null;
    }
    
    
    private String provinceholder;
    
      public PageReference viewContact(){
        PageReference ContactPage;
        ContactPage = new ApexPages.StandardController(contact).view();
        ContactPage.setRedirect(true);          
        return ContactPage; 
    }
    
        
        public void Provinceselected(){
            boolean provincechange =false;
             selectedSubDistrict =null;
        //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term --
        SubDistrictOptionList = new List<SelectOption>();
        subDistrictOptionList.add(new SelectOption('','--None--'));
        selectedPostcode = null;
        //contact.Province_Temp__c = null;   Comment cleansing remove this fields Attasit 22/08/2016
          //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term --
        PostcodeOptionList =  new List<SelectOption>();
        PostcodeOptionList.add(new SelectOption('','--None--')); 

            if(provinceholder ==null){
                provinceholder = selectedProvince;
            }else{
                if(selectedProvince !=null && selectedprovince !='' && provinceholder != selectedProvince){
                    provincechange = true;
                }
            }
          
            if((selectedProvince !=null && selectedProvince != '' && selectedProvince !='null')||provincechange){
            //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term --
              DistrictOptionList = new List<SelectOption>();
                //contact.C_Province_PE__c = [SELECT ID,NAME FROM Province__C WHERE ID =:selectedProvince LIMIT 1].Name;
                contact.C_Province_PE__c  = selectedProvince;
            
         
            //DistrictList = new List<District__c>([SELECT ID,Name,Code__c FROM District__c WHERE Province__c =:selectedProvince ORDER BY Name]);

             DistrictOptionList.add(new SelectOption('','--None--'));
            //    for(District__C dis : DistrictList){
            //       DistrictOptionList.add(new SelectOption(dis.id,dis.Name)); 
            //         }
            for(AggregateResult ca : [SELECT RTL_District__c FROM RTL_Contact_Address__c WHERE RTL_Province__c =: selectedProvince AND IsActive__c = true GROUP BY RTL_District__c])
            {
                String district = (ca.get('RTL_District__c') == null || ca.get('RTL_District__c') == '') ? '' : (String) ca.get('RTL_District__c');
                DistrictOptionList.add(new SelectOption(district,district)); 
            }
           
            DistrictOptionList.sort();
            provinceholder = selectedprovince;
      }else{
        selectedDistrict = null;
        selectedSubDistrict = null;
        selectedpostcode = null;
        DistrictOptionList = new List<SelectOption>();
        contact.C_AddressLine5_PE__c =null;
        contact.C_AddressLine4_PE__c =null;  
        contact.C_Zipcode_PE__c = null;  
        postcodeSet = new Set<String>(); 
        SubDistrictOptionList = new List<SelectOption>();
         PostcodeOptionList = new List<SelectOption>();
      }  
           
      
    }
    
    public void DistrictSelected(){
       
         if(selectedDistrict !=null && selectedDistrict != '' && selectedDistrict !='null' ){
            SubDistrictOptionList = new List<SelectOption>();
                PostcodeOptionList = new List<SelectOption>();
            PostcodeOptionList.add(new SelectOption('','--None--'));
                selectedSubDistrict = null;
            postcodeSet = new Set<String>();
            //contact.C_AddressLine5_PE__c = [SELECT ID,NAME FROM District__c WHERE ID =:selectedDistrict LIMIT 1].Name;
            //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term --
            contact.C_AddressLine5_PE__c = selectedDistrict;
            // subdisList = new List<Sub_District__c>([SELECT ID,Name,Code__c,Zip_code__c,Location_Code__c FROM Sub_District__c WHERE District__c =:selectedDistrict ORDER BY Name]);
            subDistrictOptionList.add(new SelectOption('','--None--'));
            // for(Sub_District__c subdis : subdisList){
            //   SubDistrictOptionList.add(new SelectOption(subdis.id,subdis.Name));
            //   postcodeSet.add(subdis.Zip_code__c);
            // }  
            for(RTL_Contact_Address__c ca : [SELECT Id, Name, RTL_Province__c, RTL_District__c, RTL_Sub_District__c, RTL_Zipcode__c, IsActive__c FROM RTL_Contact_Address__c WHERE RTL_District__c =: selectedDistrict AND IsActive__c = TRUE])
            {
                SubDistrictOptionList.add(new SelectOption(ca.RTL_Sub_District__c,ca.RTL_Sub_District__c)); 
            }
            SubDistrictOptionList.sort();
        }else{
            selectedSubDistrict = null;
            selectedSubDistrict = null;
            selectedPostcode = null;
            contact.C_AddressLine5_PE__c = null;
            contact.C_AddressLine4_PE__c =null;  
            contact.C_Zipcode_PE__c = null;  
            SubDistrictOptionList = new List<SelectOption>();
            PostcodeOptionList = new List<SelectOption>();
            postcodeSet = new Set<String>(); 
        
        }
    }
    
     public void SubDistrictSelected(){
        
        if(selectedSubDistrict !=null && selectedSubDistrict != '' && selectedSubDistrict !='null' ){
    //--- Modifed at 9 Feb 2022 CR AL Re-org Long Term --
            //Sub_District__c sub = [SELECT ID,Name,Zip_code__c FROM Sub_District__c WHERE ID=: selectedSubDistrict LIMIT 1];
            // contact.C_AddressLine4_PE__c = sub.Name;
            // contact.C_Zipcode_PE__c = sub.Zip_code__c;
            contact.C_AddressLine4_PE__c = selectedSubDistrict;

            
            selectedpostcode =null;
            PostcodeOptionList = new List<SelectOption>();
                PostcodeOptionList.add(new SelectOption('','--None--'));
            // for(String Postcode : postcodeSet){
                    
            // PostcodeOptionList.add(new SelectOption(Postcode,Postcode)); 
            //         System.debug(Postcode);
            // }
            for(RTL_Contact_Address__c ca : [SELECT Id,Name,RTL_Province__c,RTL_District__c,RTL_Sub_District__c,RTL_Zipcode__c,IsActive__c FROM RTL_Contact_Address__c WHERE RTL_Sub_District__c =: selectedSubDistrict AND IsActive__c = true])
            {
                PostcodeOptionList.add(new SelectOption(ca.RTL_Zipcode__c,ca.RTL_Zipcode__c));
                contact.C_Zipcode_PE__c = ca.RTL_Zipcode__c;
            }
        }else{
           PostcodeOptionList = new List<SelectOption>();
           selectedpostcode =null;
            
             contact.C_Zipcode_PE__c = null;
        }
    }
   
        public static Integer calculateAge(Date birthDate){
        Integer Age;

        Date day = Date.today();
        
        if(day >= birthDate)
        {
          Age =   day.year() - birthDate.year();
        }
        else{
            Age =   day.year() - (birthDate.year() - 1);
        }  
        return Age;
    }
    
    
    public void CheckCountry(){
        System.debug(selectedCountry);
         contact.C_Country_PE__c = selectedCountry;
        if(selectedCountry =='Thailand'){
            IsCountryAsTH =true;
            IsOtherCountry = false;
        }else{
            IsCountryAsTH =false;
            IsOtherCountry = true;
            
        }        
    }
    
    public Pagereference customCancel(){
        PageReference viewPage;
        if (contact.Account__c != null) {
            Account accountObj = [select id,name from Account where id=:contact.Account__c limit 1];
            viewPage = new ApexPages.StandardController(accountObj).view();   
            
        }
        viewPage.setRedirect(true);
        return viewPage; 
    }

    public Id getRecordType (){
        List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Contact.RecordTypeInfos;
        Id defaultRecordTypeId;

        //check each one
        for (Schema.RecordTypeInfo info : infos) {
            if (info.DefaultRecordTypeMapping) {
                defaultRecordTypeId = info.RecordTypeId;
            }
        }

        //here is the default Opportunity RecordType Id for the current user
        return defaultRecordTypeId;
    }
}