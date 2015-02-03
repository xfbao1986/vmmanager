require 'spec_helper'

describe User do
  describe "searchable field" do
    it { should have_searchable_field(:name) }

    it { should have_searchable_field(:email) }

    it { should have_searchable_field(:admin) }
  end
end
