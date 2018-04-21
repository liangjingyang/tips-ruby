require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  let(:user) { User.create!(name: '223', uid: '123') }
  let(:other) { User.create!(name: '333', uid: '123') }
  let(:token) { (Knock::AuthToken.new payload: user.to_token_payload).token }
  let(:other_token) { (Knock::AuthToken.new payload: other.to_token_payload).token }
  before do
    Rails.cache.write(CACHE_JWT(user.id), token, expires_in: 12.minutes)
    Rails.cache.write(CACHE_JWT(other.id), other_token, expires_in: 12.minutes)
  end

  describe "GET #upload_res_token" do
    it "returns http success" do
      @request.headers['Content-Type'] = 'application/json'
      get :upload_res_token, params: {token: token, user_id: user.id, box_id: user.box.id}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data']['upload_res_token']).to be_present
    end
  end

  describe "GET #uri_parser" do
    it "returns http success" do
      expect(other.all_box_ids).not_to include(user.box.id)
      @request.headers['Content-Type'] = 'application/json'
      uri = "https://#{DRAFT_CONFIG['server_host']}/uri/follow_box?qrcode_token=#{user.box.qrcode_token}"
      get :uri_parser, params: {token: other_token, user_id: other.id, uri: uri}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data']['uri_type']).to eq('follow_box')
      expect(other.all_box_ids).to include(user.box.id)
    end
  end

  describe "GET #me" do
    it "returns http success" do
      @request.headers['Content-Type'] = 'application/json'
      get :me, params: {token: token}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data']['name']).to eq('223')
      expect(JSON.parse(response.body)['data']['box']['is_mine']).to eq(true)
    end
  end
end