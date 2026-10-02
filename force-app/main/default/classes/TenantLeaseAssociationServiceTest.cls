/**
 * Description: Integration tests for Tenant_Lease_Association__c business logic.
 * Tests use DML so the full Trigger -> Dispatcher -> Handler -> Service -> Selector
 * execution path is validated.
 * @author Victor Espiritu
 */
@IsTest(SeeAllData=false)
private class TenantLeaseAssociationServiceTest {

    private static final String PRIMARY_TENANT_ERROR = 'A lease must have a primary tenant.';
    private static final Integer BULK_SIZE = 200;

    @TestSetup
    static void makeData() {

        List<Account> testAccounts = testUtils.CreateAccounts(1, 'Property Owner');
        insert testAccounts;

        List<Property__c> properties = testUtils.CreateProperties(1, testAccounts[0]);
        insert properties;

        List<Lease__c> leases = testUtils.CreateLeases(1, properties[0]);
        insert leases;

        List<Tenant__c> tenants = testUtils.CreateTenants(1);
        insert tenants;
    }

    @IsTest
    static void testInsertWithoutPrimaryFailsThroughTrigger() {

        Lease__c lease = [SELECT Id FROM Lease__c LIMIT 1];
        Tenant__c tenant = [SELECT Id FROM Tenant__c LIMIT 1];

        Tenant_Lease_Association__c tla = new Tenant_Lease_Association__c(
            Lease__c = lease.Id,
            Tenant__c = tenant.Id,
            Occupant_Type__c = 'Tenant',
            Is_Primary_Tenant__c = false
        );

        DmlException thrownException;

        Test.startTest();
        try {
            insert tla;
        } catch (DmlException e) {
            thrownException = e;
        }
        Test.stopTest();

        Assert.isTrue(
            thrownException != null,
            'Insert should fail when a lease would have no primary tenant.'
        );
        Assert.isTrue(
            thrownException.getDmlMessage(0).contains(PRIMARY_TENANT_ERROR),
            'The DML error should contain the primary tenant validation message.'
        );

        Integer associationCount = [
            SELECT COUNT()
            FROM Tenant_Lease_Association__c
            WHERE Lease__c = :lease.Id
        ];

        Assert.areEqual(
            0,
            associationCount,
            'The invalid Tenant Lease Association should not be inserted.'
        );
    }

    @IsTest
    static void testInsertPrimarySucceedsThroughTrigger() {

        Lease__c lease = [SELECT Id FROM Lease__c LIMIT 1];
        Tenant__c tenant = [SELECT Id FROM Tenant__c LIMIT 1];

        Tenant_Lease_Association__c tla = new Tenant_Lease_Association__c(
            Lease__c = lease.Id,
            Tenant__c = tenant.Id,
            Occupant_Type__c = 'Tenant',
            Is_Primary_Tenant__c = true
        );

        Test.startTest();
        insert tla;
        Test.stopTest();

        Tenant_Lease_Association__c insertedTla = [
            SELECT Id, Lease__c, Tenant__c, Is_Primary_Tenant__c
            FROM Tenant_Lease_Association__c
            WHERE Id = :tla.Id
        ];

        Assert.isTrue(
            insertedTla.Is_Primary_Tenant__c,
            'The association should be inserted as the primary tenant.'
        );

        Lease__c updatedLease = [
            SELECT Id, Primary_Tenant__c
            FROM Lease__c
            WHERE Id = :lease.Id
        ];

        Assert.areEqual(
            tenant.Id,
            updatedLease.Primary_Tenant__c,
            'The primary tenant Flow should synchronize the Lease primary tenant.'
        );
    }

    @IsTest
    static void testInsertNonPrimaryWhenLeaseHasPrimarySucceeds() {

        Lease__c lease = [SELECT Id FROM Lease__c LIMIT 1];
        Tenant__c primaryTenant = [SELECT Id FROM Tenant__c LIMIT 1];

        List<Tenant__c> additionalTenants = testUtils.CreateTenants(1);
        insert additionalTenants;

        Tenant_Lease_Association__c primaryTla = new Tenant_Lease_Association__c(
            Lease__c = lease.Id,
            Tenant__c = primaryTenant.Id,
            Occupant_Type__c = 'Tenant',
            Is_Primary_Tenant__c = true
        );
        insert primaryTla;

        Tenant_Lease_Association__c secondaryTla = new Tenant_Lease_Association__c(
            Lease__c = lease.Id,
            Tenant__c = additionalTenants[0].Id,
            Occupant_Type__c = 'Co-Tenant',
            Is_Primary_Tenant__c = false
        );

        Test.startTest();
        insert secondaryTla;
        Test.stopTest();

        Integer associationCount = [
            SELECT COUNT()
            FROM Tenant_Lease_Association__c
            WHERE Lease__c = :lease.Id
        ];

        Assert.areEqual(
            2,
            associationCount,
            'A non-primary tenant should be allowed when the lease already has a primary tenant.'
        );
    }

