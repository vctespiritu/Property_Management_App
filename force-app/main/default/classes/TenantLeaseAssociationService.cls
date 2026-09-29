/**
 * Description: To handle Tenant_Lease_Association__c busienss logic
 * @author Victor Espiritu 
 */
public with sharing class TenantLeaseAssociationService {
    
    
    /**
     * Description: prevents a lease from having no primary tenant as a primary tenant per lease is required
     * @param newRecords the new records being triggered
     * @param oldRecords the previous versions of the records being triggered
     */
    public static void preventALeaseWithNoPrimaryTenant(List<Tenant_Lease_Association__c> newRecords, List<Tenant_Lease_Association__c> oldRecords) {

        Set<Id> leaseIds = new Set<Id>();

        for (Tenant_Lease_Association__c tla : newRecords) {
            if (tla.Lease__c != null) {
                leaseIds.add(tla.Lease__c);
            }
        }

        if (leaseIds.isEmpty()) {
            return;
        }

        Map<Id, Integer> primaryCountByLeaseId = new Map<Id, Integer>();

        for (Id leaseId : leaseIds) {
            primaryCountByLeaseId.put(leaseId, 0);
        }

        List<Tenant_Lease_Association__c> existingTlas = TenantLeaseAssociationSelector.getTenantLeaseAssocByLeaseId(new List<Id>(leaseIds));

        for (Tenant_Lease_Association__c tla : existingTlas) {

            if (tla.Is_Primary_Tenant__c) {
                primaryCountByLeaseId.put(tla.Lease__c, primaryCountByLeaseId.get(tla.Lease__c) + 1);
            }
        }

        if (oldRecords == null) {

            for (Tenant_Lease_Association__c tla : newRecords) {

                if (tla.Lease__c != null && tla.Is_Primary_Tenant__c) {
                    primaryCountByLeaseId.put(tla.Lease__c, primaryCountByLeaseId.get(tla.Lease__c) + 1);
                }

            }
        } else {

            Map<Id, Tenant_Lease_Association__c> oldRecordsById = new Map<Id, Tenant_Lease_Association__c>(oldRecords);

            for (Tenant_Lease_Association__c newTla : newRecords) {

                Tenant_Lease_Association__c oldTla = oldRecordsById.get(newTla.Id);

                if (oldTla == null) {
                    continue;
                }

                if (oldTla.Is_Primary_Tenant__c && !newTla.Is_Primary_Tenant__c) {

                    primaryCountByLeaseId.put(newTla.Lease__c, primaryCountByLeaseId.get(newTla.Lease__c) - 1);

                } else if (!oldTla.Is_Primary_Tenant__c && newTla.Is_Primary_Tenant__c) {

                    primaryCountByLeaseId.put(
                        newTla.Lease__c,
                        primaryCountByLeaseId.get(newTla.Lease__c) + 1
                    );

                }
            }
        }

        // Validate final state
        for (Tenant_Lease_Association__c tla : newRecords) {

            if (tla.Lease__c != null && primaryCountByLeaseId.get(tla.Lease__c) == 0) {
                tla.addError('A lease must have a primary tenant.');
            }
            
        }
    }
    
    /**
     * Description: synchronize the primary tenant in the tenant lease association as only one primary 
     * tenant should be present
     * @param newRecords the new records being changed
     */
    public static void synchronizePrimaryTenant(List<Tenant_Lease_Association__c> newRecords){

        

    }

}