require 'rails_helper'

RSpec.describe MiniProgramController, type: :controller do

  let(:user) { User.create!(name: '223', uid: '123') }
  let(:token) { (Knock::AuthToken.new payload: user.to_token_payload).token }
  let(:box) { user.box }
  let!(:the_post) { box.create_post!(content: "test", images: ["aaa", "bbb"]) }
  let!(:mini_post) { box.create_post!(content: "mini_program", mini_program: true, images: ["aaa", "bbb"]) }
  before { Rails.cache.write(CACHE_JWT(user.id), token, expires_in: 12.minutes) }

  describe "POST #show" do
    it "Should be able to access self own post" do
      get :show, params: {box_id: box.id, post_id: mini_post.id}, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['content']).to eq('mini_program')
    end
  end

  describe "GET #mini_program" do
    it "returns http success" do
      get :index, params: {box_id: box.id, page: 1}, format: :json
      expect(response).to have_http_status(:success)
      LOG_DEBUG(response.body)
      expect(JSON.parse(response.body)['data']['posts'][0]['content']).to eq("mini_program")
    end
  end
end
