require 'rails_helper'

RSpec.describe PostsController, type: :controller do

  let(:user) { User.create!(name: '223', uid: '123') }
  let(:user2) { User.create!(name: '223', uid: '123') }
  let(:token) { (Knock::AuthToken.new payload: user.to_token_payload).token }
  let(:token2) { (Knock::AuthToken.new payload: user2.to_token_payload).token }
  let(:box) { user.box }
  let!(:the_post) { box.create_post!(content: "test", images: ["aaa", "bbb"]) }
  let!(:mini_post) { box.create_post!(content: "mini_program", mini_program: true, images: ["aaa", "bbb"]) }
  before do
    Rails.cache.write(CACHE_JWT(user.id), token, expires_in: 12.minutes)
    Rails.cache.write(CACHE_JWT(user2.id), token2, expires_in: 12.minutes)
  end

  describe "GET #index" do
    it "returns http success" do
      get :index, params: {box_id: box.id, token: token, page: 1}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      # order desc
      expect(JSON.parse(response.body)['data'][0]['content']).to eq('mini_program')
    end

    it "returns user unauthorized" do
      get :index, params: {box_id: box.id, page: 1}, format: :json
      expect(response).to have_http_status(401)
      expect(JSON.parse(response.body)['code']).to eq(401001)
    end 
  end

  describe "POST #show" do
    before do
      @user2 = User.create!(uid: '111', name: 'abc')
      @box2 = @user2.box
      @the_post2 = @box2.create_post!(content: "test2", images: ["aaa", "bbb"])
    end
    it "Should be able to access self own post" do
      get :show, params: {box_id: box.id, token: token, id: the_post.id}, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['content']).to eq('test')
    end

    it "Should not be able to access stranger's post" do
      get :show, params: {box_id: @box2.id, token: token, id: @the_post2.id}, format: :json
      expect(response).to have_http_status(401)
    end

    it "Should be able to access the post in following box" do
      user.following_boxes << @box2
      get :show, params: {box_id: @box2.id, token: token, id: @the_post2.id}, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['content']).to eq('test2')
    end
  end

  describe "POST #update" do
    it "returns http success" do
      @request.headers['Content-Type'] = 'application/json'
      post :update, params: {box_id: box.id, token: token, id: the_post.id, post: {content: "test2"}}, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['content']).to eq("test2")
    end

    it "returns http success" do
      @request.headers['Content-Type'] = 'application/json'
      post :update, params: {box_id: box.id, token: token, id: the_post.id, post: {images: ["ccc"]}}, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['images'][0]).to eq(the_post.reload.images[0])
    end
  end

  # describe "GET #mini_program" do
  #   it "returns http success" do
  #     get :mini_program, params: {box_id: box.id, token: token, page: 1}, format: :json
  #     expect(response).to have_http_status(:success)
  #     LOG_DEBUG(response.body)
  #     expect(JSON.parse(response.body)['data']['posts'][0]['content']).to eq("mini_program")
  #   end
  # end

  describe "POST #copy" do
    it "copy success" do
      BoxFollower.create(box_id: box.id, user_id: user2.id)
      post :copy, params: {box_id: box.id, token: token2, post_id: the_post.id}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data']['parent_box_name']).to eq('223')
    end

    it "copy failed" do
      post :copy, params: {box_id: box.id, token: token2, post_id: the_post.id}, format: :json
      expect(response).to have_http_status(401)
    end

    it "return the origin post" do
      post :copy, params: {box_id: box.id, token: token, post_id: the_post.id}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data']['id']).to eq(the_post.id)
    end
  end

  describe "GET #movement" do
    it "returns http success" do
      @request.headers['Content-Type'] = 'application/json'
      get :movement, params: {token: token, user_id: user.id}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data'][0]['content']).to eq('mini_program')
    end
  end
end
