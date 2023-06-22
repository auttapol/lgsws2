public class CampaignExtension {

    public string campaignID {get;set;}
    public string result {get;set;}
    public CampaignExtension(ApexPages.StandardController sc)
    {
        Campaign tmpCampaign = (Campaign)sc.getRecord();
        campaignID = tmpCampaign.ID;
    }

    public void summaryExpectedRevenue()
    {
        //string result = '';
        Campaign Self = [select ID
                                        , FullDealExpectedRevenueOpportunities__c
                                        , HierarchyFullDealExpectedRevenueOpty__c
                                        , FullDealExpectedRevenueWONOpty__c
                                        , HierarchyFullDealExpectedRevenueWONOpty__c
                                        , ThisYearExpectedRevenueOpportunities__c
                                        , HierarchyThisYearExpectedRevenueOpty__c
                                        , ThisYearExpectedRevenueWONOpty__c
                                        , HierarchyThisYearExpectedRevenueWONOpty__c
                                        from Campaign 
                                        where ID =: campaignID];

        List<Campaign> ListChild = [select HierarchyFullDealExpectedRevenueOpty__c
                                        , HierarchyFullDealExpectedRevenueWONOpty__c
                                        , HierarchyThisYearExpectedRevenueOpty__c
                                        , HierarchyThisYearExpectedRevenueWONOpty__c
                                        from Campaign 
                                        where ParentID =: campaignID];    

        List<Opportunity> ListOpt = [select Expected_Revenue_Input__c
                                        , This_Year_Expected_Revenue__c
                                        , IsWon
                                        from Opportunity 
                                        where CampaignID =: campaignID];

        try {

            if (Self != null) {

                decimal total = 0.00;
                decimal thisyear = 0.00;
                decimal totalWon = 0.00;
                decimal thisyearWon = 0.00;
                decimal ctotal = 0.00;
                decimal cthisyear = 0.00;
                decimal ctotalWon = 0.00;
                decimal cthisyearWon = 0.00;

                for (Opportunity o : ListOpt)
                {
                    total = total + ((o.Expected_Revenue_Input__c != null) ? o.Expected_Revenue_Input__c : 0.00);
                    thisyear = thisyear + ((o.This_Year_Expected_Revenue__c != null) ? o.This_Year_Expected_Revenue__c : 0.00);
                    
                    if (o.IsWon == true) {
                        totalWon = totalWon + ((o.Expected_Revenue_Input__c != null) ? o.Expected_Revenue_Input__c : 0.00);
                        thisyearWon = thisyearWon + ((o.This_Year_Expected_Revenue__c != null) ? o.This_Year_Expected_Revenue__c : 0.00);
                    }
                }

                for (Campaign c : ListChild)
                {
                    ctotal = ctotal + ((c.HierarchyFullDealExpectedRevenueOpty__c != null) ? c.HierarchyFullDealExpectedRevenueOpty__c : 0.00);
                    cthisyear = cthisyear + ((c.HierarchyThisYearExpectedRevenueOpty__c != null) ? c.HierarchyThisYearExpectedRevenueOpty__c : 0.00);
                    ctotalWon = ctotalWon + ((c.HierarchyFullDealExpectedRevenueWONOpty__c != null) ? c.HierarchyFullDealExpectedRevenueWONOpty__c : 0.00);
                    cthisyearWon = cthisyearWon + ((c.HierarchyThisYearExpectedRevenueWONOpty__c != null) ? c.HierarchyThisYearExpectedRevenueWONOpty__c : 0.00);
                }

                Self.FullDealExpectedRevenueOpportunities__c = total;
                Self.HierarchyFullDealExpectedRevenueOpty__c = total + ctotal;
                Self.FullDealExpectedRevenueWONOpty__c = totalWon;
                Self.HierarchyFullDealExpectedRevenueWONOpty__c = totalWon + ctotalWon;
                Self.ThisYearExpectedRevenueOpportunities__c = thisyear;
                Self.HierarchyThisYearExpectedRevenueOpty__c = thisyear + cthisyear;
                Self.ThisYearExpectedRevenueWONOpty__c = thisyearWon;
                Self.HierarchyThisYearExpectedRevenueWONOpty__c = thisyearWon + cthisyearWon;

                update Self;

            }

            result = 'Roll Up Revenue Complete';

        } catch (exception ex) {
            system.debug(ex.getMessage());
            result = 'Roll Up Revenue Error Line ' + ex.getLineNumber() + ' : ' + ex.getMessage();
        }

        //return result;
    }
 
}