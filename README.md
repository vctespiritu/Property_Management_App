# Property Management App

A Salesforce-based property management application designed to manage properties, leases, tenants, tenant relationships, maintenance activity, and the business rules that connect them.

This project is being built as a full Salesforce application rather than as a collection of isolated development exercises. The goal is to model a realistic property-management business and use the project to explore scalable Salesforce architecture, Apex development, Lightning Web Components, automation, security, testing, and deployment practices.

---

## Project Vision

The long-term vision for this project is to create a centralized property-management platform where property managers can manage the complete lifecycle of a rental property from Salesforce.

The application is intended to eventually support workflows such as:

- Managing properties and property owners
- Creating and managing leases
- Managing tenants and occupants
- Tracking tenant history across multiple leases
- Enforcing lease and tenant business rules
- Managing maintenance requests
- Tracking vendors and contractors
- Automating lease lifecycle events
- Providing property managers with dashboards and operational visibility
- Supporting role-based access for different types of users
- Providing reusable Lightning Web Components for common property-management workflows

The project is intentionally being developed incrementally, with each feature treated as a real software requirement that includes business rules, acceptance criteria, implementation, and testing.

---

## Current Application Model

The core application currently revolves around four primary records:

### Property

Represents a physical rental property being managed.

A property can have leases associated with it and will eventually serve as the central record for additional functionality such as maintenance activity, ownership information, financial information, and property-level reporting.

---

### Lease

Represents a rental agreement for a property.

Lease information includes fields such as:

- Lease status
- Start date
- End date
- Monthly rent
- Security deposit
- Rent due day
- Signed date
- Auto-renewal indicator
- Renewal notice information
- Special terms
- Lease term

A lease belongs to a Property and can contain multiple tenants through the Tenant Lease Association object.

---

### Tenant

Represents an individual tenant.

Tenant information includes:

- First name
- Last name
- Full name
- Email
- Phone
- Date of birth
- Tenant status
- Emergency contact information
- Notes

Tenant records are intentionally separate from leases so that the same person can retain a rental history across multiple leases over time.

---

### Tenant Lease Association

`Tenant_Lease_Association__c`

This junction object creates the many-to-many relationship between tenants and leases.

Instead of directly attaching a Tenant to a single Lease, the association object allows a tenant to participate in multiple leases while preserving lease-specific information.

Examples include:

- Whether the tenant is the Primary Tenant
- Occupant type
- Move-in date
- Move-out date
- Lease-specific notes

Conceptually:

```text
Property
   |
   └── Lease
         |
         └── Tenant Lease Association
                    |
                    └── Tenant
```

This data model allows tenant history to remain intact as tenants move between properties or participate in different leases.

---

## Business Rules

One of the goals of this project is to enforce business rules at the platform level rather than relying entirely on users to maintain correct data manually.

### Primary Tenant Requirement

Every active lease relationship is expected to maintain a Primary Tenant.

The application contains Apex logic designed to prevent a lease from being left without a primary tenant.

The implementation is designed with Salesforce transaction behavior in mind and accounts for scenarios such as:

- Updating an existing tenant association
- Changing which tenant is primary
- Moving a tenant association from one lease to another
- Processing multiple leases in the same transaction
- Bulk inserts and updates
- Comparing new and previous record state
- Evaluating existing database records before allowing a transaction to complete

The logic is intentionally separated from the trigger so that business rules remain reusable and easier to test.

---

## Apex Architecture

The project is being structured using separation of concerns rather than placing business logic directly inside Salesforce triggers.

The general pattern is:

```text
Trigger
   ↓
Service Layer
   ↓
Selector / Data Access Layer
   ↓
Salesforce Database
```

### Trigger Layer

Triggers remain lightweight and are responsible primarily for detecting Salesforce trigger events and passing records to the appropriate application logic.

### Service Layer

Service classes contain the application's business rules.

Examples include validating tenant/lease relationships and enforcing rules surrounding primary tenants.

### Selector Layer

Selector classes centralize SOQL queries and database retrieval logic.

This helps:

