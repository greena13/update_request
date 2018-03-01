RSpec.describe "UpdateRequest::Request#save:", type: :model do
  let(:user) { create(:user) }
  let(:post) { create(:post) }
  let(:admin_user) { create(:admin_user) }

  context "when a simple update" do
    let(:changes) do
      {
          title: 'new title'
      }
    end

    context "is created" do
      it "then correctly saves but does not apply that update" do
        post_title_before = post.title

        update_request = UpdateRequest::Request.new(requester: user, updateable: post, update_schema: changes)

        # Creates correct update_request
        expect{ update_request.save }.to change{ UpdateRequest::Request.count }.by(1)

        expect(update_request.requester).to eql(user)
        expect(update_request.updateable).to eql(post)
        expect(update_request.update_schema).to eql(changes)
        expect(update_request.applied).to eql(false)

        # Does not apply update
        expect(post.reload.title).to eql(post_title_before)
      end
    end

  end

  context "when an update contains characters outside of yaml's support" do
    let(:changes) do
      {
          title: "\u0092",
      }
    end

    context "is created" do
      it "then correctly saves but does not apply that update" do
        post_title_before = post.title

        update_request = UpdateRequest::Request.new(requester: user, updateable: post, update_schema: changes)

        # Creates correct update_request
        expect{ update_request.save }.to change{ UpdateRequest::Request.count }.by(1)

        expect(update_request.requester).to eql(user)
        expect(update_request.updateable).to eql(post)
        expect(update_request.update_schema).to eql(changes)
        expect(update_request.applied).to eql(false)

        # Does not apply update
        expect(post.reload.title).to eql(post_title_before)

        begin
          UpdateRequest::Request.last.update_schema
        rescue Psych::SyntaxError
          fail
        end
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

        user_avatar_before = user.avatar

        # Creates correct update_request
        expect{ update_request.save }.to change{ UpdateRequest::Request.count }.by(1)

        expect(update_request.requester).to eql(user)
        expect(update_request.updateable).to eql(user)

        expect(update_request.applied).to eql(false)

        uploaded_file = update_request.update_schema['avatar'].instance

        expect(uploaded_file.attachment_file_name).to eql(avatar.original_filename)
        expect(uploaded_file.attachment_content_type).to eql(avatar.content_type)
        expect(uploaded_file.attachment_file_size).to eql(avatar.tempfile.size)

        # Does not apply update
        expect(user.reload.avatar).to eql(user_avatar_before)
      end
    end

  end

end
