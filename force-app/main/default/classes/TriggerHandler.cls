/**
 * Description: Trigger handler interface to establish all trigger event methods
 
 */
public interface TriggerHandler {
    
    /**
     * Description: Handles before insert events
     * @param newRecords the new records that caused the before insert event
     */
    void BeforeInsert(List<SObject> newRecords);

    /**
     * Description: Handles before updates events
     * @param newRecords the new records that caused the before update event
     * @param oldRecords the record/s in their previous state
     */
    void BeforeUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords);

    /**
     * Description: Handles before delete events
     * @param oldRecords the record/s in their previous state
     */
    void BeforeDelete(Map<Id, SObject> oldRecords);

    /**
     * Description: Handles after insert events
     * @param newRecords the new records that caused the after insert event
     */
    void AfterInsert(Map<Id, SObject> newRecords);

    /**
     * Description: Handles after update events
     * @param newRecords the new records that caused the after update event
     * @param oldRecords the record/s in their previous state
     */
    void AfterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords);

    /**
     * Description: Handles after delete events
     * @param oldRecords the record/s in their previous state
     */
    void AfterDelete(Map<Id, SObject> oldRecords);

    /**
     * Description: Handles after undelete events
     * @param newRecords the new records that caused the after undelete event
     */
    void AfterUndelete(Map<Id, SObject> newRecords);

}