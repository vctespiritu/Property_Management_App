# CocoNest — Salesforce Property Management App

CocoNest is a Salesforce-based property management application for managing properties, leases, tenants, and the business rules that connect them.

The project is being built as a realistic Salesforce application to demonstrate solution design, Apex development, Flow automation, data modeling, testing, security, deployment, and source-control practices.

> **Status:** Active development

---

## Overview

CocoNest is designed around the lifecycle of managing rental properties in Salesforce.

Current functionality focuses on:

- Property management
- Lease management
- Tenant management
- Tenant-to-lease relationships
- Primary tenant business rules
- Salesforce Flow automation
- Apex trigger architecture
- Permission-based application access
- Salesforce DX deployment

Future development will expand the application into maintenance management, lease automation, reporting, and custom Lightning Web Components.

---

## Data Model

The core application uses the following model:

```text
Property
   │
   └── Lease
         │
         └── Tenant Lease Association
                    │
                    └── Tenant
```

### Property

Represents a rental property and stores information such as:

- Property owner
- Property manager
- Address
- Property type
- Property status
- Number of units
- Bedrooms and bathrooms
- Square footage
- Rental income

### Lease

Represents a rental agreement associated with a property.

Lease information includes:

- Start and end dates
- Lease status
- Monthly rent
- Security deposit
- Rent due day
- Renewal information
- Primary tenant

### Tenant

Represents an individual tenant and stores:

- Name
- Contact information
- Status
- Date of birth
- Emergency contact information
- Notes

### Tenant Lease Association

`Tenant_Lease_Association__c` connects tenants to leases.

This allows a tenant to retain lease history across multiple rental agreements while also storing lease-specific information such as:

- Primary tenant status
- Occupant type
- Move-in date
- Move-out date
- Notes

---

## Current Business Logic

### Primary Tenant Requirement

A lease with tenant associations must maintain a primary tenant.

The current Apex implementation validates primary-tenant relationships during Tenant Lease Association insert and update operations.

The feature is being expanded to enforce the complete business rule across all relevant record operations.

---

## Apex Architecture

The project uses separation of concerns rather than placing business logic directly inside triggers.

```text
Trigger
   ↓
Trigger Dispatcher
   ↓
Trigger Handler
   ↓
Service Layer
   ↓
Selector Layer
   ↓
Salesforce Database
```

Current Apex components include:

- `TriggerHandler`
- `TriggerDispatcher`
- `TenantLeaseAssociationTriggerHandler`
- `TenantLeaseAssociationService`
- `TenantLeaseAssociationSelector`
- `TenantLeaseAssociationServiceTest`
- `testUtils`

The goal of this structure is to keep trigger logic lightweight, centralize business rules, and separate SOQL access from application logic.

---

## Bulkification

Apex logic is designed with Salesforce governor limits in mind.

Development principles include:

- No SOQL inside loops
- No unnecessary DML inside loops
- Using Sets and Maps for efficient record processing
- Querying related records in bulk
- Supporting multiple records and leases within the same transaction

Bulk test coverage will continue to expand as additional business rules are implemented.

---

## Salesforce Flow

CocoNest currently uses Flow for automation that does not require complex Apex transaction logic.

Implemented flows include:

### Populate Tenant Full Name

Automatically builds the tenant record name from tenant information.

### Update Primary Tenant on Lease

Updates the Lease's `Primary_Tenant__c` field based on the Tenant Lease Association marked as primary.

The project intentionally uses both Flow and Apex depending on the complexity of each requirement.

---

## Security and Access

The project includes the:

```text
CocoNest_Admin_User_Access
```

permission set.

It provides access to CocoNest application metadata including:

- Application visibility
- Custom objects
- Fields
- Tabs
- Account record types

This reduces the amount of manual Salesforce configuration required after deployment.

---

## Development Workflow

Development is managed using Git and GitHub.

The project uses:

```text
Issue / Requirement
       ↓
Feature Branch
       ↓
Development
       ↓
Pull Request
       ↓
Review
       ↓
Squash Merge
       ↓
main
```

GitHub Issues are used to document requirements and acceptance criteria, while Pull Requests preserve the development history for each feature.

---

## Development Tooling

The project currently uses:

- Salesforce CLI
- Salesforce DX
- Apex
- Salesforce Flow
- Git
- GitHub
- Visual Studio Code
- Prettier
- ESLint
- Husky
- lint-staged
- Jest tooling for future LWC testing

---

## Deployment

Full deployment instructions are available in:

[`DEPLOYMENT.md`](DEPLOYMENT.md)

Basic deployment flow:

```bash
# Authenticate
sf org login web --alias coconest-dev

# Deploy metadata
sf project deploy start --target-org coconest-dev

# Assign CocoNest administrator access
sf org assign permset \
    --name CocoNest_Admin_User_Access \
    --target-org coconest-dev
```

The permission set is assigned to the Salesforce user associated with the authenticated CLI connection for the specified org.

---

## Running Apex Tests

Run Salesforce Apex tests with:

```bash
sf apex run test \
    --test-level RunLocalTests \
    --wait 20
```

---

## Roadmap

Planned functionality includes:

- Complete enforcement of exactly one primary tenant per lease
- Primary tenant delete protection
- Additional bulk and integration testing
- Prevention of overlapping active leases
- Automated lease-status processing
- Maintenance Request management
- Property and lease dashboards
- Role-based Property Manager access
- Tenant Lease List LWC
- Property Lease Summary LWC
- Maintenance Request Quick Create LWC
- Jest tests for Lightning Web Components
- GitHub Actions CI
- Automated deployment validation

---

## Project Goals

CocoNest is intended to demonstrate how I approach real Salesforce application development, including:

- Translating business requirements into technical solutions
- Designing Salesforce data models
- Choosing between Flow and Apex
- Building bulk-safe Apex
- Separating trigger, service, and data-access responsibilities
- Writing automated tests
- Managing permissions through metadata
- Using Git feature branches and Pull Requests
- Building reproducible Salesforce deployments

The application will continue evolving as additional property-management workflows are implemented.

---

## Author

**Victor Espiritu**

Salesforce Developer focused on Apex, automation, Salesforce data architecture, testing, and scalable application design.

GitHub: [@vctespiritu](https://github.com/vctespiritu)