public  class II_HelptextCtrl {
    //property
    public string m_SObjectname { get; set; }
    public string m_FieldApiName { get; set; }
    public string m_Screen { get; set; }
    // ถ้าจะใช้ค่าจากCustomHelpText__c
    public boolean m_iscustom {get;set;}

    
    public string getHelptext(){
       if(m_iscustom)    { 
              if(string.isBlank(m_Screen)) return '';
           return CustomHelpTextService.getHelptext(m_SObjectname,m_FieldApiName,m_Screen);
       }
       return Schema.getGlobalDescribe().get(m_SObjectname).getDescribe().fields.getMap().get(m_FieldApiName).getDescribe().getInlineHelpText();
    }     
}