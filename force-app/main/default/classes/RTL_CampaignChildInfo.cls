Global class RTL_CampaignChildInfo {
    
    private static Date Stm_child_startdate  {get;set;}
    private static Date Stm_child_enddate  {get;set;}
    private static Boolean hasChild  {get;set;}
    
	@invocableMethod
    public static void GetChildren(List<Campaign> parent){
        Stm_child_startdate = parent[0].Stamp_child_Start_Date__c;
        Stm_child_enddate = parent[0].Stamp_Child_End_Date__c;
        hasChild = parent[0].ContainsChild__c;
        UpdateMaster(parent[0].id);
    }
 
    @future
    public static void UpdateMaster(String parentid){
       
        List<Campaign> children = [SELECT id, name, StartDate, EndDate FROM Campaign WHERE parentid =: parentid AND status != 'Cancelled'];   
        If(children.size() > 0){
            hasChild = true;
            For (Campaign c : children){
                If(Stm_child_startdate == null || c.StartDate < Stm_child_startdate){
                    Stm_child_startdate = c.StartDate;
                }
                If(Stm_child_enddate == null || c.EndDate > Stm_child_enddate){
                    Stm_child_enddate = c.EndDate;
                }
            }
        }else{
            hasChild = false;
        }
        
        Campaign Master = new Campaign(id = parentid, Stamp_child_Start_Date__c = Stm_child_startdate, Stamp_Child_End_Date__c = Stm_child_enddate, ContainsChild__c = hasChild );
  		update Master;
    }
}