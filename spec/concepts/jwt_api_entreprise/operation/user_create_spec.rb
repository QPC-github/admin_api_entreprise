require 'rails_helper'

describe JwtApiEntreprise::UserCreate do
  let(:user) { create(:user_with_roles) }
  let(:roles) { user.roles }
  let(:token_params) do
    {
      user_id: user.id,
      roles: roles.pluck(:code),
      subject: 'So testy',
      contact: {
        email: 'valid@email.com',
        phone_number: '0123456789'
      }
    }
  end
  subject { described_class.call(token_params) }

  context 'when input data is valid' do
    it 'is successful' do
      expect(subject).to be_success
    end

    it 'creates the jwt' do
      expect { subject }.to change(JwtApiEntreprise, :count).by(1)
    end

    it 'belongs to the correct user' do
      created_token = subject['created_token']

      expect(created_token.user).to eq(user)
    end

    it 'is associated to the provided roles' do
      expect(subject['created_token'].roles.to_a).to eql(roles.to_a)
    end

    it 'creates the contact' do
      expect { subject }.to change(Contact, :count).by(1)
    end

    it 'sets the contact type to "token"' do
      subject

      expect(Contact.last.contact_type).to eq('token')
    end

    it 'is associated to the new contact' do
      expect(subject['created_token'].contact).to eq(Contact.last)
    end
  end

  context 'when input data is invalid' do
    describe ':roles' do
      let(:errors) { subject['result.contract.params'].errors[:roles] }
      let(:unauthorized_role) { create(:role) }

      it 'is required' do
        token_params[:roles] = []

        expect(subject).to be_failure
        expect(errors).to include 'must be filled'
      end

      context 'when no authorized roles are provided' do
        it 'does not create the token' do
          token_params[:roles] = [unauthorized_role.code]

          expect { subject }.to_not change(JwtApiEntreprise, :count)
        end

        it 'returns an error message' do
          token_params[:roles] = [unauthorized_role.code]

          expect(subject).to be_failure
          expect(subject['errors']).to eq('No authorized roles given')
        end
      end

      context 'when both authorized and unauthorized roles are provided' do
        it 'does not care about unauthorized roles' do
          token_params[:roles].push(unauthorized_role.code)
            associated_unauthorized_role = subject['created_token'].roles.where(code: unauthorized_role.code)

          expect(subject).to be_success
          expect(subject['created_token'].roles).to eq(roles)
          expect(associated_unauthorized_role).to be_empty
        end
      end
    end

    describe ':user_id' do
      let(:errors) { subject['result.contract.params'].errors[:user_id] }

      it 'is required' do
        token_params.delete(:user_id)

        expect(subject).to be_failure
        expect(errors).to include('is missing')
      end

      it 'is an existing user id' do
        token_params[:user_id] = 'not a user id'

        expect(subject).to be_failure
        expect(subject['errors']).to eq("user does not exist (UID : 'not a user id')")
      end
    end

    describe ':subject' do
      it 'is required' do
        token_params[:subject] = ''

        expect(subject).to be_failure
        expect(subject['result.contract.params'].errors[:subject]).to include('must be filled')
      end
    end

    describe ':contact' do
      it 'is required' do
        token_params.delete(:contact)

        expect(subject).to be_failure
        expect(subject['result.contract.params'].errors[:contact]).to include('is missing')
      end

      describe 'contact#email' do
        it 'is required' do
          token_params[:contact][:email] = nil

          expect(subject).to be_failure
          expect(subject['result.contract.params'].errors[:contact][:email]).to include('must be filled')
        end

        it 'has an email format' do
          token_params[:contact][:email] = 'b@dEmail'

          expect(subject).to be_failure
          expect(subject['result.contract.params'].errors[:contact][:email]).to include('is in invalid format')
        end
      end

      describe 'contact#phone_number' do
        it 'is optional' do
          token_params[:contact].delete(:phone_number)

          expect(subject).to be_success
        end

        it 'has a french number format' do
          token_params[:contact][:phone_number] = '202-555-0110'

          expect(subject).to be_failure
          expect(subject['result.contract.params'].errors[:contact][:phone_number]).to include('is in invalid format')
        end
      end
    end
  end
end