using Ambition;
using Ambition.Form;
namespace Parchment.Form {

	/**
	 * Profile Form.
	 */
	public class Profile : FormDefinition {
		private Authorization.Authorize authorization;
		private string _password = "12345678";

		[Description( nick = "Display Name" )]
		public string display_name { get; set; }

		[Description( nick = "Username" )]
		public string username { get; set; }

		[Description( nick = "Password" )]
		public string password {
			get {
				return _password;
			}
			set {
				_password = value;
				if ( value != "12345678" ) {
					password_hash = authorization.encode_password( "default", value );
				}
			}
		}

		public string password_hash { get; set; }

		[Description( nick = "Save" )]
		public string submit { get; set; }

		public Profile( Authorization.Authorize authorization ) {
			this.authorization = authorization;
		}
	}
}
