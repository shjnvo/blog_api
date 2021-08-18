require 'rails_helper'

RSpec.describe 'V1::Blogs', type: :request do
  include Pagy::Backend

  let!(:user) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:admin) { create(:admin) }
  let!(:user_blog) { create(:blog, creator: user) }
  let!(:user_blog2) { create(:blog, creator: user) }
  let!(:user_blog3) { create(:blog, creator: user) }
  let!(:user_blog4) { create(:blog, creator: user) }
  let!(:user_blog5) { create(:blog, creator: user) }
  let!(:user_blog6) { create(:blog, creator: user) }
  let!(:admin_blog) { create(:blog, creator: admin) }
  let!(:user_like_blog) { create(:user_like_blog, user: user, blog: user_blog, like_count: 1) }
  let!(:user_like_blog2) { create(:user_like_blog, user: user, blog: user_blog2, like_count: 2) }
  let!(:user_like_blog3) { create(:user_like_blog, user: user, blog: user_blog3, like_count: 3) }
  let!(:user_like_blog4) { create(:user_like_blog, user: user, blog: user_blog4, like_count: 4) }
  let!(:user_like_blog5) { create(:user_like_blog, user: user, blog: user_blog5, like_count: 5) }
  let!(:user_like_blog6) { create(:user_like_blog, user: user, blog: user_blog6, like_count: 6) }
  let!(:user_token) { JwtService.encode({ user_token: user.generate_token! }) }
  let!(:user2_token) { JwtService.encode({ user_token: user2.generate_token! }) }
  let!(:admin_token) { JwtService.encode({ user_token: admin.generate_token! }) }

  describe 'GET /v1/blogs' do
    it 'returns http success' do
      get '/v1/blogs', headers: { 'Authentication': user_token }
      data = JSON.parse(response.body)['data']
      expect(response).to have_http_status(:success)
      expect(data.size).to eq Blog.publisheds.size
    end

    it 'search blog_title' do
      get '/v1/blogs', headers: { 'Authentication': user_token }, params: { text_search: user_blog.title }
      data = JSON.parse(response.body)['data']
      expect(response).to have_http_status(:success)
      expect(data.size).to eq Blog.publisheds.search_by_title(user_blog.title).size
    end

    it 'search blog_title have unpublished blog' do
      user_blog.unpublish!
      get '/v1/blogs', headers: { 'Authentication': user_token }, params: { text_search: user_blog.title }
      data = JSON.parse(response.body)['data']
      expect(response).to have_http_status(:success)
      expect(data.size).to eq Blog.publisheds.search_by_title(user_blog.title).size
    end
  end

  describe 'GET /v1/blogs/top_5_blogs' do
    it 'returns http success' do
      get '/v1/blogs/top_5_blogs', headers: { 'Authentication': user_token }
      data = JSON.parse(response.body)['data']
      expect(response).to have_http_status(:success)
      expect(data.map{ |a| a['id'] }).to eq [user_blog6.id, user_blog5.id, user_blog4.id, user_blog3.id, user_blog2.id]
    end
  end

  describe 'GET /v1/blogs/most_like_blog' do
    it 'returns http success' do
      get '/v1/blogs/most_like_blog', headers: { 'Authentication': user_token }
      data = JSON.parse(response.body)['data']
      expect(response).to have_http_status(:success)
      expect(data['id']).to eq user_blog6.id
    end
  end

  describe 'GET /v1/blogs/:id' do
    it 'returns http success' do
      get "/v1/blogs/#{user_blog.id}", headers: { 'Authentication': user_token }
      expect(response).to have_http_status(:success)
    end

    it 'returns http success with friendly id' do
      get "/v1/blogs/#{user_blog.slug}", headers: { 'Authentication': user_token }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /v1/blogs/:id' do
    context 'with user' do
      it 'returns http success' do
        params = { title: 'user_blog title', content: 'user_blog content' }
        patch "/v1/blogs/#{user_blog.id}", headers: { 'Authentication': user_token }, params: params
        user_blog.reload
        expect(response).to have_http_status(:success)
        expect(user_blog.title).to eq params[:title]
        expect(user_blog.content).to eq params[:content]
      end

      it 'returns http forbidden with other user' do
        params = { title: 'user_blog title', content: 'user_blog content' }
        patch "/v1/blogs/#{user_blog.id}", headers: { 'Authentication': user2_token }, params: params
        user_blog.reload
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with admin' do
      it 'returns http success' do
        params = { title: 'user_blog title', content: 'user_blog content' }
        patch "/v1/blogs/#{admin_blog.id}", headers: { 'Authentication': admin_token }, params: params
        admin_blog.reload
        expect(response).to have_http_status(:success)
        expect(admin_blog.title).to eq params[:title]
        expect(admin_blog.content).to eq params[:content]
      end

      it 'returns http success with other user' do
        params = { title: 'user_blog title', content: 'user_blog content' }
        patch "/v1/blogs/#{user_blog.id}", headers: { 'Authentication': admin_token }, params: params
        user_blog.reload
        expect(response).to have_http_status(:success)
        expect(user_blog.title).to eq params[:title]
        expect(user_blog.content).to eq params[:content]
      end
    end
  end

  describe 'DELETE v1/blogs/:id' do
    context 'with user' do
      it 'returns http success' do
        delete "/v1/blogs/#{user_blog.id}", headers: { 'Authentication': user_token }
        expect(response).to have_http_status(:success)
      end

      it 'returns http forbidden with other user' do
        delete "/v1/blogs/#{user_blog.id}", headers: { 'Authentication': user2_token }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with admin' do
      it 'returns http success' do
        delete "/v1/blogs/#{admin_blog.id}", headers: { 'Authentication': admin_token }
        expect(response).to have_http_status(:success)
      end

      it 'returns http success with other user' do
        delete "/v1/blogs/#{user_blog.id}", headers: { 'Authentication': admin_token }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST /v1/blogs/:id/like' do
    it 'returns http success' do
      post "/v1/blogs/#{user_blog.id}/like", headers: { 'Authentication': user_token }
      expect(response).to have_http_status(:success)
    end

    it 'returns http success multiple like blog' do
      post "/v1/blogs/#{user_blog.id}/like", headers: { 'Authentication': user_token }
      post "/v1/blogs/#{user_blog.id}/like", headers: { 'Authentication': user_token }

      like_count = UserLikeBlog.find_by(user: user, blog: user_blog).like_count
      expect(response).to have_http_status(:success)
      expect(like_count).to eq 3
    end

    it 'returns http success with friendly id' do
      post "/v1/blogs/#{user_blog.slug}/like", headers: { 'Authentication': user_token }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /unpublesh' do
    context 'with user' do
      it 'returns http success' do
        patch "/v1/blogs/#{user_blog.id}", headers: { 'Authentication': user_token }
        expect(response).to have_http_status(:success)
      end

      it 'returns http forbidden with other user' do
        patch "/v1/blogs/#{user_blog.id}", headers: { 'Authentication': user2_token }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with admin' do
      it 'returns http success' do
        patch "/v1/blogs/#{admin_blog.id}", headers: { 'Authentication': admin_token }
        expect(response).to have_http_status(:success)
      end

      it 'returns http success with other user' do
        patch "/v1/blogs/#{user_blog.id}", headers: { 'Authentication': admin_token }
        expect(response).to have_http_status(:success)
      end
    end
  end

end
