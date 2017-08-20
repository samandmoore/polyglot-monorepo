require "spec_helper"

RSpec.describe LocalGem do
  it "has a version number" do
    expect(LocalGem::VERSION).not_to be nil
  end
end
