# TwitterBootstrap

## What is it for?

The TwitterBootstrap plugin provides <a href="http://twitter.github.com/bootstrap/">Twitter Bootstrap</a> field rendering for form fields.

## Installation and Configuration

The TwitterBootstrap plugin can be installed using the usual Ambition plugin tool. The plugin will link with your application.

## Using TwitterBootstrap

The plugin provides field renderers prefixed with `TB` for rendering form fields. Provided a form is already set up, simply use a field prefixed with `TB` instead of the standard renderer.

Example form:

    using Ambition;
    using Ambition.Form;
    namespace ExampleApp.Form {
        public class Login : FormDefinition {

            [Description( nick = "Username" )]
            public string username { get; set; }

            [Description( nick = "Password" )]
            public string password { get; set; }

            [Description( nick = "Login" )]
            public string login_button { get; set; default = "Login"; }
        }
    }

Example template:

    @parameters( Form.Login login_form )
    @using Ambition.Form
    <form method="post">
        @{login_form.render_field( "username", new TBTextInput() )}
        @{login_form.render_field( "password", new TBPasswordInput() )}
        @{login_form.render_field( "login_button", new TBSubmitButton() )}
    </form>
