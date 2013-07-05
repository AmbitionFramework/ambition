using Ambition.Form;
namespace Parchment.Form {

	/**
	 * Login Form.
	 */
	public class Login : FormDefinition {

		[Description( nick = "Username" )]
		public string username { get; set; }

		[Description( nick = "Password" )]
		public string password { get; set; }

		[Description( nick = "Login" )]
		public string submit { get; set; }

	}
}
