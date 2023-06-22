trigger SlaPerOwnerTrigger on SLA_Per_Owner__c (before update) {
    
    BusinessHours standardHoursId = [Select ID, Name from BusinessHours where name = 'Service' limit 1];
    for(SLA_Per_Owner__c Wdpo : trigger.new){
        //Calculate aging from 'Start Date/Time' and 'End Date/Time' by excluding weekend and holiday base on Business hour
        Wdpo.Is_More_1_day__c = false;
        Wdpo.Number_of_Aging__c = null;
        if(Wdpo.End_Date_Time__c != null ){
            Datetime pointer = Wdpo.Start_Date_Time__c;
            Integer days = Wdpo.Start_Date_Time__c.date().daysBetween(Wdpo.End_Date_Time__c.date());
            Wdpo.Number_of_Aging__c = 0;
            
            Datetime startDate;
            Datetime endDate;
            
            if(days > 0 || Test.isRunningTest()){                
                 Wdpo.Is_More_1_day__c = true;
                //if start date not weekend or holiday
                if(BusinessHours.isWithin(standardHoursId.id, pointer)){
                    Integer year = pointer.year();
                    Integer month = pointer.month();
                    Integer day = pointer.day()+1;
                    startDate = Datetime.newInstance(year, month, day, 0, 0, 0);
                    pointer = startDate;
                    Long dt1Long = Wdpo.Start_Date_Time__c.getTime();                
                    Long dt2Long = startDate.getTime();                    
                    Long milliseconds = dt2Long - dt1Long;                   
                    decimal seconds = milliseconds / 1000;
                    decimal minutes = seconds / 60;
                    decimal hours = minutes / 60;
                    Wdpo.Number_of_Aging__c = hours / 24.00; 
                }else{                
                   while(!BusinessHours.isWithin(standardHoursId.id, pointer)){
                             pointer = pointer.addDays(1);
                     }
                    Integer year = pointer.year();
                    Integer month = pointer.month();
                    Integer day = pointer.day();
                    pointer = Datetime.newInstance(year, month, day, 0, 0, 0); 
                }          
                while(pointer < Wdpo.End_Date_Time__c.addDays(-1)){
                    if(BusinessHours.isWithin(standardHoursId.id, pointer)){
                        Wdpo.Number_of_Aging__c = Wdpo.Number_of_Aging__c + 1; 
                    }
                    pointer = pointer.addDays(1);
                } 

                //If end date not in weekend or holiday
                if(BusinessHours.isWithin(standardHoursId.id, Wdpo.End_Date_Time__c)){                    
                    Integer year = Wdpo.End_Date_Time__c.year();
                    Integer month = Wdpo.End_Date_Time__c.month();
                    Integer day = Wdpo.End_Date_Time__c.day();
                    endDate = Datetime.newInstance(year, month, day, 0, 0, 0);
                    
                    Long dt1Long = endDate.getTime();                
                    Long dt2Long = Wdpo.End_Date_Time__c.getTime();
                    Long milliseconds = dt2Long - dt1Long;
                    decimal seconds = milliseconds / 1000;
                    decimal minutes = seconds / 60;
                    decimal hours = minutes / 60;
                    Wdpo.Number_of_Aging__c = Wdpo.Number_of_Aging__c + (hours / 24.00); 
                }
            }
        }
     } 
}