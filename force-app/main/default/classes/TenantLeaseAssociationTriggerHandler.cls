/**
 * Description: Trigger handler for the Tenant_Lease_Association__c object
 * @author Victor Espiritu
 */
public with sharing class TenantLeaseAssociationTriggerHandler implements TriggerHandler {

    /**
     * Description: Handles before insert events
     * @param newRecords the new records that caused the before insert event
     */
    public void beforeInsert(List<SObject> newRecords){
        TenantLeaseAssociationService.synchronizePrimaryTenant(newRecords);
    }

    /**
     * Description: Handles before updates events
     * @param newRecords the new records that caused the before update event
     * @param oldRecords the record/s in their previous state
     */
    public void beforeUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords){
        TenantLeaseAssociationService.synchronizePrimaryTenant(newRecords.values());
    }

    /**
     * Description: Handles before delete events
     * @param oldRecords the record/s in their previous state
     */
    public void beforeDelete(Map<Id, SObject> oldRecords){}

    /**
     * Description: Handles after insert events
     * @param newRecords the new records that caused the after insert event
     */
    public void afterInsert(Map<Id, SObject> newRecords){}

    /**
     * Description: Handles after update events
     * @param newRecords the new records that caused the after update event
     * @param oldRecords the record/s in their previous state
     */
    public void afterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords){}

    /**
     * Description: Handles after delete events
     * @param oldRecords the old records that caused the after delete event
     * @param oldRecords the record/s in their previous state
     */
    public void afterDelete(Map<Id, SObject> oldRecords){}

    /**
     * Description: Handles after undelete events
     * @param newRecords the new records that caused the after undelete event
     */
    public void afterUndelete(Map<Id, SObject> newRecords){}
    
}