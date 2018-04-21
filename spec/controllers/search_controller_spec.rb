require 'rails_helper'

RSpec.describe SearchController, type: :controller do

  let(:user) { User.create!(name: '223', uid: '123') }
  let(:token) { (Knock::AuthToken.new payload: user.to_token_payload).token }
  let(:user2) { User.create!(name: '224', uid: '124') }
  let(:token2) { (Knock::AuthToken.new payload: user.to_token_payload).token }
  let(:box) { user.box }
  let(:box2) { user2.box }
  let!(:the_post) { box.create_post!(content: "test", images: ["aaa", "bbb"]) }
  let!(:mini_post) { box.create_post!(content: "mini_program", mini_program: true, images: ["aaa", "bbb"]) }
  before do
    BoxFollower.create!(user_id: user.id, box_id: box2.id)
    BoxFollower.create!(user_id: user2.id, box_id: box.id)
    Rails.cache.write(CACHE_JWT(user.id), token, expires_in: 12.minutes)
    Rails.cache.write(CACHE_JWT(user2.id), token2, expires_in: 12.minutes)
  end

  describe "GET #box" do
    it "Should be able to search box by name" do
      get :boxes, params: {q: '22', token: token}, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data'][0]['name']).to eq('224')
    end

    it "returns user unauthorized" do
      get :boxes, params: {q: '22'}, format: :json
      expect(response).to have_http_status(401)
      expect(JSON.parse(response.body)['code']).to eq(401001)
    end 
  end

  describe "GET #post" do
    it "returns http success" do
      get :posts, params: {q: 'mini', token: token, page: 1}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data'][0]['content']).to eq("mini_program")
    end

    it "returns user unauthorized" do
      get :posts, format: :json
      expect(response).to have_http_status(401)
      expect(JSON.parse(response.body)['code']).to eq(401001)
    end 
  end

  describe "GET #all" do
  it "returns http success" do
    get :all, params: {q: 'program', token: token, page: 1}, format: :json
    expect(response).to have_http_status(:success)
    LOG_DEBUG(response.body)
    expect(JSON.parse(response.body)['data']['box_followers']).to be_empty
    expect(JSON.parse(response.body)['data']['boxes']).to be_empty
    expect(JSON.parse(response.body)['data']['posts'][0]['content']).to eq("mini_program")
  end
end
end