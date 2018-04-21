require 'rails_helper'

RSpec.describe BoxesController, type: :controller do

  let(:user) { User.create!(name: '223', openid: '123') }
  let(:token) { (Knock::AuthToken.new payload: user.to_token_payload).token }
  let(:box) { user.boxes.create!(title: 'box') }
  before { Rails.cache.write(CACHE_JWT(user.id), token, expires_in: 12.minutes) }

  describe "POST #create" do
    it "returns http success" do
      box_params = {
        title: "title", 
        price: "1.2", 
        tracking_inventory: false,
        posts: [
          {
            content: "content1",
            images: ["aaa", "bbb"]
          },
          {
            content: "content2",
            images: ["ccc", "ddd"]
          },
          {
            content: "content3",
            images: ["eee", "fff"]
          }
        ]
      }
      get :create, params: {token: token, box: box_params}, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['title']).to eq('title')
      expect(JSON.parse(response.body)['data']['price']).to eq('1.2')
    end
  end

  describe "GET #index" do
    it "returns http success" do
      user.boxes.create!(title: 'title1')
      user.boxes.create!(title: 'title2')
      get :index, params: {token: token}, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data'][1]['title']).to eq('title2')
      expect(JSON.parse(response.body)['totalCount']).to eq(2)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: {token: token, id: box.id}, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['title']).to eq('box')
    end
  end

  describe "PUT #update" do
    it "returns http success" do
      @request.headers['Content-Type'] = 'application/json'
      put :update, params: {token: token, id: box.id, box: {price: 12.0}}, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['price']).to eq("12.0")
    end
  end

  # describe "GET #generate_qrcode_token" do
  #   it "returns http success" do
  #     old_token = box.qrcode_token
  #     @request.headers['Content-Type'] = 'application/json'
  #     post :generate_qrcode_token, params: {token: token, box_id: box.id}, format: :json
  #     expect(response).to have_http_status(:success)
  #     box.reload
  #     LOG_DEBUG(response.body)
  #     expect(JSON.parse(response.body)['data']['qrcode_token']).to eq(box.qrcode_token)
  #     expect(box.qrcode_token).not_to eq(old_token)
  #   end
  # end

end
