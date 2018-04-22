require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  let(:user) { User.create!(name: '223', openid: '123') }
  let(:token) { (Knock::AuthToken.new payload: user.to_token_payload).token }
  let(:box) { user.boxes.create!(title: 'box') }
  let(:user2) { User.create!(name: '2233', openid: '1233') }
  let(:box2) { user2.boxes.create!(title: 'box2', price: 0, count_on_hand: 1) }
  let!(:post) { box2.posts.create(content: 'post')}
  before { Rails.cache.write(CACHE_JWT(user.id), token, expires_in: 12.minutes) }

  describe "POST #checkout" do
    it "returns http success" do
      get :checkout, params: {token: token, number: box2.number}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data']['state']).to eq('completed')
    end
  end

  describe "GET #cart" do
    it "returns http success" do
      get :cart, params: {token: token, number: box2.number}, format: :json
      LOG_DEBUG(response.body)
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['canSupply']).to eq(true)
    end
  end

  # describe "GET #show" do
  #   it "returns http success" do
  #     get :show, params: {token: token, id: box.id}, format: :json
  #     expect(response).to have_http_status(:success)
  #     expect(JSON.parse(response.body)['data']['title']).to eq('box')
  #   end
  # end

  # describe "PUT #update" do
  #   it "returns http success" do
  #     @request.headers['Content-Type'] = 'application/json'
  #     put :update, params: {token: token, id: box.id, box: {price: 12.0}}, format: :json
  #     expect(response).to have_http_status(:success)
  #     expect(JSON.parse(response.body)['data']['price']).to eq("12.0")
  #   end
  # end
end
