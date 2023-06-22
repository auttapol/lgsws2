public class RTL_UploadCampaignMemberCreateLead {
    
    public static Lead createLeadFromCampaignMember(RTL_Upload_Campaign_Members__c ucm, Map<String,User> um ,Map<String,String> qm,String campaignName)
    { 
    	Lead Leadrec = new Lead();
        Leadrec.RecordTypeId = RTL_UploadCampaignMemberService.retailRCT.id;
        
        String leadOwnerId = '';
        // No Lead Owner mean assigned to current user
        if( ucm.RTL_leadOwner__c == '' || ucm.RTL_leadOwner__c == NULL ){
            leadOwnerId = UserInfo.getUserId();
        //5-digit employee code
        }else if(ucm.RTL_leadOwner__c.length() ==5){
            leadOwnerId = um.get(ucm.RTL_leadOwner__c).id;
        //Else find in Queue
        }else{
            leadOwnerId = qm.get(ucm.RTL_leadOwner__c);
        }
        Leadrec.OwnerId = leadOwnerId;

        List<String> leadCH = new List<String>();

        if( ucm.RTL_CHANNEL_DM__c == 'Y')
        {
            leadCH.add('DM');
        }

        if( ucm.RTL_CHANNEL_OB__c == 'Y' )
        {
            leadCH.add('OB');
        }

        if( ucm.RTL_CHANNEL_EDM__c == 'Y' )
        {
            leadCH.add('EDM');
        }

        if( ucm.RTL_CHANNEL_BRANCH__c == 'Y' )
        {
            leadCH.add('BRANCH');
        }

        if( ucm.RTL_CHANNEL_MIB__c == 'Y' )
        {
            leadCH.add('MIB');
        }

        if( ucm.RTL_CHANNEL_OBD__c == 'Y' )
        {
            leadCH.add('OBD');
        }

        if( ucm.RTL_CHANNEL_OTHER__c == 'Y' )
        {
            leadCH.add('OTHER');
        }


        String channelStr = String.join(leadCH, ',');

        Leadrec.RTL_Lead_Channel__c = channelStr;

        Leadrec.Salutation = ucm.RTL_Title__c;
        Leadrec.FirstName = ucm.RTL_FirstName__c;
        Leadrec.LastName = ucm.RTL_LastName__c;
        Leadrec.RTL_Gender__c = ucm.RTL_GENDER__c;
        Leadrec.RTL_Age__c = ucm.RTL_AGE__c;
        Leadrec.RTL_ID_Type__c = ucm.RTL_ID_Type__c;
        Leadrec.RTL_Citizen_Id__c = ucm.RTL_Citizen_ID__c;
        Leadrec.RTL_Address_Line1__c = ucm.RTL_ADDRESS1__c;
        Leadrec.RTL_Address_Line2__c = ucm.RTL_ADDRESS2__c;
        Leadrec.RTL_Address_Line3__c = ucm.RTL_ADDRESS3__c;
        Leadrec.RTL_Address_Line4__c = ucm.RTL_PROVINCE__c;
        Leadrec.RTL_Address_Line5__c = ucm.RTL_ZIPCODE__c;

        Leadrec.RTL_Mobile_Number__c = ucm.RTL_MOBILEPHONE__c;
        Leadrec.RTL_Phone_Number__c = ucm.RTL_HOMEPHONE__c;

        try {
            Leadrec.RTL_Income__c = Decimal.valueOf(ucm.RTL_INCOME__c);
        } 
        catch(Exception e) {
            Leadrec.RTL_Income__c = 0;
            //System.debug(e.getMessage());
        }
        

        // This column is pick list , need to discuss how to insert value
        Leadrec.RTL_Occupation__c = ucm.RTL_OCCUPATION__c;

        Leadrec.RTL_Email_Address__c = ucm.RTL_Email_Address__c;
        Leadrec.RTL_FB_ID__c = ucm.RTL_FB_ID__c;
        // Leadrec.RTL_FB_Email__c = ucm.RTL_FB_EMAIL__c; <-- remove field
        Leadrec.RTL_Segment__c = ucm.RTL_Segment__c;
        Leadrec.RTL_Cost_per_lead__c = Decimal.valueof( (ucm.RTL_COST_PER_LEAD__c)!=null?ucm.RTL_COST_PER_LEAD__c:'0' );
        Leadrec.RTL_Source_of_data__c = ucm.RTL_SOURCE__c;

        Leadrec.RTL_Mobile_Number__c = ucm.RTL_MOBILEPHONE__c;

        Leadrec.Rating = ucm.RTL_Rating__c;
        // System.debug('RTL_TMB_Campaign_Source__c (LEAD): ' + ucm.RTL_TMB_Campaign_Source__c);
        // System.debug('campaignName (LEAD) : ' + campaignName);
        Leadrec.LeadSource = ucm.LeadSource__c;
        Leadrec.RTL_Source_Reference__c = ucm.RTL_Source_Reference__c;
        Leadrec.RTL_TMB_Campaign_Reference__c = ucm.RTL_TMB_Campaign_Reference__c;

        Leadrec.RTL_Customer_Segment__c = ucm.RTL_Customer_Segment__c;


        Leadrec.Company = ( ( ucm.RTL_Title__c != '' ) ? ucm.RTL_Title__c + ' ' : '' ) + ucm.RTL_FirstName__c + ' ' + ucm.RTL_LastName__c;
        
        if(campaignName != null && campaignName != ''){
            Leadrec.RTL_TMB_Campaign_Source__c = campaignName;
        }else{
            Leadrec.RTL_TMB_Campaign_Source__c = ucm.RTL_TMB_Campaign_Source__c;
        }
        
        // Leadrec.RTL_TMB_Campaign_Reference__c = ucm.RTL_TMB_Campaign_Reference__c;
        // Leadrec.RTL_Source_Reference__c = ucm.RTL_Source_Reference__c;

        // comment by Mu
        //Leadrec.Campaign = ucm.RTL_CampaignID__c;
        
                
        return leadRec;
    }

    public static List<List<String>> processProductOfferString(String productOfferString)
    {

        if( productOfferString == null )
        {
            return new List<List<String>>();           
        }

        List<List<String>> productsOffer = new List<List<String>>();

        List<String> productList = productOfferString.split(';');

        for(String productItem : productList)
        {
            List<String> productItemMap = productItem.split(':');
            productsOffer.add( productItemMap );
        }

        return productsOffer;
    }


    public static List<List<String>> generateProductOfferList( String productOfferString , Map<String,RTL_product_master__c > rpMap,Map<String,String> rpsgMap  )
    {
        List<List<String>> productOfferResultList = new List<List<String>>();

        List<List<String>> productsOffer = RTL_UploadCampaignMemberCreateLead.processProductOfferString(productOfferString);

        Integer count = 0;

        for( List<String> productItem : productsOffer  )
        {
            List<String> productOfferItem = new  List<String>();
            count++;

            String groupName = '';
            String subGroupName = '';
            String retailProductId = '';
            RTL_product_master__c campaignProduct = new RTL_product_master__c();

            if( productItem.get(0) == '1' )
            {
               groupName = productItem.get(1);
            }
            else if ( productItem.get(0) == '2' )
            {
                subGroupName = productItem.get(1);
                groupName = rpsgMap.get(subGroupName.tolowercase() );
            }
            else if ( productItem.get(0) == '3' )
            {
                String productName =  productItem.get(1);
                campaignProduct = rpMap.get(productName);

                if( campaignProduct != null )
                {

                    retailProductId = campaignProduct.id;
                    subGroupName = campaignProduct.Product_Sub_group__c;
                    groupName = campaignProduct.Product_Group__c;
                }
            }

            productOfferItem.add(groupName);
            productOfferItem.add(subGroupName);
            productOfferItem.add(retailProductId);

            productOfferResultList.add(productOfferItem);

            if( count >= 5 )
            {
                break;
            }
        }

        return productOfferResultList;


    }

    public static List<RTL_Interested_products_c__c> generateProductInterestedList( String productOfferString , Map<String,RTL_product_master__c > rpMap )
    {
        List<RTL_Interested_products_c__c> productInterestedResultList = new List<RTL_Interested_products_c__c>();

        List<List<String>> productsOffer = RTL_UploadCampaignMemberCreateLead.processProductOfferString(productOfferString);

        for( List<String> productItem : productsOffer  )
        {
            // Generated interested product only for Product name
            if ( productItem.get(0) == '3' )
            {
                String productName =  productItem.get(1);
                RTL_product_master__c campaignProduct = rpMap.get(productName);

                if( campaignProduct != null )
                {
                    String retailProductId = campaignProduct.id;
                    String subGroupName = campaignProduct.Product_Sub_group__c;
                    String groupName = campaignProduct.Product_Group__c;

                    RTL_Interested_products_c__c interestedProduct = new RTL_Interested_products_c__c();

                    interestedProduct.Product_Name__c = retailProductId;
                    interestedProduct.product_group__c = groupName;
                    interestedProduct.Product_Sub_Group__c = subGroupName;

                    productInterestedResultList.add(interestedProduct);

                }

            }
        }

        return productInterestedResultList;

    }

    
    
}