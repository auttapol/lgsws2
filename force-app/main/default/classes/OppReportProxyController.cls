public class OppReportProxyController {
    
    public string userprofile {get{
        if (userprofile == null){
            string retDat = '';
            list<profile> listProfile = [select name from profile where id =: userinfo.getProfileId()];
            if (listProfile.size() > 0)
                retDat = listProfile.get(0).name;
            return retDat;
        }else{
            return userprofile;
        }
    }set;}
    
    public Pagereference gotoReport(){
        PageReference pr;
        pr = new PageReference('/apex/OppProductReport');  
        pr.setRedirect(true);
        return pr; 
    }
    
    public pageReference backtoListOpty(){
        PageReference pr;
        pr = new PageReference('/006?fcf=00B90000008KS2Z');  
        pr.setRedirect(true);
        return pr;
    }
    
}