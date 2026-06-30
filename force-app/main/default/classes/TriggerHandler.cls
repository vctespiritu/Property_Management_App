public interface TriggerHandler {
    
    void beforeInsert(List<SObject> newRecords);
    void beforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap);
    void beforeDelete(List<SObject> oldRecords, Map<Id, SObject> oldMap);
    void afterInsert(List<SObject> newRecords);
    void afterUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap);
    void afterDelete(List<SObject> oldRecords, Map<Id, SObject> oldMap);
    void afterUndelete(List<SObject> newRecords);

}