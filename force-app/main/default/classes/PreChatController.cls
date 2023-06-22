public class PreChatController {
    @AuraEnabled
    public static List<Chat_Button_and_Topic_Setting__mdt > getSubjectList()
    {
        try
        { 
            List<Chat_Button_and_Topic_Setting__mdt > subjectList = [SELECT Id,Chat_Button_Id__c,Priority__c,Subject__c 
                                                       FROM Chat_Button_and_Topic_Setting__mdt];
            
            return subjectList;
        }
        catch(Exception e)
        {
            System.debug(e);
            return null;
        }
    }
}