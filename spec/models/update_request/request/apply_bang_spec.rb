RSpec.describe "UpdateRequest::Request#apply!:", type: :model do
  let(:user) { create(:user) }
  let(:post) { create(:post) }
  let(:admin_user) { create(:admin_user) }

  context "when a simple update" do
    let(:changes) do
      {
          title: 'new title'
      }
    end

    context "is applied WITHOUT an approver" do

      it "then correctly applies the update" do
        update_request = UpdateRequest::Request.new(requester: user, updateable: post, update_schema: changes)

        update_request.save!

        expect(update_request.apply!).to eql(true)

        expect(post.title).to eql(changes[:title])
        expect(update_request.applied).to eql(true)
      end

    end

    context "is applied with an approver" do

      it "then correctly applies the update" do
        update_request = UpdateRequest::Request.new(requester: user, updateable: post, update_schema: changes)

        update_request.save!

        expect(update_request.apply!(admin_user)).to eql(true)

        expect(post.title).to eql(changes[:title])
        expect(update_request.approver).to eql(admin_user)
        expect(update_request.applied).to eql(true)
      end

    end

  end

  context "when an update containing a file" do
    let(:avatar) { Rack::Test::UploadedFile.new('spec/support/image.png', 'image/png') }

    let(:changes) do
      {
          avatar: avatar,
      }
    end

    context "is created" do
      it "then correctly saves but does not apply that update" do
        update_request = UpdateRequest::Request.new(requester: user, updateable: user, update_schema: changes)

        # Creates correct update_request
        expect{ update_request.save }.to change{ UpdateRequest::Request.count }.by(1)

        expect(update_request.apply(admin_user)).to eql(true)

        expect(user.avatar_file_name).to eql(avatar.original_filename)
        expect(user.avatar_content_type).to eql(avatar.content_type)
        expect(user.avatar_file_size).to eql(avatar.tempfile.size)
      end
    end

  end

  context "when an update can't be applied due to validation errors" do
    let(:changes) do
      {
          title: ''
      }
    end

    it "then returns false and does not apply the changes" do
      update_request = UpdateRequest::Request.new(requester: user, updateable: post, update_schema: changes)

      update_request.save!

      title_before = post.title

      expect { update_request.apply!(admin_user) }.to raise_error(ActiveRecord::RecordInvalid)

      expect(update_request.updateable.errors.messages).to eql({ title: ["is too short (minimum is 3 characters)"] })

      expect(post.reload.title).to eql(title_before)
      expect(update_request.approver).to eql(nil)
      expect(update_request.applied).to eql(false)
    end

  end

end
