# frozen_string_literal: true

describe CommentViewers do
  describe '#viewers' do
    let(:owner) { FactoryBot.create(:user2, :with_allies) }
    let(:ally) { owner.allies.first }
    let(:ally_commenter) { owner.allies.second }

    let(:strategy) { FactoryBot.create(:strategy, user_id: owner.id) }
    let(:moment) { FactoryBot.create(:moment, user_id: owner.id) }

    let(:commentable) do
      {
        strategy: strategy,
        moment: moment
      }
    end

    %i[strategy moment].each do |commentable_name|
      let(:my_commentable) { commentable[commentable_name] }

      let(:comment) do
        Comment.create!(commentable_type: commentable_name,
                        commentable_id: my_commentable.id,
                        comment_by: commenter.id,
                        comment: 'test comment',
                        visibility: visibility,
                        viewers: viewers)
      end

      subject { CommentViewers.viewers(comment, current_user) }

      describe 'private comments (visible to you and 1 ally)' do
        let(:visibility) { 'private' }

        describe 'and comment was made by owner' do
          let(:commenter) { owner }
          let(:viewers) { [ally.id] }

          describe 'logged in as owner' do
            let(:current_user) { owner }

            it "has the ally's name in visibility" do
              expect(subject).to eq("Visible only between you and #{ally.name}")
            end
          end

          describe 'logged in as ally' do
            let(:current_user) { ally }

            it "has the owner's name in visibility" do
              expect(subject).to eq("Visible only between you and #{owner.name}")
            end
          end
        end

        describe 'and comment was made by an ally' do
          let(:commenter) { ally_commenter }
          let(:viewers) { [] }

          describe 'logged in as owner' do
            let(:current_user) { owner }

            it "has the ally's name in visibility" do
              expect(subject).to eq("Visible only between you and #{ally_commenter.name}")
            end
          end

          describe 'logged in as commenter' do
            let(:current_user) { ally_commenter }

            it "has the owner's name in visibility" do
              expect(subject).to eq("Visible only between you and #{owner.name}")
            end
          end
        end
      end

      describe 'public comments (visible to all allies)' do
        let(:visibility) { 'all' }
        let(:viewers) { [] }

        describe 'and comment was made by owner' do
          let(:commenter) { owner }

          describe 'logged in as owner' do
            let(:current_user) { owner }

            it 'has nothing for visibility' do
              expect(subject).to be_nil
            end
          end

          describe 'logged in as ally' do
            let(:current_user) { ally }

            it 'has nothing for visibility' do
              expect(subject).to be_nil
            end
          end
        end

        describe 'and comment was made by ally' do
          let(:commenter) { ally_commenter }

          describe 'logged in as owner' do
            let(:current_user) { owner }

            it 'has nothing for visibility' do
              expect(subject).to be_nil
            end
          end

          describe 'logged in as commenter' do
            let(:current_user) { commenter }

            it 'has nothing for visibility' do
              expect(subject).to be_nil
            end
          end
        end
      end
    end
  end

  describe '#viewable' do
    let(:owner) { FactoryBot.create(:user2, :with_allies) }
    let(:ally) { owner.allies.first }
    let(:ally_commenter) { owner.allies.second }

    let(:strategy) { FactoryBot.create(:strategy, user_id: owner.id) }
    let(:moment) { FactoryBot.create(:moment, user_id: owner.id) }

    let(:commentable) do
      {
        strategy: strategy,
        moment: moment
      }
    end

    %i[strategy moment].each do |commentable_name|
      let(:my_commentable) { commentable[commentable_name] }

      let(:comment) do
        Comment.create!(commentable_type: commentable_name,
                        commentable_id: my_commentable.id,
                        comment_by: commenter.id,
                        comment: 'test comment',
                        visibility: visibility,
                        viewers: viewers)
      end

      subject { CommentViewers.viewable(comment, current_user) }

      describe 'private comments (visible to you and 1 ally)' do
        let(:visibility) { 'private' }

        describe 'and comment was made by owner' do
          let(:commenter) { owner }
          let(:viewers) { [ally.id] }

          describe 'logged in as owner' do
            let(:current_user) { owner }

            it 'is visible to the current user' do
              expect(subject).to eq(true)
            end
          end

          describe 'logged in as ally' do
            let(:current_user) { ally }

            it 'is visible to the current user' do
              expect(subject).to eq(true)
            end
          end
        end

        describe 'and comment was made by an ally' do
          let(:commenter) { ally_commenter }
          let(:viewers) { [] }

          describe 'logged in as owner' do
            let(:current_user) { owner }

            it 'is visible to the current user' do
              expect(subject).to eq(true)
            end
          end

          describe 'logged in as commenter' do
            let(:current_user) { ally_commenter }

            it 'is visible to the current user' do
              expect(subject).to eq(true)
            end
          end
        end
      end

      describe 'public comments (visible to all allies)' do
        let(:visibility) { 'all' }
        let(:viewers) { [] }

        describe 'and comment was made by owner' do
          let(:commenter) { owner }

          describe 'logged in as owner' do
            let(:current_user) { owner }

            it 'is visible to the current user' do
              expect(subject).to eq(true)
            end
          end

          describe 'logged in as ally' do
            let(:current_user) { ally }

            it 'is not visible to the current user' do
              expect(subject).to eq(false)
            end
          end
        end

        describe 'and comment was made by ally' do
          let(:commenter) { ally_commenter }

          describe 'logged in as owner' do
            let(:current_user) { owner }

            it 'is visible to the current user' do
              expect(subject).to eq(true)
            end
          end

          describe 'logged in as commenter' do
            let(:current_user) { commenter }

            it 'is visible to the current user' do
              expect(subject).to eq(true)
            end
          end
        end
      end
    end
  end
end
