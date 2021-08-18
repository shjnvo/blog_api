require 'rails_helper'

RSpec.describe 'V1::Sessions', type: :request do
  let(:user) { create(:user, password: 'P@123456') }
  let(:admin) { create(:admin, password: 'P@123456') }
  describe 'POST /v1/login' do
    context 'with user' do
      it 'returns http success' do
        post '/v1/login', params: { email: user.email, password: 'P@123456' }
        expect(response).to have_http_status(:success)
      end

      it 'returns http unauthorized wrong email' do
        post '/v1/login', params: {email: 'wrong@gmail.com', password: 'P@123456'}
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns http unauthorized wrong password' do
        post '/v1/login', params: { email: user.email, password: 'wrong_pass' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns http unauthorized user locked' do
        user.locked!
        post '/v1/login', params: { email: user.email, password: 'P@123456' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with admin' do
      it 'returns http success' do
        post '/v1/login', params: { email: admin.email, password: 'P@123456' }
        expect(response).to have_http_status(:success)
      end

      it 'returns http unauthorized wrong email' do
        post '/v1/login', params: { email: 'wrong@gmail.com', password: 'P@123456' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns http unauthorized wrong password' do
        post '/v1/login', params: { email: admin.email, password: 'wrong_pass' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns http unauthorized user locked' do
        admin.locked!
        post '/v1/login', params: { email: admin.email, password: 'P@123456' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /v1/logout' do
    context 'with user' do
      it 'valid token returns http success' do
        post '/v1/login', params: { email: user.email, password: 'P@123456' }
        token = JSON.parse(response.body)['token']

        delete '/v1/logout', headers: {'Authentication': token}
        expect(response).to have_http_status(:success)
      end
    end

    context 'with admin' do
      it 'valid token returns http success' do
        post '/v1/login', params: { email: admin.email, password: 'P@123456' }
        token = JSON.parse(response.body)['token']

        delete '/v1/logout', headers: { 'Authentication': token }
        expect(response).to have_http_status(:success)
      end
    end

    it 'invalid token returns http unauthorized' do
      token = 'invalid_token'

      delete '/v1/logout', headers: { 'Authentication': token }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'none token returns http unauthorized' do
      delete '/v1/logout'
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
