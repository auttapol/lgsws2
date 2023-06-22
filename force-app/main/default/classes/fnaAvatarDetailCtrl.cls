global without sharing class fnaAvatarDetailCtrl {

   public class AvatarObj{
       @AuraEnabled
       public Avatar_Master__c avatar {get;set;}
       @AuraEnabled
       public String urlImage {get;set;}
       @AuraEnabled
       public String avatarName {get;set;}
       @AuraEnabled
       public String phone {get;set;}
   }

    private static final String SessionId {
        get {
            if(SessionId == null) {
                SessionId = UserInfo.getSessionId();
            }
            return SessionId;
        }
        set;
    }

    public static fnaOSCServiceUtility callOSCUtility {get;set;}

    public static String fetchUserSessionId(){
        String sessionId = '';
        // Get the content of the VF page
        String vfContent;
        String ns =  [SELECT NamespacePrefix FROM Organization].NamespacePrefix;

       try {
           String vf_url = '/apex/';
           if(String.isNotBlank(ns)) {
               vf_url += ns + '__' + 'getsessionidvf';    
           } else {
               vf_url += 'getsessionidvf';       
           }

           PageReference pg = new PageReference(vf_url);
           vfContent = pg.getContent().toString();
        //    if(!test.isRunningTest()) {
        //        vfContent = pg.getContent().toString();
        //    }
        //    else {
        //        vfContent = String.valueOf('Start_Of_Session_Id Test End_Of_Session_Id');
        //    }
   
           Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
           endP = vfContent.indexOf('End_Of_Session_Id');
           // Get the Session Id
           sessionId = vfContent.substring(startP, endP);
           System.debug('sessionId: ' + sessionId);
       } catch(Exception ex) {
           System.debug('***** ex: ' + ex);
       }

       // Return Session Id
       return sessionId;
    }

    @AuraEnabled(continuation=true)
    public static string stampOffSet(String fnaActivityId, String responseBodyOSC14, String responseBodyOSC16, String responseBodyGetCardsBalance){
        System.debug('OSC14| fnaActivityId : ' + fnaActivityId);
        fnaActivityId = UrlHelper.decryptParams(fnaActivityId);
        System.debug('OSC14| fnaActivityId : ' + fnaActivityId);
        System.debug('OSC14| responseBodyOSC14 : ' + responseBodyOSC14);
        System.debug('OSC14| responseBodyOSC16 : ' + responseBodyOSC16);
        System.debug('OSC14| responseBodyGetCardsBalance : ' + responseBodyGetCardsBalance);

        String responseOSC14;
        String responseOSC16;
        String responseGetCardsBalance;

        if(responseBodyOSC14 != null && responseBodyOSC14 != ''){
            CustomerAccountResponse res01Obj = (CustomerAccountResponse) System.JSON.deserialize(responseBodyOSC14, CustomerAccountResponse.class);
            // responseOSC14 = fnaUtility.stampOffSetProductHoldingOSC14(fnaActivityId, CaseAccountProduct.parseJsonToObj((String)responseBodyOSC14));
            responseOSC14 = fnaUtility.stampOffSetProductHoldingOSC01(fnaActivityId, res01Obj);
        }
        if(responseBodyOSC16 != null && responseBodyOSC16 != ''){
            BancassuranceResponse res05Obj = (BancassuranceResponse) System.JSON.deserialize(responseBodyOSC16, BancassuranceResponse.class);
        //     responseOSC16 = fnaUtility.stampOffSetProductHoldingOSC16(fnaActivityId,CaseBAProduct.parseJsonToObj((String)responseBodyOSC16));
            responseOSC16 = fnaUtility.stampOffSetProductHoldingOSC05(fnaActivityId, res05Obj);
        }
        if(responseBodyGetCardsBalance != null && responseBodyGetCardsBalance != ''){
            responseGetCardsBalance = fnaUtility.stampOffSetProductHoldingGetCardsBalance(fnaActivityId, responseBodyGetCardsBalance);
        }
        return 'STAMP OFFSET PRODUCT HOLDING : ' + responseOSC14 + ' AND ' + responseOSC16 + ' AND ' + responseGetCardsBalance;
    }

    public class ResponseOSC{
        @AuraEnabled
        public Integer statusCode {get;set;}
        @AuraEnabled
        public String status {get;set;}
    }
    //CALL SERVICE OSC14,16
    @AuraEnabled(continuation=true)
    public static Object callServiceOSC14(String fnaActivityId){
        System.debug('OSC14| fnaActivityId : ' + fnaActivityId);
        fnaActivityId = UrlHelper.decryptParams(fnaActivityId);
        System.debug('OSC14| fnaActivityId : ' + fnaActivityId);
        ResponseOSC response = new ResponseOSC();
        List<FNA_Activity__c> findCustomerId = [SELECT Customer__c, Customer__r.Id, Customer__r.TMB_Customer_ID_PE__c, Id FROM FNA_Activity__c WHERE Id =: fnaActivityId];
        // return fnaActivityId;
        if(!findCustomerId.isEmpty()){
            if(findCustomerId[0].Customer__c != null){
                if(findCustomerId[0].Customer__r.TMB_Customer_ID_PE__c != null){
                    List<FNA_Product_Offering__c> listCheckProdOffset = [SELECT Id, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: fnaActivityId AND Flag_Offset_product_holding__c = true];
                    if(listCheckProdOffset.isEmpty()){
                        System.debug('OSC14| findCustomerId : ' + findCustomerId);
                        System.debug('OSC14| TMB_Customer_ID_PE__c : ' + findCustomerId[0].Customer__r.TMB_Customer_ID_PE__c);
                        String customerTmbId = findCustomerId[0].Customer__r.Id;

                        System.debug('OSC14| customerTmbId : ' + customerTmbId);

                        callOSCUtility = new fnaOSCServiceUtility(customerTmbId,fnaActivityId);

                        return callOSCUtility.startCallCaseProductDeposit2();
                        // return 'PASS';
                    }
                    else{
                        response.statusCode = 409;
                        response.status = 'OSC14| ALREADY STAMP OFFSET';
                        return response;
                    }
                }
                else{
                    response.statusCode = 400;
                    response.status = 'OSC14| TMB CUSTOMER ID NOT FOUND';
                    return response;
                }
            }
            else{
                response.statusCode = 400;
                response.status = 'OSC14| CUSTOMER ID NOT FOUND';
                return response;
            }
        }
        else{
            response.statusCode = 400;
            response.status = 'OSC14| FNA ACTIVITY ID NOT FOUND';
            return response;
        }
    }
    public static fnaOSCServiceUtility.StateInfo stateModel {get; set;}
    // @AuraEnabled
    // public static Object processResponseWsOSC14(List<String> labels, Object state){
    //     stateModel = (fnaOSCServiceUtility.StateInfo)state;
    //     System.debug('OSC14| labels : ' + labels);
    //     System.debug('OSC14| state : ' + stateModel);

    //     callOSCUtility = new fnaOSCServiceUtility((String)stateModel.accountIdModel,(String)stateModel.fnaActivityIdModel);
    //     return callOSCUtility.processResponseWsOSC14(labels,state);
    // }
    @AuraEnabled
    public static Object processResponseCaseProductDeposit(List<String> labels, Object state){
        stateModel = (fnaOSCServiceUtility.StateInfo)state;
        // System.debug('OSC14| labels : ' + labels);
        // System.debug('OSC14| state : ' + stateModel);

        callOSCUtility = new fnaOSCServiceUtility((String)stateModel.accountIdModel,(String)stateModel.fnaActivityIdModel);
        return callOSCUtility.processResponseCaseProductDeposit(labels,state);
    }

    @AuraEnabled(continuation=true)
    public static Object callServiceOSC16(String fnaActivityId){
        System.debug('OSC16| fnaActivityId : ' + fnaActivityId);
        fnaActivityId = UrlHelper.decryptParams(fnaActivityId);
        System.debug('OSC16| fnaActivityId : ' + fnaActivityId);
        ResponseOSC response = new ResponseOSC();
        List<FNA_Activity__c> findCustomerId = [SELECT Customer__c, Customer__r.Id, Customer__r.TMB_Customer_ID_PE__c, Id FROM FNA_Activity__c WHERE Id =: fnaActivityId];
        if(!findCustomerId.isEmpty()){
            if(findCustomerId[0].Customer__c != null){
                if(findCustomerId[0].Customer__r.TMB_Customer_ID_PE__c != null){
                    List<FNA_Product_Offering__c> listCheckProdOffset = [SELECT Id, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: fnaActivityId AND Flag_Offset_product_holding__c = true];
                    if(listCheckProdOffset.isEmpty()){
                        System.debug('OSC16| findCustomerId : ' + findCustomerId);
                        System.debug('OSC16| findCustomerId : ' + findCustomerId[0].Customer__r.TMB_Customer_ID_PE__c);
                        String customerTmbId = findCustomerId[0].Customer__r.Id;

                        callOSCUtility = new fnaOSCServiceUtility(customerTmbId,fnaActivityId);

                        return callOSCUtility.startCallCaseProductBA2();
                    }
                    else{
                        response.statusCode = 409;
                        response.status = 'OSC16| ALREADY STAMP OFFSET';
                        return response;
                    }
                }
                else{
                    response.statusCode = 400;
                    response.status = 'OSC16| TMB CUSTOMER ID NOT FOUND';
                    return response;
                }
            }
            else{
                response.statusCode = 400;
                response.status = 'OSC16| CUSTOMER ID NOT FOUND';
                return response;
            }
        }
        else{
            response.statusCode = 400;
            response.status = 'OSC16| FNA ACTIVITY ID NOT FOUND';
            return response;
        }
    }
    // @AuraEnabled
    // public static Object processResponseWsOSC16(List<String> labels, Object state){
    //     stateModel = (fnaOSCServiceUtility.StateInfo)state;
    //     System.debug('OSC16| labels : ' + labels);
    //     System.debug('OSC16| state : ' + stateModel);

    //     callOSCUtility = new fnaOSCServiceUtility((String)stateModel.accountIdModel,(String)stateModel.fnaActivityIdModel);
    //     return callOSCUtility.processResponseWsOSC16(labels,state);
    // }

    @AuraEnabled
    public static Object processResponseCaseBancassurance(List<String> labels, Object state){
        stateModel = (fnaOSCServiceUtility.StateInfo)state;
        // System.debug('OSC14| labels : ' + labels);
        // System.debug('OSC14| state : ' + stateModel);

        callOSCUtility = new fnaOSCServiceUtility((String)stateModel.accountIdModel,(String)stateModel.fnaActivityIdModel);
        return callOSCUtility.processResponseCaseBancassurance(labels,state);
    }

    @AuraEnabled(continuation=true)
    public static Object callServiceGetCardsBalances(String fnaActivityId){
        System.debug('GET-CARDS-BALNCES| fnaActivityId : ' + fnaActivityId);
        fnaActivityId = UrlHelper.decryptParams(fnaActivityId);
        System.debug('GET-CARDS-BALNCES| fnaActivityId : ' + fnaActivityId);
        ResponseOSC response = new ResponseOSC();
        List<FNA_Activity__c> findCustomerId = [SELECT Customer__c, Customer__r.Id, Customer__r.TMB_Customer_ID_PE__c, Id FROM FNA_Activity__c WHERE Id =: fnaActivityId];
        // return fnaActivityId;
        // return UserInfo.getSessionId();
        if(!findCustomerId.isEmpty()){
            if(findCustomerId[0].Customer__c != null){
                if(findCustomerId[0].Customer__r.TMB_Customer_ID_PE__c != null){
                    List<FNA_Product_Offering__c> listCheckProdOffset = [SELECT Id, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: fnaActivityId AND Flag_Offset_product_holding__c = true];
                    if(listCheckProdOffset.isEmpty()){
                        System.debug('GET-CARDS-BALNCES| findCustomerId : ' + findCustomerId);
                        System.debug('GET-CARDS-BALNCES| TMB_Customer_ID_PE__c : ' + findCustomerId[0].Customer__r.TMB_Customer_ID_PE__c);
                        String customerTmbId = findCustomerId[0].Customer__r.Id;

                        System.debug('GET-CARDS-BALNCES| customerTmbId : ' + customerTmbId);

                        callOSCUtility = new fnaOSCServiceUtility(customerTmbId,fnaActivityId);

                        return callOSCUtility.startCallCaseProductCreditCards();
        //                 // return 'PASS';
                    }
                    else{
                        response.statusCode = 409;
                        response.status = 'GET-CARDS-BALNCES| ALREADY STAMP OFFSET';
                        return response;
                    }
                }
                else{
                    response.statusCode = 400;
                    response.status = 'GET-CARDS-BALNCES| TMB CUSTOMER ID NOT FOUND';
                    return response;
                }
            }
            else{
                response.statusCode = 400;
                response.status = 'GET-CARDS-BALNCES| CUSTOMER ID NOT FOUND';
                return response;
            }
        }
        else{
            response.statusCode = 400;
            response.status = 'GET-CARDS-BALNCES| FNA ACTIVITY ID NOT FOUND';
            return response;
        }
    }
    // @AuraEnabled
    // public static Object processResponseCaseCrediCards(List<String> labels, Object state){
    //     stateModel = (fnaOSCServiceUtility.StateInfo)state;
    //     // System.debug('OSC14| labels : ' + labels);
    //     // System.debug('OSC14| state : ' + stateModel);

    //     callOSCUtility = new fnaOSCServiceUtility((String)stateModel.accountIdModel,(String)stateModel.fnaActivityIdModel);
    //     return callOSCUtility.processResponseCaseCrediCards(labels,state);
    // }
    //CALL SERVICE OSC14,16
 


    @AuraEnabled
    public static AvatarObj getAvatarMasterDetail(String idForm, String urlDropOff){
        system.debug('idForm before decryptID' + idForm);
        idForm = UrlHelper.decryptParams(idForm);
        system.debug('idForm after decryptID' + idForm);

        AvatarObj avatar = new AvatarObj();
        String avtarMasterId = '';
        List<FNA_Activity__c> questionFormList = [SELECT Id, Drop_Off_URL__c, Phone__c, Avatar_Url__c, Person_Name__c, Avatar_Master__c, Avatar_Master__r.Segment__c, Drop_Off_Page__c, Answer_Flow__c, CreatedDate ,
                                                (SELECT id, Answer__c, FNA_Activity_Name__c, Question_ID__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name ='Q13')
                                                FROM FNA_Activity__c WHERE id=:idForm];
        if(questionFormList.size() > 0 ){
            avtarMasterId = questionFormList[0].Avatar_Master__c;
            questionFormList[0].Drop_Off_Page__c = 'avatardetail';
            questionFormList[0].Drop_Off_URL__c = '/fin/s/avatardetail' + urlDropOff;
            if(questionFormList[0].Phone__c == '' || questionFormList[0].Phone__c == null){
                avatar.phone = '';
            }else{
                avatar.phone = questionFormList[0].Phone__c;
            }
            // questionFormList[0].Drop_Off_URL__c = '/fin/s/avatardetail?Id=' + idForm;
            

            System.debug('idAvatar ' + avtarMasterId);
            List<Avatar_Master__c> avtarList = [SELECT Id, Segment__c, Avatar_EN__c, Avatar_TH__c, Avatar_Description__c FROM Avatar_Master__c where id =: avtarMasterId];
            if(avtarList.size()> 0){
                avatar.avatar = avtarList[0];
                avatar.avatar.Avatar_Description__c = getAvatarformat(avatar.avatar.Avatar_Description__c);
                avatar.avatarName = questionFormList[0].Person_Name__c;
                String contentVersionId = fnautility.getAvatarImage(questionFormList[0]);
                questionFormList[0].Avatar_Url__c = contentVersionId;
                avatar.urlImage = '/fin/sfc/servlet.shepherd/version/download/' + contentVersionId;
                
            }

            update questionFormList;
        }

        
        

        return avatar;

    }
     
    public static String getAvatarformat(String originalText){
        String fulltext = originalText;
        List <String> imglist = new List<String>();
        String filter = '%Avatar_bullet%';
        List<ContentVersion> cvsList = [SELECT Id, Title, VersionData, versionNumber, ContentDocumentId FROM ContentVersion WHERE Title LIKE :filter AND IsLatest = true ORDER BY Title, versionNumber ASC];  

        for (ContentVersion cvs : cvsList) {
            String b64 = '';
            b64 = '<img src="data:image/png;base64, ' + EncodingUtil.base64Encode(cvs.VersionData) + '" style=" width: 75px; margin-right: 1rem!important; float: left;"  />';
            imglist.add(b64);
        }


        integer num = 0;
        for(String img : imglist){
            // system.debug('img ' + img);
            integer index = num + 1;
            String target = '{' + index +'}';
            String replacement = img;
            system.debug('target :' + target);
            system.debug('replacement :' + replacement);
            fulltext = fulltext.replace(target, replacement);
            system.debug('fulltext :' + fulltext);
            num++;

        }
        return fulltext;

    }

    @AuraEnabled
    public static void sendOTP(String phone, String fnaId, String otpId){
        System.debug('OSC14| fnaId : ' + fnaId);
        fnaId = UrlHelper.decryptParams(fnaId);
        System.debug('OSC14| fnaId : ' + fnaId);
        
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

            FNA_Activity__c sobj = [SELECT Id, Send_SMS_Details__c, SMS_Sponsor__c, Phone__c, SMS_OTP__r.OTP_Code__c, SMS_OTP__r.Otp_Ref__c, SMS_OTP__r.Expire_DateTime__c FROM FNA_Activity__c WHERE id =: fnaid LIMIT 1];
            system.debug('sendOTP' + sobj); 
            String serviceName = 'SMS_Verify_OTP';
            fnaUtility.sendSMS(sobj, serviceName);
        }
    }     
        
    public class ImageResponse{
        @AuraEnabled
        public String logo {get;set;}
        @AuraEnabled
        public String dead {get;set;}
        @AuraEnabled
        public String hurt {get;set;}
        @AuraEnabled
        public String back {get;set;}
        @AuraEnabled
        public String backInvert {get;set;}
        @AuraEnabled
        public String cancel {get;set;}
        @AuraEnabled
        public String cancelInvert {get;set;}
        @AuraEnabled
        public String notSupport {get;set;}
        @AuraEnabled
        public String orientation {get;set;}
    }

    @AuraEnabled
    public static ImageResponse getImage(){
        ImageResponse resImage = new ImageResponse();
        Map<String, String> titleImage = new Map<String, String>();
        titleImage.put('logo', 'logo');
        titleImage.put('dead', 'img-dead');
        titleImage.put('hurt', 'img-hurt');

        titleImage.put('notSupport', 'notSupport');
        titleImage.put('orientation', 'orientation');

        titleImage.put('back', 'ico-back');
        titleImage.put('backInvert', 'ico-back-inverted');
        titleImage.put('cancel', 'ico-cancel');
        titleImage.put('cancelInvert', 'ico-cancel-inverted');
        titleImage = fnaUtility.getImageUrl(titleImage);
        
        resImage.logo = titleImage.get('logo');
        resImage.dead = titleImage.get('dead');
        resImage.hurt = titleImage.get('hurt');
        
        resImage.back = titleImage.get('back');
        resImage.backInvert = titleImage.get('backInvert');
        resImage.cancel = titleImage.get('cancel');
        resImage.cancelInvert = titleImage.get('cancelInvert');

        resImage.notSupport = titleImage.get('notSupport');
        resImage.orientation = titleImage.get('orientation');

        return resImage;
    }

    @AuraEnabled
    public static List<FNA_Product_Offering__c> getProductOffer(String fnaActivityId){
        System.debug('fnaActivityId before decryptID : ' + fnaActivityId);         
        fnaActivityId = UrlHelper.decryptParams(fnaActivityId);
        System.debug('fnaActivityId after decryptID : ' + fnaActivityId);         

        List<FNA_Activity__c> fnaObj = new List<FNA_Activity__c>();
        List<FNA_Product_Mapping__c> lstAllProd = new List<FNA_Product_Mapping__c>();

        List<FNA_Product_Mapping__c> lstProdNormal      = new List<FNA_Product_Mapping__c>();
        List<FNA_Product_Mapping__c> lstProdHighlight   = new List<FNA_Product_Mapping__c>();
        List<FNA_Product_Mapping__c> lstProdPackage = new List<FNA_Product_Mapping__c>();


        if(fnaActivityId != '') {
            fnaObj = [SELECT Id, Product_Holding__c, Customer__c, Avatar_Name__c, Avatar_Url__c, Avatar_Master__c, 
                                Avatar_Downloaded__c, Avatar_Master__r.segment__c , CreatedDate, 
                                (SELECT Id, Question__c, Answer__c, Question_ID__r.Name, Choice_Answer__c FROM Questionnaire_Results__r ) 
                                FROM FNA_Activity__c 
                                WHERE Id =: fnaActivityId];

            System.debug('fnaObj : ' + fnaObj[0].Avatar_Master__r.segment__c); 

            String avatarId = fnaObj[0].Avatar_Master__r.segment__c;

            lstAllProd = [SELECT Sequence_No__c, Product__c, Product__r.FNA_Product_Group__c, Product__r.name, Product__r.Product_Type__c,
                                Product__r.FNA_Product_Name__c, Product__r.FNA_Product_Name_TH__c, Product__r.FNA_Product_Summary__c, Segment__c, 
                                Highlight_Product_Condition__c, Avatar_Master__r.segment__c, Normal_Product_Condition__c  
                                FROM FNA_Product_Mapping__c
                                WHERE Segment__c =: avatarId AND Product__r.FNA_Active__c = true AND Product__r.FNA_Product_Name__c != null 
                                AND Project__c = :fnaUtility.getprojectFin() 
                                ORDER BY Sequence_No__c];


            
            Map<String,String> mapAnswer = new Map<String, String> ();
            for(Questionnaire_Result__c quesResult : fnaObj[0].Questionnaire_Results__r){
                mapAnswer.put(quesResult.Question_ID__r.Name, quesResult.Choice_Answer__c);
            }

            Map<String, List<FNA_Product_Mapping__c>> splitProduct = splitProductfunction(lstAllProd, mapAnswer, 'Highlight_Product_Condition__c');
            lstProdHighlight = splitProduct.get('High');

            Map<String, List<FNA_Product_Mapping__c>> splitOthertProduct = splitProductfunction(splitProduct.get('Other'), mapAnswer, 'Normal_Product_Condition__c');
            lstProdNormal = splitOthertProduct.get('High');

            /*Map<String, List<FNA_Product_Mapping__c>> splitProductType = getPackageProduct(lstProdHighlight);
            lstProdPackage = splitProductType.get('Package');
            lstProdHighlight = splitProductType.get('Highlight');*/

            String highlightProduct = '';
            System.debug('lstProdHighlight :' + lstProdHighlight);
            for(FNA_Product_Mapping__c prod : lstProdHighlight) {
                if(highlightProduct == ''){
                    highlightProduct = prod.Product__r.name;
                }else{
                    highlightProduct += ',' + prod.Product__r.name;
                }
                
                System.debug('lstProdHighlight : ' + prod);                
            }

            /*for(FNA_Product_Mapping__c y : lstProdNormal) {
                System.debug('lstProdNormal : ' + y);                
            }*/

            if(highlightProduct != ''){
                fnaObj[0].Product_Holding__c = highlightProduct;
                update fnaObj;
            }

            if(fnaObj[0].Customer__c != null){
                Account acc = new Account();
                acc.id = fnaObj[0].Customer__c;
                acc.Fna_Avatar_Name__c = fnaObj[0].Avatar_Name__c;
                acc.Fna_Avatar_Url__c = fnaObj[0].Avatar_Url__c;
                acc.Fna_Create_Date__c = fnaObj[0].CreatedDate;
                acc.Fna_Have_Referral__c = false;
                acc.Fna_Product_Holding__c = fnaObj[0].Product_Holding__c;
                acc.Fna_Product_Interested__c = '';
                update acc;
            }

        }
        System.debug('fnaActivityId : ' + fnaActivityId); 
        System.debug('lstProdHighlight : ' + lstProdHighlight); 
        System.debug('lstProdNormal : ' + lstProdNormal);
        return saveAllProdToProdOffer(fnaActivityId, lstProdHighlight, lstProdNormal);
    }

    // public static Map<String, List<FNA_Product_Mapping__c>> getPackageProduct(List<FNA_Product_Mapping__c> prodList){
    //     Map<String, List<FNA_Product_Mapping__c>> mapProductMapping = new Map<String, List<FNA_Product_Mapping__c>>();
    //     List<FNA_Product_Mapping__c> packageProductList = new List<FNA_Product_Mapping__c>();
    //     List<FNA_Product_Mapping__c> highlightProductList = new List<FNA_Product_Mapping__c>();
    //     for(FNA_Product_Mapping__c prod : prodList){
    //         if(prod.Product__r.Product_Type__c == 'Package'){
    //             packageProductList.add(prod);
    //         }else if( prod.Product__r.Product_Type__c == 'Single') {
    //             highlightProductList.add(prod);
    //         }
    //     }

    //     mapProductMapping.put('Package', packageProductList);
    //     mapProductMapping.put('Highlight', highlightProductList);

    //     return mapProductMapping;
    // }

    public static Map<String, List<FNA_Product_Mapping__c>> splitProductfunction(List<FNA_Product_Mapping__c> allHLProduct, Map<String,String> ansMap, String fieldCondition){
        List<FNA_Product_Mapping__c> showHighLightProduct = new List<FNA_Product_Mapping__c>();
        List<FNA_Product_Mapping__c> otherProduct = new List<FNA_Product_Mapping__c>();
        Map<String, List<FNA_Product_Mapping__c>> splitProduct = new Map<String, List<FNA_Product_Mapping__c>>();
        for(FNA_Product_Mapping__c product : allHLProduct){
            boolean checkAll = false;
            // system.debug('product ' + product);
            // system.debug('productCon ' + product.Highlight_Product_Condition__c);
            String condition = (String)product.get(fieldCondition);
            // system.debug('condition : ' + condition);
            if( condition != null){
                for(String otherCondition : condition.split('\\|')){
                    // system.debug('otherCondition ' + otherCondition);
                    boolean checkCon = true;
                    for(String con : otherCondition.split(',')){
                        // system.debug('con ' + con);
                        List<String> choice = con.split('-');
                        // system.debug('choice ' + choice);
                        if(choice.size() > 1){
                            // system.debug('choice0 ' + choice[0]);
                            // system.debug('choice1 ' + choice[1]);
                            String answer = ansMap.get(choice[0]);
                            // system.debug('answer ' + answer);
                            boolean haveAns = false;
                            if(answer != null && answer != ''){
                                List<String> ansList = answer.split(',');
                                for(String ans : ansList){
                                    haveAns = choice[1].contains(ans);
                                    if(haveAns){
                                        break;
                                    }
                                }
                            }
                             
                            // system.debug(' haveAns : ' + haveAns);
                            if(!haveAns){
                                checkCon = false;
                                break;
                            }
                        }                     
                    }

                    // system.debug('checkCon ' + checkCon);
                    if(checkCon){
                        checkAll = true;
                        break;
                    }
                }

            }else{
                checkAll = false;
            }
            

            // system.debug('checkAll ' + checkAll);
            if(checkAll){
                showHighLightProduct.add(product);
            }else{
                otherProduct.add(product);
            }

        }

        splitProduct.put('High', showHighLightProduct);
        splitProduct.put('Other', otherProduct);
        
        System.debug('splitProduct : ' + splitProduct); 
        
        return splitProduct;
    }

    public static List<FNA_Product_Offering__c> saveAllProdToProdOffer(String fnaId, List<FNA_Product_Mapping__c> prodHighlight, List<FNA_Product_Mapping__c> prodNormal) {
        System.debug('checkProdHighlight>>> : ' + prodHighlight); 
        System.debug('checkProdNormal>>> : ' + prodNormal);

        List<FNA_Product_Offering__c> allProdDB = [SELECT Id, FNA_Product_Name__c, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: fnaId];

        List<FNA_Product_Offering__c> allProd = new List<FNA_Product_Offering__c>();

        if(allProdDB.isEmpty()){

            if(!prodHighlight.isEmpty()){
                //for loop for get data Product Highlight
                for(FNA_Product_Mapping__c prodHigh : prodHighlight){
                    FNA_Product_Offering__c allProdH_Obj = new FNA_Product_Offering__c();
                    allProdH_Obj.FNA_Product_Name__c = prodHigh.Id;
                    allProdH_Obj.Flag_Highlight__c = true;
                    allProdH_Obj.FNA_Activity__c = fnaId;
                    allProd.add(allProdH_Obj);
                    // System.debug('allProdH_Obj : ' + allProdH_Obj); 
                }
            }

            if(!prodNormal.isEmpty()){
                //for loop for get data Product Normal
                for(FNA_Product_Mapping__c prodNor : prodNormal){
                    FNA_Product_Offering__c allProdN_Obj = new FNA_Product_Offering__c();
                    allProdN_Obj.FNA_Product_Name__c = prodNor.Id;
                    allProdN_Obj.FNA_Activity__c = fnaId;
                    allProd.add(allProdN_Obj);
                    // System.debug('allProdN_Obj : ' + allProdN_Obj); 
                }
            }

            // if(!prodPackageList.isEmpty()){
            //     for(FNA_Product_Mapping__c prodPackage : prodPackageList){
            //         FNA_Product_Offering__c allProdP_Obj = new FNA_Product_Offering__c();
            //         allProdP_Obj.FNA_Product_Name__c = prodPackage.Id;
            //         allProdP_Obj.FNA_Activity__c = fnaId;
            //         allProd.add(allProdP_Obj); 
            //     }
            // }
            

            upsert allProd;
            System.debug('SUCCESS TO UPSERT ALL PRODUCT TO PRODUCT OFFERING');
            System.debug('allProd : ' + allProd); 
            return allProd;
        }
        else{
            System.debug('PRODUCT OFFERING IS ALREADY EXIST');
            System.debug('allProdDB : ' + allProdDB); 
            return allProdDB;
        }
    }
}