require 'rails_helper'

RSpec.describe ToursController, type: :controller do

  let(:valid_attributes) {
    FactoryBot.attributes_for(:tour)
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ToursController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "returns a success response" do
      tour = Tour.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      tour = Tour.create! valid_attributes
      get :show, params: {id: tour.to_param}, session: valid_session
      expect(response).to be_successful
    end
    it "returns the proper collection of other tours" do
      tour1 = Tour.create! valid_attributes
      tour2 = Tour.create! valid_attributes
      # TODO: add booking dates to tour2
      # TODO: add cover_image to tour2
      get :show, params: {id: tour.to_param}, session: valid_session
      expect(@tours).to eq( [tour2] )
    end
  end
end
