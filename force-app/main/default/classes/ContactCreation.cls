public with sharing class ContactCreation {
    
    @AuraEnabled        
    public static String[] picklist_values(String object_name, String field_name) {
        String[] values = new String[]{};
            String[] types = new String[]{object_name};
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {values.add(entry.getValue());}
            }
        }
        System.debug(values);
        return values;
    }
    
    @AuraEnabled        
    public static String[] countries() {
        List<Country__c> countries = [SELECT ID,Name,Code__c FROM Country__c WHERE Name != '' AND Code__c != null ORDER BY Name];
        String[] countriesName = new String[]{};
            for(Country__c c : countries){
                countriesName.add(c.Name);
            }
        return countriesName;
    }
    
    //Modified 9 Feb 2022 CR AL Re-org Long Term
    @AuraEnabled        
    public static String[] provinces() {
        List<RTL_Contact_Address__c> contactAddrList = [SELECT Id,Name,RTL_Province__c,RTL_District__c,RTL_Sub_District__c,RTL_Zipcode__c,isActive__c FROM RTL_Contact_Address__c WHERE isActive__c = true ORDER BY RTL_Province__c];
        //List<Province__c> provinces = [SELECT Id,Name,Code__c FROM Province__c WHERE id != null ORDER BY Name];
        Set<String> provinceSet = new Set<String>();
        String[] provincesName = new String[]{};
        // for(Province__c p : provinces){
        //     provincesName.add(p.Name);
        // }

        for(RTL_Contact_Address__c ca : contactAddrList){
            provinceSet.add(ca.RTL_Province__c);
        }
        provincesName.addAll(provinceSet);
        return provincesName;
    }

    //Modified 9 Feb 2022 CR AL Re-org Long Term
    @AuraEnabled        
    public static String[] districts(String selectedProvince) {
        List<RTL_Contact_Address__c> contactAddrList = [SELECT Id,Name,RTL_Province__c,RTL_District__c,RTL_Sub_District__c,RTL_Zipcode__c,isActive__c FROM RTL_Contact_Address__c WHERE RTL_Province__c =: selectedProvince AND isActive__c = true  ORDER BY RTL_District__c];
        //List<District__c> districts = [SELECT ID,Name,Code__c FROM District__c WHERE Province__r.Name =:selectedProvince ORDER BY Name];
        Set<String> districtSet = new Set<String>();
        String[] districtsName = new String[]{};
        // for(District__c d : districts){
        //     districtsName.add(d.Name);
        // }

        for(RTL_Contact_Address__c ca : contactAddrList){
            districtSet.add(ca.RTL_District__c);
        }
        districtsName.addAll(districtSet);
        return districtsName;
    }
    
    //Modified 9 Feb 2022 CR AL Re-org Long Term
    @AuraEnabled        
    public static String[] subDistricts(String selectedDistrict) {
        List<RTL_Contact_Address__c> contactAddrList = [SELECT Id,Name,RTL_Province__c,RTL_District__c,RTL_Sub_District__c,RTL_Zipcode__c,isActive__c FROM RTL_Contact_Address__c WHERE RTL_District__c =: selectedDistrict AND isActive__c = true ORDER BY RTL_Sub_District__c];
        // List<Sub_District__c> subDistricts = [SELECT ID,Name,Code__c,Zip_code__c,Location_Code__c FROM Sub_District__c WHERE District__r.Name =:selectedDistrict ORDER BY Name];
        Set<String> subdistrictSet = new Set<String>();
        String[] subDistrictsName = new String[]{};
        // for(Sub_District__c d : subDistricts){
        //     subDistrictsName.add(d.Name);
        // }
        for(RTL_Contact_Address__c ca : contactAddrList){
            subdistrictSet.add(ca.RTL_Sub_District__c);
        }
        subDistrictsName.addAll(subdistrictSet);
        return subDistrictsName;
    }

   //Modified 9 Feb 2022 CR AL Re-org Long Term    
    @AuraEnabled        
    public static String[] postalCode(String selectedDistrict,String selectedSubDistrict) {
        System.debug('selectedDistrict:'+selectedDistrict);
        System.debug('selectedSubDistrict:'+selectedSubDistrict);
        List<RTL_Contact_Address__c> contactAddrList = [SELECT Id,Name,RTL_Province__c,RTL_District__c,RTL_Sub_District__c,RTL_Zipcode__c,isActive__c FROM RTL_Contact_Address__c WHERE RTL_District__c =: selectedDistrict AND RTL_Sub_District__c =: selectedSubDistrict AND isActive__c = true ORDER BY RTL_Zipcode__c];
        // List<Sub_District__c> subDistricts = [SELECT ID,Name,Code__c,Zip_code__c,Location_Code__c FROM Sub_District__c WHERE Name =:selectedSubDistrict AND District__r.Name=:selectedDistrict ORDER BY Name];
        Set<String> codeSet = new Set<String>();
        String[] code = new String[]{};
        // for(Sub_District__c d : subDistricts){
        //     code.add(d.Zip_code__c);
        // }
        for(RTL_Contact_Address__c ca : contactAddrList){
            codeSet.add(ca.RTL_Zipcode__c);
        }
        code.addAll(codeSet);
        system.debug(code);
        return code;
    }
    
    @AuraEnabled        
    public static Contact getContact(Id recordId) {
        Contact con = [SELECT Id,RecordTypeId,RecordType.Name,Salutation,AccountId,ID_Type_PE__c,FirstName,ID_Number_PE__c,Last_Name__c,LastName,Position__c,Date_of_Birth__c,Authorized_person_of_signature__c,Account__c,Main_contact__c,Photo__c,MobilePhone,C_AddressLine1_PE__c,Phone,C_AddressLine3_PE__c,Primary_Phone_Ext_PE__c,C_AddressLine2_PE__c,Fax,C_Province_PE__c,Email,C_AddressLine5_PE__c,Facebook_ID__c,C_AddressLine4_PE__c,Line_ID__c,C_Zipcode_PE__c,C_Country_PE__c,Value_Style__c,Difficult_to_deal__c,Decision_Map__c,Product_Decision__c,Decision_Map2__c,Product_Decision_2_2__c,Decision_Map3__c,Product_Decision_3_2__c,Description2__c 
                       FROM Contact WHERE Id =:recordId LIMIT 1];
        
        return con;
    }
}