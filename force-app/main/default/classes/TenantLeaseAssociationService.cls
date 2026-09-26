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

        List<Id> leaseIds = new List<Id>();

        // Get new Lease Ids
        for (Tenant_Lease_Association__c tla : newRecords) {
            if (tla.Lease__c != null && tla.Tenant__c != null) {
                leaseIds.add(tla.Lease__c);
            }
        }

        // Also get old Lease Ids in case a TLA was moved to another Lease
        if (oldRecords != null) {
            for (Tenant_Lease_Association__c tla : oldRecords) {
                if (tla.Lease__c != null) {
                    leaseIds.add(tla.Lease__c);
                }
            }
        }

        // New versions of records
        Map<Id, Tenant_Lease_Association__c> newTlasById =
            new Map<Id, Tenant_Lease_Association__c>();

        for (Tenant_Lease_Association__c tla : newRecords) {
            if (tla.Id != null) {
                newTlasById.put(tla.Id, tla);
            }
        }

        // Old versions of records
        Map<Id, Tenant_Lease_Association__c> oldTlasById =
            new Map<Id, Tenant_Lease_Association__c>();

        if (oldRecords != null) {
            for (Tenant_Lease_Association__c tla : oldRecords) {
                oldTlasById.put(tla.Id, tla);
            }
        }

        List<Tenant_Lease_Association__c> existingTlas = TenantLeaseAssociationSelector.getTenantLeaseAssocByLeaseId(leaseIds);

        Map<Id, List<Tenant_Lease_Association__c>> tlasByLeaseId = groupTlasByLease(existingTlas);


        // Make sure newly added/moved TLAs are represented
        for (Tenant_Lease_Association__c tla : newRecords) {

            if (tla.Lease__c == null) {
                continue;
            }

            if (!tlasByLeaseId.containsKey(tla.Lease__c)) {
                tlasByLeaseId.put(
                    tla.Lease__c,
                    new List<Tenant_Lease_Association__c>()
                );
            }

            Boolean alreadyExists = false;

            for (
                Tenant_Lease_Association__c existingTla :
                tlasByLeaseId.get(tla.Lease__c)
            ) {
                if (existingTla.Id == tla.Id) {
                    alreadyExists = true;
                    break;
                }
            }

            if (!alreadyExists) {
                tlasByLeaseId.get(tla.Lease__c).add(tla);
            }
        }


        // Check each Lease
        for (Id leaseId : tlasByLeaseId.keySet()) {

            Boolean hasPrimaryTenant = false;

            for (
                Tenant_Lease_Association__c tla :
                tlasByLeaseId.get(leaseId)
            ) {

                Tenant_Lease_Association__c tlaToCheck = tla;

                // If this TLA is being updated, use its NEW version
                if (
                    tla.Id != null &&
                    newTlasById.containsKey(tla.Id)
                ) {

                    tlaToCheck = newTlasById.get(tla.Id);

                    // If the TLA was moved to another Lease,
                    // don't count it toward this old Lease
                    if (tlaToCheck.Lease__c != leaseId) {
                        continue;
                    }
                }

                if (tlaToCheck.Is_Primary_Tenant__c) {
                    hasPrimaryTenant = true;
                    break;
                }
            }


            if (!hasPrimaryTenant) {

                for (Tenant_Lease_Association__c tla : newRecords) {

                    Boolean affectsThisLease =
                        tla.Lease__c == leaseId;

                    // Also check whether it USED TO belong to this Lease
                    if (
                        !affectsThisLease &&
                        tla.Id != null &&
                        oldTlasById.containsKey(tla.Id)
                    ) {
                        affectsThisLease =
                            oldTlasById.get(tla.Id).Lease__c == leaseId;
                    }

                    if (affectsThisLease) {
                        tla.addError(
                            'A lease must have a primary tenant.'
                        );
                    }
                }
            }
        }
    }


    private static Map<Id, List<Tenant_Lease_Association__c>> groupTlasByLease(List<Tenant_Lease_Association__c> tlas){

        Map<Id, List<Tenant_Lease_Association__c>> tlasByLeaseId = new Map<Id, List<Tenant_Lease_Association__c>>();

        for (Tenant_Lease_Association__c tla : tlas) {
            if (!tlasByLeaseId.containsKey(tla.lease__c)) {
                tlasByLeaseId.put(tla.lease__c, new List<Tenant_Lease_Association__c>());
            }

            tlasByLeaseId.get(tla.lease__c).add(tla);
        }

        return tlasByLeaseId;
    }
    
    /**
     * Description: synchronize the primary tenant in the tenant lease association as only one primary 
     * tenant should be present
     * @param newRecords the new records being changed
     */
    public static void synchronizePrimaryTenant(List<Tenant_Lease_Association__c> newRecords){

        

    }

}