- Reduce duplicated SOQL
- Keep business logic easier to read
- Improve testability
- Make governor-limit behavior easier to reason about
- Support bulk processing

The architecture will continue evolving as additional functionality is added.

---

## Bulkification

A major development goal for the project is ensuring Apex logic works correctly for both individual records and bulk transactions.

Salesforce can process as many as hundreds of records within the same transaction, so business logic is being designed to:

- Avoid SOQL inside loops
- Avoid DML inside loops
- Use Sets and Maps for record lookup
- Query related records in bulk
- Process multiple leases independently within the same transaction
- Remain within Salesforce governor limits

Bulk behavior is also considered when designing unit tests.

---

## Lightning Web Components

Lightning Web Components are being added to provide more useful user experiences than standard record pages alone.

Planned and in-progress components include functionality such as:

### Tenant Lease History

A component that allows a user to view the leases associated with a tenant.

The goal is to give property managers an immediate view of a tenant's rental history without navigating through multiple related lists.

The component is intended to display information such as:

- Property
- Lease status
- Lease dates
- Tenant role
- Primary tenant status
- Move-in and move-out dates

---

### Maintenance Request Experience

A custom interface for creating and managing maintenance requests.

The long-term goal is to allow users to quickly record maintenance issues while associating them with the appropriate property, tenant, lease, vendor, and status.

---

## Automation

The project uses Salesforce automation where it makes sense rather than automatically solving every requirement with Apex.

Examples include Salesforce Flow for record automation and Apex for rules requiring more complex transaction-level processing.

One example is tenant name population, where declarative automation can handle a relatively simple operation without requiring unnecessary custom code.

As the application grows, each requirement is evaluated to determine whether it is best implemented using:

- Formula fields
- Validation rules
- Flow
- Apex
- Lightning Web Components

The goal is to use the simplest Salesforce capability that can reliably meet the requirement while remaining maintainable.

---

## Account Roles

Accounts are being used to represent organizations and individuals involved in property operations.

Current or planned Account record types include:

- Property Owner
- Vendor
- Contractor
- HOA

This provides a foundation for expanding the application beyond tenant and lease management into broader property operations.

---

## Testing Strategy

Apex testing in this project focuses on validating business behavior rather than only reaching Salesforce's minimum code coverage requirement.

Tests are intended to cover scenarios such as:

### Positive Cases

Valid records should successfully complete transactions.

### Negative Cases

Invalid business states should be rejected.

### Bulk Cases

Business rules should continue working when multiple records and multiple leases are processed simultaneously.

### State Changes

Tests validate behavior when existing records are changed rather than testing only record creation.

Examples include:

- Changing the primary tenant
- Removing primary status
- Moving an association to another lease
- Updating multiple tenant relationships in one transaction

The goal is for the test suite to document expected application behavior in addition to protecting against regressions.

---

## Development Tooling

The project uses the Salesforce DX development model and source control through Git and GitHub.

Development tooling includes:

- Salesforce CLI
- Salesforce DX project structure
- Visual Studio Code
- Apex
- Lightning Web Components
- Salesforce Flow
- Jest
- ESLint
- Prettier
- Husky
- lint-staged
- Git
- GitHub

The repository includes tooling for formatting, linting, JavaScript testing, and development workflow consistency.

---

## Project Structure

The Salesforce application source is contained primarily under:

```text
force-app/
└── main/
    └── default/
        ├── classes/
        ├── triggers/
        ├── lwc/
        ├── objects/
        ├── flows/
        ├── permissionsets/
        └── other Salesforce metadata
```

As the project grows, application logic will continue to be separated by responsibility rather than consolidated into large classes or triggers.

---

## Development Principles

Several principles guide development of this project.

### Separation of Concerns

Triggers, business logic, data access, and user-interface logic should have clearly defined responsibilities.

### Bulk-Safe Apex

Apex should work correctly whether Salesforce processes one record or hundreds of records.

### Test Business Behavior

Tests should validate expected behavior, failure scenarios, bulk transactions, and edge cases.

### Declarative First — When Appropriate

