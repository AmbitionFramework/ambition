# TextCaptcha

## What is it for?

The TextCaptcha plugin provides integration with the <a href="http://textcaptcha.com/">TextCAPTCHA</a> web service. As an alternative to other CAPTCHA systems, TextCaptcha asks very simple questions of the user to prove they are human, without having to decipher potentially unreadable text.

## Installation and Configuration

The TextCaptcha plugin can be installed using the usual Ambition plugin tool. The plugin will link with your application. To use TextCAPTCHA, you must register for an API key on their site, and then provide that key to the plugin. To do that, edit the application config file in the `config/` directory, and add:

    textcaptcha.key = <your API key>

If this is not entered, the plugin will throw a warning when your application loads.

## Using TextCaptcha

Questions are generally provided to the user in the template/view context, so the example will be used accordingly. Since these are regular Vala methods, the same actions can be translated to a Controller easily. In a template, use the `Template.Helper` namespace, and provide the question and a field to answer the question.

    @using Ambition.Helper
    <form method="post">
        <fieldset>
            <p>
                To prove you are human, please answer the following question.
            </p>

            <label for="text_captcha" style="width: 100%">
                @{TextCaptcha.get_new_question(state)}
            </label>
            <input type="text" name="text_captcha" class="reply_field" />
        </fieldset>
    </form>

In the corresponding controller action to receive that form, call `TextCaptcha.check_existing_answer( state, value )`:

    if ( state.request.params["text_captcha"] != null ) {
        bool success = Helper.TextCaptcha.check_existing_answer(
            state,
            state.request.params["text_captcha"]
        );
        if (!success) {
            return new CoreView.Redirect("/");
        }
    }
