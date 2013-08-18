CREATE TABLE comment (
    comment_id serial primary key,
    parent_comment_id integer,
    entry_id integer not null,
    publisher_id integer,
    is_visible integer default 1,
    date_created timestamp with time zone,
    comment_sha1 character(40),
    ip_address varchar(15),
    display_name varchar(255),
    email_address varchar(255),
    content text
) WITH OIDS;

CREATE INDEX comment_entry_id ON comment (entry_id);
CREATE INDEX comment_comment_sha1 ON comment (comment_sha1);

CREATE TABLE entry (
    entry_id serial primary key,
    publisher_id integer not null,
    date_created timestamp,
    date_modified timestamp,
    title varchar(255),
    content text
) WITH OIDS;

CREATE INDEX entry_publisher_id ON entry (publisher_id);

CREATE TABLE entry_tag (
    entry_id integer not null,
    tag_id integer not null,
    PRIMARY KEY (entry_id, tag_id)
);

CREATE TABLE publisher (
    publisher_id serial primary key,
    username varchar(64),
    password_hash char(40),
    display_name varchar(255),
    date_created timestamp,
    date_modified timestamp,
    date_login timestamp
) WITH OIDS;

CREATE INDEX publisher_username ON publisher (username);

CREATE TABLE session (
    session_id char(40) primary key,
    session_data text
);

CREATE TABLE tag (
    tag_id serial primary key,
    name varchar(64)
) WITH OIDS;

CREATE INDEX tag_name ON tag (name);
