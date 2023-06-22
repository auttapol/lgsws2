public class OpportunityReportController {

    public string sysYear {get;set;}
    public user userObj {get;set;}
    
    public set<string> setAccountId {get;set;}
    
    public map<string,integer> mapOpportunityProductQuantity {get;set;}
    public map<integer,list<account>> mapPageAccount {get;set;}
    public integer rowPerPage = 50;
    public integer currentPage {get;set;}
    public integer totalPage {get;set;}
    public string pageMode {get;set;}
    
    public string inputPage {get;set;}
    public string inputPage1 {get;set;}
    public string inputPage2 {get;set;}
    
    public boolean isNotConsole {get{
        if (isNotConsole == null){
            boolean retDat = true;
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) 
                || String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) 
                || ApexPages.currentPage().getParameters().get('isdtp') == 'p1' 
                || (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
            ){
                retDat= false;
            }
            return retDat;
        }else{
            return isNotConsole;
        }
    }set;}
    
    public list<wrapper1> wrapObj {get;set;}

    public OpportunityReportController()
    {
        setAccountId = new set<string>();
        mapPageAccount = new map<integer,list<account>>();
        mapOpportunityProductQuantity = new map<string,integer>();
        currentPage = 1;
        totalPage = 1;
        inputPage = '1';
        inputPage1 = inputPage;
        inputPage2 = inputPage;
        
        wrapObj = new list<wrapper1>();
        
        userObj = [select id, name from user where id =: userinfo.getuserid()];
        
        if (Userinfo.getLocale() == 'th_TH'){
            sysYear = string.valueof(system.now().year() - 543);
        }else{
            sysYear = string.valueof(system.now().year());
        }
        
        for (opportunity o : [select accountid,(select id, RevisedStartYearFee__c, RevisedStartYear__c 
                                                from OpportunityLineItems) from opportunity where ownerid =: userObj.id])
        {
            setAccountId.add(o.accountid);
            
            boolean currentYearExist = false;
            for (OpportunityLineItem ol : o.OpportunityLineItems)
            {
                if (ol.RevisedStartYearFee__c == sysYear || ol.RevisedStartYear__c == sysYear){
                    currentYearExist = true;
                }
            }
            if (currentYearExist){
                mapOpportunityProductQuantity.put(o.id,o.OpportunityLineItems.size());
            }else{
                mapOpportunityProductQuantity.put(o.id,0);
            }
        }
        
        list<account> listAcctPerPage = new list<account>();
        integer curPage = 1;
        integer curRow = 0;
        
        for (account a : [select id, name
                                   , (select id, name, stageName, isClosed from opportunities where ownerid =: userObj.id)
                          from account
                          where id in: setAccountId])
        {
        
            if (a.opportunities.size() > 0){
                
                list<opportunity> listOptyAfterRemoveEmptyOppProd = new list<opportunity>();
                for (opportunity o : a.opportunities)
                {
                    if (mapOpportunityProductQuantity.get(o.id) > 0){
                        curRow += mapOpportunityProductQuantity.get(o.id);
                        listOptyAfterRemoveEmptyOppProd.add(o);
                    }
                }
                
                if (listOptyAfterRemoveEmptyOppProd.size() > 0){
                
                    curRow++;
                    curRow += listOptyAfterRemoveEmptyOppProd.size();
                      
                    if (curRow <= rowPerPage){
                        listAcctPerPage.add(a);
                    }else{
                    
                        if (listAcctPerPage.size() == 0){
                            listAcctPerPage.add(a);
                        }else{
                            mapPageAccount.put(curPage, listAcctPerPage);
                            listAcctPerPage = new list<account>();
                            curPage++;
                            curRow = 1;
                            curRow += listOptyAfterRemoveEmptyOppProd.size();
                            listAcctPerPage.add(a);
                        }
                    }
                
                }
                
            }else{
                
            }
            
        }  
        
        if (mapPageAccount.size() < curPage){
            mapPageAccount.put(curPage, listAcctPerPage);
        }
        
        totalPage = curPage;
        //pageMode = 'Page : 1 of ' + totalPage;
        pageMode = ' of ' + totalPage;
        
system.debug(mapPageAccount);
        
        
        for (account a : mapPageAccount.get(currentPage))
        {
            wrapper1 wp = new wrapper1();
            wp.acct = a;
            wp.opty = getListOpty(a.id);
            
            wrapObj.add(wp);

        }
        
        
        if (apexPages.currentPage().getParameters().get('prevPageNo') != null){
            string inputCurPage = apexPages.currentPage().getParameters().get('prevPageNo');
            
            if (inputCurPage.toLowerCase() == 'all'){
                allPage();
            }else if (!inputCurPage.isNumeric() || integer.valueof(inputCurPage) > totalPage || integer.valueof(inputCurPage) < 1){
                firstPage();
            }else{
                inputPage1 = inputCurPage;
                inputPage2 = inputCurPage;
                searchPage();
            }
        }
        

    }
    
    public pageReference backToListView()
    {
        return new pageReference('/006?fcf=00B90000008KS2Z');
    }
    
    public void nextPage()
    {
        integer nextP = currentPage + 1;
        if (totalPage >= nextP){ 
            currentPage++;
            wrapObj = new list<wrapper1>();
            for (account a : mapPageAccount.get(currentPage))
            {
                wrapper1 wp = new wrapper1();
                wp.acct = a;
                wp.opty = getListOpty(a.id);
                
                wrapObj.add(wp);
            }
        }
        //pageMode = 'Page : ' + string.valueof(currentPage) + ' of ' + totalPage;
        inputPage = string.valueof(currentPage);
        inputPage1 = inputPage;
        inputPage2 = inputPage;
    }
    public void previousPage()
    {
        integer nextP = currentPage - 1;
        if (nextP > 0){ 
            currentPage--;
            wrapObj = new list<wrapper1>();
            for (account a : mapPageAccount.get(currentPage))
            {
                wrapper1 wp = new wrapper1();
                wp.acct = a;
                wp.opty = getListOpty(a.id);
                
                wrapObj.add(wp);
            }
        }
        //pageMode = 'Page : ' + string.valueof(currentPage) + ' of ' + totalPage;
        inputPage = string.valueof(currentPage);
        inputPage1 = inputPage;
        inputPage2 = inputPage;
    }
    public void showCurrentPage()
    {
        wrapObj = new list<wrapper1>();
        for (account a : mapPageAccount.get(currentPage))
        {
            wrapper1 wp = new wrapper1();
            wp.acct = a;
            wp.opty = getListOpty(a.id);
            
            wrapObj.add(wp);
        }
        pageMode = 'Page : ' + string.valueof(currentPage) + ' of ' + totalPage;
    }
    public void allPage()
    {
        integer ii = 1;
        wrapObj = new list<wrapper1>();
        while(ii<=totalPage)
        {
            for (account a : mapPageAccount.get(ii))
            {
                wrapper1 wp = new wrapper1();
                wp.acct = a;
                wp.opty = getListOpty(a.id);
                
                wrapObj.add(wp);
            } 
            ii++;
        }
        //pageMode = 'All Page';
        inputPage = 'All';
        inputPage1 = inputPage;
        inputPage2 = inputPage;
    }
    public void firstPage()
    {
        currentPage = 1;
        wrapObj = new list<wrapper1>();
        for (account a : mapPageAccount.get(currentPage))
        {
            wrapper1 wp = new wrapper1();
            wp.acct = a;
            wp.opty = getListOpty(a.id);
            
            wrapObj.add(wp);
        }
        //pageMode = 'Page : ' + string.valueof(currentPage) + ' of ' + totalPage;
        inputPage = string.valueof(currentPage);
        inputPage1 = inputPage;
        inputPage2 = inputPage;
    }
    public void lastPage()
    {
        currentPage = totalPage;
        wrapObj = new list<wrapper1>();
        for (account a : mapPageAccount.get(currentPage))
        {
            wrapper1 wp = new wrapper1();
            wp.acct = a;
            wp.opty = getListOpty(a.id);
            
            wrapObj.add(wp);
        }
        //pageMode = 'Page : ' + string.valueof(currentPage) + ' of ' + totalPage;
        inputPage = string.valueof(currentPage);
        inputPage1 = inputPage;
        inputPage2 = inputPage;
    }
    public void searchPage()
    {
        if (inputPage != inputPage1){
            inputPage = inputPage1;
        }else if (inputPage != inputPage2){
            inputPage = inputPage2;
        }
    
        if (inputPage.toLowerCase() == 'all'){
            allPage();
        }else{
            if (!inputPage.isNumeric() || integer.valueof(inputPage) > totalPage || integer.valueof(inputPage) < 1){
                inputPage = '1';
            }
        
            integer searchInputPage = integer.valueof(inputPage);
        
            wrapObj = new list<wrapper1>();
            for (account a : mapPageAccount.get(searchInputPage))
            {
                wrapper1 wp = new wrapper1();
                wp.acct = a;
                wp.opty = getListOpty(a.id);
                
                wrapObj.add(wp);
            }
        }
        
        inputPage1 = inputPage;
        inputPage2 = inputPage;
    }
    
    public list<opportunity> getListOpty(string acctid)
    {
        list<opportunity> retDat = new list<opportunity>();
        for (opportunity o : [select id, name, stageName, isClosed
                                       , (select id, PricebookEntry.Product2.Name
                                       , RevisedStartMonth__c, RevisedStartYear__c
                                       , RevisedStartMonthFee__c, RevisedStartYearFee__c
                                       , ni_january__c, ni_february__c, ni_march__c, ni_april__c
                                       , ni_may__c, ni_june__c, ni_july__c, ni_august__c
                                       , ni_september__c, ni_october__c, ni_november__c, ni_december__c
                                       , fee_january__c, fee_february__c, fee_march__c, fee_april__c
                                       , fee_may__c, fee_june__c, fee_july__c, fee_august__c
                                       , fee_september__c, fee_october__c, fee_november__c, fee_december__c
                                       , This_Year_Expected_NI__c, This_Year_Expected_Fee__c
                                       , Frequency__c, FrequencyFee__c
                                       , Type_Of_Reference_Fee__c, Type_Of_Reference__c
                                       from opportunitylineitems)
                                  from opportunity
                                  where ownerid = : userObj.id
                                  and accountid = : acctid])
        {
            boolean currentYearExist = false;
            for (opportunitylineitem ol : o.opportunitylineitems)
            {
                if (ol.RevisedStartYear__c == sysYear || ol.RevisedStartYearFee__c == sysYear)
                    currentYearExist = true;
            } 
            
            if (currentYearExist)
                retDat.add(o);
        }

        return retDat;
    }
    
    public class wrapper1{
        public account acct {get;set;}
        public list<opportunity> opty {get;set;}
    }


}