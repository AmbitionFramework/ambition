using Ambition;
using Parchment;
using Parchment.View;
using Parchment.Model.DB;
using Gee;
namespace Parchment.Controller {

	/**
	 * Admin Controller.
	 */
	public class Admin : Object {

		/**
		 * Check if a user is authenticated.
		 * @param state State object.
		 */
		public static Result check_user( State state ) {
			if ( ! state.has_user ) {
				state.response.done(); // Stop processing after this method
				return new CoreView.Redirect("/admin/login");
			}
			return new CoreView.None();
		}

		/**
		 * Admin dashboard to list recent entries.
		 * @param state State object.
		 */
		public static Result dashboard( State state ) {
			var entries = new Almanna.Search<Implementation.Entry>()
							.eq( "publisher_id", (int) state.user.id )
							.order_by( "date_created", true )
							.rows(15)
							.page(1)
							.list();
			return new Template.Admin.dashboard(entries);
		}

		/**
		 * Admin page to create/edit entries.
		 * @param state State object.
		 */
		public static Result entry( State state ) {
			var form = new Form.Entry();

			// Bind from Entry object, if it exists
			string entry_id = state.request.params["id"];
			if ( entry_id != null ) {
				var entry = new Almanna.Search<Implementation.Entry>().lookup( int.parse(entry_id) );
				entry.bind_data_to(form);
				form.tags = arraylist_joinv( ",", entry.tags() );
			}

			if ( state.request.method == HttpMethod.POST ) {
				form.bind_state( state );
				if ( form.is_valid() ) {
					Implementation.Entry entry;
					if ( state.request.params["entry_id"] != null ) {
						int existing_id = int.parse( state.request.params["entry_id"] );
    					entry = new Almanna.Search<Implementation.Entry>().lookup(existing_id);
					} else {
						entry = new Implementation.Entry();
					}
					entry.bind_data_from( form, true );
					entry.publisher_id = state.user.id;
					try {
						entry.save();
						entry.add_tags( form.parsed_tags() );
					} catch (Almanna.EntityError e) {
						form.add_form_error("Unable to save entry.");
					}
					if ( entry.entry_id > 0 ) {
						state.session.set_value( "entry_id", entry.entry_id.to_string() );
						return new CoreView.Redirect("/admin");
					}
				}
			}
			return new Template.Admin.entry(form);
		}

		/**
		 * Admin page to edit your account profile.
		 * @param state State object.
		 */
		public static Result profile( State state ) {
			var form = new Form.Profile( state.authorization );

			// Bind data from the logged in user
			var publisher = (Implementation.Publisher) state.user.get_object();
			publisher.bind_data_to(form);
			
			if ( state.request.method == HttpMethod.POST ) {
				form.bind_state(state);
				if ( form.is_valid() ) {
					publisher.bind_data_from( form, true );
					publisher.save();
					state.authorize( "default", publisher.username, form.password );
					return new CoreView.Redirect("/admin");
				}
			}

			return new Template.Admin.profile(form);
		}

		/**
		 * Log in to admin section.
		 * @param state State object.
		 */
		public static Result login( State state ) {
			var form = new Form.Login();
			if ( state.request.method == HttpMethod.POST ) {
				form.bind_state( state );
				if ( form.is_valid() ) {
					if ( state.authorization.authorize( "default", form.username, form.password ) ) {
						return new CoreView.Redirect("/admin");
					} else {
						form.add_form_error("Invalid username or password");
					}
				} else {
					form.add_form_error("Something is wrong");
				}
			}
			return new Template.Admin.login(form);
		}

		/**
		 * Log out.
		 * @param state State object.
		 */
		public static Result logout( State state ) {
			state.logout();
			return new CoreView.Redirect("/");
		}

	}
}
