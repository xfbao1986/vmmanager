require 'spec_helper'

describe Setup do
  describe "searchable field" do
    it { should have_searchable_field(:host) }

    it { should have_searchable_field(:user) }

    it { should have_searchable_field(:ssh_key) }

    it { should have_searchable_field(:password) }

    it { should have_searchable_field(:setup_role) }

    it { should have_searchable_field(:state) }

    it { should have_searchable_field(:dry_run) }
  end
end
