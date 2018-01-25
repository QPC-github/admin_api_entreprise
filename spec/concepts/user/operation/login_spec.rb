require 'rails_helper'

describe User::Login do
  let(:result) { described_class.call(login_params) }

  context 'when user email is unknown' do
    let(:login_params) do
      { username: 'unknownem@il.bad', password: 'couCOU123' }
    end

    it 'fails authentication' do
      expect(result).to be_failure
    end
  end

  context 'when user email is valid' do
    let(:login_params) do
      { username: user.email, password: user.password }
    end

    context 'when user is not confirmed' do
      let(:user) { UsersFactory.inactive_user }

      it 'fails authentication' do
        # much edge case where user is unconfirmed but has password set
        user.password = 'verypwd'
        user.save

        expect(result).to be_failure
      end
    end

    context 'when user is confirmed' do
      let(:user) { UsersFactory.confirmed_user }

      context 'when password is invalid' do
        it 'fails authentication' do
          login_params[:password] = 'invalid password'

          expect(result).to be_failure
        end

        it 'increments counter before lock'
      end

      context 'when incomming params are valid' do
        it 'returns the user' do
          expect(result).to be_success
          expect(result['model']).to eq user
        end

        it 'resets counter before lock'
      end
    end

    context 'when user is locked' do
      it 'fails authentication'
    end
  end
end