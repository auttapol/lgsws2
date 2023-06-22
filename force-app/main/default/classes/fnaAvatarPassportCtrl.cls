public without sharing class fnaAvatarPassportCtrl {

    /****************************
        fnaAvatarPassPort.page 
        fnaAvatarSharing.page
    ******************************/

    public String urlImage              {get;set;}
    public String avatarName            {get;set;}
    public String imageSharing          {get;set;}
    public String urlForSharing         {get;set;}
    public String ShareDescription      {get;set;}
    public String fnaIdEncrypted        {get;set;}
    public Avatar_Master__c avatar      {get;set;}
    public ImageResponse imageResource  {get;set;} 

    public String fnaName;
    public String fnaId;

    public String headerdata;
    public class ImageResponse{
        public String fb                {get;set;}
        public String logo              {get;set;}
        public String dead              {get;set;}
        public String hurt              {get;set;}
        public String download          {get;set;}
        public String messenger         {get;set;}
        public String line              {get;set;}

        public String safari              {get;set;}
        public String chrome              {get;set;}
        public String firefox              {get;set;}

    }

    private final String SHARE_FB_DESCRIPTION = 'Message_Share_Facebook_Additional';

    public fnaAvatarPassportCtrl() {
        String idForm = ApexPages.currentpage().getparameters().get('Id');
        headerdata = ApexPages.currentPage().getHeaders().get('Host');
        urlForSharing = 'https://' + headerdata + '/fin/fnaavatarSharing?Id=' + idForm;
        
        List<FNA_Activity__c> questionFormList = [SELECT Id, name, Drop_Off_URL__c, Avatar_Master__c, Avatar_Master__r.Segment__c, Drop_Off_Page__c, Answer_Flow__c, CreatedDate, Person_Name__c,
                                                    (SELECT id, Answer__c, FNA_Activity_Name__c, Question_ID__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name ='Q13')
                                                    FROM FNA_Activity__c WHERE id=:idForm];
        if(questionFormList.size() > 0 ){
            fnaName = questionFormList[0].name;
            fnaId = questionFormList[0].Id;
            List<Attachment> imageList = [SELECT Id, Name FROM Attachment WHERE ParentId =: fnaId ORDER BY CreatedDate DESC LIMIT 1];
            if(imageList.size() > 0){
                imageSharing = 'https://' + headerdata + '/fin/servlet/servlet.FileDownload?file=' + imageList[0].id;
            }
            
            List<Avatar_Master__c> avtarList = [SELECT Id, Segment__c, Avatar_EN__c, Avatar_TH__c, Avatar_Description__c, Avatar_Short_Description__c
                                                FROM Avatar_Master__c where id =: questionFormList[0].Avatar_Master__c];
            if(avtarList.size()> 0){
                avatar = avtarList[0];
                // avatar.Avatar_Short_Description__c = getAvatarformat(avatar.Avatar_Short_Description__c);
                avatarName = questionFormList[0].Person_Name__c;
                List<App_Config__mdt> messageShareFB = [SELECT Id, Label, Value__c, DeveloperName FROM App_Config__mdt WHERE DeveloperName =:SHARE_FB_DESCRIPTION];
                if(messageShareFB.size() > 0){
                    ShareDescription = avatar.Avatar_Short_Description__c + messageShareFB[0].Value__c;
                }else{
                    ShareDescription = avatar.Avatar_Short_Description__c;
                }
                System.debug('ShareDescription ' + ShareDescription);
                urlImage = '/fin/sfc/servlet.shepherd/version/download/' + fnaUtility.getAvatarImage(questionFormList[0]);
            }
        }

        imageResource = getImage();
        fnaIdEncrypted = UrlHelper.encryptParams(idForm);
    }
     
    public ImageResponse getImage(){
        ImageResponse resImage = new ImageResponse();
        Map<String, String> titleImage = new Map<String, String>();
        titleImage.put('logo', 'logo');
        titleImage.put('dead', 'img-dead');
        titleImage.put('hurt', 'img-hurt');
        titleImage.put('download', 'ico-download');
        titleImage.put('fb', 'ico-fb');
        titleImage.put('line', 'ico-line');
        titleImage.put('safari', 'ico-safari');
        titleImage.put('chrome', 'ico-chrome');
        titleImage.put('firefox', 'ico-ffox');
        titleImage.put('messenger', 'ico-messenger');
        titleImage = fnaUtility.getImageUrl(titleImage);
        
        resImage.logo = titleImage.get('logo');
        resImage.dead = titleImage.get('dead');
        resImage.hurt = titleImage.get('hurt');
        resImage.download = titleImage.get('download');
        resImage.fb = titleImage.get('fb');
        resImage.line = titleImage.get('line');
        resImage.safari = titleImage.get('safari');
        resImage.chrome = titleImage.get('chrome');
        resImage.firefox = titleImage.get('firefox');
        resImage.messenger = titleImage.get('messenger');
        return resImage;
    
    }

    /* Start test take a screen shot of VF page and store into document */
    public string strImageBlob {get;set;}

    public void saveScreenShot()
    {
        system.debug(strImageBlob);
        system.debug('fnaName' + fnaName);

        String contentName = fnaName + '_avatarpassport';
        Attachment atth = new Attachment();
            atth.Name = contentName;
            atth.body = EncodingUtil.base64Decode(strImageBlob.replaceFirst('data:image/png;base64,',''));
            atth.ContentType = 'image/png';
            atth.ParentId = fnaId;
        List<Attachment> imageList = [SELECT Id, Name FROM Attachment WHERE ParentId =: fnaId ORDER BY CreatedDate DESC LIMIT 1];
        if(imageList.size() > 0){
            atth.id = imageList[0].id;
        }
        upsert atth;
    }
    /* End test take a screen shot of VF page and store into document */
    
    // public String getAvatarformat(String originalText){
    //     String fulltext = originalText;
    //     List <String> imglist = new List<String>();
    //     String filter = '%Avatar_bulletA%';
    //     List<ContentVersion> cvsList = [SELECT Id, Title, VersionData, versionNumber, ContentDocumentId FROM ContentVersion WHERE Title LIKE :filter AND IsLatest = true ORDER BY Title, versionNumber ASC];  

    //     for (ContentVersion cvs : cvsList) {
    //         String b64 = '';
    //         b64 = '<img src="data:image/png;base64, ' + EncodingUtil.base64Encode(cvs.VersionData) + '" style=" width: 32px !important; margin-right: 1rem!important; float: left;"  />';
    //         imglist.add(b64);
    //     }

    //     integer num = 1; 
    //     String a = 'A';

    //     for(String img : imglist){
    //         system.debug('img ' + img);
    //         String index = a + num ;
    //         String target = '{' + index +'}';
    //         system.debug('Number ' + index);
    //         String replacement = img;
    //          if(fulltext.contains(target)){
    //             fulltext = fulltext.replace(target, replacement);
    //         }
    //         system.debug('fulltext ' + fulltext);
    //         num++;

    //     }

    //     fulltext.replace('&nbsp;', ' ');
    //     return fulltext;

    // }
    
}