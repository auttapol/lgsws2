public class OpportunityLineItemBreakDownController {

    public list<opportunitylineitem> listOppProd {get;set;}

    public string sysYear {get;set;}
    public map<string,mapRenderField> mapProductRender {get;set;}
    public map<string,integer> mapMonth {
        get{
            if (mapMonth == null){
                mapMonth = new map<string,integer>();
                mapMonth.put('jan',1);
                mapMonth.put('feb',2);
                mapMonth.put('mar',3);
                mapMonth.put('apr',4);
                mapMonth.put('may',5);
                mapMonth.put('jun',6);
                mapMonth.put('jul',7);
                mapMonth.put('aug',8);
                mapMonth.put('sep',9);
                mapMonth.put('oct',10);
                mapMonth.put('nov',11);
                mapMonth.put('dec',12);
            }
            return mapMonth;
        }
        set;
    }
    public map<string,string> mapProductName {get;set;}

    public map<integer,string> niName {get;set;}
    public map<integer,string> nitotalSum {get;set;}
    public list<integer> nitotalSumVF {get;set;}
    public map<integer,string> feeName {get;set;}
    public map<integer,string> feetotalSum {get;set;}
    public list<integer> feetotalSumVF {get;set;}
    public string previousPage {get;set;}
    public list<string> listOpportunityProductId {get;set;}
    public integer optLineSize {get;set;}
    public boolean validateOpty {get;set;}
    
    public string firstOppProdId {get;set;}
    public string optyId {get;set;}
    public string prevPage {get;set;}
    public string prevPageNo {get;set;}

    public OpportunityLineItemBreakDownController()
    {
        mapProductRender = new map<string,mapRenderField>();
        mapProductName = new map<string,string>();

        niName = new map<integer,string>();
        feeName = new map<integer,string>();
        nitotalSum = new map<integer,string>();
        feetotalSum = new map<integer,string>();
        nitotalSumVF = new list<integer>();
        feetotalSumVF = new list<integer>();
        previousPage = '';
        optLineSize = 0;
        validateOpty = true;
        listOppProd = new list<opportunitylineitem>();
        firstOppProdId = '';
        optyId = '';
        prevPage = ((ApexPages.currentPage().getParameters().get('prevPage') != null) ? ApexPages.currentPage().getParameters().get('prevPage') : '');
        prevPageNo = ((ApexPages.currentPage().getParameters().get('prevPageNo') != null) ? ApexPages.currentPage().getParameters().get('prevPageNo') : '');

        if (ApexPages.currentPage().getHeaders().get('Referer') != null)
            previousPage = ApexPages.currentPage().getHeaders().get('Referer');
        //sysYearTH = string.valueof(system.now().year() + 543);
        
        if (Userinfo.getLocale() == 'th_TH'){
            sysYear = string.valueof(system.now().year() - 543);
        }else{
            sysYear = string.valueof(system.now().year());
        }

        string listTempOpportunityProductId = apexPages.currentPage().getParameters().get('listoppprodid');
        if (listTempOpportunityProductId != null){
            listOpportunityProductId = listTempOpportunityProductId.split(',');
        }else{
            listOpportunityProductId = new list<string>();
        }
        
        for(opportunitylineitem ol : [select id, PricebookEntry.Product2.Name
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
                           , isNiBreakdownCalculate__c, isFeeBreakdownCalculate__c
                           , opportunityid, opportunity.name, opportunity.closeDate
                           , opportunity.isClosed
                           , opportunity.recordtype.name
                           , opportunity.Expected_submit_date__c
                           from opportunitylineitem 
                           where id in: listOpportunityProductId
                           order by createddate asc])
        {
            /*
            if (ol.opportunity.CloseDate < system.today()){
                validateOpty = false;
            }
            */
            if (!ol.opportunity.isClosed
             && !ol.opportunity.recordtype.name.contains('2')
             && !ol.opportunity.recordtype.name.contains('3')
             && ol.opportunity.Expected_submit_date__c < system.today()){
                validateOpty = false; 
            }
            listOppProd.add(ol);
        }
        
        if (listOppProd.size() == 0){
            for (opportunitylineitem ol : [select id, opportunityid from opportunitylineitem where id in: listOpportunityProductId order by createddate desc])
            {
                firstOppProdId = ol.id;
                optyId = ol.opportunityid;
            }
        }
                           
        if (!validateOpty){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8056').status_message__c));
        } 
                           
        optLineSize = listOppProd.size();
 
                      
        integer cntindex = 0;               
        for (opportunitylineitem o : listOppProd)
        {
            string tempName = o.PricebookEntry.Product2.Name;
            decimal nameLength = tempName.length();
            if (tempName.length() > 13){
                string fullName = tempName;
                tempName = '';
                integer countLoop = integer.valueof((nameLength/13).round(System.RoundingMode.CEILING));
                for(integer nLoop = 0; nLoop < countLoop; nLoop++)
                {
                    integer startIndex = nLoop * 13;
                    integer endIndex = startIndex + 13;
                    if (fullName.length() > endIndex){
                        if (fullName.substring(startIndex,endIndex).contains(' ')){
                            tempName += fullName.substring(startIndex,endIndex).replace(' ','<br/>');
                        }else{
                            tempName += fullName.substring(startIndex,endIndex)+'<br/>';
                        }
                    }else{
                        tempName += fullName.substring(startIndex,fullName.length());
                    }
                }
            }
            mapProductName.put(o.id,tempName);
        
            mapRenderField mrf = new mapRenderField();
            
            if (o.RevisedStartYear__c == sysYear && o.isNiBreakdownCalculate__c){
            
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 1){
                    
                }
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 2){
                    mrf.ni_jan = false;
                    o.ni_january__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 3){
                    mrf.ni_feb = false;
                    o.ni_february__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 4){
                    mrf.ni_mar = false;
                    o.ni_march__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 5){
                    mrf.ni_apr = false;
                    o.ni_april__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 6){
                    mrf.ni_may = false;
                    o.ni_may__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 7){
                    mrf.ni_jun = false;
                    o.ni_june__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 8){
                    mrf.ni_jul = false;
                    o.ni_july__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 9){
                    mrf.ni_aug = false;
                    o.ni_august__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 10){
                    mrf.ni_sep = false;
                    o.ni_september__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 11){
                    mrf.ni_oct = false;
                    o.ni_october__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) >= 12){
                    mrf.ni_nov = false;
                    o.ni_november__c = 0;
                }

            }else{
                mrf.ni_jan = false;
                mrf.ni_feb = false;
                mrf.ni_mar = false;
                mrf.ni_apr = false;
                mrf.ni_may = false;
                mrf.ni_jun = false;
                mrf.ni_jul = false;
                mrf.ni_aug = false;
                mrf.ni_sep = false;
                mrf.ni_oct = false;
                mrf.ni_nov = false;
                mrf.ni_dec = false;
            }
            
            if (o.RevisedStartYearFee__c == sysYear && o.isFeeBreakdownCalculate__c){
            
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 1){
                    
                }
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 2){
                    mrf.fee_jan = false;
                    o.fee_january__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 3){
                    mrf.fee_feb = false;
                    o.fee_february__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 4){
                    mrf.fee_mar = false;
                    o.fee_march__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 5){
                    mrf.fee_apr = false;
                    o.fee_april__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 6){
                    mrf.fee_may = false;
                    o.fee_may__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 7){
                    mrf.fee_jun = false;
                    o.fee_june__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 8){
                    mrf.fee_jul = false;
                    o.fee_july__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 9){
                    mrf.fee_aug = false;
                    o.fee_august__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 10){
                    mrf.fee_sep = false;
                    o.fee_september__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 11){
                    mrf.fee_oct = false;
                    o.fee_october__c = 0;
                }
                if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) >= 12){
                    mrf.fee_nov = false;
                    o.fee_november__c = 0;
                }
 
            }else{
                mrf.fee_jan = false;
                mrf.fee_feb = false;
                mrf.fee_mar = false;
                mrf.fee_apr = false;
                mrf.fee_may = false;
                mrf.fee_jun = false;
                mrf.fee_jul = false;
                mrf.fee_aug = false;
                mrf.fee_sep = false;
                mrf.fee_oct = false;
                mrf.fee_nov = false;
                mrf.fee_dec = false;
            }
            
            mapProductRender.put(o.id,mrf);
            
 
            niName.put(cntindex, (o.Type_Of_Reference__c != null) ? o.Type_Of_Reference__c : 'NI');
            feeName.put(cntindex, (o.Type_Of_Reference_Fee__c != null) ? o.Type_Of_Reference_Fee__c : 'Fee');
            
            if (o.isNiBreakdownCalculate__c == true && o.RevisedStartYear__c == sysYear){
                string tempVal = string.valueof((o.This_Year_Expected_NI__c!=null) ? o.This_Year_Expected_NI__c : 0);
                if (tempVal.length() >= 4){
                    tempVal = tempVal.substring(0,(tempVal.length() - 3));
                }
                nitotalSum.put(cntindex, tempVal);
            }else{
                nitotalSum.put(cntindex, '0');
            }
            if (o.isFeeBreakdownCalculate__c == true && o.RevisedStartYearFee__c == sysYear){
                string tempVal = string.valueof((o.This_Year_Expected_Fee__c!=null) ? o.This_Year_Expected_Fee__c : 0);
                if (tempVal.length() >= 4){
                    tempVal = tempVal.substring(0,(tempVal.length() - 3));
                }
                feetotalSum.put(cntindex, tempVal);
            }else{
                feetotalSum.put(cntindex, '0');
            }
            
            nitotalSumVF.add(integer.valueof((o.This_Year_Expected_NI__c!=null) ? o.This_Year_Expected_NI__c : 0));
            feetotalSumVF.add(integer.valueof((o.This_Year_Expected_Fee__c!=null) ? o.This_Year_Expected_Fee__c : 0));
            
            cntindex++;
        }
        
        system.debug(nitotalSum);
        system.debug(feetotalSum);
    }
    
    public class mapRenderField {
        public boolean ni_jan {get;set;}
        public boolean ni_feb {get;set;}
        public boolean ni_mar {get;set;}
        public boolean ni_apr {get;set;}
        public boolean ni_may {get;set;}
        public boolean ni_jun {get;set;}
        public boolean ni_jul {get;set;}
        public boolean ni_aug {get;set;}
        public boolean ni_sep {get;set;}
        public boolean ni_oct {get;set;}
        public boolean ni_nov {get;set;}
        public boolean ni_dec {get;set;}
        public boolean fee_jan {get;set;}
        public boolean fee_feb {get;set;}
        public boolean fee_mar {get;set;}
        public boolean fee_apr {get;set;}
        public boolean fee_may {get;set;}
        public boolean fee_jun {get;set;}
        public boolean fee_jul {get;set;}
        public boolean fee_aug {get;set;}
        public boolean fee_sep {get;set;}
        public boolean fee_oct {get;set;}
        public boolean fee_nov {get;set;}
        public boolean fee_dec {get;set;}
        public mapRenderField ()
        {
            ni_jan = true;
            ni_feb = true;
            ni_mar = true;
            ni_apr = true;
            ni_may = true;
            ni_jun = true;
            ni_jul = true;
            ni_aug = true;
            ni_sep = true;
            ni_oct = true;
            ni_nov = true;
            ni_dec = true;
            fee_jan = true;
            fee_feb = true;
            fee_mar = true;
            fee_apr = true;
            fee_may = true;
            fee_jun = true;
            fee_jul = true;
            fee_aug = true;
            fee_sep = true;
            fee_oct = true;
            fee_nov = true;
            fee_dec = true;
        }
 
    }
    
    public pageReference cancel()
    {
        if ((previousPage.toLowerCase().contains('oppproductreport') || previousPage.toLowerCase().contains('console?tsid='))
            || prevPage.toLowerCase() == 'pipeline'){
            return new pageReference('/apex/OppProductReport?prevPageNo='+prevPageNo);
        }else{
            string retid = '';
            if (listOpportunityProductId.size() == 1 && !prevPage.toLowerCase().contains('all')){
                retid = (listOppProd.size() > 0 ) ? listOppProd.get(0).id : firstOppProdId;
                if (prevPage.toLowerCase().contains('closewon')){
                    return new pageReference('/apex/CloseWonOppProduct2?id='+listOppProd.get(0).opportunityid);
                }else{
                    return new pageReference('/apex/EditSingleOppProduct?id='+retid);
                }
            }else if (listOpportunityProductId.size() > 1 || prevPage.toLowerCase().contains('all')){
                retid = (listOppProd.size() > 0 ) ? listOppProd.get(0).opportunityid : optyId;
                if (prevPage.toLowerCase().contains('closewon')){
                    return new pageReference('/apex/CloseWonOppProduct2?id='+listOppProd.get(0).opportunityid);
                }else{
                    return new pageReference('/apex/EditAllOppProduct?id='+retid);
                }
            }else{
                return null;
            }
        }
    }
    
    public pageReference save()
    {
        try {
        
            for (opportunityLineItem o: listOppProd)
            {
                if (o.RevisedStartYear__c == sysYear){
                    
                    o.This_Year_Expected_NI__c = 0;
                    
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 1 && !string.isBlank(string.valueof(o.ni_january__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_january__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 2 && !string.isBlank(string.valueof(o.ni_february__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_february__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 3 && !string.isBlank(string.valueof(o.ni_march__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_march__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 4 && !string.isBlank(string.valueof(o.ni_april__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_april__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 5 && !string.isBlank(string.valueof(o.ni_may__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_may__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 6 && !string.isBlank(string.valueof(o.ni_june__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_june__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 7 && !string.isBlank(string.valueof(o.ni_july__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_july__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 8 && !string.isBlank(string.valueof(o.ni_august__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_august__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 9 && !string.isBlank(string.valueof(o.ni_september__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_september__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 10 && !string.isBlank(string.valueof(o.ni_october__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_october__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 11 && !string.isBlank(string.valueof(o.ni_november__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_november__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonth__c.toLowerCase()) <= 12 && !string.isBlank(string.valueof(o.ni_december__c))){
                        o.This_Year_Expected_NI__c += integer.valueof(o.ni_december__c);
                    }
 
                }
                
                if (o.RevisedStartYearFee__c == sysYear){
                
                    o.This_Year_Expected_Fee__c = 0;
                    
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 1 && !string.isBlank(string.valueof(o.fee_january__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_january__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 2 && !string.isBlank(string.valueof(o.fee_february__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_february__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 3 && !string.isBlank(string.valueof(o.fee_march__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_march__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 4 && !string.isBlank(string.valueof(o.fee_april__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_april__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 5 && !string.isBlank(string.valueof(o.fee_may__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_may__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 6 && !string.isBlank(string.valueof(o.fee_june__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_june__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 7 && !string.isBlank(string.valueof(o.fee_july__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_july__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 8 && !string.isBlank(string.valueof(o.fee_august__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_august__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 9 && !string.isBlank(string.valueof(o.fee_september__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_september__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 10 && !string.isBlank(string.valueof(o.fee_october__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_october__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 11 && !string.isBlank(string.valueof(o.fee_november__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_november__c);
                    }
                    if (mapMonth.get(o.RevisedStartMonthFee__c.toLowerCase()) <= 12 && !string.isBlank(string.valueof(o.fee_december__c))){
                        o.This_Year_Expected_Fee__c += integer.valueof(o.fee_december__c);
                    }
                }
                
            }
        
            update listOppProd;
            
        }catch(exception ex){
            system.debug(ex.getMessage());
        }
        
        if ((previousPage.toLowerCase().contains('oppproductreport') || previousPage.toLowerCase().contains('console?tsid='))
            || prevPage.toLowerCase() == 'pipeline'){
            return new pageReference('/apex/OppProductReport?prevPageNo='+prevPageNo);
        }else{
            string retid = '';
            if (listOpportunityProductId.size() == 1 && !prevPage.toLowerCase().contains('all')){
                retid = (listOppProd.size() > 0 ) ? listOppProd.get(0).id : firstOppProdId;
                if (prevPage.toLowerCase().contains('closewon')){
                    return new pageReference('/apex/CloseWonOppProduct2?id='+listOppProd.get(0).opportunityid);
                }else{
                    return new pageReference('/apex/EditSingleOppProduct?id='+retid);
                }
            }else if (listOpportunityProductId.size() > 1 || prevPage.toLowerCase().contains('all')){
                retid = (listOppProd.size() > 0 ) ? listOppProd.get(0).opportunityid : optyId;
                if (prevPage.toLowerCase().contains('closewon')){
                    return new pageReference('/apex/CloseWonOppProduct2?id='+listOppProd.get(0).opportunityid);
                }else{
                    return new pageReference('/apex/EditAllOppProduct?id='+retid);
                }
            }else{
                return null;
            }
        }
    }
    
    public void validateExpected()
    {
        string niNewValue = apexpages.currentPage().getParameters().get('niNewValue');
        string feeNewValue = apexpages.currentPage().getParameters().get('feeNewValue');
        string nloop = apexpages.currentPage().getParameters().get('nloop');
        integer indexNo = (!string.isBlank(nloop)) ? integer.valueof(nloop) : 0;
        string warningMessage = '';
       
        if (niNewValue != string.valueof(nitotalSum.get(indexNo)) && listOppProd.get(indexNo).isNiBreakdownCalculate__c == true){
            //warningMessage += niName + ' : Total amount is different from This Year Expected Revenue from ' + nitotalSum + ' to ' + niNewValue + '. If click Save, System will re-calculate "This year expected revenue" on opportunity product page .';
            warningMessage += (status_code__c.getValues('8061a').status_message__c + '<br/>' + status_code__c.getValues('8061b').status_message__c).replace('xxx',string.valueof(nitotalSum.get(indexNo))).replace('yyy',string.valueof(niNewValue));
            warningMessage = niName.get(indexNo) + ' : ' + warningMessage;
        }
        if (feeNewValue != string.valueof(feetotalSum.get(indexNo)) && listOppProd.get(indexNo).isFeeBreakdownCalculate__c == true){
            if (warningMessage != ''){
                warningMessage += '<br/> ' + feeName.get(indexNo);
                warningMessage += (status_code__c.getValues('8061a').status_message__c + '<br/>' + status_code__c.getValues('8061b').status_message__c).replace('xxx',string.valueof(feetotalSum.get(indexNo))).replace('yyy',string.valueof(feeNewValue));
            }else{
                warningMessage += (status_code__c.getValues('8061a').status_message__c + '<br/>' + status_code__c.getValues('8061b').status_message__c).replace('xxx',string.valueof(feetotalSum.get(indexNo))).replace('yyy',string.valueof(feeNewValue));
                warningMessage = feeName.get(indexNo) + ' : ' + warningMessage;
            }
            //warningMessage += feeName + ' : Total amount is different from This Year Expected Revenue from ' + feetotalSum + ' to ' + feeNewValue + '. If click Save, System will re-calculate "This year expected revenue" on opportunity product page .';            
        }
        
        if (warningMessage != '')
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, warningMessage));
    }

}