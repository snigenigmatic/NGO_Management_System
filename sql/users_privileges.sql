-- Create app users with varied privileges for rubric
-- NOTE: Adjust passwords before running. Run as a MySQL admin user.
-- Wildcard-host accounts (connects from any host)
CREATE USER IF NOT EXISTS 'ngo_app_admin' @'%' IDENTIFIED BY 'Admin#123';
CREATE USER IF NOT EXISTS 'ngo_app_editor' @'%' IDENTIFIED BY 'Editor#123';
CREATE USER IF NOT EXISTS 'ngo_app_viewer' @'%' IDENTIFIED BY 'Viewer#123';
-- Admin: full control on the project database
GRANT ALL PRIVILEGES ON ngo_management.* TO 'ngo_app_admin' @'%';
-- Editor: read/write and execute routines
GRANT SELECT,
    INSERT,
    UPDATE,
    DELETE,
    EXECUTE ON ngo_management.* TO 'ngo_app_editor' @'%';
-- Viewer: read-only on tables and views, and execute function
GRANT SELECT,
    EXECUTE ON ngo_management.* TO 'ngo_app_viewer' @'%';
-- Localhost-scoped accounts (recommended for single-PC dev)
CREATE USER IF NOT EXISTS 'ngo_app_admin' @'localhost' IDENTIFIED BY 'Admin#123';
CREATE USER IF NOT EXISTS 'ngo_app_editor' @'localhost' IDENTIFIED BY 'Editor#123';
CREATE USER IF NOT EXISTS 'ngo_app_viewer' @'localhost' IDENTIFIED BY 'Viewer#123';
GRANT ALL PRIVILEGES ON ngo_management.* TO 'ngo_app_admin' @'localhost';
GRANT SELECT,
    INSERT,
    UPDATE,
    DELETE,
    EXECUTE ON ngo_management.* TO 'ngo_app_editor' @'localhost';
GRANT SELECT,
    EXECUTE ON ngo_management.* TO 'ngo_app_viewer' @'localhost';
FLUSH PRIVILEGES;