public without sharing class fnaHighlightProductCtrl {

    public class WrapGroup {
        @AuraEnabled
        public List<ProductFNA> resProdHightlight   {get;set;}
        @AuraEnabled
        public List<ProductFNA> resProdNormal       {get;set;}
        @AuraEnabled
        public List<ProductFNA> resProdPackage      {get;set;}
        @AuraEnabled
        public Boolean resIsDownload                {get;set;}
        @AuraEnabled
        public String avatarName                    {get;set;}
    }

    public class ProductFNA {
        @AuraEnabled
        public String thumbnail {get;set;}
        @AuraEnabled
        public String preLoad {get;set;}
        @AuraEnabled
        public String cssTag {get;set;}
        @AuraEnabled
        public FNA_Product_Mapping__c product {get;set;}
    }

    public class FnaDetail {
        @AuraEnabled
        public String avatarImage {get;set;}
        @AuraEnabled
        public String mobileNumber {get;set;}
    }

    // @AuraEnabled
    // public static String fnaActId {get;set;}

    private final static List<App_Config__mdt> IDLE_TIME_MILLISECONDS = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'FNA IDLE TIME MILLISECONDS' LIMIT 1];
    @AuraEnabled    
    public static String idleTime(){
        String idleTimeTemp = IDLE_TIME_MILLISECONDS[0].Value__c;
        system.debug('idleTimeTemp : ' + idleTimeTemp);
        return idleTimeTemp;
    }

    @AuraEnabled    
    public static void createRef(String fnaActId,String sessionData){
        fnaActId = UrlHelper.decryptParams(fnaActId);
        system.debug('fnaActId : ' + fnaActId);
        system.debug('sessionData : ' + sessionData);
        system.debug('-----create Ref-----');
        ReferralUtility.createReferral(fnaActId,sessionData);
    }

    @AuraEnabled
    public static WrapGroup getMapGroup(String fnaActivityId) {
        fnaActivityId = UrlHelper.decryptParams(fnaActivityId);
        WrapGroup result = new WrapGroup();

        if(fnaActivityId != '') {
            FNA_Activity__c avatarMasterID = [SELECT Avatar_Master__c, Avatar_Downloaded__c, Avatar_Master__r.segment__c, Avatar_Master__r.Avatar_TH__c, 
                                                (SELECT id, Question__c, Answer__c, Question_ID__r.Name, Choice_Answer__c FROM Questionnaire_Results__r ) 
                                                FROM FNA_Activity__c 
                                                WHERE id =: fnaActivityId];
            result.resIsDownload = avatarMasterID.Avatar_Downloaded__c;
            result.avatarName = avatarMasterID.Avatar_Master__r.Avatar_TH__c;

            //PRODUCT OFFSET = FALSE AND FNA ACTIVE = TRUE
            List<FNA_Product_Offering__c> getAllProdOfferList = [SELECT Id, FNA_Product_Name__c, Flag_Highlight__c, Product_Type__c,
                                        Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c, 
                                        FNA_Product_Name__r.Product__r.FNA_Active__c 
                                        FROM FNA_Product_Offering__c 
                                        WHERE FNA_Activity__c =: fnaActivityId 
                                        AND Flag_Offset_product_holding__c = false
                                        AND FNA_Product_Name__r.Product__r.FNA_Active__c = true];

            system.debug('getAllProdOfferList : ' + getAllProdOfferList);

            Set<Id> prodMapId = new Set<Id>();
            for(FNA_Product_Offering__c getIdProdMapping : getAllProdOfferList){
                prodMapId.add(getIdProdMapping.FNA_Product_Name__c);
            }

            List<FNA_Product_Mapping__c> productMapList = [SELECT Sequence_No__c, Product__c, Product__r.FNA_Product_Group__c, 
                                Product__r.FNA_Product_Name__c, Product__r.FNA_Product_Name_TH__c, Product__r.FNA_Product_Summary__c, Segment__c, 
                                Highlight_Product_Condition__c, Avatar_Master__r.segment__c, Normal_Product_Condition__c, Product__r.FNA_Product_Group_TH__c
                                FROM FNA_Product_Mapping__c WHERE Id IN: prodMapId];
            Map<Id,FNA_Product_Mapping__c> prodIdFindProdMap = new Map<Id,FNA_Product_Mapping__c>(productMapList);

            List<ProductFNA> productHighlightList   = new List<ProductFNA>();
            List<ProductFNA> productNormalList      = new List<ProductFNA>();
            List<ProductFNA> productPackageList     = new List<ProductFNA>();

            for(FNA_Product_Offering__c getAllProdOfferObj : getAllProdOfferList){
                if(getAllProdOfferObj.Product_Type__c == 'Package'){
                    ProductFNA prodPackageObj = new ProductFNA();
                    prodPackageObj.product = prodIdFindProdMap.get(getAllProdOfferObj.FNA_Product_Name__c);
                    prodPackageObj.thumbnail = '';
                    productPackageList.add(prodPackageObj);

                }else if(getAllProdOfferObj.Flag_Highlight__c == true){
                    ProductFNA prodHighlightObj = new ProductFNA();
                    prodHighlightObj.product = prodIdFindProdMap.get(getAllProdOfferObj.FNA_Product_Name__c);
                    prodHighlightObj.thumbnail = '';
                    productHighlightList.add(prodHighlightObj);
                }
                else if (getAllProdOfferObj.Flag_Highlight__c == false){
                    ProductFNA prodNormalObj = new ProductFNA();
                    prodNormalObj.product = prodIdFindProdMap.get(getAllProdOfferObj.FNA_Product_Name__c);
                    prodNormalObj.thumbnail = '';
                    productNormalList.add(prodNormalObj);
                }
                else{
                    System.debug('PRODUCT OFFERING IS NOT HIGHLIGHT FLAG');
                }
            }
            result.resProdPackage = productPackageList;
            result.resProdHightlight = productHighlightList;
            result.resProdNormal = productNormalList;
        }
        return result;
    }

    @AuraEnabled
    public static List<ProductFNA> getThumbnailUrlAll(List<ProductFNA> prodFNA) {
        System.debug('getThumbnailUrlAll');
        System.debug('prodFNA : ' + prodFNA);

        List<String> thumbnailName = new List<String>();

        String thumbUrl = '';
        String preLoadStr = '';

        for(Integer i=0; i < prodFNA.size(); i++){
            System.debug('Product__r : ' + prodFNA[i].product.Product__r.FNA_Product_Name__c);
            thumbnailName.add(prodFNA[i].product.Product__r.FNA_Product_Name__c);
        }
        
        // String thumnailTitle = prodFNA.product.Product__r.FNA_Product_Name__c;
        List<ContentVersion> thumbnailUrlList = new List<ContentVersion>();
        thumbnailUrlList.addAll(fnaUtility.getListContentVersionAll('Banner','Thumbnail', thumbnailName));

        List<ContentVersion> thumbnailUrlListDefault = new List<ContentVersion>();
        List<String> defaultThumbnailList = new List<String>();
        defaultThumbnailList.add('Default');
        defaultThumbnailList.add('PreLoading');
        thumbnailUrlListDefault.addAll(fnaUtility.getListContentVersionAll('Banner','Thumbnail', defaultThumbnailList));

        for(Integer i=0;i<prodFNA.size();i++){
            // System.debug('prodFNA Before : ' + prodFNA[i]);
            for(Integer j=0;j<thumbnailUrlList.size();j++){
                // System.debug('thumbnailUrlList : ' + thumbnailUrlList[i]);
                if(prodFNA[i].product.Product__r.FNA_Product_Name__c == thumbnailUrlList[j].Title){
                    // System.debug('thumbnailUrlList : ' + thumbnailUrlList[j]);
                    thumbUrl = '/fin/sfc/servlet.shepherd/version/download/' + thumbnailUrlList[j].Id;
                    break;
                }
            }
            prodFNA[i].thumbnail = thumbUrl;
            for(ContentVersion thumbnailUrlObjDefault : thumbnailUrlListDefault){
                if(prodFNA[i].thumbnail == ''){
                    if(thumbnailUrlObjDefault.Title == 'Default'){
                        prodFNA[i].thumbnail = '/fin/sfc/servlet.shepherd/version/download/' + thumbnailUrlObjDefault.Id;                
                    }
                }
                if(thumbnailUrlObjDefault.Title == 'PreLoading'){
                    prodFNA[i].preLoad = '/fin/sfc/servlet.shepherd/version/download/' + thumbnailUrlObjDefault.Id;                
                }
                System.debug('thumbnailUrlListDefault : ' + thumbnailUrlListDefault);
            }
            // System.debug('Problem After : ' + prodFNA[i]);
        }

        for(Integer i=0;i<prodFNA.size();i++){
            System.debug('prodFNA After : ' + prodFNA[i]);

                if(prodFNA[i].product.Product__r.FNA_Product_Group_TH__c == 'บัญชีเพื่อใช้ - เพื่อออม'){
                    prodFNA[i].cssTag = 'fas fa-tag spendings';
                }

                else if(prodFNA[i].product.Product__r.FNA_Product_Group_TH__c == 'บัตรเครดิต - สินเชื่อ'){
                    prodFNA[i].cssTag = 'fas fa-tag savings';
                }

                else if(prodFNA[i].product.Product__r.FNA_Product_Group_TH__c == 'ประกัน'){
                    prodFNA[i].cssTag = 'fas fa-tag insurance';
                }

                else if(prodFNA[i].product.Product__r.FNA_Product_Group_TH__c == 'ลงทุน'){
                    prodFNA[i].cssTag = 'fas fa-tag invest';
                }

                else if(prodFNA[i].product.Product__r.FNA_Product_Group_TH__c == 'เอสเอ็มอี'){
                    prodFNA[i].cssTag = 'fas fa-tag sme';
                }
        }

        return prodFNA;

    }

    @AuraEnabled
    public static Avatar_Master__c getAvatar(String idForm){
        idForm = UrlHelper.decryptParams(idForm);
        String avtarMasterId = '';
        List<FNA_Activity__c> questionFormList = [SELECT Id, Person_Name__c, Avatar_Master__c, Avatar_Master__r.Segment__c, Drop_Off_Page__c, Answer_Flow__c FROM FNA_Activity__c WHERE id=:idForm];
        if(questionFormList.size() > 0 ){
            avtarMasterId = questionFormList[0].Avatar_Master__c;
        }
        Avatar_Master__c avtarList = [SELECT Id, Segment__c, Avatar_EN__c, Avatar_TH__c, Avatar_Description__c FROM Avatar_Master__c where id =: avtarMasterId];
        return avtarList;
    }

    @AuraEnabled
    public static FnaDetail getAvatarMasterDetail(String idForm, String urlDropOff){
        FnaDetail fnaWapper = new FnaDetail();

        idForm = UrlHelper.decryptParams(idForm);
        system.debug('idForm : ' + idForm);
        List<FNA_Activity__c> questionFormList = [SELECT Id, Avatar_Master__r.segment__c, Drop_Off_URL__c, Drop_Off_Page__c, phone__c,
                                    (Select id, answer__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name = 'Q13' ) 
                                    FROM FNA_Activity__c WHERE id=:idForm];
        if(questionFormList.size() > 0 ){
            String urlIconAvatar = fnaUtility.meargeSmallAvatarTitle(questionFormList[0].Avatar_Master__r.segment__c, questionFormList[0].Questionnaire_Results__r[0].answer__c);
            Map<String, String> titleURL = new Map<String, String>();
            titleURL.put('AvatarIcon', urlIconAvatar);
            titleURL = fnaUtility.getImageUrl(titleURL);
            fnaWapper.avatarImage = titleURL.get('AvatarIcon');
            if(questionFormList[0].phone__c == '' || questionFormList[0].phone__c == null){
                fnaWapper.mobileNumber = '';
            }else{
                fnaWapper.mobileNumber = questionFormList[0].phone__c;
            }
            
            questionFormList[0].Drop_Off_Page__c = 'HighlightProduct';
            questionFormList[0].Drop_Off_URL__c = '/fin/s/fnaHighlightProduct' + urlDropOff;
            update questionFormList;
        }

        return fnaWapper;

    }

    public static String getAvatarImageUrl(String segment , String gender){

        if (gender=='ชาย'){
            gender ='_male_small';
        }else {
            gender ='_female_small';
        }
        if(segment.containsIgnoreCase('Default') ){
            segment = 'Default';
        }

        
        String avatartitle = segment + gender;

        system.debug('Avatar Title' + avatartitle);

        List<ContentVersion> cvs = [SELECT Id, Title, VersionData, versionNumber, ContentDocumentId FROM ContentVersion where Title = :avatartitle AND IsLatest = true ORDER BY Title, versionNumber DESC];    
        system.debug('CVS ' + cvs);
        String b64 = '';
        if(!cvs.isEmpty()) {
            b64 = EncodingUtil.base64Encode(cvs[0].VersionData);
        }
        return b64;
    
    }

    public static Map<String, String> getAvatarName(String idForm){
        idForm = UrlHelper.decryptParams(idForm);

        List<Questionnaire_Result__c> questionwho =[SELECT Id, Question__c,Question_ID__r.Name, Answer__c, FNA_Activity_Name__c, Question_ID__c FROM Questionnaire_Result__c Where FNA_Activity_Name__c =:idForm];
        system.debug('Avatarname ' + questionwho);
        Map<String, String> name1 = new Map<String, String>(); 

        for (Questionnaire_Result__c item : questionwho) {
            if (item.Question_ID__r.Name == 'Q13') {
                name1.put('gender', item.Answer__c);
            }else if (item.Question_ID__r.Name =='Q0'){
                name1.put('name',item.Answer__c);

            }
        }
        return name1;
    }
  
    @AuraEnabled
    public static void sendOTP(String phone, String fnaId, String otpId){
        fnaId = UrlHelper.decryptParams(fnaId);
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        system.debug('Success' +fnaActivity);
        system.debug('Success' +phone);
        system.debug('Success' +fnaId);
        system.debug('Success' +otpId);
        if(fnaId != null){
            fnaActivity.id = fnaId;
            fnaActivity.Phone__c = phone;
            fnaActivity.SMS_OTP__c = otpId;

            update fnaActivity;
            system.debug('Success' +fnaactivity);
            
            FNA_Activity__c sobj = [SELECT Id, Send_SMS_Details__c, SMS_Sponsor__c, Phone__c, SMS_OTP__r.OTP_Code__c, SMS_OTP__r.Otp_Ref__c, SMS_OTP__r.Expire_DateTime__c FROM FNA_Activity__c WHERE id =: fnaId LIMIT 1];
            system.debug('sendOTP' + sobj); 
            String serviceName = 'SMS_Verify_OTP';
            fnaUtility.sendSMS(sobj, serviceName);
        }
    }

    // <---------- BACKUP SAVE TO PRODUCT OFFERING ---------->
    // public static void getAllProdToProdOffer(String fnaId, List<FNA_Product_Mapping__c> prodHighlight, List<FNA_Product_Mapping__c> prodNormal) {
    //     System.debug('checkProdHighlight>>> : ' + prodHighlight); 
    //     System.debug('checkProdNormal>>> : ' + prodNormal);

    //     List<FNA_Product_Offering__c> allProdDB = [SELECT Id, FNA_Product_Name__c, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: fnaId];

    //     if(allProdDB.isEmpty()){
    //         List<FNA_Product_Offering__c> allProd = new List<FNA_Product_Offering__c>();

    //         if(!prodHighlight.isEmpty()){
    //             //for loop for get data Product Highlight
    //             for(FNA_Product_Mapping__c prodHigh : prodHighlight){
    //                 FNA_Product_Offering__c allProdH_Obj = new FNA_Product_Offering__c();
    //                 allProdH_Obj.FNA_Product_Name__c = prodHigh.Id;
    //                 allProdH_Obj.FNA_Activity__c = fnaId;
    //                 allProd.add(allProdH_Obj);
    //                 System.debug('allProdH_Obj>>> : ' + allProdH_Obj); 
    //             }
    //         }
    //         if(!prodNormal.isEmpty()){
    //             //for loop for get data Product Normal
    //             for(FNA_Product_Mapping__c prodNor : prodNormal){
    //                 FNA_Product_Offering__c allProdN_Obj = new FNA_Product_Offering__c();
    //                 allProdN_Obj.FNA_Product_Name__c = prodNor.Id;
    //                 allProdN_Obj.FNA_Activity__c = fnaId;
    //                 allProd.add(allProdN_Obj);
    //                 System.debug('allProd์N_Obj>>> : ' + allProdN_Obj); 
    //             }
    //         }
    //         upsert allProd;
    //     }

    // }
}