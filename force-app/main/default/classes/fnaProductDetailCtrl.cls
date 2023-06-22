global without sharing class fnaProductDetailCtrl {
    public Set<String> province     {get;set;}
    public Set<String> district     {get;set;}
    public Set<String> branch       {get;set;}
  
    public String provinceDependent {get;set;}
    public String districtDependent {get;set;}
    public String branchDependent   {get;set;}
    public string personName        {get;set;}
    public string mobileNumber      {get;set;}

    public string sessionData       {get;set;}

    public String b64               {get;set;}	
    public String formIdOriginal    {get;set;}
    public Id formId                {get;set;}
    public Id idRTL                 {get;set;}
    public String logoImage         {get;set;}
    public String heart             {get;set;}
    public String notSupport        {get;set;}
    public String orientation       {get;set;}
    public String heartInvert       {get;set;}
    public String back              {get;set;}
    public String dead              {get;set;}
    public String hurt              {get;set;}
    public String backInvert        {get;set;}

    public String domain {
        get{
            if(domain == '' || domain == null){
                List<App_Config__mdt> appConfigList = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'FNA Community Url'];
                if(appConfigList.size() > 0){
                    return appConfigList[0].Value__c;
                }
            }
            return '';
        }
    }

    global class reponsePDF{
        global String pdfId;
        global String pdffile;
        global String productName;
        global boolean isError;
        global String productId;
    }

    private final static List<App_Config__mdt> IDLE_TIME_MILLISECONDS = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'FNA IDLE TIME MILLISECONDS' LIMIT 1];

    public String idleTimeMilliseconds {get;set;} 


    public void idleTime(){
        String idleTimeTemp = IDLE_TIME_MILLISECONDS[0].Value__c;
        idleTimeMilliseconds = idleTimeTemp;
        system.debug('idleTimeMilliseconds : ' + idleTimeMilliseconds);
    }

    @RemoteAction
    global static String idleTimeConstructor(){
        String idleTimeTemp = IDLE_TIME_MILLISECONDS[0].Value__c;
        system.debug('idleTimeTemp : ' + idleTimeTemp);
        return idleTimeTemp;
    }

    public static Map<String, String> getParamsUrl(String enUrls){
        system.debug('enUrls : ' + enUrls);
        Map<String, String> myMap = new Map<String, String>();
        List<String> sURLVariables = new List<String>(enUrls.split('&'));
        Integer i;
        List<String> sParameterName = new List<String>();
        for (i = 0; i < sURLVariables.size(); i++) {
            system.debug('sURLVariables[i] : ' + sURLVariables[i]);
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            system.debug('sParameterName : ' + sParameterName);
            myMap.put(sParameterName[0], sParameterName[1]);
        }
        return myMap;
    }

    public fnaProductDetailCtrl(){

        String enUrls = '';
        for(String sUrl : apexpages.currentpage().getparameters().keyset()){
            enUrls = sUrl;
        }
        
        enUrls = Test.isRunningTest() ? apexpages.currentpage().getparameters().get('fullParam') : enUrls;
        System.debug('enUrls :' + enUrls);
        
        /* Section Decrypt Params */
        Map<String, String> sMapUrl = new Map<String, String>();
        sMapUrl = getParamsUrl(enUrls);
        System.debug('sMapUrl :' + sMapUrl);
        formIdOriginal = sMapUrl.get('Id');
        formIdOriginal = UrlHelper.decryptParams(formIdOriginal);
        System.debug('formIdOriginal :' + formIdOriginal);
        String rtlIdEncrypte = sMapUrl.get('RTLId');  
        idRTL = UrlHelper.decryptParams(rtlIdEncrypte);
        System.debug('idRTL :' + idRTL);
        formId = formIdOriginal;

        /* Section Default Value */
        defaultValue(formId, idRTL);

    }

    public void defaultValue(String fnaId, String productId){
        Map<String, String> titleURL = new Map<String, String>();
        if(formId != null && formId.getSObjectType() == FNA_Activity__c.sObjectType){

            List<FNA_Activity__c> form = [SELECT Id, Avatar_Master__r.segment__c, Avatar_Downloaded__c, phone__c, Drop_Off_URL__c, Drop_Off_Page__c,
                                    (Select id, answer__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name = 'Q13' ) 
                                    FROM FNA_Activity__c WHERE id=:formId];
            if(form.size()>0){
                String urlIconAvatar = fnaUtility.meargeSmallAvatarTitle(form[0].Avatar_Master__r.segment__c, form[0].Questionnaire_Results__r[0].answer__c);
                titleURL.put('AvatarIcon', urlIconAvatar);
                mobileNumber = form[0].phone__c;
            }
        }
        titleURL.put('LogoImage', 'logo');
        titleURL.put('heart', 'ico-heart');
        titleURL.put('heartInvert', 'ico-heart-inverted');
        titleURL.put('back', 'ico-back');
        titleURL.put('backInvert', 'ico-back-inverted');
        titleURL.put('notSupport', 'notSupport');
        titleURL.put('orientation', 'orientation');
        titleURL.put('dead', 'img-dead');
        titleURL.put('hurt', 'img-hurt');
        titleURL = fnaUtility.getImageUrl(titleURL);

        b64 = titleURL.get('AvatarIcon');
        logoImage = titleURL.get('LogoImage');
        heart = titleURL.get('heart');
        heartInvert = titleURL.get('heartInvert');
        back = titleURL.get('back');
        backInvert = titleURL.get('backInvert');
        notSupport = titleURL.get('notSupport');
        orientation = titleURL.get('orientation');
        dead = titleURL.get('dead');
        hurt = titleURL.get('hurt');

    }

    @RemoteAction
    global static void stampUrlDropOff(String FNAId, String urlPage, String RTL){
        //FNAId = UrlHelper.decryptParams(FNAId);
        System.debug('FNAId :'+ FNAId);
        List<FNA_Activity__c> form = [SELECT Id, Drop_Off_URL__c, Drop_Off_Page__c FROM FNA_Activity__c WHERE id=: FNAId];
        System.debug('idRTL :'+ RTL);
        List<RTL_product_master__c> listRTLProduct = [SELECT Id,FNA_Product_Name__c, Name, FNA_Product_Name_TH__c FROM RTL_product_master__c WHERE id = :RTL];         
        System.debug('idRTL :'+ listRTLProduct);
        if(form.size() > 0 && listRTLProduct.size() > 0){
            form[0].Drop_Off_Page__c = 'ProductDetail : ' + listRTLProduct[0].FNA_Product_Name__c;
            form[0].Drop_Off_URL__c = '/fin/fnaProductDetail' + urlPage;
            update form;
        }
    }

    @RemoteAction
    global static reponsePDF getStream(String rtlid){
        reponsePDF res = new reponsePDF();
        String titlePDF = '';
        system.debug('rtlid : ' + rtlid);
        if(rtlid != '' && rtlid != null){
            List<RTL_product_master__c> listRTLProduct = [SELECT Id,FNA_Product_Name__c, Name, FNA_Product_Name_TH__c FROM RTL_product_master__c WHERE id = :rtlid];         
            for(RTL_product_master__c rtl : listRTLProduct){
                titlePDF = rtl.FNA_Product_Name__c;
                res.productName = rtl.FNA_Product_Name_TH__c;
                res.productId = rtl.Id;
            } 

            system.debug('titlePDF : ' + titlePDF);
            
            if(titlePDF != '' && titlePDF != null){
                List<ContentVersion> pdflist = new List<ContentVersion>();
                pdflist = fnaUtility.getListContentVersion('Product Detail', 'PDF', titlePDF);
                System.debug('pdflist ' + pdflist);
                if(pdflist.size() > 0){
                    System.debug('ContentSize ' + pdflist[0].ContentSize);
                    if(pdflist[0].ContentSize <= 4418421){
                        res.pdffile = EncodingUtil.base64Encode(pdflist[0].VersionData);
                        res.pdfId = pdflist[0].id;
                    }else{
                        res.isError = true;
                    }
                }
            }
        }
        return res;
    }

    @RemoteAction
    global static OTP__c fnGenerateOTP (String fnaId, String phone){
        OTP__c tempOtp = new OTP__c();
        tempOtp = fnaGenerateOTPCtrl.fnGenerateOTP(fnaId);

        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        system.debug('Success' + phone);
        system.debug('Success' + fnaId);
        system.debug('Success' + tempOtp.id);
        if(fnaId != null && fnaId != null){
            fnaActivity.id = fnaId;
            fnaActivity.Phone__c = phone;
            fnaActivity.SMS_OTP__c = tempOtp.id;
            update fnaActivity;

            FNA_Activity__c sobj = [SELECT Id, Send_SMS_Details__c, SMS_Sponsor__c, Phone__c, SMS_OTP__r.OTP_Code__c, SMS_OTP__r.Otp_Ref__c, SMS_OTP__r.Expire_DateTime__c FROM FNA_Activity__c WHERE id =: fnaId LIMIT 1];
            system.debug('sendOTP' + sobj); 
            String serviceName = 'SMS_Verify_OTP';
            fnaUtility.sendSMS(sobj, serviceName);
        }

        return tempOtp;
    }

    @RemoteAction
    global static void sendSMSUrl (String fnaId){
        System.debug('sendSMSUrl fnaId Before: ' + fnaId);
        fnaId = UrlHelper.encryptParams(fnaId);
        System.debug('sendSMSUrl fnaId After: ' + fnaId);
        fnaUtility.sendSMSURL(fnaId);
    }

    @RemoteAction
    global static void successDownload (String fnaId){
        System.debug('successDownload fnaId Before: ' + fnaId);
        fnaId = UrlHelper.encryptParams(fnaId);
        System.debug('successDownload fnaId After: ' + fnaId);
        fnaUtility.successDownload(fnaId);
    }


    @RemoteAction
    global static Integer fnVerifyOTP (String fnaId, String otpCode){
        Integer caseOTP = fnaGenerateOTPCtrl.fnVerifyOTP(fnaId, otpCode);
        if(caseOTP == 7){
            fnaUtility.FnaCheckExistingNonEncrypt(fnaId);
        }
        return caseOTP;
    }   

    public void dependentInformationDistrict() {
        system.debug('Dependent District');
        system.debug('provinceDependent' + provinceDependent);
        system.debug('districtDependent' + districtDependent);
        system.debug('branchDependent' + branchDependent);
        branchDependent = 'สาขา';

        district = new Set<String>();

        if(provinceDependent != 'จังหวัด'){
            List<Branch_and_Zone__c> allTMBDistrict_List = [SELECT Id, RTL_Address__c, Branch_Name__c, IsActive__c, Province__c, District__c FROM Branch_and_Zone__c WHERE isActive__c = true AND Province__c =: provinceDependent ORDER BY District__c, Branch_Name__c];
            for(Branch_and_Zone__c allTMBDistrict_Obj : allTMBDistrict_List){
                district.add(allTMBDistrict_Obj.District__c);    
                System.debug('district : '+ district);
            }     
        }
    }

    public void dependentInformationBranch() {
        branch = new Set<String>();
        system.debug('Dependent Branch');
        system.debug('Dependent District');
        system.debug('provinceDependent' + provinceDependent);
        system.debug('districtDependent' + districtDependent);
        system.debug('branchDependent' + branchDependent);
        if(provinceDependent != 'จังหวัด'){
            if(districtDependent != 'เขต'){
                // if(branchDependent != 'สาขา'){
                    List<Branch_and_Zone__c> allTMBBranch_List = [SELECT Id, RTL_Address__c, Branch_Name__c, IsActive__c, Province__c, District__c FROM Branch_and_Zone__c WHERE isActive__c = true AND District__c =: districtDependent AND Province__c =: provinceDependent ORDER BY Branch_Name__c];
                    for(Branch_and_Zone__c allTMBBranch_Obj : allTMBBranch_List){
                        branch.add(allTMBBranch_Obj.Branch_Name__c);
                        System.debug('branch : '+ branch);
                    }     
                // }
            }
        }
    }

    public void setInformation() {
        System.debug('formId : '+ formId);
        List<FNA_Activity__c> personInfo = [SELECT Id, Avatar_Master__c, Questionnaire_Flow__c, Answer_Flow__c, Branch__c, Phone__c, Person_Name__c,  Branch_Name__c FROM FNA_Activity__c WHERE Id =: formId];
        System.debug('personInfo : '+ personInfo);

        mobileNumber = personInfo[0].Phone__c;
        personName = personInfo[0].Person_Name__c;

        System.debug('personInfo[0].Branch__c : '+ personInfo[0].Branch__c);

        if(personInfo[0].Branch__c != 'undefined' && personInfo[0].Branch__c != null && personInfo[0].Branch__c != 'null'){
            String branchCode = personInfo[0].Branch__c;
            System.debug('branchCode : '+ branchCode);
            List<Branch_and_Zone__c> allTMBAddr_List = [SELECT Id, name, Province__c, District__c, IsActive__c, Branch_Name__c, Branch_Code__c FROM Branch_and_Zone__c WHERE IsActive__c = true AND Branch_Code__c =: branchCode ORDER BY Province__c, District__c, Branch_Name__c];
            System.debug('allTMBAddr_List : '+ allTMBAddr_List);
            provinceDependent = allTMBAddr_List[0].Province__c;
            districtDependent = allTMBAddr_List[0].District__c;
            branchDependent = allTMBAddr_List[0].Branch_Name__c;
        }
        else if (personInfo[0].Branch_Name__c != null){
            String branchName = personInfo[0].Branch_Name__c;
            List<Branch_and_Zone__c> allTMBAddr_List = [SELECT Id, name, Province__c, District__c, IsActive__c, Branch_Name__c, Branch_Code__c FROM Branch_and_Zone__c WHERE IsActive__c = true AND name =: branchName ORDER BY Province__c, District__c, Branch_Name__c];
            provinceDependent = allTMBAddr_List[0].Province__c;
            districtDependent = allTMBAddr_List[0].District__c;
            branchDependent = allTMBAddr_List[0].Branch_Name__c;
        }
        
        personName = personName != null ? EncodingUtil.urlEncode(personName, 'UTF-8') : '';
        system.debug('mobileNumber ' + mobileNumber);
        system.debug('personName ' + personName);
        system.debug('provinceDependent ' + provinceDependent);
        system.debug('districtDependent ' + districtDependent);
        system.debug('branchDependent ' + branchDependent);

    }

    public void getInformation() { // get value in select input to ready for query dependent
        province = new Set<String>();
        district = new Set<String>();
        branch = new Set<String>();

        system.debug('mobileNumber ' + mobileNumber);
        system.debug('personName ' + personName);
        system.debug('provinceDependent ' + provinceDependent);
        system.debug('districtDependent ' + districtDependent);
        system.debug('branchDependent ' + branchDependent);

        List<Branch_and_Zone__c> allTMBAddr_List_SortProvince = [SELECT Id, Province__c, District__c, IsActive__c, Branch_Name__c, Branch_Code__c FROM Branch_and_Zone__c WHERE IsActive__c = true ORDER BY Province__c];
        List<Branch_and_Zone__c> allTMBAddr_List_SortDistrict = [SELECT Id, Province__c, District__c, IsActive__c, Branch_Name__c, Branch_Code__c FROM Branch_and_Zone__c WHERE IsActive__c = true ORDER BY District__c];
        List<Branch_and_Zone__c> allTMBAddr_List_SortBranch = [SELECT Id, Province__c, District__c, IsActive__c, Branch_Name__c, Branch_Code__c FROM Branch_and_Zone__c WHERE IsActive__c = true ORDER BY Branch_Name__c];

        for(integer i =0; i < allTMBAddr_List_SortProvince.size(); i++){
            province.add(allTMBAddr_List_SortProvince[i].Province__c);
            district.add(allTMBAddr_List_SortDistrict[i].District__c);     
            branch.add(allTMBAddr_List_SortBranch[i].Branch_Name__c);
        }
        
        provinceDependent = 'จังหวัด';
        districtDependent = 'เขต';
        branchDependent = 'สาขา';
    }

    public CustomerProductLists callOSCUtility {get;set;}
    public void saveInformation() {
        system.debug('mobileNumber ' + mobileNumber);
        system.debug('personName ' + personName);
        system.debug('provinceDependent ' + provinceDependent);
        system.debug('districtDependent ' + districtDependent);
        system.debug('branchDependent ' + branchDependent);

        List<FNA_Activity__c> personInfo = [SELECT Id, Avatar_Name__c, CreatedDate, Customer__r.TMB_Customer_ID_PE__c, Customer__c, Customer__r.Id, 
                                                Avatar_Master__c, Avatar_Master__r.Avatar_Segment__c, Avatar_Master__r.Segment__c, Questionnaire_Flow__c, 
                                                Answer_Flow__c, Branch__c, Phone__c, Person_Name__c,  Branch_Name__c , Product_Holding__c,
                                                (Select id, Answer__c, FNA_Activity_Name__c, Question_ID__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name ='Q13'),
                                                (SELECT id, name, FNA_Activity__c FROM Leads__r) 
                                                FROM FNA_Activity__c WHERE Id =: formId];
        personInfo[0].Phone__c = mobileNumber;
        personInfo[0].Person_Name__c = personName;
        if(personInfo[0].Customer__c == null && personInfo[0].Leads__r.size() == 0){
            personInfo[0] = fnaUtility.stampFieldExisting(personInfo[0], fnaUtility.functionCheckExisting(mobileNumber));
        }

        if(personInfo[0].Customer__c != null){
            System.debug('OSC14| findCustomerId : ' + personInfo);
            System.debug('OSC14| findCustomerTMBId : ' + personInfo[0].Customer__r.TMB_Customer_ID_PE__c);
            System.debug('OSC14| findCustomerId : ' + personInfo[0].Customer__r.Id);
            String customerTmbId = personInfo[0].Customer__r.Id;
        }
        
        List<Branch_and_Zone__c> getBranchCode = [SELECT Id, name, Province__c, District__c, IsActive__c, Branch_Name__c, Branch_Code__c FROM Branch_and_Zone__c WHERE IsActive__c = true AND Branch_Name__c =: branchDependent];
        if(getBranchCode.size() > 0){
            personInfo[0].Branch__c = getBranchCode[0].Branch_Code__c;
       		personInfo[0].Branch_Name__c = getBranchCode[0].name;
        }
        

        system.debug('personInfo ' + personInfo);
        
        update personInfo;
    }

    public void createRef(){
        system.debug('-----create Ref-----');
        ReferralUtility.createReferral(formId,sessionData);
    }

    public String responseOSC14 {get;set;}
    public String responseOSC16 {get;set;}

    public String responseOSC01 {get;set;}
    public String responseOSC05 {get;set;}
    public String responseGetCardsBalance {get;set;}

    public String statusResponse {get;set;}
    public Integer statusCode {get;set;}
    public Boolean sendSMS {get;set;}
    // public void stampOffSet(){
    //     System.debug('OSC14| FNA Activity Id : ' + formId);
    //     System.debug('OSC14| responseOSC14 : ' + responseOSC14);
    //     System.debug('OSC16| responseOSC16 : ' + responseOSC16);

    //     String responseCallBackOSC14;
    //     String responseCallBackOSC16;

    //     if(responseOSC14 != null && responseOSC14 != ''){
    //         responseCallBackOSC14 = fnaUtility.stampOffSetProductHoldingOSC14(formId,CaseAccountProduct.parseJsonToObj((String)responseOSC14));
    //     }
    //     if(responseOSC16 != null && responseOSC16 != ''){
    //         responseCallBackOSC16 = fnaUtility.stampOffSetProductHoldingOSC16(formId,CaseBAProduct.parseJsonToObj((String)responseOSC16));
    //     }
    //     statusCode = 200;
    //     statusResponse = 'STAMP OFFSET PRODUCT HOLDING : ' + responseCallBackOSC14 + ' AND ' + responseCallBackOSC16;
    // }

    // new
    public void stampOffSet(){
        System.debug('OSC14| FNA Activity Id : ' + formId);
        System.debug('OSC14| responseOSC01 : ' + responseOSC01);
        System.debug('OSC16| responseOSC05 : ' + responseOSC05);
        System.debug('GET-CARDS-BALANCE| responseGetCardsBalance : ' + responseGetCardsBalance);

        String responseCallBackOSC01;
        String responseCallBackOSC05;
        String responseCallBackGetCardsBalance;

        if(responseOSC01 != null && responseOSC01 != ''){
            CustomerAccountResponse res01Obj = (CustomerAccountResponse) System.JSON.deserialize(responseOSC01, CustomerAccountResponse.class);
            responseCallBackOSC01 = fnaUtility.stampOffSetProductHoldingOSC01(formId, res01Obj);
        }
        if(responseOSC05 != null && responseOSC05 != ''){
            BancassuranceResponse res05Obj = (BancassuranceResponse) System.JSON.deserialize(responseOSC05, BancassuranceResponse.class);
            responseCallBackOSC05 = fnaUtility.stampOffSetProductHoldingOSC05(formId, res05Obj);
        }
        if(responseGetCardsBalance != null && responseGetCardsBalance != ''){
            responseCallBackGetCardsBalance = fnaUtility.stampOffSetProductHoldingGetCardsBalance(formId, responseGetCardsBalance);
        }
        statusCode = 200;
        statusResponse = 'STAMP OFFSET PRODUCT HOLDING : ' + responseCallBackOSC01 + ' AND ' + responseCallBackOSC05 + ' AND ' + responseCallBackGetCardsBalance;
        
    }

    @RemoteAction
    global static String encryptId(String FNAIdEncrypt){
        FNAIdEncrypt = UrlHelper.encryptParams(FNAIdEncrypt);
        return FNAIdEncrypt;
    }

}