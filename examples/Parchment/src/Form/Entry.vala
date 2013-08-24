using Ambition.Form;
namespace Parchment.Form {

    /**
    * Entry Form.
    */
    public class Entry : FormDefinition {

        [Description( nick = "Title" )]
        public string title { get; set; }

        public string content { get; set; }

        [Description( nick = "Tags (comma-separated)" )]
        public string tags { get; set; }

        [Description( nick = "Publish" )]
        public string submit { get; set; }

        public override bool validate_form() {
            if ( title == null || title.length == 0 ) {
                this.add_field_error( "title", "Missing title" );
            }
            if ( content == null || content.length == 0 ) {
                this.add_field_error( "content", "Missing content" );
            }

            return !this.has_errors();
        }

        public string[] parsed_tags() {
            return /,\s*/.split( this.tags );
        }
    }
}
