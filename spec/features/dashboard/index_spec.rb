require 'rails_helper'

RSpec.describe('Dashboard') do
  describe 'happy path' do
    describe 'as an authenticated user' do
      before :each do
        @user = User.create(name: 'Buffy', email: "buffyslayer@example.com", password: "test")

        visit login_path

        fill_in :email, with: @user.email.upcase
        fill_in :password, with: @user.password

        click_button 'Log In'

        # Logging In Redirects to Dashboard
      end

      it "should display 'Welcome <username>!' at the top of page" do
        expect(page).to have_content("Welcome, #{@user.name}")
      end

      it "should have a button to 'Discover Movies'" do
        expect(page).to have_button('Discover Movies')
      end

      it 'should have a friends section' do
        expect(page).to have_content('My Friends:')
        expect(page).to have_selector("section[class='friends']")
      end

      describe 'inside the friends section' do
        it "should have a text field to enter a friend's email" do
          within '.friends' do
            expect(page).to have_field("email")
          end
        end

        it "should have a button to 'Add Friend'" do
          within '.friends' do
            expect(page).to have_button('Add Friend')
          end
        end


        describe 'friendship happy path' do
          describe "when I fill in the add friend form with a user's email and click 'Add Friend'" do
            before :each do
              @other_user = User.create(name: 'other', email: "otheruser@example.com", password: "otherpassword")

              within '.friends' do
                fill_in 'email', with: @other_user.email

                click_button 'Add Friend'
              end
            end

            it 'I should be redirected to my dashboard' do
              expect(current_path).to eq(dashboard_path)
            end

            it "I should see my friend's name in my list of friends" do
              within '.friends' do
                expect(page).to have_content(@other_user.name)
              end
            end
          end
        end

        describe 'if I have not added any friends' do
          it 'there should be a message "You currently have no friends"' do
            within '.friends' do
              expect(page).to have_content('You currently have no friends')
            end
          end
        end
      end

      it 'should have a viewing parties section' do
        movie1 = Movie.create(mdb_id: 'A123')
        party1 = Party.create(movie: movie1, start_time: '2021-03-01 01:00:00 UTC')
        viewer = Viewer.create(status: 'host', party: party1, user: @user)

        visit dashboard_path

        expect(page).to have_content('My Viewing Parties:')
        expect(page).to have_selector("section[class='viewing-parties']")

        # expect(page).to have_content("movie name from API")
        expect(page).to have_content(party1.start_time)
        expect(page).to have_content(viewer.status)
      end

      describe "when a user clicks the 'Discover Movies' button" do
        it 'they should be taken to the discover movies page /discover' do
          click_button 'Discover Movies'

          expect(current_path).to eq(discover_path)
        end
      end
    end
  end

  describe 'sad path' do
    describe 'when I am NOT an authenticated user' do
      before :each do
        visit dashboard_path
      end

      it 'should redirect back to the log in page' do
        expect(current_path).to eq(login_path)
      end

      it "should give a 'You Must Log In To Visit Your Dashboard' notice" do
        expect(page).to have_content('You Must Log In To Visit Your Dashboard')
      end
    end
  end
end
