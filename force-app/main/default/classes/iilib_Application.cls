public with sharing class iilib_Application {

    public class ServiceFactory {
        private Map<Type, Type> m_servicesConfigMap;
        public ServiceFactory(Map<Type, Type> servicesConfigMap) {
            m_servicesConfigMap = servicesConfigMap;
        }
        public Object newInstance(Type apexClass){
            if(!m_servicesConfigMap.containsKey(apexClass)){
                throw new DeveloperException('Must config HandlerFactory for ' + apexClass.getName() + ' before using' );
            }
            return m_servicesConfigMap.get(apexClass).newInstance();
        }
    }
    /*
    public LoggerFactory{
        private Map<Type, Boolean> m_loggerConfigMap;
        public LoggerFactory(Map<Type, Type> loggerConfigMap) {
            m_loggerConfigMap = loggerConfigMap;
        }
         public Boolean newInstance(Type classType){
            if(!m_loggerConfigMap.containsKey(classType)){
               return true;
            }
            return (Boolean)m_loggerConfigMap.get(classType);
        }
    }    
    */
    
    public class DeveloperException extends Exception { } 
}