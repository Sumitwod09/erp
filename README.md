# ERP Desktop Application

A comprehensive ERP solution built with Flutter and Nhost.

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Git](https://git-scm.com/)

## Getting Started

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/Sumitwod09/erp.git
    cd erp
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Configuration:**

    Create a `.env` file in the root directory by copying `.env.example`:

    ```bash
    cp .env.example .env
    ```

    Open `.env` and configure your Nhost project details:

    ```env
    NHOST_SUBDOMAIN=your_subdomain
    NHOST_REGION=your_region
    ```

4.  **Setup Database (Nhost)**:
    -   Create a new project on [Nhost](https://nhost.io/).
    -   Go to the **Database** section in Nhost dashboard.
    -   Run the SQL scripts located in `database/migrations/` in order:
        -   `001_initial_schema.sql`
        -   `002_rbac_schema.sql`
        -   `003_create_test_users.sql` (Optional: for test data)
        -   `004_add_module_settings.sql`
        -   `005_create_inventory_table.sql`

## Running on Desktop

### Windows

Enable desktop support (if not already enabled):
```bash
flutter config --enable-windows-desktop
```

Run the application:
```bash
flutter run -d windows
```

### macOS

Enable desktop support:
```bash
flutter config --enable-macos-desktop
```

Run the application:
```bash
flutter run -d macos
```

### Linux

Enable desktop support:
```bash
flutter config --enable-linux-desktop
```

Run the application:
```bash
flutter run -d linux
```

## Features

- **Authentication**: Secure login and signup powered by Nhost.
- **Role-Based Access Control (RBAC)**: Manage user roles and permissions.
- **Module Management**: flexible module system (Inventory, Sales, Accounting, etc.) with customizable settings.
- **Desktop Optimized**: Responsive sidebar navigation and data tables.
