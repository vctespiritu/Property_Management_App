# Deployment

This document describes the steps required to deploy CocoNest and complete the required post-deployment setup.

## 1. Authenticate to the Salesforce Org

Before deploying the project, authenticate the Salesforce org you want to use.

Example:

```bash
sf org login web --alias coconest-dev
```

This opens Salesforce in your browser and connects the authenticated Salesforce user to the Salesforce CLI.

---

## 2. Deploy the Project

From the root directory of the project, deploy the Salesforce metadata:

```bash
sf project deploy start --target-org coconest-dev
```

Replace `coconest-dev` with the alias of the org you authenticated if you are using a different alias.

---

## 3. Assign the CocoNest Administrator Permission Set

After deployment, assign the CocoNest administrator permission set:

```bash
sf org assign permset \
    --name CocoNest_Admin_User_Access \
    --target-org coconest-dev
```

The permission set is assigned to the Salesforce user associated with the authenticated CLI connection for the specified org.

In other words, if you authenticated to Salesforce using:

```bash
sf org login web --alias coconest-dev
```

the user who logged in during that authentication process will receive the `CocoNest_Admin_User_Access` permission set when the command above is executed.

The permission set provides the access required to use and administer the CocoNest application, including access to the application's objects, fields, tabs, record types, and other configured permissions.

---

## Verify the Assignment

You can confirm the assignment in Salesforce by navigating to:

**Setup → Permission Sets → CocoNest Admin User Access → Manage Assignments**

The authenticated user should appear in the list of assigned users.

---

## Deployment Summary

The complete setup process is:

```bash
# Authenticate the Salesforce org
sf org login web --alias coconest-dev

# Deploy CocoNest metadata
sf project deploy start --target-org coconest-dev

# Assign CocoNest administrator permissions to the authenticated user
sf org assign permset \
    --name CocoNest_Admin_User_Access \
    --target-org coconest-dev
```

After these steps are completed, the authenticated Salesforce user should have the required access to use the CocoNest application.