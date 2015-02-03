require 'spec_helper'
require 'rake'

describe "vms rake tasks" do
  before :all do
    @rake = Rake::Application.new
    Rake.application = @rake
    load Rails.root + 'lib/tasks/pool_updater.rake'
    Rake::Task.define_task(:environment)
  end

  before do
    @xcp_pool = double("xcp_pool").as_null_object
    Xcp::Pool.stub(:new).and_return @xcp_pool
    Xcp::Pool.stub(:valid_names).and_return(['pool1', 'pool2'])
    @xcp_pool.stub(:storage_total).and_return(100*1024*1024*1024)
    @xcp_pool.stub(:storage_used).and_return(50*1024*1024*1024)
    @xcp_pool.stub(:vms).and_return(['vm1','vm2','vm3','vm4','vm5'])
    @exist_pool = Pool.create! valid_attr
  end

  def valid_attr
    {
      "name"          => "pool1",
      "num_of_vms"    => 0,
      "storage_total" => 0,
      "storage_used"  => 0,
    }
  end

  describe "rake pools:update" do
    let(:pool) { Pool.find(@exist_pool.id) }

    before do
      @rake['pools:update'].execute
    end

    it "have 'environment' as a prerequisite" do
      @rake['pools:update'].prerequisites.should include("environment")
    end

    it "create valid pool('pool2')" do
      expect(Pool.all.count).to eq 2
    end

    it "update exist pool('pool1')" do
      expect(pool.num_of_vms).to eq 5
      expect(pool.storage_total).to eq 100 
      expect(pool.storage_used).to eq 50
    end
  end
end
