require 'rails_helper'

RSpec.describe Post, type: :model do
  before :all do
    @user = create(:user, uid: '123', provider: 'wx', name: 'abc')
    @box = @user.box
  end
  describe "Post" do
    it "Number should be present" do
      expect(@box.number).to be_present
    end
  end

  describe "Copy Post" do
    before do
      @user2 = create(:user, uid: '111', provider: 'wx', name: 'abc')
      @box2 = @user2.box
      @copied_post = @box.posts.create(content:"test", images: ['aaa'])
    end

    it "Should succeed" do
      @pasted_post = @copied_post.copy_to(@box2)
      expect(@pasted_post.parent_id).to eq(@copied_post.id)
      expect(@pasted_post.content).to eq(@copied_post.content)
      expect(@pasted_post.images[0]).to eq('aaa')
      expect(@pasted_post.last_pasted_at).to be_present
      expect(@copied_post.last_copied_at).to be_present
      expect(@copied_post.copied_count).to eq(1)
    end

    it "Should do nothing if copy to the same box" do
      @pasted_post = @copied_post.copy_to(@box)
      expect(@pasted_post).to be_nil
    end
  end
end
