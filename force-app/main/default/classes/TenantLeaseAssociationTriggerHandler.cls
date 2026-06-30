public with sharing class TenantLeaseAssociationTriggerHandler implements TriggerHandler {

    public void beforeInsert(List<SObject> newRecords){}
    public void beforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap){}
    public void beforeDelete(List<SObject> oldRecords, Map<Id, SObject> oldMap){}
    public void afterInsert(List<SObject> newRecords){}
    public void afterUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap){}
    public void afterDelete(List<SObject> oldRecords, Map<Id, SObject> oldMap){}
    public void afterUndelete(List<SObject> newRecords){}
    
}