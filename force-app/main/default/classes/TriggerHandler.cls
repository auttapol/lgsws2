public virtual class TriggerHandler {
/*----------------------------------------------------------------------------------
Author:        Dave Norris
Company:       Salesforce
Description:   A trigger handler class framework.
               Provide standard methods that can be overridden in object specific trigger classes.
               Provides ability to:
               1. Bypass trigger logic for cascading updated records (e.g. don't fire related trigger updates)
               2. Prevent recursion by specifying a max count
               3. Bypass trigger logic per user for the trigger handler (i.e. never fire this trigger)
Inputs:        None
Test Class:    TriggerHandler_Test
History
<Date>      <Authors Name>     <Brief Description of Change>
----------------------------------------------------------------------------------*/


  // static map of handler name, times run() was invoked
  private static Map<String, LoopCount> loopCountMap;
  private static Set<String> bypassedHandlers;
  
  private static Map<String, String> debugMsgMap;
  
  // the current context of the trigger, overridable in tests
  @TestVisible
  private TriggerContext context;

  // the current context of the trigger, overridable in tests
  @TestVisible
  private Boolean isTriggerExecuting;

  // static initialization
  static {
    loopCountMap = new Map<String, LoopCount>();
    bypassedHandlers = new Set<String>();
  }
  
  // constructor
  public TriggerHandler() {
    this.setTriggerContext();
  }

  /***************************************
   * public instance methods
   ***************************************/

  // main method that will be called during execution
  public void run() {
    
    System.Debug( 'NBN: Running TriggerHandler execution of ' + getHandlerName() + ' (' + this.context + ')' );
                   
    try {          
        //Check that the trigger event should run
        if( validateRun() ) {   
        
            // dispatch to the correct handler method
            if(this.context == TriggerContext.BEFORE_INSERT) {
              this.beforeInsert(Trigger.new);
            } else if(this.context == TriggerContext.BEFORE_UPDATE) {
              this.beforeUpdate(Trigger.oldMap, Trigger.newMap);
            } else if(this.context == TriggerContext.BEFORE_DELETE) {
              this.beforeDelete(Trigger.oldMap);
            } else if(this.context == TriggerContext.AFTER_INSERT) {
              this.afterInsert(Trigger.newMap);
            } else if(this.context == TriggerContext.AFTER_UPDATE) {
              this.afterUpdate(Trigger.oldMap, Trigger.newMap);
            } else if(this.context == TriggerContext.AFTER_DELETE) {
              this.afterDelete(Trigger.oldMap);
            } else if(this.context == TriggerContext.AFTER_UNDELETE) {
              this.afterUndelete(Trigger.newMap);
            }
        
        }   
        
        System.Debug( 'NBN: SUCCESS End TriggerHandler execution of ' + getHandlerName() + ' (' + this.context + ')' );
      
    }   
    catch (exception e) {

        System.Debug( 'NBN: ERROR End TriggerHandler execution of ' + getHandlerName() + ' (' + this.context + ')' );
        System.Debug( 'NBN:' + e.getMessage() );
              
        throw ( e ); 
    }
    
  }
  
  public void setMaxLoopCount(Integer max) {
    String handlerName = getHandlerName();
    if(!TriggerHandler.loopCountMap.containsKey(handlerName)) {
      TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
    } else {
      TriggerHandler.loopCountMap.get(handlerName).setMax(max);
    }
  }

  public void clearMaxLoopCount() {
    this.setMaxLoopCount(-1);
  }

  /***************************************
   * public static methods
   ***************************************/

  public static void bypass(String handlerName) {
    TriggerHandler.bypassedHandlers.add(handlerName);
  }

  public static void clearBypass(String handlerName) {
    TriggerHandler.bypassedHandlers.remove(handlerName);
  }

  public static Boolean isBypassed(String handlerName) {
    return TriggerHandler.bypassedHandlers.contains(handlerName);
  }

  public static void clearAllBypasses() {
    TriggerHandler.bypassedHandlers.clear();
  }

  /***************************************
   * private instance methods
   ***************************************/

  @TestVisible
  private void setTriggerContext() {
    this.setTriggerContext(null, false);
  }

  @TestVisible
  private void setTriggerContext(String ctx, Boolean testMode) {
    
    if(!Trigger.isExecuting && !testMode) {
      this.isTriggerExecuting = false;
      return;
    } else {
      this.isTriggerExecuting = true;
    }
    
    if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
        (ctx != null && ctx == 'before insert')) {
      this.context = TriggerContext.BEFORE_INSERT;
    } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
        (ctx != null && ctx == 'before update')){
      this.context = TriggerContext.BEFORE_UPDATE;
    } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
        (ctx != null && ctx == 'before delete')) {
      this.context = TriggerContext.BEFORE_DELETE;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
        (ctx != null && ctx == 'after insert')) {
      this.context = TriggerContext.AFTER_INSERT;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
        (ctx != null && ctx == 'after update')) {
      this.context = TriggerContext.AFTER_UPDATE;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
        (ctx != null && ctx == 'after delete')) {
      this.context = TriggerContext.AFTER_DELETE;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
        (ctx != null && ctx == 'after undelete')) {
      this.context = TriggerContext.AFTER_UNDELETE;
    }
  }

  // increment the loop count
  @TestVisible
  private void addToLoopCount() {
    
    //Boolean exceeded = false;
    String handlerName = getHandlerName();
    
    if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
      
      Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
      
    }
 
  }

  // make sure this trigger should continue to run
  @TestVisible
  private Boolean validateRun() {
     
     System.Debug( 'NBN: Checking if trigger handler has been called outside of trigger execution' );
    
    if(!this.isTriggerExecuting || this.context == null) {
        System.Debug( 'NBN: STOP - exception thrown to end user' );
        throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
    }
    
    System.Debug( 'NBN: PASS' );
    
    System.Debug( 'NBN: Checking if trigger handler has exceeded its maximum count for recursion' );
    
    integer maxLoopCount = TriggerHandler.loopCountMap.get(getHandlerName()).max;
    integer currentLoopCount = TriggerHandler.loopCountMap.get(gethandlerName()).count;
    
    if ( currentLoopCount >= maxLoopCount ) {
        
        System.Debug( 'NBN: STOP - Maximum loop count of ' + String.valueOf(maxLoopCount) + ' reached in ' + getHandlerName() );
        return false;
    
    }
    else {
        System.Debug( 'NBN: PASS' );
        addToLoopCount();
    }
    
    System.Debug( 'NBN: Checking if trigger handler has been bypassed through Apex logic not allowing child triggers to execute' );
 
    if(TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
        
        System.Debug( 'NBN: STOP - Trigger handler being bypassed by design through Apex logic: ' + UserInfo.getName() + ' (' + UserInfo.getUserId() + ')' );
        return false;
    }
    
    System.Debug( 'NBN: PASS' );
   
    System.Debug( 'NBN: Checking if trigger handler has been bypassed for the current user ' + UserInfo.getName() + ' (' + UserInfo.getUserId() + ')' );
  
    if( ! canTrigger( getHandlerName() ) ) {
    
        System.Debug( 'NBN: STOP - Trigger has been found to be bypassed in the User object in field Bypass_Trigger__c: ' + UserInfo.getName() + ' (' + UserInfo.getUserId() + ')' );            
        return false;
    }
    
    System.Debug( 'NBN: PASS' );
    
    return true;
  }

    @TestVisible
    private static final String bypassTrigger;
 
        //static {
            //User triggerList = [ Select Bypass_Triggers__c from User where Id =: UserInfo.getUserId() ];
            //bypassTrigger = ';' + triggerList.Bypass_Triggers__c + ';';
            
            //System.Debug( 'NBN: Bypass trigger list ' + bypassTrigger );
        //}
        
    @TestVisible
    public static boolean canTrigger(string apexTriggerName) {

        //if (bypassTrigger != null && bypassTrigger.indexOf(';'+apexTriggerName+';') > -1){
            //return false;
        //}

        return true;
    } 

  @TestVisible
  private String getHandlerName() {
    return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
  }

  /***************************************
   * context methods
   ***************************************/

  // context-specific methods for override
  @TestVisible
  protected virtual void beforeInsert(List<SObject> so){}
  @TestVisible
  protected virtual void beforeUpdate(map<id,SObject> oldMap, map<id,SObject> newMap){}
  @TestVisible
  protected virtual void beforeDelete(map<id,SObject> oldMap){}
  @TestVisible
  protected virtual void afterInsert(map<id,SObject> newMap){}
  @TestVisible
  protected virtual void afterUpdate(map<id,SObject> oldMap, map<id,SObject> newMap){}
  @TestVisible
  protected virtual void afterDelete(map<id,SObject> oldMap){}
  @TestVisible
  protected virtual void afterUndelete(map<id,SObject> newMap){}

  /***************************************
   * inner classes
   ***************************************/

  // inner class for managing the loop count per handler
  @TestVisible
  private class LoopCount {
    private Integer max;
    private Integer count;

    public LoopCount() {
      this.max = 5;
      this.count = 0;
    }

    public LoopCount(Integer max) {
      this.max = max;
      this.count = 0;
    }

    public Boolean increment() {
      this.count++;
      return this.exceeded();
    }

    public Boolean exceeded() {
      if(this.max < 0) return false;
      if(this.count > this.max) {
        return true;
      }
      return false;
    }

    public Integer getMax() {
      return this.max;
    }

    public Integer getCount() {
      return this.count;
    }

    public void setMax(Integer max) {
      this.max = max;
    }
  }

  // possible trigger contexts
  @TestVisible
  private enum TriggerContext {
    BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
    AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
    AFTER_UNDELETE
  }

  @TestVisible
  private static boolean run = true;
  public static boolean runOnce(){
    if(run){
     run=false;
     return true;
    }else{
        return run;
    }
  }

  // exception class
  public class TriggerHandlerException extends Exception {}

}