    @IsTest
    static void testRemovingOnlyPrimaryFailsThroughTrigger() {

        Lease__c lease = [SELECT Id FROM Lease__c LIMIT 1];
        Tenant__c tenant = [SELECT Id FROM Tenant__c LIMIT 1];

        Tenant_Lease_Association__c primaryTla = new Tenant_Lease_Association__c(
            Lease__c = lease.Id,
            Tenant__c = tenant.Id,
            Occupant_Type__c = 'Tenant',
            Is_Primary_Tenant__c = true
        );
        insert primaryTla;

        primaryTla.Is_Primary_Tenant__c = false;

        DmlException thrownException;

        Test.startTest();
        try {
            update primaryTla;
        } catch (DmlException e) {
            thrownException = e;
        }
        Test.stopTest();

        Assert.isTrue(
            thrownException != null,
            'Update should fail when removing the lease\'s only primary tenant.'
        );
        Assert.isTrue(
            thrownException.getDmlMessage(0).contains(PRIMARY_TENANT_ERROR),
            'The DML error should contain the primary tenant validation message.'
        );

        Tenant_Lease_Association__c persistedTla = [
            SELECT Is_Primary_Tenant__c
            FROM Tenant_Lease_Association__c
            WHERE Id = :primaryTla.Id
        ];

        Assert.isTrue(
            persistedTla.Is_Primary_Tenant__c,
            'The failed update should leave the persisted association as primary.'
        );
    }

    @IsTest
    static void testPrimaryHandoffSucceedsInSameTransaction() {

        Lease__c lease = [SELECT Id FROM Lease__c LIMIT 1];
        Tenant__c firstTenant = [SELECT Id FROM Tenant__c LIMIT 1];

        List<Tenant__c> additionalTenants = testUtils.CreateTenants(1);
        insert additionalTenants;

        Tenant_Lease_Association__c firstTla = new Tenant_Lease_Association__c(
            Lease__c = lease.Id,
            Tenant__c = firstTenant.Id,
            Occupant_Type__c = 'Tenant',
            Is_Primary_Tenant__c = true
        );
        insert firstTla;

        Tenant_Lease_Association__c secondTla = new Tenant_Lease_Association__c(
            Lease__c = lease.Id,
            Tenant__c = additionalTenants[0].Id,
            Occupant_Type__c = 'Co-Tenant',
            Is_Primary_Tenant__c = false
        );
        insert secondTla;

        firstTla.Is_Primary_Tenant__c = false;
        secondTla.Is_Primary_Tenant__c = true;

        Test.startTest();
        update new List<Tenant_Lease_Association__c>{ firstTla, secondTla };
        Test.stopTest();

        Map<Id, Tenant_Lease_Association__c> associationsById =
            new Map<Id, Tenant_Lease_Association__c>([
                SELECT Id, Tenant__c, Is_Primary_Tenant__c
                FROM Tenant_Lease_Association__c
                WHERE Id IN :new Set<Id>{ firstTla.Id, secondTla.Id }
            ]);

        Assert.isFalse(
            associationsById.get(firstTla.Id).Is_Primary_Tenant__c,
            'The original primary tenant should no longer be primary.'
        );
        Assert.isTrue(
            associationsById.get(secondTla.Id).Is_Primary_Tenant__c,
            'The new primary tenant should be saved successfully.'
        );

        Lease__c updatedLease = [
            SELECT Primary_Tenant__c
            FROM Lease__c
            WHERE Id = :lease.Id
        ];

        Assert.areEqual(
            additionalTenants[0].Id,
            updatedLease.Primary_Tenant__c,
            'The Lease should point to the new primary tenant after the handoff.'
        );
    }

