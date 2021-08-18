require 'rails_helper'

RSpec.describe 'V1::Users', type: :request do
  let!(:user) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:admin) { create(:admin) }
  let(:user_token) { JwtService.encode({ user_token: user.generate_token! }) }
  let(:admin_token) { JwtService.encode({ user_token: admin.generate_token! }) }

  describe 'GET /v1/users' do
    context 'with user' do
      it 'returns http success' do
        user2.locked!
        get '/v1/users', headers: { 'Authentication': user_token }
        data = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:success)
        expect(data.size).to eq User.collection_for(user).size
      end

      it 'search email locked user' do
        user2.locked!
        get '/v1/users', headers: { 'Authentication': user_token }, params: { text_search: user2.email }
        data = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:success)
        expect(data.size).to eq User.collection_for(user).search_by_name_email(user2.email).size
      end

      it 'search user_email' do
        user2.locked!
        get '/v1/users', headers: { 'Authentication': user_token }, params: { text_search: user.email }
        data = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:success)
        expect(data.size).to eq User.collection_for(user).search_by_name_email(user.email).size
      end

      it 'search user_name locked user' do
        user2.locked!
        get '/v1/users', headers: { 'Authentication': user_token }, params: { text_search: user2.name }
        data = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:success)
        expect(data.size).to eq User.collection_for(user).search_by_name_email(user2.name).size
      end

      it 'search user_name' do
        user2.locked!
        get '/v1/users', headers: { 'Authentication': user_token }, params: { text_search: user.name }
        data = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:success)
        expect(data.size).to eq User.collection_for(user).search_by_name_email(user.name).size
      end

      it 'search user_name have multiple same word' do
        user2.locked!
        get '/v1/users', headers: { 'Authentication': user_token }, params: { text_search: 'Johnd' }
        data = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:success)
        expect(data.size).to eq User.collection_for(user).search_by_name_email('Johnd').size
      end
    end

    context 'with admin' do
      it 'returns http success' do
        user2.locked!
        get '/v1/users', headers: { 'Authentication': admin_token }
        data = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:success)
        expect(data.size).to eq User.collection_for(admin).size
      end
    end
  end

  describe 'POST /v1/users' do
    context 'with user' do
      it 'returns http forbidden' do
        post '/v1/users', headers: { 'Authentication': user_token }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with admin' do
      it 'returns http success' do
        params = { name: 'test_name', email: 'test_email@gmail.com', role: 'user', password: '12345678'}
        post '/v1/users', headers: { 'Authentication': admin_token }, params: params
        expect(response).to have_http_status(:success)
        expect(User.count).to be(4)
      end
    end
  end

  describe 'PATCH /v1/update' do
    context 'with user' do
      it 'returns http forbidden' do
        patch "/v1/users/#{user.id}", headers: { 'Authentication': user_token }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with admin' do
      it 'returns http success' do
        params = { name: 'test_name', email: 'test_email@gmail.com', role: 'user', password: '12345678' }
        patch "/v1/users/#{user.id}", headers: { 'Authentication': admin_token }, params: params

        user_updated = User.find_by(email: 'test_email@gmail.com')
        expect(response).to have_http_status(:success)
        expect(user_updated.email).to eq('test_email@gmail.com')
        expect(user_updated.name).to eq('test_name')
        expect(user_updated.role).to eq('user')
        expect(user_updated.authenticate('12345678')).to_not eq false
      end
    end
  end

  describe 'DELETE /v1/users/:id' do
    context 'with user' do
      it 'returns http forbidden' do
        delete "/v1/users/#{user.id}", headers: { 'Authentication': user_token }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with admin' do
      it 'returns http success' do
        delete "/v1/users/#{user.id}", headers: { 'Authentication': admin_token }
        expect(response).to have_http_status(:success)
        expect(User.count).to be(2)
      end
    end
  end

  describe 'PATCH /v1/users/:id/lock' do
    context 'with user' do
      it 'returns http forbidden' do
        patch "/v1/users/#{user.id}/lock", headers: { 'Authentication': user_token }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with admin' do
      it 'returns http success' do
        patch "/v1/users/#{user.id}/lock", headers: { 'Authentication': admin_token }
        expect(response).to have_http_status(:success)
        user.reload
        expect(user.locked?).to eq true
        expect(user.locked_at.present?).to eq true
      end
    end
  end

  describe 'PATCH /v1/users/:id/unlock' do
    context 'with user' do
      it 'returns http forbidden' do
        patch "/v1/users/#{user.id}/unlock", headers: { 'Authentication': user_token }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with admin' do
      it 'returns http success' do
        user.locked!
        patch "/v1/users/#{user.id}/unlock", headers: { 'Authentication': admin_token }
        expect(response).to have_http_status(:success)
        user.reload
        expect(user.locked?).to eq false
        expect(user.locked_at).to eq nil
      end
    end
  end
end
