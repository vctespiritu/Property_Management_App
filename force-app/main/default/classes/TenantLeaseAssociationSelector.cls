/**
 * Description: To handle Tenant_Lease_Association__c queries
 * @author Victor Espiritu 
 */
public with sharing class TenantLeaseAssociationSelector {


    /**
     * Description: gets all the Tenant Lease Associations of the passed in leaseIds
     * @param leaseIds the passed in lease ids to get all the tenant lease associations of it
     */
    public static List<Tenant_Lease_Association__c> getTenantLeaseAssocByLeaseId(List<Id> leaseIds){

        return [
                SELECT
                    Id,
                    Lease__c,
                    Tenant__c,
                    Is_Primary_Tenant__c,
                    Occupant_Type__c
                FROM
                    Tenant_Lease_Association__c
                WHERE
                    Lease__c IN : leaseIds
            ];

    }

}