Salesforce's declarative capabilities should be used when they provide the cleanest solution.

Apex is used when requirements require more complex transaction handling, reusable application logic, or capabilities that are difficult to maintain declaratively.

### Maintainability

Code should be understandable by another developer without requiring knowledge of how it was originally written.

### Realistic Requirements

Features are being built around realistic property-management workflows rather than around isolated examples designed only to demonstrate a Salesforce feature.

---

## Planned Features

The application is still actively being developed.

The roadmap includes functionality such as:

- Preventing overlapping leases for the same property
- Tenant lease-history components
- Maintenance request management
- Lease status automation
- Lease expiration and renewal workflows
- Property-manager permissions
- Role-based access
- Vendor and contractor management
- Maintenance assignment
- Property ownership relationships
- Property dashboards
- Lease dashboards
- Occupancy reporting
- Rent and lease analytics
- Notifications and reminders
- Additional Lightning Web Components
- Expanded Apex unit testing
- LWC Jest testing
- Automated deployment validation
- CI/CD workflows

Future iterations may also introduce additional architectural patterns where they add meaningful value to the application.

---

## Example Future Workflow

One of the long-term goals is to allow a property manager to perform an end-to-end workflow entirely inside Salesforce.

For example:

```text
Create Property
      ↓
Assign Property Owner
      ↓
Create Lease
      ↓
Add Tenants
      ↓
Assign Primary Tenant
      ↓
Activate Lease
      ↓
Track Occupancy
      ↓
Create Maintenance Requests
      ↓
Assign Vendor / Contractor
      ↓
Track Lease Expiration
      ↓
Renew or Close Lease
      ↓
Retain Tenant Rental History
```

The application should ultimately provide one connected system for managing that lifecycle.

---

## Screenshots

Application screenshots and demonstrations will be added as additional user-facing functionality is completed.

Planned examples include:

- Property record page
- Lease record page
- Tenant record page
- Tenant lease history
- Maintenance request interface
- Property-management dashboard

---

## Getting Started

### Prerequisites

To work with this project you should have:

- A Salesforce Developer Org or Scratch Org
- Salesforce CLI
- Git
- Node.js
- Visual Studio Code with Salesforce extensions

### Clone the Repository

```bash
git clone https://github.com/vctespiritu/Property_Management_App.git
cd Property_Management_App
```

### Authenticate to Salesforce

```bash
sf org login web
```

### Deploy the Project

```bash
sf project deploy start
```

Additional Salesforce configuration requirements are documented in:

```text
SETUP.md
```

---

## Running Tests

Apex tests can be executed using Salesforce CLI.

Example:

```bash
sf apex run test --test-level RunLocalTests --wait 20
```

LWC Jest tests can be executed with:

```bash
npm test
```

Additional commands are available in `package.json`.

---

## Project Status

🚧 **Active Development**

This project is intentionally being developed over time.

Features may be added, refactored, or redesigned as new requirements are introduced and as the architecture evolves.

GitHub Issues are used to document feature requirements, user stories, acceptance criteria, bugs, and planned improvements.

---

## Why I Built This Project

I built this project to create a realistic Salesforce application where I could design and implement an entire solution rather than demonstrate individual Salesforce features in isolation.

The project gives me a place to work through the same types of decisions that occur in enterprise Salesforce development:

- Translating business requirements into technical solutions
- Designing Salesforce data models
- Determining when to use Flow versus Apex
- Building bulk-safe Apex
- Designing reusable service and selector layers
- Creating Lightning Web Components
- Enforcing cross-record business rules
- Designing permissions and access
- Building meaningful automated tests
- Managing source through Git
- Iteratively improving application architecture

My long-term goal is to continue expanding the application while improving its architecture, testability, automation, security, and deployment process.

The project also serves as an evolving example of my approach to Salesforce development and solution design.

---

## Author

**Victor Espiritu**

Salesforce Developer focused on Apex, Lightning Web Components, automation, Salesforce data architecture, testing, and scalable application design.

GitHub: [@vctespiritu](https://github.com/vctespiritu)