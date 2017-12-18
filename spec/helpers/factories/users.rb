module UsersFactory
  def self.inactive_user
    params = { email: 'in@ctive.user', context: 'testing confirmation' }
    operation_result = User::Create.call(params)
    operation_result['model']
  end

  def self.confirmed_user
    unconfirmed_user = inactive_user
    params = { confirmation_token: unconfirmed_user.confirmation_token,
               password: 'couCOU123',
               password_confirmation: 'couCOU123'
    }
    operation_result = User::Confirm.call(params)
    operation_result['model']
  end
end
