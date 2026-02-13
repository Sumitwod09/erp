# Test User Credentials & Setup

This document contains the test user credentials for each role in the RBAC system, utilizing the Nhost backend.

## 📋 Test User Accounts

| Role | Email | Password | Access Level |
|------|-------|----------|--------------|
| **Administrator** | `admin@test.com` | `password123` | Full access to all features |
| **Manager** | `manager@test.com` | `password123` | Most features, limited settings |
| **Accountant** | `accountant@test.com` | `password123` | Full accounting, read-only others |
| **Sales Rep** | `sales@test.com` | `password123` | Full sales/customers, read inventory |
| **Inventory Manager** | `inventory@test.com` | `password123` | Full inventory, read sales |
| **Warehouse** | `warehouse@test.com` | `password123` | Warehouse operations |

## 🔧 Setup Instructions (Automated)

We have implemented an automated **Data Seeder** tool built directly into the application to create these users and link them to a test business with active modules.

1.  **Run the Application**: Start the desktop app.
2.  **Go to Login Screen**.
3.  **Enter Admin Credentials** (Optional):
    *   If you have already created an admin account manually (e.g. `admin@test.com`), enter your email and password in the login fields.
    *   If not, leave the fields blank (the seeder will try to create/login as default admin).
4.  **Click "Seed Test Users"**:
    *   This button is located at the bottom of the Login form (in Debug mode).
5.  **Wait for Completion**:
    *   A notification will appear when seeding is complete.
    *   The tool will create the Business, Admin profile, and all other role-based users.
    *   It will also activate standard modules (Sales, Inventory, Accounting, etc.) for the business.

## ✅ Verification

After running the seeder:

1.  **Login** with any of the credentials above (e.g., `manager@test.com` / `password123`).
2.  **Check Sidebar**: You should see modules relevant to that role (e.g., Inventory, Sales).
3.  **Check Business Profile**: Go to Settings -> Business Profile to see the generated business details.
