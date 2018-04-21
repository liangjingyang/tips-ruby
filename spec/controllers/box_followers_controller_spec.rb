require 'rails_helper'

RSpec.describe BoxFollowersController, type: :controller do

  let(:user) { User.create!(name: '223', uid: '123') }
  let(:other) { User.create!(name: '333', uid: '123') }
  let(:token) { (Knock::AuthToken.new payload: user.to_token_payload).token }
  let(:other_token) { (Knock::AuthToken.new payload: other.to_token_payload).token }
  let!(:box_follower) { other.box_followers.create(box_id: user.box.id) }
  before do
    Rails.cache.write(CACHE_JWT(user.id), token, expires_in: 12.minutes)
    Rails.cache.write(CACHE_JWT(other.id), other_token, expires_in: 12.minutes)
  end

  describe "GET #index" do
    it "returns http success" do
      get :index, params: {token: token, page: 1}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data'][0]['user_id']).to eq(other.id)
    end

    it "returns user unauthorized" do
      get :index, format: :json
      expect(response).to have_http_status(401)
      expect(JSON.parse(response.body)['code']).to eq(401001)
    end 
  end

  describe "POST #update" do
    it "returns http success" do
      @request.headers['Content-Type'] = 'application/json'
      post :update, params: {token: token, id: box_follower.id, allowed: false}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data']['allowed']).to eq(false)
    end
  end

  describe "DELETE #destroy" do
    it "returns http success" do
      expect(other.all_box_ids).to include(user.box.id)

      @request.headers['Content-Type'] = 'application/json'
      delete :destroy, params: {token: other_token, id: box_follower.id}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data']['box_id']).to eq(user.box.id)

      expect(other.reload.all_box_ids).not_to include(user.box.id)
    end
  end

end
