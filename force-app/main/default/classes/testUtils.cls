/**
 * Description: TestUtils for Property Management app
 * @author Victor Espiritu 
 */
@IsTest
public class testUtils {

    public static List<Account> CreateAccounts(Integer accountsToCreate, String recordType){

        List<Account> accts = new List<Account>();
        Id accountPropertyOwnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                                                            .get(recordType).getRecordTypeId();

        for (Integer i = 0; i < accountsToCreate; i++) {
            accts.add(new Account(RecordTypeId = accountPropertyOwnerRecordTypeId,
                                    Name = 'Test Account ' + i));
        }

        return accts;

    }

    public static List<Property__c> CreateProperties(Integer propertiesToCreate, Account propertyOwner){

        List<Property__c> properties = new List<Property__c>();

        for (Integer i = 0; i < propertiesToCreate; i++) {
            properties.add(new Property__c(Property_Owner__c = propertyOwner.Id,
                                                Property_Status__c = 'Active',
                                                Street_Address__c = '123 Test St',
                                                City__c = 'Test',
                                                State__c = 'AL'));
        }

        return properties;

    }

    public static List<Lease__c> CreateLeases(Integer leasesToCreate, Property__c property){
        List<Lease__c> leases = new List<Lease__c>();

        for (Integer i = 0; i < leasesToCreate; i++) {
            leases.add(new Lease__c(Property__c = property.Id));
        }

        return leases;
    }

    public static List<Tenant__c> CreateTenants(Integer tenantsToCreate){
        List<Tenant__c> tenants = new List<Tenant__c>();

        for (Integer i = 0; i < tenantsToCreate; i++) {
            tenants.add(new Tenant__c(Last_Name__c = 'Test Tenant ' + i));
        }

        return tenants;
    }

}