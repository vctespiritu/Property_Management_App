/**
 * Description: To handle Tenant_Lease_Association__c busienss logic testing
 * @author Victor Espiritu 
 */
@IsTest(SeeAllData=false)
private class TenantLeaseAssociationServiceTest{

    @TestSetup
    static void makeData(){
        
        List<Account> testAccount = testUtils.CreateAccounts(1, 'Property Owner');

        insert testAccount;

        List<Property__c> property = testUtils.CreateProperties(1, testAccount[0]);

        insert property;

        List<Lease__c> lease = testUtils.CreateLeases(1, property[0]);

        insert lease;

        List<Tenant__c> tenant = testUtils.CreateTenants(1);

        insert tenant;
        
    }

    @IsTest
    static void testPreventALeaseWithNoPrimaryTenant(){

        Lease__c lease = [Select Id From Lease__c LIMIT 1];

        Tenant__c tenant = [Select Id From Tenant__c LIMIT 1];

        Tenant_Lease_Association__c tla = new Tenant_Lease_Association__c();
        tla.Lease__c = lease.Id;
        tla.Tenant__c = tenant.Id;
        tla.Occupant_Type__c = 'Tenant';

        Test.startTest();
        TenantLeaseAssociationService.preventALeaseWithNoPrimaryTenant(new List<Tenant_Lease_Association__c>{ tla }, null);
        Test.stopTest();

        Assert.isTrue(tla.hasErrors(), 'The TLA should have an error because the lease has not primary tenant.');
        Assert.areEqual('A lease must have a primary tenant.', tla.getErrors()[0].getMessage(), 'Error message should match.');

    }

    @IsTest
    static void testNewPrimaryTenantHasNoError(){

        Lease__c lease = [Select Id From Lease__c LIMIT 1];

        Tenant__c tenant = [Select Id From Tenant__c LIMIT 1];

        Tenant_Lease_Association__c tla = new Tenant_Lease_Association__c();
        tla.Lease__c = lease.Id;
        tla.Tenant__c = tenant.Id;
        tla.Occupant_Type__c = 'Tenant';
        tla.Is_Primary_Tenant__c = true;

        Test.startTest();
        TenantLeaseAssociationService.preventALeaseWithNoPrimaryTenant(new List<Tenant_Lease_Association__c>{ tla }, null);
        Test.stopTest();

        Assert.isFalse(tla.hasErrors(), 'The TLA should NOT have an error because the lease has a primary tenant.');

    }

    @IsTest
    static void testLeaseWithExistingPrimaryTenant(){

        Lease__c lease = [Select Id From Lease__c LIMIT 1];

        Tenant__c tenant = [Select Id From Tenant__c LIMIT 1];

        Tenant_Lease_Association__c tla = new Tenant_Lease_Association__c(
            Lease__c = lease.Id,
            Tenant__c = tenant.Id,
            Occupant_Type__c = 'Tenant',
            Is_Primary_Tenant__c = true
        );

        insert tla;

        Tenant_Lease_Association__c tla2 = new Tenant_Lease_Association__c(
            Lease__c = lease.Id,
            Tenant__c = tenant.Id,
            Occupant_Type__c = 'Co-Tenant',
            Is_Primary_Tenant__c = false
        );

        Test.startTest();
        TenantLeaseAssociationService.preventALeaseWithNoPrimaryTenant(new List<Tenant_Lease_Association__c>{ tla2 }, null);
        Test.stopTest();

        Assert.isFalse(tla2.hasErrors(), 'The TLA should NOT have an error because the lease has a primary tenant.');

    }

    @IsTest
    static void testUpdatingToNonPrimaryTenant(){
        
        Lease__c lease = [Select Id From Lease__c LIMIT 1];

        Tenant__c tenant = [Select Id From Tenant__c LIMIT 1];

        Tenant_Lease_Association__c tla = new Tenant_Lease_Association__c(
            Lease__c = lease.Id,
            Tenant__c = tenant.Id,
            Occupant_Type__c = 'Tenant',
            Is_Primary_Tenant__c = true
        );

        insert tla;

        Tenant_Lease_Association__c oldTla = tla.clone(true);
        
        tla.Is_Primary_Tenant__c = false;

        Test.startTest();

        TenantLeaseAssociationService.preventALeaseWithNoPrimaryTenant(new List<Tenant_Lease_Association__c>{ tla }, new List<Tenant_Lease_Association__c>{ oldTla });

        Test.stopTest();

        Assert.isTrue(tla.hasErrors(), 'The TLA should have an error as a lease should not be without a primary tenant.');

    }

    // Temporary setup until primary handoff / single-primary enforcement is implemented.
    // This test only validates that removing one primary does not error
    // when another primary already exists.
    @IsTest
    static void testLeaseWith2PrimariesUpdate1ToFalse(){

        Lease__c lease = [Select Id From Lease__c LIMIT 1];

        Tenant__c tenant = [Select Id From Tenant__c LIMIT 1];

        List<Tenant__c> tenant2 = testUtils.CreateTenants(1);

        insert tenant2;

        Tenant_Lease_Association__c tla = new Tenant_Lease_Association__c();
        tla.Lease__c = lease.Id;
        tla.Tenant__c = tenant.Id;
        tla.Occupant_Type__c = 'Tenant';
        tla.Is_Primary_Tenant__c = true;

        insert tla;

        Tenant_Lease_Association__c tla2 = new Tenant_Lease_Association__c();
        tla2.Lease__c = lease.Id;
        tla2.Tenant__c = tenant2[0].Id;
        tla2.Occupant_Type__c = 'Tenant';
        tla2.Is_Primary_Tenant__c = true;

        insert tla2;

        Tenant_Lease_Association__c oldTla = tla.clone(true);

        tla.Is_Primary_Tenant__c = false;

        Test.startTest();
        TenantLeaseAssociationService.preventALeaseWithNoPrimaryTenant(new List<Tenant_Lease_Association__c>{ tla }, new List<Tenant_Lease_Association__c>{ oldTla });
        Test.stopTest();

        Assert.isFalse(tla.hasErrors(), 'The TLA should not have an error because the lease has primary tenant.');

    }

}