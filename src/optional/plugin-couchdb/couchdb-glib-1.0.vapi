
[CCode (cprefix = "Couchdb", gir_namespace = "Couchdb", gir_version = "1.0", lower_case_cprefix = "couchdb_")]
namespace Couchdb {
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", type_id = "couchdb_array_field_get_type ()")]
	public class ArrayField : GLib.Object {
		[CCode (has_construct_function = false)]
		public ArrayField ();
		public void add_array_element (Couchdb.ArrayField value);
		public void add_boolean_element (bool value);
		public void add_double_element (double value);
		public void add_int_element (int value);
		public void add_string_element (string value);
		public void add_struct_element (Couchdb.StructField value);
		public bool get_boolean_element (uint index);
		public double get_double_element (uint index);
		public int get_int_element (uint index);
		public uint get_length ();
		public unowned string get_string_element (uint index);
		public void remove_element (uint index);
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", type_id = "couchdb_credentials_get_type ()")]
	public class Credentials : GLib.Object {
		[CCode (has_construct_function = false)]
		protected Credentials ();
		public Couchdb.CredentialsType get_auth_type ();
		public unowned string get_item (string item);
		public void set_item (string item, string value);
		[CCode (has_construct_function = false)]
		public Credentials.with_oauth (string consumer_key, string consumer_secret, string token_key, string token_secret);
		[CCode (has_construct_function = false)]
		public Credentials.with_username_and_password (string username, string password);
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", type_id = "couchdb_database_get_type ()")]
	public class Database : GLib.Object {
		[CCode (has_construct_function = false)]
		public Database (Couchdb.Session session, string dbname);
		public bool delete_document (Couchdb.Document document) throws GLib.Error;
		public unowned string get_name ();
		public void listen_for_changes ();
		public bool put_document (Couchdb.Document document) throws GLib.Error;
		public Couchdb.Document get_document (string docid) throws GLib.Error;
		public GLib.SList<Document> list_documents () throws GLib.Error;
		[NoAccessorMethod]
		public string database_name { owned get; set construct; }
		[NoAccessorMethod]
		public Couchdb.Session session { owned get; set construct; }
		public virtual signal void document_created (Couchdb.Document document);
		public virtual signal void document_deleted (string docid);
		public virtual signal void document_updated (Couchdb.Document document);
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "couchdb_database_info_get_type ()")]
	[Compact]
	public class DatabaseInfo {
		[CCode (has_construct_function = false)]
		public DatabaseInfo (string dbname, int doc_count, int doc_del_count, int update_seq, int purse_seq, bool compact_running, int disk_size, int disk_format_version, int instance_start_time);
		public unowned string get_dbname ();
		public int get_deleted_documents_count ();
		public int get_disk_format_version ();
		public int get_disk_size ();
		public int get_documents_count ();
		public int get_instance_start_time ();
		public int get_purge_sequence ();
		public int get_update_sequence ();
		public bool is_compact_running ();
		public Couchdb.DatabaseInfo @ref ();
		public void unref ();
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", type_id = "couchdb_design_document_get_type ()")]
	public class DesignDocument : Couchdb.Document {
		[CCode (has_construct_function = false)]
		public DesignDocument ();
		public void add_view (string name, string map_function, string reduce_function);
		public void delete_view (string name);
		public Couchdb.DesignDocumentLanguage get_language ();
		public void set_language (Couchdb.DesignDocumentLanguage language);
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", type_id = "couchdb_document_get_type ()")]
	public class Document : GLib.Object {
		[CCode (has_construct_function = false)]
		public Document ();
		public Couchdb.ArrayField get_array_field (string field);
		public bool get_boolean_field (string field);
		public double get_double_field (string field);
		public GLib.Type get_field_type (string field);
		public unowned string get_id ();
		public int get_int_field (string field);
		public unowned string get_record_type ();
		public unowned string get_revision ();
		public unowned string get_string_field (string field);
		public bool has_field (string field);
		public bool is_contact ();
		public bool is_task ();
		public void remove_field (string field);
		public void set_application_annotations (Couchdb.StructField annotations);
		public void set_array_field (string field, Couchdb.ArrayField value);
		public void set_boolean_field (string field, bool value);
		public void set_double_field (string field, double value);
		public void set_id (string id);
		public void set_int_field (string field, int value);
		public void set_record_type (string record_type);
		public void set_revision (string revision);
		public void set_string_field (string field, string value);
		public void set_struct_field (string field, Couchdb.StructField value);
		public string to_string ();
		[NoAccessorMethod]
		public Couchdb.Database database { owned get; set construct; }
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", type_id = "couchdb_document_contact_get_type ()")]
	public class DocumentContact : Couchdb.Document {
		[CCode (has_construct_function = false)]
		public DocumentContact ();
		public static unowned string address_get_city (Couchdb.StructField sf);
		public static unowned string address_get_country (Couchdb.StructField sf);
		public static unowned string address_get_description (Couchdb.StructField sf);
		public static unowned string address_get_ext_street (Couchdb.StructField sf);
		public static unowned string address_get_pobox (Couchdb.StructField sf);
		public static unowned string address_get_postalcode (Couchdb.StructField sf);
		public static unowned string address_get_state (Couchdb.StructField sf);
		public static unowned string address_get_street (Couchdb.StructField sf);
		[CCode (cname = "couchdb_document_contact_address_new", has_construct_function = false, type = "CouchdbStructField*")]
		public DocumentContact.address_new (string uuid, string street, string ext_street, string city, string state, string country, string postalcode, string pobox, string description);
		public static void address_set_city (Couchdb.StructField sf, string city);
		public static void address_set_country (Couchdb.StructField sf, string country);
		public static void address_set_description (Couchdb.StructField sf, string description);
		public static void address_set_ext_street (Couchdb.StructField sf, string ext_street);
		public static void address_set_pobox (Couchdb.StructField sf, string pobox);
		public static void address_set_postalcode (Couchdb.StructField sf, string postalcode);
		public static void address_set_state (Couchdb.StructField sf, string state);
		public static void address_set_street (Couchdb.StructField sf, string street);
		public static unowned string email_get_address (Couchdb.StructField sf);
		public static unowned string email_get_description (Couchdb.StructField sf);
		[CCode (cname = "couchdb_document_contact_email_new", has_construct_function = false, type = "CouchdbStructField*")]
		public DocumentContact.email_new (string uuid, string address, string description);
		public static void email_set_address (Couchdb.StructField sf, string email);
		public static void email_set_description (Couchdb.StructField sf, string description);
		public unowned string get_assistant_name ();
		public unowned string get_birth_date ();
		public unowned string get_categories ();
		public unowned string get_company ();
		public unowned string get_department ();
		public unowned string get_first_name ();
		public unowned string get_job_title ();
		public unowned string get_last_name ();
		public unowned string get_manager_name ();
		public unowned string get_middle_name ();
		public unowned string get_nick_name ();
		public unowned string get_notes ();
		public unowned string get_office ();
		public unowned string get_spouse_name ();
		public unowned string get_suffix ();
		public unowned string get_title ();
		public unowned string get_wedding_date ();
		public static unowned string im_get_address (Couchdb.StructField sf);
		public static unowned string im_get_description (Couchdb.StructField sf);
		public static unowned string im_get_protocol (Couchdb.StructField sf);
		[CCode (cname = "couchdb_document_contact_im_new", has_construct_function = false, type = "CouchdbStructField*")]
		public DocumentContact.im_new (string uuid, string address, string description, string protocol);
		public static void im_set_address (Couchdb.StructField sf, string address);
		public static void im_set_description (Couchdb.StructField sf, string description);
		public static void im_set_protocol (Couchdb.StructField sf, string protocol);
		public static unowned string phone_get_description (Couchdb.StructField sf);
		public static unowned string phone_get_number (Couchdb.StructField sf);
		public static int phone_get_priority (Couchdb.StructField sf);
		[CCode (cname = "couchdb_document_contact_phone_new", has_construct_function = false, type = "CouchdbStructField*")]
		public DocumentContact.phone_new (string uuid, string number, string description, int priority);
		public static void phone_set_description (Couchdb.StructField sf, string description);
		public static void phone_set_number (Couchdb.StructField sf, string number);
		public static void phone_set_priority (Couchdb.StructField sf, int priority);
		public void set_assistant_name (string assistant_name);
		public void set_birth_date (string birth_date);
		public void set_categories (string categories);
		public void set_company (string company);
		public void set_department (string department);
		public void set_first_name (string first_name);
		public void set_job_title (string job_title);
		public void set_last_name (string last_name);
		public void set_manager_name (string manager_name);
		public void set_middle_name (string middle_name);
		public void set_nick_name (string nick_name);
		public void set_notes (string notes);
		public void set_office (string office);
		public void set_spouse_name (string spouse_name);
		public void set_suffix (string suffix);
		public void set_title (string title);
		public void set_wedding_date (string wedding_date);
		public static unowned string url_get_address (Couchdb.StructField sf);
		public static unowned string url_get_description (Couchdb.StructField sf);
		[CCode (cname = "couchdb_document_contact_url_new", has_construct_function = false, type = "CouchdbStructField*")]
		public DocumentContact.url_new (string uuid, string address, string description);
		public static void url_set_address (Couchdb.StructField sf, string address);
		public static void url_set_description (Couchdb.StructField sf, string description);
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "couchdb_document_info_get_type ()")]
	[Compact]
	public class DocumentInfo {
		[CCode (has_construct_function = false)]
		public DocumentInfo (string docid, string revision);
		public unowned string get_docid ();
		public unowned string get_revision ();
		public Couchdb.DocumentInfo @ref ();
		public void unref ();
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", type_id = "couchdb_document_task_get_type ()")]
	public class DocumentTask : Couchdb.Document {
		[CCode (has_construct_function = false)]
		public DocumentTask ();
		public unowned string get_description ();
		public unowned string get_summary ();
		public void set_description (string description);
		public void set_summary (string summary);
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", type_id = "couchdb_query_get_type ()")]
	public class Query : GLib.Object {
		[CCode (has_construct_function = false)]
		public Query ();
		[CCode (has_construct_function = false)]
		public Query.for_path (string path);
		[CCode (has_construct_function = false)]
		public Query.for_view (string design_doc, string view_name);
		public Json.Object get_json_object ();
		public unowned string get_method ();
		public unowned string get_option (string name);
		public unowned string get_path ();
		public unowned string get_query_options_string ();
		public void set_json_object (Json.Object object);
		public void set_method (string method);
		public void set_option (string name, string value);
		public void set_path (string path);
		public string path { get; set; }
		[NoAccessorMethod]
		public GLib.HashTable<weak void*,weak void*> query_options { owned get; set; }
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", type_id = "couchdb_response_get_type ()")]
	public class Response : GLib.Object {
		[CCode (has_construct_function = false)]
		public Response ();
		public size_t get_content_length ();
		public unowned string get_content_type ();
		public unowned string get_etag ();
		public unowned Json.Object get_json_object ();
		public GLib.List<weak Json.Object> get_rows ();
		public uint get_status_code ();
		public ulong content_length { get; construct; }
		public string content_type { get; construct; }
		public string etag { get; construct; }
		[NoAccessorMethod]
		public Json.Object response { owned get; construct; }
		public uint status_code { get; construct; }
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", type_id = "couchdb_session_get_type ()")]
	public class Session : GLib.Object {
		[CCode (has_construct_function = false)]
		public Session (string uri);
		public bool compact_database (string dbname) throws GLib.Error;
		public bool create_database (string dbname) throws GLib.Error;
		public bool delete_database (string dbname) throws GLib.Error;
		public void disable_authentication ();
		public void enable_authentication (Couchdb.Credentials credentials);
		public Couchdb.DatabaseInfo get_database_info (string dbname) throws GLib.Error;
		public unowned string get_uri ();
		public bool is_authentication_enabled ();
		public bool replicate (string source, string target, bool continous) throws GLib.Error;
		[NoAccessorMethod]
		public string uri { owned get; set construct; }
		public virtual signal void authentication_failed ();
		public virtual signal void database_created (string dbname);
		public virtual signal void database_deleted (string dbname);
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", type_id = "couchdb_struct_field_get_type ()")]
	public class StructField : GLib.Object {
		[CCode (has_construct_function = false)]
		public StructField ();
		[CCode (has_construct_function = false)]
		public StructField.from_string (string str);
		public bool get_boolean_field (string field);
		public double get_double_field (string field);
		public GLib.Type get_field_type (string field);
		public int get_int_field (string field);
		public unowned string get_string_field (string field);
		public unowned string get_uuid ();
		public bool has_field (string field);
		public void remove_field (string field);
		public void set_array_field (string field, Couchdb.ArrayField value);
		public void set_boolean_field (string field, bool value);
		public void set_double_field (string field, double value);
		public void set_int_field (string field, int value);
		public void set_string_field (string field, string value);
		public void set_struct_field (string field, Couchdb.StructField value);
		public void set_uuid (string uuid);
		public string to_string ();
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cprefix = "COUCHDB_CREDENTIALS_TYPE_", has_type_id = false)]
	public enum CredentialsType {
		UNKNOWN,
		OAUTH,
		USERNAME_AND_PASSWORD
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cprefix = "COUCHDB_DESIGN_DOCUMENT_LANGUAGE_", has_type_id = false)]
	public enum DesignDocumentLanguage {
		UNKNOWN,
		JAVASCRIPT,
		PYTHON
	}
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_CREDENTIALS_ITEM_OAUTH_CONSUMER_KEY")]
	public const string CREDENTIALS_ITEM_OAUTH_CONSUMER_KEY;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_CREDENTIALS_ITEM_OAUTH_CONSUMER_SECRET")]
	public const string CREDENTIALS_ITEM_OAUTH_CONSUMER_SECRET;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_CREDENTIALS_ITEM_OAUTH_TOKEN_KEY")]
	public const string CREDENTIALS_ITEM_OAUTH_TOKEN_KEY;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_CREDENTIALS_ITEM_OAUTH_TOKEN_SECRET")]
	public const string CREDENTIALS_ITEM_OAUTH_TOKEN_SECRET;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_CREDENTIALS_ITEM_PASSWORD")]
	public const string CREDENTIALS_ITEM_PASSWORD;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_CREDENTIALS_ITEM_USERNAME")]
	public const string CREDENTIALS_ITEM_USERNAME;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_ADDRESS_DESCRIPTION_HOME")]
	public const string DOCUMENT_CONTACT_ADDRESS_DESCRIPTION_HOME;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_ADDRESS_DESCRIPTION_OTHER")]
	public const string DOCUMENT_CONTACT_ADDRESS_DESCRIPTION_OTHER;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_ADDRESS_DESCRIPTION_WORK")]
	public const string DOCUMENT_CONTACT_ADDRESS_DESCRIPTION_WORK;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_EMAIL_DESCRIPTION_HOME")]
	public const string DOCUMENT_CONTACT_EMAIL_DESCRIPTION_HOME;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_EMAIL_DESCRIPTION_OTHER")]
	public const string DOCUMENT_CONTACT_EMAIL_DESCRIPTION_OTHER;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_EMAIL_DESCRIPTION_WORK")]
	public const string DOCUMENT_CONTACT_EMAIL_DESCRIPTION_WORK;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_IM_PROTOCOL_AIM")]
	public const string DOCUMENT_CONTACT_IM_PROTOCOL_AIM;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_IM_PROTOCOL_GADU_GADU")]
	public const string DOCUMENT_CONTACT_IM_PROTOCOL_GADU_GADU;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_IM_PROTOCOL_GROUPWISE")]
	public const string DOCUMENT_CONTACT_IM_PROTOCOL_GROUPWISE;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_IM_PROTOCOL_ICQ")]
	public const string DOCUMENT_CONTACT_IM_PROTOCOL_ICQ;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_IM_PROTOCOL_IRC")]
	public const string DOCUMENT_CONTACT_IM_PROTOCOL_IRC;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_IM_PROTOCOL_JABBER")]
	public const string DOCUMENT_CONTACT_IM_PROTOCOL_JABBER;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_IM_PROTOCOL_MSN")]
	public const string DOCUMENT_CONTACT_IM_PROTOCOL_MSN;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_IM_PROTOCOL_SKYPE")]
	public const string DOCUMENT_CONTACT_IM_PROTOCOL_SKYPE;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_IM_PROTOCOL_YAHOO")]
	public const string DOCUMENT_CONTACT_IM_PROTOCOL_YAHOO;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_ASSISTANT")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_ASSISTANT;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_CALLBACK")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_CALLBACK;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_CAR")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_CAR;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_COMPANY")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_COMPANY;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_HOME")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_HOME;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_HOME_FAX")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_HOME_FAX;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_MOBILE")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_MOBILE;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_OTHER")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_OTHER;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_OTHER_FAX")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_OTHER_FAX;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_PAGER")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_PAGER;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_PRIMARY")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_PRIMARY;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_RADIO")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_RADIO;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_TELEX")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_TELEX;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_WORK")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_WORK;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_PHONE_DESCRIPTION_WORK_FAX")]
	public const string DOCUMENT_CONTACT_PHONE_DESCRIPTION_WORK_FAX;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_URL_DESCRIPTION_BLOG")]
	public const string DOCUMENT_CONTACT_URL_DESCRIPTION_BLOG;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_DOCUMENT_CONTACT_URL_DESCRIPTION_HOMEPAGE")]
	public const string DOCUMENT_CONTACT_URL_DESCRIPTION_HOMEPAGE;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_RECORD_TYPE_CONTACT")]
	public const string RECORD_TYPE_CONTACT;
	[CCode (cheader_filename = "couchdb-glib-1.0/couchdb-glib.h", cname = "COUCHDB_RECORD_TYPE_TASK")]
	public const string RECORD_TYPE_TASK;
}
