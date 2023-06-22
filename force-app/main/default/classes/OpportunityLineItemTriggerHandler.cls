public class OpportunityLineItemTriggerHandler {

    
    public static List<RecordType> RTSECredit{
        get{
            if(RTSECredit == null){
                RTSECredit = [SELECT id FROM RecordType WHERE DeveloperName LIKE 'SE_Credit%' AND sObjectType = 'Opportunity'];
            }
            return RTSECredit;
        }set;
    }
    private static Map<Id,Host_Product_Mapping__c> getHostProdMapping{
        get{
            Map<Id,Host_Product_Mapping__c> listHostProdMap = new Map<Id,Host_Product_Mapping__c>();
            for(Host_Product_Mapping__c mapHProd : [SELECT Id, Product_Group_ID__c, Product_Program_ID__c, Credit_Type_ID__c
                                                    FROM Host_Product_Mapping__c 
                                                    WHERE Active_Flag__c = true] ){
                    listHostProdMap.put(mapHProd.Id, mapHProd);
            }
        	return new Map<Id,Host_Product_Mapping__c>(listHostProdMap);
        }
        set; 
    }
    
    public OpportunityLineItemTriggerHandler()
    {
    
    }
    
    public static void CalculateOpportunityTotalVol (list<opportunitylineitem> listOptyLine)
    {
        /*
        decimal TotalVol = 0.00;
        for (opportunitylineitem a: [select quantity, National_Amt_TMB__c from opportunitylineitem 
                                     where opportunityid =: listOptyLine.get(0).opportunityid])
        {
            TotalVol += (a.Quantity == null ? 0 : a.Quantity) * (a.National_Amt_TMB__c == null ? 0 : a.National_Amt_TMB__c);
        }
        
        opportunity op = [select id,Total_Vol__c from opportunity where id =: listOptyLine.get(0).opportunityid];
        op.Total_Vol__c = TotalVol;
        
        update op;
        */
    }

    public static void getDeletedRecord (Map<Id,OpportunityLineItem> mapOld){
        try {
            List<Opportunity_Product_History__c> lstOppProductTemp = new List<Opportunity_Product_History__c>();
            for(Id oppProductId : mapOld.keySet()){
                OpportunityLineItem oppProduct = mapOld.get(oppProductId);
                Opportunity_Product_History__c oppProductTemp = new Opportunity_Product_History__c();
    
                oppProductTemp.Deal_Probability__c = oppProduct.Deal_Probability__c;
                oppProductTemp.Description__c = oppProduct.Description;
                oppProductTemp.Expected_Fee_Rate__c = oppProduct.Expected_Fee_Rate__c;
                oppProductTemp.Expected_NIM__c = oppProduct.Expected_NIM__c;
                oppProductTemp.Expected_Revenue__c = oppProduct.Expected_Revenue__c;
                oppProductTemp.Expected_Revenue_Fee__c = oppProduct.Expected_Revenue_Fee__c;
                oppProductTemp.Expected_Revenue_Total__c = oppProduct.Expected_Revenue_Total__c;
                oppProductTemp.Expected_Util_Year_Fee__c = oppProduct.Expected_Util_Year_Fee__c;
                oppProductTemp.Expected_Util_Year_NI__c = oppProduct.Expected_Util_Year_NI__c;
                oppProductTemp.Expected_Utilization_Vol_Fee__c = oppProduct.Expected_Utilization_Vol_Fee__c;
                oppProductTemp.Expected_Utilization_Vol_NI__c = oppProduct.Expected_Utilization_Vol_NI__c;
                oppProductTemp.Frequency__c = oppProduct.Frequency__c;
                oppProductTemp.FrequencyFee__c = oppProduct.FrequencyFee__c;
                oppProductTemp.Notional_Amount__c = oppProduct.Notional_Amount__c;
                oppProductTemp.Opportunity__c = oppProduct.OpportunityId;
                oppProductTemp.OpportunityLineItemId__c = oppProduct.Id;
                oppProductTemp.OriginalStartMonth__c = oppProduct.OriginalStartMonth__c;
                oppProductTemp.OriginalStartMonthFee__c = oppProduct.OriginalStartMonthFee__c;
                oppProductTemp.OriginalStartYear__c = oppProduct.OriginalStartYear__c;
                oppProductTemp.OriginalStartYearFee__c = oppProduct.OriginalStartYearFee__c;
                oppProductTemp.Product_Domain__c = oppProduct.Product_Domain__c;
                oppProductTemp.Product__c = oppProduct.Product2Id;
                oppProductTemp.Quantity__c = oppProduct.Quantity;
                oppProductTemp.Recurring_Type__c = oppProduct.Recurring_Type__c;
                oppProductTemp.Recurring_Type_Fee__c = oppProduct.Recurring_Type_Fee__c;
                oppProductTemp.RevisedStartMonth__c = oppProduct.RevisedStartMonth__c;
                oppProductTemp.RevisedStartMonthFee__c = oppProduct.RevisedStartMonthFee__c;
                oppProductTemp.RevisedStartYear__c = oppProduct.RevisedStartYear__c;
                oppProductTemp.RevisedStartYearFee__c = oppProduct.RevisedStartYearFee__c;
                oppProductTemp.Tenor_Years__c = oppProduct.Tenor_Years__c;
                oppProductTemp.This_Year_Expected_Fee__c = oppProduct.This_Year_Expected_Fee__c;
                oppProductTemp.This_Year_Expected_NI__c = oppProduct.This_Year_Expected_NI__c;
                oppProductTemp.Total_Volume_Amount__c = oppProduct.Total_Volume_Amount__c;
                oppProductTemp.Type_Of_Reference__c = oppProduct.Type_Of_Reference__c;
                oppProductTemp.Type_Of_Reference_Fee__c = oppProduct.Type_Of_Reference_Fee__c;
                oppProductTemp.UnitPrice__c = oppProduct.UnitPrice;
                
                oppProductTemp.Actual_Amount__c        = oppProduct.Actual_Amount__c;
                oppProductTemp.Approved_Amount__c      = oppProduct.Approved_Amount__c;
                oppProductTemp.Cancel_Reject_Reason__c = oppProduct.Cancel_Reject_Reason__c;
                oppProductTemp.Host_Product_Mapping__c = oppProduct.Host_Product_Mapping__c;
                oppProductTemp.Host_Product_Status__c  = oppProduct.Host_Product_Status__c;
                oppProductTemp.TMB_Account_ID__c       = oppProduct.TMB_Account_ID__c;
                
                /*2017Mar - CR Oppty Template*/
                oppProductTemp.Fee_January__c = oppProduct.Fee_January__c; 
                oppProductTemp.Fee_February__c = oppProduct.Fee_February__c;
                oppProductTemp.Fee_March__c = oppProduct.Fee_March__c; 
                oppProductTemp.Fee_April__c = oppProduct.Fee_April__c;
                oppProductTemp.Fee_May__c = oppProduct.Fee_May__c; 
                oppProductTemp.Fee_June__c = oppProduct.Fee_June__c;
                oppProductTemp.Fee_July__c = oppProduct.Fee_July__c; 
                oppProductTemp.Fee_August__c = oppProduct.Fee_August__c; 
                oppProductTemp.Fee_September__c = oppProduct.Fee_September__c; 
                oppProductTemp.Fee_October__c = oppProduct.Fee_October__c;
                oppProductTemp.Fee_November__c = oppProduct.Fee_November__c; 
                oppProductTemp.Fee_December__c = oppProduct.Fee_December__c; 
                oppProductTemp.NI_January__c = oppProduct.NI_January__c;
                oppProductTemp.NI_February__c = oppProduct.NI_February__c;
                oppProductTemp.NI_March__c = oppProduct.NI_March__c; 
                oppProductTemp.NI_April__c = oppProduct.NI_April__c; 
                oppProductTemp.NI_May__c = oppProduct.NI_May__c; 
                oppProductTemp.NI_June__c = oppProduct.NI_June__c; 
                oppProductTemp.NI_July__c = oppProduct.NI_July__c;
                oppProductTemp.NI_August__c = oppProduct.NI_August__c; 
                oppProductTemp.NI_September__c = oppProduct.NI_September__c; 
                oppProductTemp.NI_October__c = oppProduct.NI_October__c;
                oppProductTemp.NI_November__c = oppProduct.NI_November__c;
                oppProductTemp.NI_December__c = oppProduct.NI_December__c; 
                oppProductTemp.Total_January__c = oppProduct.Total_January__c;
                oppProductTemp.Total_February__c = oppProduct.Total_February__c;
                oppProductTemp.Total_March__c = oppProduct.Total_March__c;
                oppProductTemp.Total_April__c = oppProduct.Total_April__c; 
                oppProductTemp.Total_May__c = oppProduct.Total_May__c;
                oppProductTemp.Total_June__c = oppProduct.Total_June__c;
                oppProductTemp.Total_July__c = oppProduct.Total_July__c;
                oppProductTemp.Total_August__c = oppProduct.Total_August__c;
                oppProductTemp.Total_September__c = oppProduct.Total_September__c; 
                oppProductTemp.Total_October__c = oppProduct.Total_October__c; 
                oppProductTemp.Total_November__c = oppProduct.Total_November__c;
                oppProductTemp.Total_December__c = oppProduct.Total_December__c;
                oppProductTemp.TotalPrice__c = oppProduct.TotalPrice;
                /*oppProductTemp.Host_Product_Mapping__c = oppProduct.Host_Product_Mapping__c;*/
                
                /*2018Jun - CR Opportunity & Lead to DWH*/
                oppProductTemp.Credit_Type_ID__c = oppProduct.Credit_Type_ID__c;
				oppProductTemp.Product_Group_ID__c = oppProduct.Product_Group_ID__c;
				oppProductTemp.Product_Program_ID__c = oppProduct.Product_Program_ID__c;
    
                lstOppProductTemp.add(oppProductTemp);
            }

            insert lstOppProductTemp;
        }catch(exception ex){
            system.debug(ex.getLineNumber()+' - '+ex.getMessage());
        }
        
    }

    public static void summaryExpectedRevenue (List<OpportunityLineItem> listNewOptyLine, List<OpportunityLineItem> listOldOptyLine, String actionType)
    {
        system.debug('opportunity line item trigger : summaryExpectedRevenue start');

        Boolean IsChangeVal = false;
        Map<Id,OpportunityLineItem> mapOld = new Map<Id,OpportunityLineItem>();

        if (actionType == 'insert') {

            if (listNewOptyLine != null) {
                for (OpportunityLineItem o : listNewOptyLine)
                {
                    if (o.Expected_Revenue_Total__c != 0 || o.This_Year_Expected_Revenue__c != 0)
                        IsChangeVal = true;
                }
            }

        } else if (actionType == 'delete') {

            IsChangeVal = true;

        } else if (listOldOptyLine != null) {

            mapOld.putAll(listOldOptyLine);

            if (listNewOptyLine != null) {
                for (OpportunityLineItem o : listNewOptyLine)
                {
                    if (o.Expected_Revenue_Total__c != mapOld.get(o.ID).Expected_Revenue_Total__c
                     && o.This_Year_Expected_Revenue__c != mapOld.get(o.ID).This_Year_Expected_Revenue__c)
                        IsChangeVal = true;
                }
            }

        }

        if (IsChangeVal) {

            /*** for Remove opportunity line from opportunity ***/
            Integer prefix = 1;
            if (listNewOptyLine == null && listOldOptyLine != null) {
                listNewOptyLine = listOldOptyLine;
                listOldOptyLine = null;
                mapOld = new Map<Id,OpportunityLineItem>();
                prefix = -1;
            }



            Map<string,decimal> mapOppTotal = new Map<string,decimal>();
            Map<string,decimal> mapOppThisYear = new Map<string,decimal>();

            List<String> ListOpportunityID = new List<String>();
            Set<String> ListCampaignID = new Set<String>();

            List<Campaign> listUpdateCampaign = new List<Campaign>();
            List<Opportunity> listOppUpdate = new List<Opportunity>();

            for (OpportunityLineItem ol : listNewOptyLine)
            {
                if (mapOld.size() == 0) {

                    ListOpportunityID.add(ol.OpportunityID);

                    decimal TotalSum = prefix * ol.Expected_Revenue_Total__c;
                    decimal ThisYearSum = prefix * ol.This_Year_Expected_Revenue__c;

                    if (mapOppTotal.get(ol.OpportunityID) == null && mapOppThisYear.get(ol.OpportunityID) == null)
                    {
                        mapOppTotal.put(ol.OpportunityID, TotalSum);
                        mapOppThisYear.put(ol.OpportunityID, ThisYearSum);
                    } else {
                        TotalSum = TotalSum + mapOppTotal.get(ol.OpportunityID);
                        ThisYearSum = ThisYearSum + mapOppThisYear.get(ol.OpportunityID);
                        mapOppTotal.put(ol.OpportunityID, TotalSum);
                        mapOppThisYear.put(ol.OpportunityID, ThisYearSum);
                    }
                    
                } else if (ol.Expected_Revenue_Total__c != mapOld.get(ol.ID).Expected_Revenue_Total__c
                    || ol.This_Year_Expected_Revenue__c != mapOld.get(ol.ID).This_Year_Expected_Revenue__c) {

                    ListOpportunityID.add(ol.OpportunityID);

                    decimal TotalSum = ol.Expected_Revenue_Total__c - mapOld.get(ol.ID).Expected_Revenue_Total__c;
                    decimal ThisYearSum = ol.This_Year_Expected_Revenue__c - mapOld.get(ol.ID).This_Year_Expected_Revenue__c;

                    if (mapOppTotal.get(ol.OpportunityID) == null && mapOppThisYear.get(ol.OpportunityID) == null)
                    {
                        mapOppTotal.put(ol.OpportunityID, TotalSum);
                        mapOppThisYear.put(ol.OpportunityID, ThisYearSum);
                    } else {
                        TotalSum = TotalSum + mapOppTotal.get(ol.OpportunityID);
                        ThisYearSum = ThisYearSum + mapOppThisYear.get(ol.OpportunityID);
                        mapOppTotal.put(ol.OpportunityID, TotalSum);
                        mapOppThisYear.put(ol.OpportunityID, ThisYearSum);
                    }

                }                
            }

            Map<Id,Campaign> mapCampaign = new Map<Id,Campaign>();
            Map<Id,Campaign> mapParentCampaign = new Map<Id,Campaign>();

            List<Opportunity> listOpportunity = [select ID, CampaignID
                                    , Campaign.FullDealExpectedRevenueOpportunities__c, Campaign.ThisYearExpectedRevenueOpportunities__c
                                    , Campaign.FullDealExpectedRevenueWONOpty__c, Campaign.ThisYearExpectedRevenueWONOpty__c
                                    , Campaign.HierarchyFullDealExpectedRevenueOpty__c, Campaign.HierarchyThisYearExpectedRevenueOpty__c
                                    , Campaign.HierarchyFullDealExpectedRevenueWONOpty__c, Campaign.HierarchyThisYearExpectedRevenueWONOpty__c
                                    , IsWon
                                    , Rollup_flag__c
                                    , Lead_Expect_Revenue__c
                                    from Opportunity where ID in: ListOpportunityID
                                    and CampaignID != ''];

            for (Opportunity op : listOpportunity)
            {
                ListCampaignID.add(op.CampaignID);

                if (mapCampaign.get(op.CampaignID) == null) {
                    Campaign campObj = new Campaign();
                    campObj.ID = op.CampaignID;

                    if (op.IsWon == true) {
                        campObj.FullDealExpectedRevenueWONOpty__c = ((op.Campaign.FullDealExpectedRevenueWONOpty__c != null) ? op.Campaign.FullDealExpectedRevenueWONOpty__c : 0.00) + mapOppTotal.get(op.ID);
                        campObj.ThisYearExpectedRevenueWONOpty__c = ((op.Campaign.ThisYearExpectedRevenueWONOpty__c != null) ? op.Campaign.ThisYearExpectedRevenueWONOpty__c : 0.00) + mapOppThisYear.get(op.ID);
                        campObj.HierarchyFullDealExpectedRevenueWONOpty__c = ((op.Campaign.HierarchyFullDealExpectedRevenueWONOpty__c != null) ? op.Campaign.HierarchyFullDealExpectedRevenueWONOpty__c : 0.00) + mapOppTotal.get(op.ID);
                        campObj.HierarchyThisYearExpectedRevenueWONOpty__c = ((op.Campaign.HierarchyThisYearExpectedRevenueWONOpty__c != null) ? op.Campaign.HierarchyThisYearExpectedRevenueWONOpty__c : 0.00) + mapOppThisYear.get(op.ID);
                    } else {
                        campObj.FullDealExpectedRevenueOpportunities__c = ((op.Campaign.FullDealExpectedRevenueOpportunities__c != null) ? op.Campaign.FullDealExpectedRevenueOpportunities__c : 0.00) + mapOppTotal.get(op.ID);
                        campObj.ThisYearExpectedRevenueOpportunities__c = ((op.Campaign.ThisYearExpectedRevenueOpportunities__c != null) ? op.Campaign.ThisYearExpectedRevenueOpportunities__c : 0.00) + mapOppThisYear.get(op.ID);
                        campObj.HierarchyFullDealExpectedRevenueOpty__c = ((op.Campaign.HierarchyFullDealExpectedRevenueOpty__c != null) ? op.Campaign.HierarchyFullDealExpectedRevenueOpty__c : 0.00) + mapOppTotal.get(op.ID);
                        campObj.HierarchyThisYearExpectedRevenueOpty__c = ((op.Campaign.HierarchyThisYearExpectedRevenueOpty__c != null) ? op.Campaign.HierarchyThisYearExpectedRevenueOpty__c : 0.00) + mapOppThisYear.get(op.ID);
                    }

                    if (op.Rollup_flag__c == false) {
                        campObj.FullDealExpectedRevenueOpportunities__c = campObj.FullDealExpectedRevenueOpportunities__c - ((op.Lead_Expect_Revenue__c != null) ? op.Lead_Expect_Revenue__c : 0.00);
                        campObj.HierarchyFullDealExpectedRevenueOpty__c = campObj.HierarchyFullDealExpectedRevenueOpty__c - ((op.Lead_Expect_Revenue__c != null) ? op.Lead_Expect_Revenue__c : 0.00);
                        op.Rollup_flag__c = true;
                        listOppUpdate.add(op);
                    }

                    mapCampaign.put(op.CampaignID, campObj);
                } else {
                    Campaign campObj = mapCampaign.get(op.CampaignID);

                    if (op.IsWon == true) {
                        campObj.FullDealExpectedRevenueWONOpty__c = ((campObj.FullDealExpectedRevenueWONOpty__c != null) ? campObj.FullDealExpectedRevenueWONOpty__c : 0.00) + mapOppTotal.get(op.ID);
                        campObj.ThisYearExpectedRevenueWONOpty__c = ((campObj.ThisYearExpectedRevenueWONOpty__c != null) ? campObj.ThisYearExpectedRevenueWONOpty__c : 0.00) + mapOppThisYear.get(op.ID);
                        campObj.HierarchyFullDealExpectedRevenueWONOpty__c = ((campObj.HierarchyFullDealExpectedRevenueWONOpty__c != null) ? campObj.HierarchyFullDealExpectedRevenueWONOpty__c : 0.00) + mapOppTotal.get(op.ID);
                        campObj.HierarchyThisYearExpectedRevenueWONOpty__c = ((campObj.HierarchyThisYearExpectedRevenueWONOpty__c != null) ? campObj.HierarchyThisYearExpectedRevenueWONOpty__c : 0.00) + mapOppThisYear.get(op.ID);
                    } else {        
                        campObj.FullDealExpectedRevenueOpportunities__c = ((campObj.FullDealExpectedRevenueOpportunities__c != null) ? campObj.FullDealExpectedRevenueOpportunities__c : 0.00) + mapOppTotal.get(op.ID);
                        campObj.ThisYearExpectedRevenueOpportunities__c = ((campObj.ThisYearExpectedRevenueOpportunities__c != null) ? campObj.ThisYearExpectedRevenueOpportunities__c : 0.00) + mapOppThisYear.get(op.ID);
                        campObj.HierarchyFullDealExpectedRevenueOpty__c = ((campObj.HierarchyFullDealExpectedRevenueOpty__c != null) ? campObj.HierarchyFullDealExpectedRevenueOpty__c : 0.00) + mapOppTotal.get(op.ID);
                        campObj.HierarchyThisYearExpectedRevenueOpty__c = ((campObj.HierarchyThisYearExpectedRevenueOpty__c != null) ? campObj.HierarchyThisYearExpectedRevenueOpty__c : 0.00) + mapOppThisYear.get(op.ID);
                    }

                    if (op.Rollup_flag__c == false) {
                        campObj.FullDealExpectedRevenueOpportunities__c = campObj.FullDealExpectedRevenueOpportunities__c - ((op.Lead_Expect_Revenue__c != null) ? op.Lead_Expect_Revenue__c : 0.00);
                        campObj.HierarchyFullDealExpectedRevenueOpty__c = campObj.HierarchyFullDealExpectedRevenueOpty__c - ((op.Lead_Expect_Revenue__c != null) ? op.Lead_Expect_Revenue__c : 0.00);
                        op.Rollup_flag__c = true;
                        listOppUpdate.add(op);
                    }

                    mapCampaign.put(op.CampaignID, campObj);
                }
            }

            for (String cid : ListCampaignID)
            {
                if (mapCampaign.get(cid) != null) {
                    listUpdateCampaign.add(mapCampaign.get(cid));
                }
            }

            try {
                if (listUpdateCampaign.size() > 0)
                    update listUpdateCampaign;
                if (listOppUpdate.size() > 0)
                    update listOppUpdate;
            } catch (exception ex) {
                system.debug('opportunity line item trigger parent campaign Error Line '+ ex.getLineNumber() + ' : '+ ex.getMessage());
            }

        }

        system.debug('opportunity line item trigger : summaryExpectedRevenue end');

    }
    
    public static void setOpportunityProductGroupIfNoProduct(list<opportunitylineitem> listOppProduct)
    {
        list<string> listOpportunityID = new list<string>();
        list<string> listOpportunityProductID = new list<string>();
        set<string> setAllOpportunityID = new set<string>();
        set<string> setExistProduct = new set<string>();
        list<opportunity> listUpdateOpportunityId = new list<opportunity>();
        for (opportunitylineitem ol : listOppProduct)
        {
            listOpportunityProductID.add(ol.id);
            listOpportunityID.add(ol.opportunityID);
            setAllOpportunityID.add(ol.opportunityID);
        }
        
        for (opportunity o : [select id, (select id from opportunitylineitems where id not in: listOpportunityProductID) 
                              from opportunity where id in: listOpportunityID])
        {
            if (o.opportunitylineitems.size() > 0){
                setExistProduct.add(o.id);
            }
        }
       
        for (string s: setAllOpportunityID)
        {
            boolean NoHaveProduct = true;
            for (string se: setExistProduct)
            {
                if (se == s){
                    NoHaveProduct = false;
                }
            }
            
            if (NoHaveProduct){
                listUpdateOpportunityId.add(new opportunity(id=s,host_product_group__c=''));
            }
        }
   
        try {     
            if (listUpdateOpportunityId.size() > 0){
                update listUpdateOpportunityId;
            }
        }catch(exception ex){
            system.debug(ex.getMessage());
        }
    }
    
    //Fix BAU_8571_INC0086691
    public static void SetHostProductMappingToOppProduct(List<Opportunitylineitem> listOptyProductNew){
        
        //System.debug(':: START: Stamp ProductGroupID, ProductProgramID, CreditTypeID to Opp Product ::');    
        
        //Fix BAU_8654_INC0090053
        Map<Id,Host_Product_Mapping__c> mapHostProdMapping =  getHostProdMapping;          
                
        if (listOptyProductNew != null) {
            
            for (OpportunityLineItem objOptyProd : listOptyProductNew) {
                                
                if (objOptyProd.Host_Product_Mapping__c != null) {
                    
                    Host_Product_Mapping__c hostProdMap = mapHostProdMapping.get(objOptyProd.Host_Product_Mapping__c);
                    if(hostProdMap != null) {
                        
                        objOptyProd.Product_Group_ID__c = hostProdMap.Product_Group_ID__c;
                        objOptyProd.Product_Program_ID__c = hostProdMap.Product_Program_ID__c;
                        objOptyProd.Credit_Type_ID__c = hostProdMap.Credit_Type_ID__c;
                                                
                        //system.debug('ProductGroupID=' + objOptyProd.Product_Group_ID__c
                        //             + ', ProductProgramID=' + objOptyProd.Product_Program_ID__c
                        //             + ', CreditTypeID=' + objOptyProd.Credit_Type_ID__c);                        
                    }
                }
            }
        }        
        //System.debug(':: END: Stamp ProductGroupID, ProductProgramID, CreditTypeID to Opp Product ::');
    }

    public static void GenerateDealForecast(List<Opportunitylineitem> listOptyProductNew){
        if (listOptyProductNew != null) {
            try {    
                List<Deal_Forecast_Income__c> dealForecastList = new List<Deal_Forecast_Income__c>();

                list<string> listOpportunityID = new list<string>();
                for (opportunitylineitem ol : listOptyProductNew){
                    listOpportunityID.add(ol.OpportunityId);
                }

                Map<Id, Opportunity> OppDataList = new Map<Id, Opportunity>([SELECT Id, AccountId, StageName, CloseDate, RecordTypeId FROM Opportunity WHERE Id IN :listOpportunityID]);

                for (OpportunityLineItem objOptyProd : listOptyProductNew) {
                    if(objOptyProd.Deal_Probability__c != null && objOptyProd.Deal_Probability__c != ''){
                        Deal_Forecast_Income__c dealForecast = new Deal_Forecast_Income__c();
                        Opportunity OppData = OppDataList.get(objOptyProd.OpportunityId);

                        dealForecast.Opportunity_Product_Id__c = objOptyProd.Id;
                        dealForecast.Customer__c = OppData.AccountId;
                        dealForecast.Year__c = String.valueOf(Date.Today().Year());
                        dealForecast.Opportunity__c = OppData.Id;
                        dealForecast.Probability__c = getProbName(objOptyProd.Deal_Probability__c);
                        dealForecast.Product__c = objOptyProd.Product2Id;
                        dealForecast.OpportunityLineItem_Limit_Volume__c = objOptyProd.UnitPrice;
                        dealForecast.Expected_Start_Month__c = getMonthName(OppData.CloseDate.month());
                        dealForecast.Expected_Start_Year__c = String.valueOf(OppData.CloseDate.year());
                        dealForecast.Start_Utilization_Date__c = Date.newInstance(OppData.CloseDate.year(), (OppData.CloseDate.month()) + 1, 0);
                        list<String> RTSECreditId = new list<String>();
                        for(RecordType eachRTSECredit: RTSECredit){
                            RTSECreditId.add(eachRTSECredit.Id);
                        }
                        System.debug('RTSECreditId::'+RTSECreditId);
                        System.debug('dealForecast.Product__c::'+dealForecast.Product__c);

                        list<Product2> pdRemark = [SELECT Remark__c FROM Product2 WHERE Id = :dealForecast.Product__c LIMIT 1];
                        System.debug('pdRemark::'+ pdRemark[0].Remark__c );
                        if(RTSECreditId.contains(OppData.RecordTypeId) && pdRemark[0].Remark__c != null && pdRemark[0].Remark__c == 'ST loan'){
                            dealForecast.Income_Type__c = 'NIIc';
                            dealForecast.Utilization_Percent__c = 35;
                            dealForecast.Volume__c = objOptyProd.UnitPrice * 0.35;
                        }
                        dealForecastList.add(dealForecast);
                    }
                }

                insert dealForecastList;
                
            } catch (Exception ex) {
                system.debug(ex.getLineNumber() + ' - ' + ex.getMessage());
            }
        }
    }

    public static void syncDealForecast(map<Id, Opportunitylineitem> oldMap, map<Id, Opportunitylineitem> newMap){
        Set<Id> oppItemIdSet = newMap.keySet();

        map<Id, Deal_Forecast_Income__c> dealForecastList = new map<Id, Deal_Forecast_Income__c>([SELECT Id, Opportunity_Product_Id__c, Probability__c, OpportunityLineItem_Limit_Volume__c FROM Deal_Forecast_Income__c WHERE Opportunity_Product_Id__c IN :oppItemIdSet]);
        List<Deal_Forecast_Income__c> dealForecastUpdatedList = new List<Deal_Forecast_Income__c>();
        
        System.debug('syncDealForecast | dealForecastList: ' + dealForecastList);

        if (dealForecastList == null || dealForecastList.isEmpty()) {
            GenerateDealForecast(newMap.values());
        } else {
    
            for(Deal_Forecast_Income__c dealForecast : dealForecastList.values()){
                Opportunitylineitem newOppItem = newMap.get(dealForecast.Opportunity_Product_Id__c);
                Opportunitylineitem oldOppItem = oldMap.get(dealForecast.Opportunity_Product_Id__c);
                Boolean isUpdate = false;
    
                if(newOppItem.UnitPrice != oldOppItem.UnitPrice && newOppItem.UnitPrice != dealForecast.OpportunityLineItem_Limit_Volume__c){
                    dealForecast.OpportunityLineItem_Limit_Volume__c = newOppItem.UnitPrice;
                    isUpdate = true;
                }
                
                if(newOppItem.Deal_Probability__c != oldOppItem.Deal_Probability__c && dealForecast.Probability__c != newOppItem.Deal_Probability__c){
                    dealForecast.Probability__c = getProbName(newOppItem.Deal_Probability__c);
                    isUpdate = true;
                }
                if(isUpdate) dealForecastUpdatedList.add(dealForecast);
            }
        }
        
        if(dealForecastUpdatedList.size() > 0){
            try{
                update dealForecastUpdatedList;
            }catch (Exception e) {
                system.debug(e.getLineNumber() + ' - ' + e.getMessage());
            }
        }
    }

    public static void deleteDealForecast(Map<Id, Opportunitylineitem> oppItemList){
        Set<Id> oppItemIdSet = oppItemList.keySet();

        map<Id, Deal_Forecast_Income__c> dealForecastList = new map<Id, Deal_Forecast_Income__c>([SELECT Id, Opportunity_Product_Id__c FROM Deal_Forecast_Income__c WHERE Opportunity_Product_Id__c IN :oppItemIdSet]);
        
        List<Deal_Forecast_Income__c> dealForecastDeletedList = new List<Deal_Forecast_Income__c>();

        for(Deal_Forecast_Income__c dealForecast : dealForecastList.values()){
            Opportunitylineitem oppItem = oppItemList.get(dealForecast.Opportunity_Product_Id__c);

            if(oppItem != null) dealForecastDeletedList.add(dealForecast);
        }
        
        if(dealForecastDeletedList.size() > 0){
            try{
                delete dealForecastDeletedList;
            }catch (Exception e) {
                system.debug(e.getLineNumber() + ' - ' + e.getMessage());
            }
        }
    }

    public static String getMonthName (Integer monthNumber){
        monthNumber = monthNumber - 1;
        List<String> monthsMap = new List<String>();
        monthsMap.add('Jan');
        monthsMap.add('Feb');
        monthsMap.add('Mar');
        monthsMap.add('Apr');
        monthsMap.add('May');
        monthsMap.add('Jun');
        monthsMap.add('Jul');
        monthsMap.add('Aug');
        monthsMap.add('Sep');
        monthsMap.add('Oct');
        monthsMap.add('Nov');
        monthsMap.add('Dec');
        
        return monthsMap.get(monthNumber);
    }

    public static String getProbName (String probPercent){
        Map<String, String> probMap = new  Map<String, String>();
        probMap.put('0%', 'Cancelled');
        probMap.put('25%', 'Low');
        probMap.put('50%', 'Medium');
        probMap.put('75%', 'High');
        
        return probMap.get(probPercent);
    }

    public static void updateOpportunityProductName (list<OpportunityLineItem> listOptyLine)
    {
        String opptyProductName = '';       
        for (OpportunityLineItem opptyLine: [SELECT Id,OpportunityId,Product2.Name FROM OpportunityLineItem 
                                     WHERE OpportunityId =: listOptyLine.get(0).OpportunityId ORDER BY CreatedDate DESC])
        {
            if(opptyProductName == '')
            {
                opptyProductName = opptyLine.Product2.Name;
            }
            else 
            {
                opptyProductName += ', '+opptyLine.Product2.Name;
            }
        }
        
        Opportunity op = [SELECT Id FROM Opportunity WHERE id =: listOptyLine.get(0).OpportunityId];
        op.Comm_Product_List__c = opptyProductName;
        
        update op;
    }
}