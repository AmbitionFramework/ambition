-- This creates a username of "example" with a password of "example".
INSERT INTO publisher
 ( username, password_hash, display_name, date_created, date_modified )
VALUES 
 (
    'example',
    'c3499c2729730a7f807efb8676a92dcb6f8a3f8f',
    'Example User',
    now(),
    now()
 )
;

INSERT INTO entry
 ( publisher_id, date_created, date_modified, title, content )
VALUES
 (
    1,
    now(),
    now(),
    'Example Entry',
    'This is a test entry, it is wonderful.'
 )
;
