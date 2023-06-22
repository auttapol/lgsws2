public class ii_UserInfoEx {
    public static string EmployeeId{
        get{
            
            return GetCurrentUser();
        }
    }   
    
    public static string GetCurrentUser(){
        string empId = UserInfo.getUserName();
        
        system.debug('UserInfoEx Log >> First GetCurrentUser : ' + empId);
        
        // get TMB Employee ID
        integer index = empId.indexOf('@');
        if(empId.length()>= 5){//  make sure first digit is Employee id
            empId = empId.substring(0, index);
        }
        system.debug('UserInfoEx Log >> Final GetCurrentUser : ' + empId);
        
        return empId;
    }
}