    @IsTest
    static void testBulkInsert200PrimaryAssociationsSucceeds() {

        Property__c property = [SELECT Id FROM Property__c LIMIT 1];

        List<Lease__c> leases = testUtils.CreateLeases(BULK_SIZE, property);
        insert leases;

        List<Tenant__c> tenants = testUtils.CreateTenants(BULK_SIZE);
        insert tenants;

        List<Tenant_Lease_Association__c> associations =
            new List<Tenant_Lease_Association__c>();

        for (Integer i = 0; i < BULK_SIZE; i++) {
            associations.add(
                new Tenant_Lease_Association__c(
                    Lease__c = leases[i].Id,
                    Tenant__c = tenants[i].Id,
                    Occupant_Type__c = 'Tenant',
                    Is_Primary_Tenant__c = true
                )
            );
        }

        Test.startTest();
        insert associations;
        Test.stopTest();

        Set<Id> leaseIds = new Map<Id, Lease__c>(leases).keySet();

        Integer associationCount = [
            SELECT COUNT()
            FROM Tenant_Lease_Association__c
            WHERE Lease__c IN :leaseIds
        ];

        Assert.areEqual(
            BULK_SIZE,
            associationCount,
            'All 200 valid primary tenant associations should be inserted in one transaction.'
        );

        Integer leasesWithPrimaryTenant = [
            SELECT COUNT()
            FROM Lease__c
            WHERE Id IN :leaseIds
            AND Primary_Tenant__c != null
        ];

        Assert.areEqual(
            BULK_SIZE,
            leasesWithPrimaryTenant,
            'The primary tenant Flow should synchronize all leases in the bulk transaction.'
        );
    }

    @IsTest
    static void testBulkInsert200AssociationsWithoutPrimariesFails() {

        Property__c property = [SELECT Id FROM Property__c LIMIT 1];

        List<Lease__c> leases = testUtils.CreateLeases(BULK_SIZE, property);
        insert leases;

        List<Tenant__c> tenants = testUtils.CreateTenants(BULK_SIZE);
        insert tenants;

        List<Tenant_Lease_Association__c> associations =
            new List<Tenant_Lease_Association__c>();

        for (Integer i = 0; i < BULK_SIZE; i++) {
            associations.add(
                new Tenant_Lease_Association__c(
                    Lease__c = leases[i].Id,
                    Tenant__c = tenants[i].Id,
                    Occupant_Type__c = 'Tenant',
                    Is_Primary_Tenant__c = false
                )
            );
        }

        DmlException thrownException;

        Test.startTest();
        try {
            insert associations;
        } catch (DmlException e) {
            thrownException = e;
        }
        Test.stopTest();

        Assert.isTrue(
            thrownException != null,
            'Bulk insert should fail when the leases would have no primary tenants.'
        );
        Assert.isTrue(
            thrownException.getDmlMessage(0).contains(PRIMARY_TENANT_ERROR),
            'The bulk DML error should contain the primary tenant validation message.'
        );

        Set<Id> leaseIds = new Map<Id, Lease__c>(leases).keySet();

        Integer associationCount = [
            SELECT COUNT()
            FROM Tenant_Lease_Association__c
            WHERE Lease__c IN :leaseIds
        ];

        Assert.areEqual(
            0,
            associationCount,
            'The failed all-or-none bulk insert should not persist any associations.'
        );
    }

    @IsTest
    static void testBulkUpdateRemoving200PrimariesFails() {

        Property__c property = [SELECT Id FROM Property__c LIMIT 1];

        List<Lease__c> leases = testUtils.CreateLeases(BULK_SIZE, property);
        insert leases;

        List<Tenant__c> tenants = testUtils.CreateTenants(BULK_SIZE);
        insert tenants;

        List<Tenant_Lease_Association__c> associations =
            new List<Tenant_Lease_Association__c>();

        for (Integer i = 0; i < BULK_SIZE; i++) {
            associations.add(
                new Tenant_Lease_Association__c(
                    Lease__c = leases[i].Id,
                    Tenant__c = tenants[i].Id,
                    Occupant_Type__c = 'Tenant',
                    Is_Primary_Tenant__c = true
                )
            );
        }

        insert associations;

        for (Tenant_Lease_Association__c association : associations) {
            association.Is_Primary_Tenant__c = false;
        }

        DmlException thrownException;

        Test.startTest();
        try {
            update associations;
        } catch (DmlException e) {
            thrownException = e;
        }
        Test.stopTest();

        Assert.isTrue(
            thrownException != null,
            'Bulk update should fail when removing every lease\'s only primary tenant.'
        );
        Assert.isTrue(
            thrownException.getDmlMessage(0).contains(PRIMARY_TENANT_ERROR),
            'The bulk update error should contain the primary tenant validation message.'
        );

        Set<Id> associationIds =
            new Map<Id, Tenant_Lease_Association__c>(associations).keySet();

        Integer persistedPrimaryCount = [
            SELECT COUNT()
            FROM Tenant_Lease_Association__c
            WHERE Id IN :associationIds
            AND Is_Primary_Tenant__c = true
        ];

        Assert.areEqual(
            BULK_SIZE,
            persistedPrimaryCount,
            'The failed all-or-none update should leave all persisted associations as primary.'
        );
    }
}
