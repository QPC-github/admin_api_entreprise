class UserForm
  class Create < Reform::Form
    property :email
    property :context

    validation do
      required(:email).filled(format?: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/)
      required(:context).maybe(:str?)
    end

    collection :contacts, form: ContactForm, populate_if_empty: Contact
  end
end