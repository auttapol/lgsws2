// public with sharing class fnaAvatarPassportFlagshipCtrl {
//     public fnaAvatarPassportFlagshipCtrl() {

//     }
// }

public without sharing class fnaAvatarPassportFlagshipCtrl {

    public Avatar_Master__c avatar              {get;set;}
    public ImageResponse imageResource          {get;set;} 
    public StationTemplate stationMap           {get;set;}
    public String urlImage                      {get;set;}
    public String avatarName                    {get;set;}
    public String fnaIdEncrypted                {get;set;}
    public String urlForSharing                 {get;set;}
    public String fnaName                       {get;set;}
    public String fnaId                         {get;set;}

   public class ImageResponse{
        public String logo              {get;set;}
        public String dead              {get;set;}
        public String hurt              {get;set;}
        public String download          {get;set;}
        public String fb                {get;set;}
        public String messenger         {get;set;}
        public String line              {get;set;}
        public String safari            {get;set;}
        public String chrome            {get;set;}
        public String firefox           {get;set;}
    }

    public class StationTemplate{
       //public Flagship_Station_Mapping__mdt sta {get;set;}
       //public String urlImage                   {get;set;}
        public String bgImage                    {get;set;}
        public String highLightImage             {get;set;}
        public String iconImage                  {get;set;}
        public String positionHighlight          {get;set;}
        public String branchCode                 {get;set;}
       
    }

    public fnaAvatarPassportFlagshipCtrl(){
        String idForm = ApexPages.currentpage().getparameters().get('Id');
        String headerdata = ApexPages.currentPage().getHeaders().get('Host');
        urlForSharing = 'https://' + headerdata + '/fin/fnaavatarSharing?Id=' + idForm;
        System.debug('Current page ' + urlForSharing);

        List<FNA_Activity__c> questionFormList = [SELECT Id, name, Drop_Off_URL__c, Branch__c, Created_Branch_Code__c, Avatar_Master__c, Avatar_Master__r.Segment__c, Drop_Off_Page__c, Answer_Flow__c, CreatedDate, Person_Name__c,
                                                    (SELECT id, Answer__c, FNA_Activity_Name__c, Question_ID__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name ='Q13')
                                                    FROM FNA_Activity__c WHERE id=:idForm];
        if(questionFormList.size() > 0 ){
            fnaName = questionFormList[0].name;
            fnaId = questionFormList[0].Id;
            String gender = 'm';
            String segment = '';
            if(questionFormList[0].Questionnaire_Results__r.size() > 0){
                String temp = questionFormList[0].Questionnaire_Results__r[0].Answer__c;
                if( temp == 'ชาย'){
                    gender = 'm';
                }else{
                    gender = 'w';
                }
            }
            
            List<Avatar_Master__c> avtarList = [SELECT Id, Segment__c, Avatar_EN__c, Avatar_TH__c, Avatar_Description__c, Avatar_Short_Description__c
                                                FROM Avatar_Master__c where id =: questionFormList[0].Avatar_Master__c];
            if(avtarList.size()> 0){
                avatar = avtarList[0];
                avatarName = questionFormList[0].Person_Name__c;
                segment = avtarList[0].Segment__c;
                urlImage = '/fin/sfc/servlet.shepherd/version/download/' + fnaUtility.getAvatarImage(questionFormList[0]);
            }

            stationMap = getStation( idForm, segment,  questionFormList[0].Created_Branch_Code__c, gender);
        }

        imageResource = getImage();
        fnaIdEncrypted = UrlHelper.encryptParams(idForm);

    }

    /* Start test take a screen shot of VF page and store into document */
    public string strImageBlob {get;set;}

    public void saveScreenShot(){
        system.debug(strImageBlob);
        system.debug('fnaName' + fnaName);

        try{
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

        }catch (Exception ex ){
            system.debug('Exception : ' + ex);
        }
        
    }
    /* End test take a screen shot of VF page and store into document */

    public static StationTemplate getStation(String idForm, String segment, String branchCode, String gender){
        StationTemplate resStation = new StationTemplate();
        resStation.branchCode = branchCode;
        List<AggregateResult> productOfferingList = [SELECT FNA_Product_Name__r.Product__r.FNA_Product_Group__c 
                                                                    FROM FNA_Product_Offering__c 
                                                                    WHERE fna_activity__c = :idForm AND Flag_Highlight__c = true 
                                                                    GROUP BY FNA_Product_Name__r.Product__r.FNA_Product_Group__c];

        Set<String> productGroup = new Set<String>();
        system.debug('segment : ' + segment);
        system.debug('branchCode : ' + branchCode);
        
        for(AggregateResult pro : productOfferingList){
            productGroup.add((String)pro.get('FNA_Product_Group__c'));
            system.debug('pro : ' + pro.get('FNA_Product_Group__c'));
        }

        List<Flagship_Station_Mapping__mdt> stationList = [SELECT Id, Branch_Name__c, Branch_Code__c, label, Station_Number__c, Station_Name_EN__c, FNA_Product_Group__c 
                                FROM Flagship_Station_Mapping__mdt 
                                WHERE Branch_Code__c =: branchCode AND FNA_Product_Group__c in :productGroup Order by label];

        System.debug('stationList : ' + stationList);
        Map<String, String> titleImage = new Map<String, String>();
        
        /* Position icon Avatar */
        String stationPosition = '';
        for(Flagship_Station_Mapping__mdt station : stationList){
            if(stationPosition == ''){
                stationPosition = station.Station_Number__c;
            }else if(!stationPosition.contains(station.Station_Number__c)){
                stationPosition += ',' + station.Station_Number__c;
            }
        }
        
        String folderName = 'Map_' + branchCode;

        String bgImage = 'bg_main';
        String highlightImage = ('p_result_line_' + segment + '_' + gender).toLowerCase();
        String iconAvatar = (segment + '_' + gender).toLowerCase();
        System.debug('bgImage' + bgImage);
        System.debug('highlightImage' + highlightImage);
        System.debug('iconAvatar' + iconAvatar);
        List<String> titleList = new List<String>{bgImage, highlightImage};
        List<String> titleList2 = new List<String>{iconAvatar};
        List<ContentVersion> conVersionList = fnaUtility.getListContentVersionAll('Flagship', folderName, titleList);
        conVersionList.addAll(fnaUtility.getListContentVersionAll('Flagship', 'AvatarIcon', titleList2));
        Map<String, String> conVersionmap = new Map<String, String>();
        for( ContentVersion conVer : conVersionList){
            System.debug('conVer' + conVer.title);
            conVersionmap.put(conVer.title, '/fin/sfc/servlet.shepherd/version/download/' + conVer.Id);
        }

        resStation.bgImage = conVersionmap.get(bgImage);
        resStation.highLightImage = conVersionmap.get(highlightImage);
        resStation.iconImage = conVersionmap.get(iconAvatar);
        resStation.positionHighlight = stationPosition;
        return resStation;

        /*for(Flagship_Station_Mapping__mdt station : stationList){
            String fileTitle = station.FNA_Product_Group__c;
            if(station.FNA_Product_Group__c == '' || station.FNA_Product_Group__c == null){
                fileTitle = 'For TMB';
            }
            titleImage.put(station.FNA_Product_Group__c, fileTitle);
        }
        titleImage = fnaUtility.getImageUrl(titleImage);

        for(Flagship_Station_Mapping__mdt station : stationList){
            stationTemplate tempStation = new stationTemplate();
            tempStation.sta = station;
            tempStation.urlImage = titleImage.get(station.FNA_Product_Group__c);
            resStation.add(tempStation);
        }*/
        //return stationList;
        
    }
          
    public static ImageResponse getImage(){
        ImageResponse resImage = new ImageResponse();
        Map<String, String> titleImage = new Map<String, String>();
        titleImage.put('logo', 'logo');
        titleImage.put('dead', 'img-dead');
        titleImage.put('hurt', 'img-hurt');
        titleImage.put('download', 'ico-download');
        titleImage.put('fb', 'ico-fb');
        titleImage.put('line', 'ico-line');
        titleImage.put('messenger', 'ico-messenger');
        titleImage.put('safari', 'ico-safari');
        titleImage.put('chrome', 'ico-chrome');
        titleImage.put('firefox', 'ico-ffox');
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

    // public static String getAvatarformat(String originalText){
        //     String fulltext = originalText;
        //     List <String> imglist = new List<String>();
        //     String filter = '%Avatar_bulletA%';
        //     List<ContentVersion> cvsList = [SELECT Id, Title, VersionData, versionNumber, ContentDocumentId FROM ContentVersion WHERE Title LIKE :filter AND IsLatest = true ORDER BY Title, versionNumber ASC];  

        //     for (ContentVersion cvs : cvsList) {
        //         String b64 = '';
        //         b64 = '<img src="data:image/png;base64, ' + EncodingUtil.base64Encode(cvs.VersionData) + '" style="width: 32px !important; margin-right: 1rem!important; float: left;"  />';
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
        //     return fulltext;

    // }
}