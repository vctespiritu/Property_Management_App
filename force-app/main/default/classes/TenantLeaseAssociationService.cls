/**
 * Description: To handle Tenant_Lease_Association__c busienss logic
 * @author Victor Espiritu 
 */
public with sharing class TenantLeaseAssociationService {
    
    
    /**
     * Description: prevents a lease from having no primary tenant as a primary tenant per lease is required
     * @param newRecords the new records being triggered
     */
    public static void preventALeaseWithNoPrimaryTenant(List<Tenant_Lease_Association__c> newRecords){

        
        
    }
    
    /**
     * Description: synchronize the primary tenant in the tenant lease association as only one primary 
     * tenant should be present
     * @param newRecords the new records being changed
     */
    public static void synchronizePrimaryTenant(List<Tenant_Lease_Association__c> newRecords){

        

    }

}