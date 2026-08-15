require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  it "signs a user out via DELETE" do
    sign_in create(:user)
    delete "/users/sign_out"
    expect(response).to redirect_to(root_path)
  end
end
